import 'dart:async';
import 'dart:convert';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../webmcp_scope.dart';
import '../webmcp_tool.dart';
import 'webmcp_page_protocol.dart';
import 'webmcp_view_provider.dart';

/// Fixed evidence kinds emitted by app-owned operation tracking.
enum WebMcpEvidenceKind {
  /// A command passed final admission and was synchronously dispatched.
  commandDispatched,

  /// A later permitted semantic projection changed.
  visibleEffectObserved,

  /// An explicitly tracked domain Future settled.
  domainFutureCompleted,

  /// An explicit operation-linked application signal confirmed an outcome.
  backendConfirmed,
}

/// Internal contract between a mounted page and its application session.
abstract interface class WebMcpPageSessionClient {
  /// Opaque page mount reference used only by the broker.
  String get scopeReference;

  /// Whether the page is currently eligible for observation.
  bool get isEligibleForObservation;

  /// Current externally visible page revision.
  int get currentRevision;

  /// Revokes eligibility synchronously.
  void revokeForSession(WebMcpPageErrorCode reason);

  /// Removes page-owned endpoints and source registrations.
  void detachForSession();

  /// Requests recapture after independently proved route settlement.
  void requestSessionRecapture();
}

/// One application-owned automatic page session.
final class WebMcpAppSession {
  /// Creates a detached session with downward-only [limits].
  WebMcpAppSession({
    WebMcpPageLimits? limits,
    WebMcpViewProvider? viewProvider,
    DateTime Function()? clock,
  }) : limits = limits ?? WebMcpPageLimits(),
       _clock = clock ?? DateTime.now,
       viewProvider = viewProvider ?? const WebMcpBindingViewProvider();

  /// Resource limits for this session.
  final WebMcpPageLimits limits;

  /// Source of the complete current Flutter view set.
  final WebMcpViewProvider viewProvider;

  final DateTime Function() _clock;

  static WebMcpAppSession? _activeSession;
  static int _mountCounter = 0;
  static int _scopeCounter = 0;
  static int _operationCounter = 0;

  /// The currently attached application session, if any.
  static WebMcpAppSession? get activeSession => _activeSession;

  final Set<WebMcpPageSessionClient> _pages = <WebMcpPageSessionClient>{};
  final Set<WebMcpNavigatorAdapter> _adapters = <WebMcpNavigatorAdapter>{};
  final ListQueue<_BrokerEvent> _events = ListQueue<_BrokerEvent>();
  final Map<String, _TrackedOperation> _operations =
      <String, _TrackedOperation>{};

  WebMcpScope? _observeScope;
  String? _appId;
  String? _appMount;
  int _sequence = 0;
  int _ringBytes = 0;
  int _outstandingExecutions = 0;
  bool _attached = false;
  bool _observeOwned = false;

  /// Whether the session is currently attached.
  bool get isAttached => _attached;

  /// Whether this session owns its observe endpoint.
  bool get ownsObserveTool => _observeOwned;

  /// The opaque current app mount, or null while detached.
  String? get appMount => _appMount;

  /// Number of currently registered automatic page scopes.
  int get liveScopeCount => _pages.length;

  /// Number of currently registered Navigator adapters.
  int get navigatorAdapterCount => _adapters.length;

  /// Whether all registered Navigator evidence is known and settled.
  bool get routeEvidenceReady =>
      _adapters.isNotEmpty &&
      _adapters.every(
        (WebMcpNavigatorAdapter adapter) => adapter.hasSettledEvidence,
      );

  /// Whether [route] has complete, settled Navigator and root-modal evidence.
  bool isRouteEligible(Route<Object?> route) {
    if (!routeEvidenceReady) {
      return false;
    }
    final List<WebMcpNavigatorAdapter> owners = _adapters
        .where(
          (WebMcpNavigatorAdapter adapter) =>
              identical(adapter.navigator, route.navigator),
        )
        .toList(growable: false);
    if (owners.length != 1 || !owners.single.isSettled) {
      return false;
    }
    final List<WebMcpNavigatorAdapter> blockingRoots = _adapters
        .where((WebMcpNavigatorAdapter adapter) => adapter.hasBlockingRootModal)
        .toList(growable: false);
    if (blockingRoots.length > 1) {
      return false;
    }
    if (blockingRoots.length == 1) {
      return identical(blockingRoots.single.topRoute, route);
    }
    // The adapter's top-route observation is the settled Navigator evidence.
    // Route.isCurrent can lag that observation on Wasm during replacement
    // transitions, which could otherwise re-expose the covered route.
    return identical(owners.single.topRoute, route);
  }

  /// Number of retained broker events.
  int get retainedEventCount => _events.length;

  /// Number of retained operation receipts.
  int get retainedOperationCount {
    _purgeOperations();
    return _operations.length;
  }

  /// Number of unsettled asynchronous source executions.
  int get outstandingExecutionCount => _outstandingExecutions;

  /// Attaches the session and registers `<appId>.app.observe`.
  ///
  /// Repeated calls for the same attached session preserve existing state.
  Map<String, Object?> attach({required String appId}) {
    _validateIdentifier(appId, '.app.observe');
    if (_attached) {
      if (_appId != appId) {
        return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
      }
      return _attachmentState();
    }
    if (_activeSession != null && !identical(_activeSession, this)) {
      return webMcpPageError(WebMcpPageErrorCode.resourceLimit);
    }

    _attached = true;
    _appId = appId;
    _appMount = _newOpaque('a', ++_mountCounter);
    _activeSession = this;
    final WebMcpScope scope = WebMcpScope(scopeName: 'app-observe');
    _observeScope = scope;
    _observeOwned = scope.addTool(
      WebMcpTool(
        name: '$appId.app.observe',
        description: 'Observe bounded automatic page lifecycle metadata.',
        inputSchema: _observeSchema,
        handler: _observe,
      ),
    );
    return _attachmentState();
  }

  /// Detaches owned tools, pages, adapters, waits, and receipt delivery.
  void detach() {
    if (!_attached) {
      return;
    }
    for (final WebMcpPageSessionClient page in _pages.toList()) {
      page.revokeForSession(WebMcpPageErrorCode.cancelled);
      page.detachForSession();
    }
    for (final WebMcpNavigatorAdapter adapter in _adapters.toList()) {
      adapter._detachFromSession();
    }
    _pages.clear();
    _adapters.clear();
    _events.clear();
    _operations.clear();
    _ringBytes = 0;
    _outstandingExecutions = 0;
    _observeScope?.close();
    _observeScope = null;
    _observeOwned = false;
    _attached = false;
    _appId = null;
    _appMount = null;
    _sequence = 0;
    if (identical(_activeSession, this)) {
      _activeSession = null;
    }
  }

  /// Allocates an opaque page scope reference.
  String allocateScopeReference() => _newOpaque('s', ++_scopeCounter);

  /// Registers a mounted page without evicting any existing page.
  WebMcpPageErrorCode? registerPage(WebMcpPageSessionClient page) {
    if (!_attached) {
      return WebMcpPageErrorCode.scopeGone;
    }
    if (_pages.contains(page)) {
      return null;
    }
    if (_pages.length >= limits.liveScopes) {
      return WebMcpPageErrorCode.resourceLimit;
    }
    _pages.add(page);
    _emit(
      kind: 'scopeChanged',
      scopeReference: page.scopeReference,
      revision: page.currentRevision,
    );
    return null;
  }

  /// Removes a page and redacts future delivery of its historical identity.
  void unregisterPage(WebMcpPageSessionClient page) {
    if (!_pages.remove(page)) {
      return;
    }
    _emit(kind: 'scopeChanged');
  }

  /// Records a page eligibility or revision change using safe metadata only.
  void publishPageState(WebMcpPageSessionClient page, {required String kind}) {
    if (!_attached || !_pages.contains(page)) {
      return;
    }
    _emit(
      kind: kind,
      scopeReference: page.isEligibleForObservation
          ? page.scopeReference
          : null,
      revision: page.currentRevision,
    );
  }

  /// Starts a bounded app-owned operation before semantic dispatch.
  String? beginOperation({
    required String scopeReference,
    required int requestId,
  }) {
    _purgeOperations();
    if (!_attached || _operations.length >= limits.trackedOperations) {
      return null;
    }
    final String operationId = _newOpaque('o', ++_operationCounter);
    _operations[operationId] = _TrackedOperation(
      operationId: operationId,
      scopeReference: scopeReference,
      requestId: requestId,
      expiresAt: _clock().add(limits.operationRetention),
    );
    return operationId;
  }

  /// Records one fixed operation evidence kind.
  void recordEvidence(String operationId, WebMcpEvidenceKind kind) {
    _purgeOperations();
    final _TrackedOperation? operation = _operations[operationId];
    if (!_attached || operation == null) {
      return;
    }
    operation.latestEvidence = kind;
    _emit(
      kind: kind.name,
      scopeReference: _isScopeEligible(operation.scopeReference)
          ? operation.scopeReference
          : null,
      operationId: operationId,
      outcome: operation.backendOutcome,
    );
  }

  /// Records an explicit backend outcome for a known operation.
  bool confirmBackend({required String operationId, required String outcome}) {
    const Set<String> outcomes = <String>{'succeeded', 'failed', 'cancelled'};
    if (!outcomes.contains(outcome) || !_operations.containsKey(operationId)) {
      return false;
    }
    _operations[operationId]!.backendOutcome = outcome;
    recordEvidence(operationId, WebMcpEvidenceKind.backendConfirmed);
    return true;
  }

  /// Returns the latest sanitized receipt for [operationId].
  Map<String, Object?>? operationReceipt(String operationId) {
    _purgeOperations();
    final _TrackedOperation? operation = _operations[operationId];
    if (operation == null) {
      return null;
    }
    return <String, Object?>{
      'operationId': operation.operationId,
      'requestId': operation.requestId,
      'evidence': operation.latestEvidence?.name,
      if (operation.backendOutcome != null)
        'backendOutcome': operation.backendOutcome,
    };
  }

  /// Reserves one outstanding asynchronous execution slot.
  bool beginAsynchronousExecution() {
    if (!_attached || _outstandingExecutions >= limits.outstandingExecutions) {
      return false;
    }
    _outstandingExecutions++;
    return true;
  }

  /// Releases one asynchronous execution slot only after actual settlement.
  void settleAsynchronousExecution() {
    if (_outstandingExecutions > 0) {
      _outstandingExecutions--;
    }
  }

  bool _registerAdapter(WebMcpNavigatorAdapter adapter) {
    if (!_attached ||
        _adapters.length >= limits.navigatorAdapters ||
        _adapters.contains(adapter)) {
      return false;
    }
    _adapters.add(adapter);
    return true;
  }

  void _unregisterAdapter(WebMcpNavigatorAdapter adapter) {
    _adapters.remove(adapter);
  }

  void _revokeForNavigation() {
    for (final WebMcpPageSessionClient page in _pages.toList()) {
      page.revokeForSession(WebMcpPageErrorCode.inactiveScope);
    }
  }

  void _navigationSettled() {
    if (_adapters.any((WebMcpNavigatorAdapter item) => !item.isSettled)) {
      return;
    }
    for (final WebMcpPageSessionClient page in _pages.toList()) {
      page.requestSessionRecapture();
    }
  }

  FutureOr<Object?> _observe(Map<String, Object?> arguments) {
    const Set<String> allowed = <String>{'cursor', 'waitMs', 'scopeReference'};
    if (arguments.keys.any((String key) => !allowed.contains(key))) {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }
    final Object? cursorValue = arguments['cursor'];
    final Object? waitValue = arguments['waitMs'];
    final Object? scopeValue = arguments['scopeReference'];
    if (cursorValue != null && cursorValue is! String ||
        waitValue != null && waitValue is! int ||
        scopeValue != null && scopeValue is! String) {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }
    final int waitMs = waitValue is int ? waitValue : 0;
    if (waitMs < 0 || waitMs > limits.maxWaitMs) {
      return webMcpPageError(WebMcpPageErrorCode.invalidArguments);
    }
    if (waitMs > 0) {
      return <String, Object?>{
        ...webMcpPageError(WebMcpPageErrorCode.unsupportedWait),
        'waitCapability': <String, Object?>{
          'positiveWaitSupported': false,
          'maxWaitMs': 0,
        },
      };
    }
    final String? scopeFilter = scopeValue is String ? scopeValue : null;
    if (scopeFilter != null &&
        !_pages.any(
          (WebMcpPageSessionClient page) =>
              page.scopeReference == scopeFilter &&
              page.isEligibleForObservation,
        )) {
      return webMcpPageError(
        WebMcpPageErrorCode.invalidArguments,
        refreshRequired: true,
      );
    }

    final List<String> eligible = _eligibleReferences();
    final String currentCursor = _encodeCursor(_sequence);
    final Map<String, Object?> emptyProbe = _observeSuccess(
      currentCursor: currentCursor,
      eligible: eligible,
      events: const <Map<String, Object?>>[],
      unchanged: true,
      gap: false,
      partial: false,
    );
    if (utf8.encode(jsonEncode(emptyProbe)).length > limits.observeBytes) {
      return webMcpPageError(
        WebMcpPageErrorCode.resourceLimit,
        retryable: true,
      );
    }
    if (cursorValue == null) {
      return emptyProbe;
    }
    final int? requestedSequence = _decodeCursor(cursorValue as String);
    final int earliest = _events.isEmpty
        ? _sequence + 1
        : _events.first.sequence;
    if (requestedSequence == null ||
        requestedSequence > _sequence ||
        requestedSequence < earliest - 1) {
      return _observeSuccess(
        currentCursor: currentCursor,
        eligible: eligible,
        events: const <Map<String, Object?>>[],
        unchanged: false,
        gap: true,
        partial: false,
        refreshRequired: true,
      );
    }

    final List<Map<String, Object?>> selected = <Map<String, Object?>>[];
    bool partial = false;
    int representedSequence = requestedSequence;
    for (final _BrokerEvent event in _events) {
      if (event.sequence <= requestedSequence) {
        continue;
      }
      final Map<String, Object?> safe = event.toWire(
        eligible: eligible,
        scopeFilter: scopeFilter,
      );
      if (scopeFilter != null &&
          safe['scopeReference'] != scopeFilter &&
          safe['kind'] != 'scopeChanged') {
        representedSequence = event.sequence;
        continue;
      }
      if (selected.length >= limits.observeEvents) {
        partial = true;
        break;
      }
      final List<Map<String, Object?>> candidate = <Map<String, Object?>>[
        ...selected,
        safe,
      ];
      final Map<String, Object?> probe = _observeSuccess(
        currentCursor: _encodeCursor(event.sequence),
        eligible: eligible,
        events: candidate,
        unchanged: false,
        gap: false,
        partial: false,
      );
      if (utf8.encode(jsonEncode(probe)).length > limits.observeBytes) {
        partial = true;
        break;
      }
      selected.add(safe);
      representedSequence = event.sequence;
    }
    return _observeSuccess(
      currentCursor: _encodeCursor(partial ? representedSequence : _sequence),
      eligible: eligible,
      events: selected,
      unchanged: selected.isEmpty && !partial,
      gap: false,
      partial: partial,
    );
  }

  Map<String, Object?> _observeSuccess({
    required String currentCursor,
    required List<String> eligible,
    required List<Map<String, Object?>> events,
    required bool unchanged,
    required bool gap,
    required bool partial,
    bool refreshRequired = false,
  }) {
    return webMcpPageSuccess(<String, Object?>{
      'appMount': _appMount,
      'cursor': currentCursor,
      'eligibleScopes': eligible,
      'events': events,
      'unchanged': unchanged,
      'gap': gap,
      'refreshRequired': refreshRequired,
      'eventCoverage': <String, Object?>{
        'partial': partial,
        'returned': events.length,
        'maxEvents': limits.observeEvents,
        'maxBytes': limits.observeBytes,
      },
      'waitCapability': <String, Object?>{
        'positiveWaitSupported': false,
        'maxWaitMs': 0,
      },
    });
  }

  void _emit({
    required String kind,
    String? scopeReference,
    int? revision,
    String? operationId,
    String? outcome,
  }) {
    if (!_attached) {
      return;
    }
    final _BrokerEvent event = _BrokerEvent(
      sequence: ++_sequence,
      kind: kind,
      scopeReference: scopeReference,
      revision: revision,
      operationId: operationId,
      outcome: outcome,
    );
    final int bytes = utf8.encode(jsonEncode(event.toStored())).length;
    while (_events.isNotEmpty &&
        (_events.length >= limits.ringEvents ||
            _ringBytes + bytes > limits.ringBytes)) {
      final _BrokerEvent removed = _events.removeFirst();
      _ringBytes -= removed.encodedBytes;
    }
    if (bytes <= limits.ringBytes) {
      event.encodedBytes = bytes;
      _events.addLast(event);
      _ringBytes += bytes;
    }
  }

  List<String> _eligibleReferences() {
    final List<String> references =
        _pages
            .where(
              (WebMcpPageSessionClient page) => page.isEligibleForObservation,
            )
            .map((WebMcpPageSessionClient page) => page.scopeReference)
            .toList()
          ..sort();
    return references;
  }

  bool _isScopeEligible(String reference) {
    return _pages.any(
      (WebMcpPageSessionClient page) =>
          page.scopeReference == reference && page.isEligibleForObservation,
    );
  }

  void _purgeOperations() {
    final DateTime now = _clock();
    _operations.removeWhere(
      (String _, _TrackedOperation operation) =>
          !operation.expiresAt.isAfter(now),
    );
  }

  Map<String, Object?> _attachmentState() {
    return webMcpPageSuccess(<String, Object?>{
      'attached': _attached,
      'observeOwned': _observeOwned,
      'appMount': _appMount,
    });
  }

  String _encodeCursor(int sequence) {
    return base64Url.encode(utf8.encode('${_appMount ?? ''}:$sequence'));
  }

  int? _decodeCursor(String cursor) {
    try {
      final String decoded = utf8.decode(base64Url.decode(cursor));
      final int separator = decoded.lastIndexOf(':');
      if (separator < 1 || decoded.substring(0, separator) != _appMount) {
        return null;
      }
      return int.tryParse(decoded.substring(separator + 1));
    } on FormatException {
      return null;
    }
  }

  static void _validateIdentifier(String identifier, String suffix) {
    final RegExp valid = RegExp(r'^[A-Za-z0-9_.-]+$');
    if (!valid.hasMatch(identifier) ||
        identifier.length + suffix.length > 128) {
      throw ArgumentError.value(
        identifier,
        'identifier',
        'Must fit the registry alphabet and 128-character suffixed limit.',
      );
    }
  }

  static String _newOpaque(String prefix, int counter) {
    return '$prefix${counter.toRadixString(36)}';
  }

  static const Map<String, Object?> _observeSchema = <String, Object?>{
    'type': 'object',
    'additionalProperties': false,
    'properties': <String, Object?>{
      'cursor': <String, Object?>{'type': 'string'},
      'waitMs': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
        'maximum': 1000,
      },
      'scopeReference': <String, Object?>{'type': 'string'},
    },
  };
}

/// A distinct observer adapter owned by exactly one Navigator.
final class WebMcpNavigatorAdapter extends NavigatorObserver {
  /// Creates and registers a Navigator adapter with [session].
  WebMcpNavigatorAdapter({
    required this.session,
    required this.navigatorId,
    this.parentNavigatorId,
    this.rootModalRelationship = false,
    this.persistentParallelBranch = false,
    this.selectedBranch,
  }) {
    _validateOpaqueIdentity(navigatorId, 'navigatorId');
    if (parentNavigatorId != null) {
      _validateOpaqueIdentity(parentNavigatorId!, 'parentNavigatorId');
    }
    if (parentNavigatorId == navigatorId ||
        persistentParallelBranch && selectedBranch == null ||
        !persistentParallelBranch && selectedBranch != null) {
      registrationError = WebMcpPageErrorCode.invalidArguments;
      return;
    }
    if (!session._registerAdapter(this)) {
      registrationError = WebMcpPageErrorCode.resourceLimit;
      return;
    }
    _registered = true;
    selectedBranch?.addListener(_selectionChanged);
  }

  /// Owning application session.
  final WebMcpAppSession session;

  /// Opaque identity, at most 32 ASCII characters.
  final String navigatorId;

  /// Optional opaque parent Navigator identity.
  final String? parentNavigatorId;

  /// Whether this adapter supplies a root-modal relationship.
  final bool rootModalRelationship;

  /// Whether this Navigator is a persistent parallel branch.
  final bool persistentParallelBranch;

  /// Explicit selected-branch signal for a persistent parallel branch.
  final ValueListenable<bool>? selectedBranch;

  /// Safe registration failure, if registration failed closed.
  WebMcpPageErrorCode? registrationError;

  bool _registered = false;
  bool _disposed = false;
  bool _settled = true;
  bool _unknown = false;
  Route<dynamic>? _topRoute;
  Animation<double>? _watchedAnimation;

  /// Whether route, gesture, and branch evidence is currently settled.
  bool get isSettled => hasSettledEvidence && (selectedBranch?.value ?? true);

  /// Whether this observer has settled lifecycle evidence, regardless of
  /// whether its persistent branch is selected.
  bool get hasSettledEvidence =>
      _registered && !_disposed && !_unknown && _settled;

  /// The latest top route reported by this adapter.
  Route<dynamic>? get topRoute => _topRoute;

  /// Whether this adapter proves a blocking modal on the root Navigator.
  bool get hasBlockingRootModal =>
      rootModalRelationship && _topRoute is PopupRoute<dynamic>;

  /// Marks an externally detected transition as unknown and revokes pages.
  void markTransitionUnknown() {
    if (!_registered || _disposed) {
      return;
    }
    _unknown = true;
    _settled = false;
    session._revokeForNavigation();
  }

  /// Disposes this adapter without affecting consumer observers.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    selectedBranch?.removeListener(_selectionChanged);
    _removeAnimationListener();
    if (_registered) {
      session._unregisterAdapter(this);
      _registered = false;
    }
    session._revokeForNavigation();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _topRoute = route;
    _beginKnownTransition(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _topRoute = previousRoute;
    _beginKnownTransition(previousRoute ?? route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (identical(_topRoute, route)) {
      _topRoute = previousRoute;
    }
    markTransitionUnknown();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute == null) {
      markTransitionUnknown();
      return;
    }
    _topRoute = newRoute;
    _beginKnownTransition(newRoute);
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    _topRoute = topRoute;
    session._revokeForNavigation();
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    markTransitionUnknown();
  }

  @override
  void didStopUserGesture() {
    // A stop callback alone cannot prove whether an interrupted gesture settled.
  }

  void _beginKnownTransition(Route<dynamic> route) {
    if (!_registered || _disposed) {
      return;
    }
    _unknown = false;
    _settled = false;
    session._revokeForNavigation();
    _removeAnimationListener();
    if (route is! TransitionRoute<dynamic> || route.animation == null) {
      _unknown = true;
      return;
    }
    final Animation<double> animation = route.animation!;
    _watchedAnimation = animation;
    animation.addStatusListener(_animationStatusChanged);
    _animationStatusChanged(animation.status);
  }

  void _animationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed &&
        status != AnimationStatus.dismissed) {
      return;
    }
    _settled = true;
    _unknown = false;
    _removeAnimationListener();
    session._navigationSettled();
  }

  void _selectionChanged() {
    session._revokeForNavigation();
    if (selectedBranch?.value ?? false) {
      _settled = true;
      _unknown = false;
      session._navigationSettled();
    }
  }

  void _removeAnimationListener() {
    _watchedAnimation?.removeStatusListener(_animationStatusChanged);
    _watchedAnimation = null;
  }

  void _detachFromSession() {
    selectedBranch?.removeListener(_selectionChanged);
    _removeAnimationListener();
    _registered = false;
    _disposed = true;
  }

  static void _validateOpaqueIdentity(String value, String name) {
    if (value.isEmpty ||
        value.length > 32 ||
        value.codeUnits.any((int unit) => unit < 0x21 || unit > 0x7e)) {
      throw ArgumentError.value(
        value,
        name,
        'Must contain 1 to 32 visible ASCII characters.',
      );
    }
  }
}

final class _BrokerEvent {
  _BrokerEvent({
    required this.sequence,
    required this.kind,
    this.scopeReference,
    this.revision,
    this.operationId,
    this.outcome,
  });

  final int sequence;
  final String kind;
  final String? scopeReference;
  final int? revision;
  final String? operationId;
  final String? outcome;
  int encodedBytes = 0;

  Map<String, Object?> toStored() {
    return <String, Object?>{
      'sequence': sequence,
      'kind': kind,
      if (scopeReference != null) 'scopeReference': scopeReference,
      if (revision != null) 'revision': revision,
      if (operationId != null) 'operationId': operationId,
      if (outcome != null) 'outcome': outcome,
    };
  }

  Map<String, Object?> toWire({
    required List<String> eligible,
    required String? scopeFilter,
  }) {
    final bool exposeScope =
        scopeReference != null && eligible.contains(scopeReference);
    final bool exposeOperation = operationId != null;
    return <String, Object?>{
      'sequence': sequence,
      'kind': exposeScope || exposeOperation ? kind : 'scopeChanged',
      if (exposeScope) 'scopeReference': scopeReference,
      if (exposeScope && revision != null) 'revision': revision,
      if (exposeOperation) 'operationId': operationId,
      if (exposeOperation && outcome != null) 'outcome': outcome,
    };
  }
}

final class _TrackedOperation {
  _TrackedOperation({
    required this.operationId,
    required this.scopeReference,
    required this.requestId,
    required this.expiresAt,
  });

  final String operationId;
  final String scopeReference;
  final int requestId;
  final DateTime expiresAt;
  WebMcpEvidenceKind? latestEvidence;
  String? backendOutcome;
}
