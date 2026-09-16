import 'package:flutter/material.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'example_agent_probe.dart';

/// Demonstrates a fully non-default [WebMcpPagePolicy]: one labelled
/// semantics node per policy behaviour, plus on-screen buttons that run
/// [ExampleAgentProbe] against two of those nodes and a transcript view.
///
/// Takes no argument beyond the inherited key, per the plan's fixed screen
/// constructors: every long-lived object it needs is either owned locally
/// (the probe and the small pieces of note/archive/history state) or
/// reached through the process-wide registry the enclosing runtime already
/// installed.
final class ExampleFormScreen extends StatefulWidget {
  /// Creates the form screen.
  const ExampleFormScreen({super.key});

  /// The page identifier used as the prefix for this screen's
  /// `.page.read` and `.page.act` endpoint names.
  static const String pageId = 'example.form';

  /// The semantics identifier of the note field, used both by [policy]'s
  /// editable-value and set-text sets and by the excluded/sensitive marker
  /// checks in the owning test.
  static const String noteFieldIdentifier = 'example.form.note';

  /// The semantics identifier of the excluded panel.
  static const String excludedPanelIdentifier = 'example.form.excluded';

  /// The semantics identifier of the secret panel.
  static const String secretPanelIdentifier = 'example.form.secret';

  /// The marker text the excluded panel carries, checkable only by its
  /// absence from a read response.
  static const String excludedMarkerText = 'EXCLUDED-CONTENT';

  /// The marker text the secret panel carries, checkable only by its
  /// absence from a read response.
  static const String sensitiveMarkerText = 'SENSITIVE-VALUE';

  /// The non-editable marker value the status node carries, checkable
  /// only by its absence from a read response once the policy excludes
  /// non-editable values.
  static const String nonEditableMarkerValue = 'NON-EDITABLE-VALUE';

  /// The fully non-default page policy this screen's [WebMcpPage] carries.
  /// All eight fields differ from [WebMcpPagePolicy.defaults]: long press
  /// is allowed, bounds are included, non-editable values are excluded,
  /// the maximum accepted text length is one hundred and twenty, and the
  /// four identifier sets each hold exactly the identifier named in the
  /// plan.
  static final WebMcpPagePolicy policy = WebMcpPagePolicy(
    allowLongPress: true,
    includeBounds: true,
    includeNonEditableValues: false,
    maxTextLength: 120,
    excludedSemanticsIdentifiers: <String>{excludedPanelIdentifier},
    sensitiveSemanticsIdentifiers: <String>{secretPanelIdentifier},
    editableValueIdentifiers: <String>{noteFieldIdentifier},
    setTextIdentifiers: <String>{noteFieldIdentifier},
  );

  @override
  State<ExampleFormScreen> createState() => _ExampleFormScreenState();
}

class _ExampleFormScreenState extends State<ExampleFormScreen> {
  final ExampleAgentProbe _probe = ExampleAgentProbe();
  String _noteText = 'initial note';
  bool _archived = false;
  int _historyOffset = 0;
  List<String> _transcript = <String>[];

  Future<void> _runNoteProbe() async {
    final List<String> transcript = await _probe.run(
      pageId: ExampleFormScreen.pageId,
      nodeLabel: 'Note field',
      action: 'setText',
      arguments: <String, Object?>{'text': 'set by note probe'},
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _transcript = transcript;
    });
  }

  Future<void> _runArchiveProbe() async {
    final List<String> transcript = await _probe.run(
      pageId: ExampleFormScreen.pageId,
      nodeLabel: 'Archive note',
      action: 'longPress',
      arguments: const <String, Object?>{},
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _transcript = transcript;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form')),
      body: WebMcpPage(
        pageId: ExampleFormScreen.pageId,
        policy: ExampleFormScreen.policy,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                identifier: ExampleFormScreen.noteFieldIdentifier,
                label: 'Note field',
                value: _noteText,
                textField: true,
                onSetText: (String value) {
                  setState(() => _noteText = value);
                },
                child: const SizedBox(width: 10, height: 10),
              ),
              Text('Note text: $_noteText'),
              const SizedBox(height: 12),
              Semantics(
                identifier: 'example.form.archive',
                label: 'Archive note',
                onLongPress: () {
                  setState(() => _archived = true);
                },
                child: const SizedBox(width: 100, height: 40),
              ),
              // A sibling, not a child, of the node above: a Text
              // descendant of a plain (non-container) Semantics node merges
              // its own label into the parent's, which would turn the
              // exact label "Archive note" into "Archive note\nNot
              // archived" and break exact-label node targeting.
              Text(_archived ? 'Archived' : 'Not archived'),
              const SizedBox(height: 12),
              Semantics(
                identifier: 'example.form.history',
                label: 'Note history',
                onScrollUp: () {
                  setState(() => _historyOffset -= 1);
                },
                onScrollDown: () {
                  setState(() => _historyOffset += 1);
                },
                child: const SizedBox(width: 200, height: 80),
              ),
              Text('History offset: $_historyOffset'),
              const SizedBox(height: 12),
              Semantics(
                identifier: 'example.form.status',
                label: 'Save status',
                value: ExampleFormScreen.nonEditableMarkerValue,
                increasedValue: 'saved',
                decreasedValue: 'saving',
                onIncrease: () {},
                onDecrease: () {},
                child: const SizedBox(width: 10, height: 10),
              ),
              const SizedBox(height: 12),
              Semantics(
                identifier: ExampleFormScreen.excludedPanelIdentifier,
                label: 'Excluded panel',
                child: Text(ExampleFormScreen.excludedMarkerText),
              ),
              const SizedBox(height: 12),
              Semantics(
                identifier: ExampleFormScreen.secretPanelIdentifier,
                label: 'Secret panel',
                child: Text(ExampleFormScreen.sensitiveMarkerText),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _runNoteProbe,
                child: const Text('Run note probe'),
              ),
              ElevatedButton(
                onPressed: _runArchiveProbe,
                child: const Text('Run archive probe'),
              ),
              // Changes visible page content with no involvement of the
              // WebMcp act protocol, so the owning test can force a real
              // revision change between a probe's read and its act without
              // consuming a page request identifier -- the page's own
              // request-identifier ledger is per-page, not per-node, so any
              // genuine `.page.act` call the test made for this purpose
              // would make the probe's own first request identifier (which
              // always starts at one) look reused rather than stale. A
              // plain widget rebuild sidesteps that ledger entirely, the
              // same way the library's own passing tests force staleness.
              ElevatedButton(
                key: const Key('example.form.forceContentChange'),
                onPressed: () {
                  setState(() => _historyOffset += 1);
                },
                child: const Text('Force content change (test only)'),
              ),
              const SizedBox(height: 12),
              Text('Transcript: ${_transcript.join(' | ')}'),
            ],
          ),
        ),
      ),
    );
  }
}
