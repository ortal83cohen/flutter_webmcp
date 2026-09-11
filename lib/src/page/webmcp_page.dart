import 'dart:async';
import 'dart:convert';
import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../webmcp_scope.dart';
import '../webmcp_tool.dart';
import '../webmcp_tool_source.dart';
import 'webmcp_app_session.dart';
import 'webmcp_page_protocol.dart';
import 'webmcp_view_provider.dart';

const String _markerPrefix = 'webmcp-page-scope:';

/// An opt-in semantic page boundary with bounded read and act endpoints.
final class WebMcpPage extends StatefulWidget {
  /// Creates one automatic page boundary.
  WebMcpPage({
    required this.pageId,
    required this.child,
    WebMcpPagePolicy? policy,
    this.activity,
    this.sources = const <WebMcpToolSource>[],
    super.key,
  }) : policy = policy ?? WebMcpPagePolicy.defaults {
    _validatePageId(pageId);
  }

  /// Stable developer page identifier used in endpoint names.
  final String pageId;

  /// Page subtree owned by this boundary.
  final Widget child;

  /// Restrictive page disclosure and action policy.
  final WebMcpPagePolicy policy;

  /// Explicit activity evidence for unsupported navigation arrangements.
  final ValueListenable<bool>? activity;

  /// Optional live domain tool sources attached with this page.
  final List<WebMcpToolSource> sources;

  @override
  State<WebMcpPage> createState() => _WebMcpPageState();

  static void _validatePageId(String value) {
    final RegExp valid = RegExp(r'^[A-Za-z0-9_.-]+$');
    if (!valid.hasMatch(value) || value.length + '.page.read'.length > 128) {
      throw ArgumentError.value(
        value,
        'pageId',
        'Must fit the registry alphabet and suffixed 128-character limit.',
      );
    }
  }
}

final class _WebMcpPageState extends State<WebMcpPage>
    implements WebMcpPageSessionClient {
  WebMcpAppSession? _session;
  SemanticsHandle? _semanticsHandle;
  PipelineOwner? _pipelineOwner;
  SemanticsOwner? _semanticsOwner;
  WebMcpScope? _pageScope;
  WebMcpScope? _sourceScope;
  _CapturedWindow? _window;
  Timer? _captureTimer;

  late String _scopeReference;
  late String _mountToken;
  late String _marker;
  int _mountGeneration = 0;
  int _ownerGeneration = 0;
  int _revision = 0;
  int _highestRequestId = 0;
  String? _latestRequestFingerprint;
  Map<String, Object?>? _latestReceipt;
  String? _pendingVisibleOperationId;
  bool _mountedOwner = false;
  bool _eligible = false;
  bool _dirty = true;
  bool _captureQueued = false;
  bool _toolsAttempted = false;
  bool? _lastActivityValue;
  WebMcpPageErrorCode? _unavailableReason;

  @override
  String get scopeReference => _scopeReference;

  @override
  bool get isEligibleForObservation => _eligible;

  @override
  int get currentRevision => _revision;

  @override
  void initState() {
    super.initState();
    _mountGeneration++;
    _session = WebMcpAppSession.activeSession;
    _scopeReference = _session?.allocateScopeReference() ?? 's-unattached';
    _mountToken = _scopeReference;
    _marker = '$_markerPrefix$_scopeReference';
    _semanticsHandle = SemanticsBinding.instance.ensureSemantics();
    _mountedOwner = true;
    _lastActivityValue = widget.activity?.value;
    widget.activity?.addListener(_activityChanged);
    WebMcpPageErrorCode? registration;
    if (_session == null) {
      registration = WebMcpPageErrorCode.scopeGone;
    } else {
      registration = _session!.registerPage(this);
    }
    if (registration != null) {
      _unavailableReason = registration;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _queueCapture();
  }

  @override
  void didUpdateWidget(WebMcpPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.activity, widget.activity)) {
      oldWidget.activity?.removeListener(_activityChanged);
      widget.activity?.addListener(_activityChanged);
      _lastActivityValue = widget.activity?.value;
      _invalidateAdmission();
    }
    if (!identical(oldWidget.policy, widget.policy)) {
      _invalidateAdmission();
    }
    if (!_sameSourceIdentities(oldWidget.sources, widget.sources)) {
      _replaceSources();
      _invalidateAdmission();
    }
    _queueCapture();
  }

  @override
  void dispose() {
    _mountedOwner = false;
    _mountGeneration++;
    _eligible = false;
    _captureTimer?.cancel();
    _captureTimer = null;
    widget.activity?.removeListener(_activityChanged);
    _detachOwner();
    _pageScope?.close();
    _sourceScope?.close();
    _pageScope = null;
    _sourceScope = null;
    _window = null;
    _session?.unregisterPage(this);
    _semanticsHandle?.dispose();
    _semanticsHandle = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: _marker,
      container: true,
      explicitChildNodes: true,
      child: widget.child,
    );
  }

  @override
  void revokeForSession(WebMcpPageErrorCode reason) {
    if (!_mountedOwner) {
      return;
    }
    final bool invalidatedRead = _eligible || _window != null;
    _eligible = false;
    _window = null;
    _unavailableReason = reason;
    if (invalidatedRead) {
      _revision++;
    }
    _session?.publishPageState(this, kind: 'scopeChanged');
  }

  @override
  void requestSessionRecapture() {
    if (!_mountedOwner) {
      return;
    }
    _dirty = true;
    _queueCapture();
  }

  @override
  void detachForSession() {
    _pageScope?.close();
    _sourceScope?.close();
    _pageScope = null;
    _sourceScope = null;
    _window = null;
    _eligible = false;
    _unavailableReason = WebMcpPageErrorCode.cancelled;
  }

  void _activityChanged() {
    final bool? current = widget.activity?.value;
    if (current != _lastActivityValue) {
      _lastActivityValue = current;
      _invalidateAdmission();
    } else {
      _dirty = true;
    }
    _queueCapture();
  }

  void _invalidateAdmission() {
    final bool invalidatedRead = _eligible || _window != null;
    _eligible = false;
    _window = null;
    _dirty = true;
    if (invalidatedRead) {
      _revision++;
    }
    _session?.publishPageState(this, kind: 'scopeChanged');
  }

  void _queueCapture() {
    if (!_mountedOwner || _captureQueued) {
      return;
    }
    _captureQueued = true;
    final int mountGeneration = _mountGeneration;
    final int ownerGeneration = _ownerGeneration;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!_mountedOwner || mountGeneration != _mountGeneration) {
        return;
      }
      _captureQueued = false;
      if (ownerGeneration != _ownerGeneration) {
        _queueCapture();
        return;
      }
      try {
        _captureNow();
      } on Object {
        _captureTimer?.cancel();
        _captureTimer = null;
        revokeForSession(WebMcpPageErrorCode.internalError);
      }
    });
    WidgetsBinding.instance.scheduleFrame();
    _captureTimer?.cancel();
    _captureTimer = Timer(
      _session?.limits.captureDeadline ?? const Duration(seconds: 2),
      () {
        if (!_mountedOwner || !_dirty) {
          return;
        }
        revokeForSession(WebMcpPageErrorCode.snapshotUnavailable);
      },
    );
  }

  void _captureNow() {
    if (!_mountedOwner || _session == null || !_session!.isAttached) {
      revokeForSession(WebMcpPageErrorCode.scopeGone);
      return;
    }
    final List<WebMcpViewBinding> views = _session!.viewProvider.getViews();
    if (views.length != 1) {
      _replaceOwner(null, null);
      revokeForSession(WebMcpPageErrorCode.unsupportedViewConfiguration);
      return;
    }
    final WebMcpViewBinding view = views.single;
    if (view.pipelineOwner == null ||
        view.semanticsOwner == null ||
        !identical(view.pipelineOwner?.semanticsOwner, view.semanticsOwner)) {
      _replaceOwner(view.pipelineOwner, null);
      revokeForSession(WebMcpPageErrorCode.boundaryUnavailable);
      return;
    }
    if (!identical(_pipelineOwner, view.pipelineOwner) ||
        !identical(_semanticsOwner, view.semanticsOwner)) {
      _replaceOwner(view.pipelineOwner, view.semanticsOwner);
    }
    if (!_activityIsProved()) {
      revokeForSession(WebMcpPageErrorCode.inactiveScope);
      return;
    }
    final SemanticsNode? boundary = _resolveBoundary(view.semanticsOwner!);
    if (boundary == null) {
      revokeForSession(WebMcpPageErrorCode.boundaryUnavailable);
      return;
    }
    final _CapturedWindow captured = _captureBoundary(boundary);
    final String newProjection = jsonEncode(
      captured.nodes.map((_CapturedNode node) => node.wire).toList(),
    );
    final String? oldProjection = _window?.projection;
    if (oldProjection == null || oldProjection != newProjection) {
      _revision++;
    }
    _window = captured.withRevision(_revision, newProjection);
    _dirty = false;
    _eligible = true;
    _unavailableReason = null;
    _captureTimer?.cancel();
    _captureTimer = null;
    _registerToolsIfNeeded();
    if (_pageScope != null &&
        _sourceScope == null &&
        widget.sources.isNotEmpty) {
      _replaceSources();
    }
    if (oldProjection != null && oldProjection != newProjection) {
      final String? operationId = _pendingVisibleOperationId;
      if (operationId != null) {
        _session?.recordEvidence(
          operationId,
          WebMcpEvidenceKind.visibleEffectObserved,
        );
        _pendingVisibleOperationId = null;
      }
    }
    if (oldProjection == null || oldProjection != newProjection) {
      _session?.publishPageState(
        this,
        kind: oldProjection == null ? 'scopeChanged' : 'contentChanged',
      );
    }
  }

  bool _activityIsProved() {
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    if (route == null || !(_session?.isRouteEligible(route) ?? false)) {
      return false;
    }
    return widget.activity?.value ?? true;
  }

  void _replaceOwner(
    PipelineOwner? pipelineOwner,
    SemanticsOwner? semanticsOwner,
  ) {
    if (identical(_pipelineOwner, pipelineOwner) &&
        identical(_semanticsOwner, semanticsOwner)) {
      return;
    }
    revokeForSession(WebMcpPageErrorCode.boundaryUnavailable);
    _ownerGeneration++;
    _detachOwner();
    _pipelineOwner = pipelineOwner;
    _semanticsOwner = semanticsOwner;
    semanticsOwner?.addListener(_semanticsChanged);
  }

  void _detachOwner() {
    _semanticsOwner?.removeListener(_semanticsChanged);
    _semanticsOwner = null;
    _pipelineOwner = null;
  }

  void _semanticsChanged() {
    final SemanticsOwner? callbackOwner = _semanticsOwner;
    final int ownerGeneration = _ownerGeneration;
    if (!_mountedOwner ||
        callbackOwner == null ||
        !identical(callbackOwner, _semanticsOwner) ||
        ownerGeneration != _ownerGeneration) {
      return;
    }
    _dirty = true;
    _queueCapture();
  }

  SemanticsNode? _resolveBoundary(SemanticsOwner owner) {
    final SemanticsNode? root = owner.rootSemanticsNode;
    if (root == null) {
      return null;
    }
    final List<SemanticsNode> matches = <SemanticsNode>[];
    void visit(SemanticsNode node) {
      if (node.identifier == _marker) {
        matches.add(node);
      }
      node.visitChildren((SemanticsNode child) {
        visit(child);
        return true;
      });
    }

    visit(root);
    return matches.length == 1 ? matches.single : null;
  }

  _CapturedWindow _captureBoundary(SemanticsNode boundary) {
    final WebMcpPageLimits limits = _session!.limits;
    final List<_CapturedNode> nodes = <_CapturedNode>[];
    int visited = 0;
    bool truncated = false;
    String? reason;

    void visit(SemanticsNode node, int depth, String? parentHandle) {
      if (truncated) {
        return;
      }
      if (visited >= limits.visitedNodes) {
        truncated = true;
        reason = 'visitedNodes';
        return;
      }
      visited++;
      if (depth > limits.maxDepth) {
        truncated = true;
        reason = 'maxDepth';
        return;
      }
      if (!identical(node, boundary) &&
          node.identifier.startsWith(_markerPrefix)) {
        return;
      }
      if (_isExcluded(node.identifier)) {
        return;
      }
      final SemanticsFlags flags = node.flagsCollection;
      if (flags.isHidden || flags.isObscured) {
        return;
      }
      if (nodes.length >= limits.returnedNodes) {
        truncated = true;
        reason = 'returnedNodes';
        return;
      }
      final String handle = '${_mountToken}h${nodes.length.toRadixString(36)}';
      final Map<String, Object?> wire = _nodeWire(
        node,
        flags,
        handle,
        parentHandle,
      );
      final _CapturedNode captured = _CapturedNode(
        semanticsNodeId: node.id,
        semanticsIdentifier: node.identifier,
        handle: handle,
        parentHandle: parentHandle,
        wire: wire,
        actions: (wire['actions']! as List<Object?>).cast<String>(),
      );
      nodes.add(captured);
      node.visitChildren((SemanticsNode child) {
        visit(child, depth + 1, handle);
        return !truncated;
      });
    }

    visit(boundary, 0, null);
    return _CapturedWindow(
      revision: _revision,
      projection: '',
      nodes: List<_CapturedNode>.unmodifiable(nodes),
      visited: visited,
      truncated: truncated,
      truncationReason: reason,
    );
  }

  bool _isExcluded(String identifier) {
    return widget.policy.excludedSemanticsIdentifiers.contains(identifier) ||
        widget.policy.sensitiveSemanticsIdentifiers.contains(identifier);
  }

  Map<String, Object?> _nodeWire(
    SemanticsNode node,
    SemanticsFlags flags,
    String handle,
    String? parentHandle,
  ) {
    final SemanticsData data = node.getSemanticsData();
    final bool editable = flags.isTextField;
    final bool exposeEditableValue =
        editable &&
        widget.policy.editableValueIdentifiers.contains(node.identifier);
    final List<String> actions = <String>[
      if (data.hasAction(SemanticsAction.tap)) 'tap',
      if (widget.policy.allowLongPress &&
          data.hasAction(SemanticsAction.longPress))
        'longPress',
      if (data.hasAction(SemanticsAction.increase)) 'increase',
      if (data.hasAction(SemanticsAction.decrease)) 'decrease',
      if (data.hasAction(SemanticsAction.scrollLeft)) 'scrollLeft',
      if (data.hasAction(SemanticsAction.scrollRight)) 'scrollRight',
      if (data.hasAction(SemanticsAction.scrollUp)) 'scrollUp',
      if (data.hasAction(SemanticsAction.scrollDown)) 'scrollDown',
      if (editable &&
          exposeEditableValue &&
          widget.policy.setTextIdentifiers.contains(node.identifier) &&
          data.hasAction(SemanticsAction.setText))
        'setText',
    ];
    final Map<String, Object?> states = <String, Object?>{
      if (flags.isEnabled != Tristate.none)
        'enabled': flags.isEnabled == Tristate.isTrue,
      if (flags.isChecked != CheckedState.none)
        'checked': flags.isChecked == CheckedState.isTrue,
      if (flags.isSelected != Tristate.none)
        'selected': flags.isSelected == Tristate.isTrue,
      if (flags.isExpanded != Tristate.none)
        'expanded': flags.isExpanded == Tristate.isTrue,
      'editable': editable,
      if (flags.isObscured) 'obscured': true,
    };
    final String value = node.attributedValue.string;
    final Map<String, Object?> wire = <String, Object?>{
      'handle': handle,
      'role': _roleFor(flags),
      if (node.attributedLabel.string.isNotEmpty)
        'label': node.attributedLabel.string,
      if (node.attributedHint.string.isNotEmpty)
        'hint': node.attributedHint.string,
      if (value.isNotEmpty &&
          (!editable && widget.policy.includeNonEditableValues ||
              exposeEditableValue))
        'value': value,
      'states': states,
      'actions': actions,
      if (widget.policy.includeBounds)
        'bounds': <String, Object?>{
          'left': node.rect.left,
          'top': node.rect.top,
          'width': node.rect.width,
          'height': node.rect.height,
          'coordinateSpace': 'flutterView',
        },
    };
    if (parentHandle != null) {
      wire['parentHandle'] = parentHandle;
    }
    return wire;
  }

  String _roleFor(SemanticsFlags flags) {
    if (flags.isTextField) {
      return 'textField';
    }
    if (flags.isButton) {
      return 'button';
    }
    if (flags.isLink) {
      return 'link';
    }
    if (flags.isHeader) {
      return 'header';
    }
    if (flags.isChecked != CheckedState.none) {
      return 'checkbox';
    }
    return 'generic';
  }

  void _registerToolsIfNeeded() {
    if (_toolsAttempted || !_eligible) {
      return;
    }
    _toolsAttempted = true;
    final WebMcpScope pageScope = WebMcpScope(scopeName: widget.pageId);
    final bool readOwned = pageScope.addTool(
      WebMcpTool(
        name: '${widget.pageId}.page.read',
        description: 'Read a bounded permitted semantic page snapshot.',
        inputSchema: _readSchema,
        handler: _read,
      ),
    );
    final bool actOwned = pageScope.addTool(
      WebMcpTool(
        name: '${widget.pageId}.page.act',
        description: 'Dispatch a guarded action against a fresh page snapshot.',
        inputSchema: _actSchema,
        handler: _act,
      ),
    );
    if (!readOwned || !actOwned) {
      pageScope.close();
      _unavailableReason = WebMcpPageErrorCode.resourceLimit;
      _eligible = false;
      return;
    }
    _pageScope = pageScope;
    _replaceSources();
  }

  void _replaceSources() {
    _sourceScope?.close();
    _sourceScope = null;
    if (!_eligible || widget.sources.isEmpty) {
      return;
    }
    final WebMcpScope scope = WebMcpScope(
      scopeName: '${widget.pageId}-sources',
    );
    for (final WebMcpToolSource source in widget.sources) {
      for (final WebMcpTool tool in source.getWebMcpTools()) {
        scope.addTool(_wrapSourceTool(tool));
      }
    }
    _sourceScope = scope;
  }

  WebMcpTool _wrapSourceTool(WebMcpTool tool) {
    return WebMcpTool(
      name: tool.name,
      description: tool.description,
      inputSchema: tool.inputSchema,
      annotations: tool.annotations,
      handler: (Map<String, Object?> arguments) {
        if (!_mountedOwner || !_eligible) {
          return webMcpPageError(WebMcpPageErrorCode.inactiveScope);
        }
        if (!(_session?.beginAsynchronousExecution() ?? false)) {
          return webMcpPageError(WebMcpPageErrorCode.busy);
        }
        final String? operationId = _session?.beginOperation(
          scopeReference: _scopeReference,
          requestId: 0,
        );
        if (operationId == null) {
          _session?.settleAsynchronousExecution();
          return webMcpPageError(WebMcpPageErrorCode.busy);
        }
        final Object? result;
        try {
          result = tool.handler(arguments);
        } on Object {
          _session?.recordEvidence(
            operationId,
            WebMcpEvidenceKind.commandDispatched,
          );
          _session?.settleAsynchronousExecution();
          rethrow;
        }
        _session?.recordEvidence(
          operationId,
          WebMcpEvidenceKind.commandDispatched,
        );
        if (result is! Future<Object?>) {
          _session?.settleAsynchronousExecution();
          return result;
        }
        return result.whenComplete(() {
          _session?.settleAsynchronousExecution();
          _session?.recordEvidence(
            operationId,
            WebMcpEvidenceKind.domainFutureCompleted,
          );
        });
      },
    );
  }

  FutureOr<Object?> _read(Map<String, Object?> arguments) {
    const Set<String> allowed = <String>{
      'query',
      'roles',
      'actions',
      'limit',
      'cursor',
    };
    if (arguments.keys.any((String key) => !allowed.contains(key))) {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }
    if (!_mountedOwner) {
      return webMcpPageError(WebMcpPageErrorCode.scopeGone);
    }
    final WebMcpPageErrorCode? admissionError =
        _revalidateAdmissionBeforeAccess();
    if (admissionError != null) {
      return webMcpPageError(
        admissionError,
        retryable: true,
        refreshRequired: true,
      );
    }
    if (!_eligible) {
      return webMcpPageError(
        _unavailableReason ?? WebMcpPageErrorCode.inactiveScope,
        retryable: true,
        refreshRequired: true,
      );
    }
    final _CapturedWindow? window = _window;
    if (window == null || _dirty) {
      return webMcpPageError(
        WebMcpPageErrorCode.snapshotUnavailable,
        retryable: true,
        refreshRequired: true,
      );
    }
    final Object? queryValue = arguments['query'];
    final Object? rolesValue = arguments['roles'];
    final Object? actionsValue = arguments['actions'];
    final Object? limitValue = arguments['limit'];
    final Object? cursorValue = arguments['cursor'];
    if (queryValue != null && queryValue is! String ||
        rolesValue != null && !_isStringList(rolesValue) ||
        actionsValue != null && !_isStringList(actionsValue) ||
        limitValue != null && limitValue is! int ||
        cursorValue != null && cursorValue is! String) {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }
    final int limit = limitValue is int
        ? limitValue
        : _session!.limits.returnedNodes;
    if (limit < 1 || limit > _session!.limits.returnedNodes) {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }
    int start = 0;
    if (cursorValue is String) {
      final int? decoded = _decodePageCursor(cursorValue, window.revision);
      if (decoded == null) {
        return webMcpPageError(
          WebMcpPageErrorCode.invalidCursor,
          refreshRequired: true,
        );
      }
      start = decoded;
    }
    final String query = _normalize(queryValue is String ? queryValue : '');
    final Set<String> roles = rolesValue is List<Object?>
        ? rolesValue.cast<String>().toSet()
        : const <String>{};
    final Set<String> actions = actionsValue is List<Object?>
        ? actionsValue.cast<String>().toSet()
        : const <String>{};
    final List<_CapturedNode> filtered = window.nodes
        .where((_CapturedNode node) {
          final Map<String, Object?> wire = node.wire;
          if (roles.isNotEmpty && !roles.contains(wire['role'])) {
            return false;
          }
          final Set<String> nodeActions = (wire['actions']! as List<Object?>)
              .cast<String>()
              .toSet();
          if (actions.isNotEmpty && actions.intersection(nodeActions).isEmpty) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          final String searchable = _normalize(
            <Object?>[
              wire['label'],
              wire['hint'],
              wire['value'],
            ].whereType<String>().join(' '),
          );
          return searchable.contains(query);
        })
        .toList(growable: false);
    if (start > filtered.length) {
      return webMcpPageError(
        WebMcpPageErrorCode.invalidCursor,
        refreshRequired: true,
      );
    }

    final List<Map<String, Object?>> returned = <Map<String, Object?>>[];
    final Set<String> returnedHandles = <String>{};
    int next = start;
    int fieldOmissions = 0;
    bool unrepresentableNode = false;
    while (next < filtered.length && returned.length < limit) {
      final Map<String, Object?> candidateNode = Map<String, Object?>.of(
        filtered[next].wire,
      );
      final Object? parentHandle = candidateNode['parentHandle'];
      if (parentHandle is String && !returnedHandles.contains(parentHandle)) {
        candidateNode.remove('parentHandle');
      }
      bool fits = false;
      while (true) {
        final List<Map<String, Object?>> candidate = <Map<String, Object?>>[
          ...returned,
          candidateNode,
        ];
        final Map<String, Object?> response = _readResponse(
          window,
          candidate,
          next + 1 < filtered.length
              ? _encodePageCursor(window.revision, next + 1)
              : null,
          fieldOmissions: fieldOmissions,
        );
        if (utf8.encode(jsonEncode(response)).length <=
            _session!.limits.readBytes) {
          fits = true;
          break;
        }
        final String? removed = _removeLargestOptionalField(candidateNode);
        if (removed == null) {
          break;
        }
        fieldOmissions++;
      }
      if (!fits) {
        unrepresentableNode = true;
        break;
      }
      returned.add(candidateNode);
      returnedHandles.add(candidateNode['handle']! as String);
      next++;
    }
    if (unrepresentableNode && returned.isEmpty) {
      return webMcpPageError(WebMcpPageErrorCode.resourceLimit);
    }
    final bool hasMore = next < filtered.length;
    return _readResponse(
      window,
      returned,
      hasMore ? _encodePageCursor(window.revision, next) : null,
      byteTruncated: hasMore && returned.length < limit || fieldOmissions > 0,
      fieldOmissions: fieldOmissions,
    );
  }

  Map<String, Object?> _readResponse(
    _CapturedWindow window,
    List<Map<String, Object?>> nodes,
    String? nextCursor, {
    bool byteTruncated = false,
    int fieldOmissions = 0,
  }) {
    final Map<String, Object?> coverage = <String, Object?>{
      'materialized': true,
      'partial': window.truncated || byteTruncated || nextCursor != null,
      'truncated': window.truncated || byteTruncated,
      'visited': window.visited,
      'returned': nodes.length,
      'budgets': <String, Object?>{
        'returnedNodes': _session!.limits.returnedNodes,
        'visitedNodes': _session!.limits.visitedNodes,
        'maxDepth': _session!.limits.maxDepth,
        'responseBytes': _session!.limits.readBytes,
      },
      'unknownCoverage': const <String>['unbuiltContent'],
    };
    if (window.truncationReason != null) {
      coverage['omissionReasons'] = <String, Object?>{
        window.truncationReason!: 1,
      };
    }
    if (fieldOmissions > 0) {
      final Map<String, Object?> omissionReasons =
          (coverage['omissionReasons'] as Map<String, Object?>?) ??
          <String, Object?>{};
      omissionReasons['responseBytes'] = fieldOmissions;
      coverage['omissionReasons'] = omissionReasons;
    }
    final Map<String, Object?> fields = <String, Object?>{
      'pageId': widget.pageId,
      'mountToken': _mountToken,
      'revision': window.revision,
      'active': true,
      'coverage': coverage,
      'nodes': nodes,
    };
    if (nextCursor != null) {
      fields['nextCursor'] = nextCursor;
    }
    return webMcpPageSuccess(fields);
  }

  String? _removeLargestOptionalField(Map<String, Object?> node) {
    for (final String key in const <String>[
      'value',
      'hint',
      'label',
      'bounds',
    ]) {
      if (node.containsKey(key)) {
        node.remove(key);
        return key;
      }
    }
    return null;
  }

  FutureOr<Object?> _act(Map<String, Object?> request) {
    const Set<String> allowed = <String>{
      'pageId',
      'mountToken',
      'revision',
      'handle',
      'action',
      'requestId',
      'arguments',
    };
    if (request.keys.any((String key) => !allowed.contains(key)) ||
        request['pageId'] is! String ||
        request['mountToken'] is! String ||
        request['revision'] is! int ||
        request['handle'] is! String ||
        request['action'] is! String ||
        request['requestId'] is! int ||
        request['arguments'] is! Map<String, Object?>) {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }
    final String pageId = request['pageId']! as String;
    final String mountToken = request['mountToken']! as String;
    final int revision = request['revision']! as int;
    final String handle = request['handle']! as String;
    final String action = request['action']! as String;
    final int requestId = request['requestId']! as int;
    final Map<String, Object?> actionArguments =
        request['arguments']! as Map<String, Object?>;
    if (pageId != widget.pageId ||
        mountToken != _mountToken ||
        !_mountedOwner) {
      return webMcpPageError(
        WebMcpPageErrorCode.scopeGone,
        refreshRequired: true,
      );
    }
    if (!_eligible) {
      return webMcpPageError(
        _unavailableReason ?? WebMcpPageErrorCode.inactiveScope,
        refreshRequired: true,
      );
    }
    if (revision != _revision || _window?.revision != revision) {
      return webMcpPageError(
        WebMcpPageErrorCode.staleSnapshot,
        refreshRequired: true,
      );
    }
    const Set<String> supported = <String>{
      'tap',
      'longPress',
      'increase',
      'decrease',
      'scrollLeft',
      'scrollRight',
      'scrollUp',
      'scrollDown',
      'setText',
    };
    if (!supported.contains(action)) {
      return webMcpPageError(WebMcpPageErrorCode.unsupportedAction);
    }
    if (requestId < 1 || requestId > webMcpMaxSafeInteger) {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }
    late final String fingerprint;
    try {
      fingerprint = jsonEncode(<String, Object?>{
        'pageId': pageId,
        'mountToken': mountToken,
        'revision': revision,
        'handle': handle,
        'action': action,
        'arguments': actionArguments,
      });
    } on JsonUnsupportedObjectError {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }
    if (requestId <= _highestRequestId) {
      if (requestId == _highestRequestId &&
          fingerprint == _latestRequestFingerprint &&
          _latestReceipt != null) {
        return _latestReceipt;
      }
      return webMcpPageError(WebMcpPageErrorCode.duplicateRequest);
    }
    if (actionArguments['cancelled'] == true) {
      return webMcpPageError(WebMcpPageErrorCode.cancelled);
    }
    final WebMcpPageErrorCode? admissionError =
        _revalidateAdmissionBeforeAccess();
    if (admissionError != null) {
      return webMcpPageError(admissionError, refreshRequired: true);
    }
    final _CapturedNode? captured = _window?.byHandle(handle);
    if (captured == null) {
      return webMcpPageError(WebMcpPageErrorCode.unknownHandle);
    }
    if (!captured.actions.contains(action)) {
      return webMcpPageError(WebMcpPageErrorCode.actionUnavailable);
    }

    final SemanticsOwner? owner = _semanticsOwner;
    final SemanticsNode? boundary = owner == null
        ? null
        : _resolveBoundary(owner);
    final SemanticsNode? current = boundary == null
        ? null
        : _findOwnedNode(boundary, captured.semanticsNodeId);
    if (current == null ||
        !current.attached ||
        current.identifier != captured.semanticsIdentifier) {
      return webMcpPageError(
        WebMcpPageErrorCode.actionUnavailable,
        refreshRequired: true,
      );
    }
    final SemanticsFlags flags = current.flagsCollection;
    if (flags.isHidden ||
        flags.isObscured ||
        flags.isEnabled == Tristate.isFalse) {
      return webMcpPageError(WebMcpPageErrorCode.actionUnavailable);
    }
    final SemanticsAction? semanticsAction = _semanticsAction(action);
    if (semanticsAction == null ||
        !current.getSemanticsData().hasAction(semanticsAction)) {
      return webMcpPageError(WebMcpPageErrorCode.actionUnavailable);
    }
    Object? actionArgument;
    if (action == 'longPress' && !widget.policy.allowLongPress) {
      return webMcpPageError(WebMcpPageErrorCode.policyDenied);
    }
    if (action == 'setText') {
      final Object? text = actionArguments['text'];
      if (actionArguments.keys.any((String key) => key != 'text') ||
          text is! String ||
          text.length > widget.policy.maxTextLength ||
          !flags.isTextField ||
          flags.isObscured ||
          !widget.policy.editableValueIdentifiers.contains(
            current.identifier,
          ) ||
          !widget.policy.setTextIdentifiers.contains(current.identifier)) {
        return webMcpPageError(WebMcpPageErrorCode.policyDenied);
      }
      actionArgument = text;
    } else if (actionArguments.keys.any((String key) => key != 'cancelled')) {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }

    final String? operationId = _session?.beginOperation(
      scopeReference: _scopeReference,
      requestId: requestId,
    );
    if (operationId == null) {
      return webMcpPageError(WebMcpPageErrorCode.busy);
    }
    _highestRequestId = requestId;
    _latestRequestFingerprint = fingerprint;
    owner!.performAction(current.id, semanticsAction, actionArgument);
    _session?.recordEvidence(operationId, WebMcpEvidenceKind.commandDispatched);
    _pendingVisibleOperationId = operationId;
    final Map<String, Object?> receipt = webMcpPageSuccess(<String, Object?>{
      'pageId': widget.pageId,
      'mountToken': _mountToken,
      'requestId': requestId,
      'operationId': operationId,
      'dispatched': true,
      'observedRevision': _revision,
      'evidence': WebMcpEvidenceKind.commandDispatched.name,
    });
    _latestReceipt = receipt;
    if (action.startsWith('scroll')) {
      _invalidateAdmission();
      _queueCapture();
    }
    return receipt;
  }

  WebMcpPageErrorCode? _revalidateAdmissionBeforeAccess() {
    try {
      return _revalidateAdmissionBeforeAccessUnsafe();
    } on Object {
      revokeForSession(WebMcpPageErrorCode.internalError);
      return WebMcpPageErrorCode.internalError;
    }
  }

  WebMcpPageErrorCode? _revalidateAdmissionBeforeAccessUnsafe() {
    final WebMcpAppSession? session = _session;
    if (!_mountedOwner || session == null || !session.isAttached) {
      return WebMcpPageErrorCode.scopeGone;
    }
    if (!_activityIsProved()) {
      revokeForSession(WebMcpPageErrorCode.inactiveScope);
      return WebMcpPageErrorCode.inactiveScope;
    }
    final List<WebMcpViewBinding> views = session.viewProvider.getViews();
    if (views.length != 1) {
      revokeForSession(WebMcpPageErrorCode.unsupportedViewConfiguration);
      return WebMcpPageErrorCode.unsupportedViewConfiguration;
    }
    final WebMcpViewBinding view = views.single;
    if (view.pipelineOwner == null ||
        view.semanticsOwner == null ||
        !identical(view.pipelineOwner?.semanticsOwner, view.semanticsOwner)) {
      revokeForSession(WebMcpPageErrorCode.boundaryUnavailable);
      return WebMcpPageErrorCode.boundaryUnavailable;
    }
    if (!identical(_pipelineOwner, view.pipelineOwner) ||
        !identical(_semanticsOwner, view.semanticsOwner)) {
      _replaceOwner(view.pipelineOwner, view.semanticsOwner);
      _dirty = true;
      _queueCapture();
      return WebMcpPageErrorCode.snapshotUnavailable;
    }
    if (_resolveBoundary(view.semanticsOwner!) == null) {
      revokeForSession(WebMcpPageErrorCode.boundaryUnavailable);
      return WebMcpPageErrorCode.boundaryUnavailable;
    }
    return null;
  }

  SemanticsNode? _findOwnedNode(SemanticsNode root, int nodeId) {
    SemanticsNode? result;
    void visit(SemanticsNode node, {required bool isRoot}) {
      if (result != null ||
          !isRoot && node.identifier.startsWith(_markerPrefix) ||
          _isExcluded(node.identifier)) {
        return;
      }
      if (node.id == nodeId) {
        result = node;
        return;
      }
      node.visitChildren((SemanticsNode child) {
        visit(child, isRoot: false);
        return result == null;
      });
    }

    visit(root, isRoot: true);
    return result;
  }

  SemanticsAction? _semanticsAction(String action) {
    return switch (action) {
      'tap' => SemanticsAction.tap,
      'longPress' => SemanticsAction.longPress,
      'increase' => SemanticsAction.increase,
      'decrease' => SemanticsAction.decrease,
      'scrollLeft' => SemanticsAction.scrollLeft,
      'scrollRight' => SemanticsAction.scrollRight,
      'scrollUp' => SemanticsAction.scrollUp,
      'scrollDown' => SemanticsAction.scrollDown,
      'setText' => SemanticsAction.setText,
      _ => null,
    };
  }

  String _encodePageCursor(int revision, int index) {
    return base64Url.encode(utf8.encode('$_mountToken:$revision:$index'));
  }

  int? _decodePageCursor(String cursor, int revision) {
    try {
      final String decoded = utf8.decode(base64Url.decode(cursor));
      final List<String> parts = decoded.split(':');
      if (parts.length != 3 ||
          parts[0] != _mountToken ||
          int.tryParse(parts[1]) != revision) {
        return null;
      }
      return int.tryParse(parts[2]);
    } on FormatException {
      return null;
    }
  }

  static bool _isStringList(Object value) {
    return value is List<Object?> &&
        value.every((Object? item) => item is String);
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _sameSourceIdentities(
    List<WebMcpToolSource> left,
    List<WebMcpToolSource> right,
  ) {
    if (left.length != right.length) {
      return false;
    }
    for (int index = 0; index < left.length; index++) {
      if (!identical(left[index], right[index])) {
        return false;
      }
    }
    return true;
  }

  static const Map<String, Object?> _readSchema = <String, Object?>{
    'type': 'object',
    'additionalProperties': false,
  };

  static const Map<String, Object?> _actSchema = <String, Object?>{
    'type': 'object',
    'additionalProperties': false,
    'required': <String>[
      'pageId',
      'mountToken',
      'revision',
      'handle',
      'action',
      'requestId',
      'arguments',
    ],
  };
}

final class _CapturedWindow {
  const _CapturedWindow({
    required this.revision,
    required this.projection,
    required this.nodes,
    required this.visited,
    required this.truncated,
    required this.truncationReason,
  });

  final int revision;
  final String projection;
  final List<_CapturedNode> nodes;
  final int visited;
  final bool truncated;
  final String? truncationReason;

  _CapturedWindow withRevision(int value, String serializedProjection) {
    return _CapturedWindow(
      revision: value,
      projection: serializedProjection,
      nodes: nodes,
      visited: visited,
      truncated: truncated,
      truncationReason: truncationReason,
    );
  }

  _CapturedNode? byHandle(String handle) {
    for (final _CapturedNode node in nodes) {
      if (node.handle == handle) {
        return node;
      }
    }
    return null;
  }
}

final class _CapturedNode {
  const _CapturedNode({
    required this.semanticsNodeId,
    required this.semanticsIdentifier,
    required this.handle,
    required this.parentHandle,
    required this.wire,
    required this.actions,
  });

  final int semanticsNodeId;
  final String semanticsIdentifier;
  final String handle;
  final String? parentHandle;
  final Map<String, Object?> wire;
  final List<String> actions;
}
