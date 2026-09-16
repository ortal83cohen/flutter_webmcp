import 'package:webmcp_flutter/webmcp_flutter.dart';

/// Performs a read-then-act round trip against one automatic
/// [WebMcpPage]'s `<pageId>.page.read` and `<pageId>.page.act` endpoints and
/// records a human-readable transcript of every attempt.
///
/// Holds a private request-identifier counter starting at one. The counter
/// is incremented on every act attempt, including a retry, because reusing
/// a request identifier is forbidden by the page protocol's
/// duplicate-request rule: a retry after a stale snapshot necessarily
/// carries a different revision and therefore a different request
/// fingerprint, so a reused identifier would return the duplicate-request
/// code instead of a fresh attempt.
final class ExampleAgentProbe {
  int _nextRequestId = 1;

  /// The request identifier the next act attempt will consume. Exposed so
  /// tests can assert the strictly-increasing rule across a retry.
  int get nextRequestId => _nextRequestId;

  /// Performs up to [maxAttempts] read-then-act attempts, one node-labelled
  /// [action] against the node exactly labelled [nodeLabel] on the page
  /// identified by [pageId].
  ///
  /// Each attempt invokes `<pageId>.page.read` with [nodeLabel] as its
  /// query, appends a transcript line naming the attempt number, the
  /// success flag, the returned node count and the revision, then locates
  /// the first returned node whose label equals [nodeLabel] exactly and
  /// which advertises [action]. The act call always supplies all seven
  /// required arguments, taking the mount token and revision from the read
  /// it just performed and the request identifier from this probe's
  /// counter.
  ///
  /// An attempt whose act reports the stale-snapshot code is retried until
  /// [maxAttempts] is exhausted; any other outcome — success or a different
  /// failure — stops the run.
  ///
  /// [beforeFirstAct], if supplied, is invoked exactly once, immediately
  /// before the first attempt's act call, and is then cleared. It is the
  /// only injection seam a caller has to invalidate the snapshot the first
  /// attempt just read, in order to force a stale-snapshot retry. It is
  /// awaited, so a caller may drive real, asynchronous test machinery
  /// (widget gestures and frame pumps) from it rather than being confined
  /// to a synchronous side effect.
  Future<List<String>> run({
    required String pageId,
    required String nodeLabel,
    required String action,
    required Map<String, Object?> arguments,
    int maxAttempts = 2,
    Future<void> Function()? beforeFirstAct,
  }) async {
    final List<String> transcript = <String>[];
    Future<void> Function()? pendingBeforeAct = beforeFirstAct;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final Object? readResult = await WebMcp.instance.invokeTool(
        '$pageId.page.read',
        <String, Object?>{'query': nodeLabel},
      );
      final Map<String, Object?> read = readResult as Map<String, Object?>;
      final bool readOk = read['ok'] == true;
      final List<Object?> nodes = readOk
          ? (read['nodes']! as List<Object?>)
          : const <Object?>[];
      transcript.add(
        'attempt $attempt: read ok=$readOk nodes=${nodes.length} '
        'revision=${read['revision']}',
      );
      if (!readOk) {
        return transcript;
      }

      Map<String, Object?>? node;
      for (final Object? candidate in nodes) {
        if (candidate is Map<String, Object?> &&
            candidate['label'] == nodeLabel) {
          final List<String> nodeActions =
              (candidate['actions']! as List<Object?>).cast<String>();
          if (nodeActions.contains(action)) {
            node = candidate;
            break;
          }
        }
      }
      if (node == null) {
        transcript.add(
          'attempt $attempt: no node labelled "$nodeLabel" advertises "$action"',
        );
        return transcript;
      }

      final Future<void> Function()? callback = pendingBeforeAct;
      pendingBeforeAct = null;
      if (callback != null) {
        await callback();
      }

      final int requestId = _nextRequestId;
      _nextRequestId++;
      final Object? actResult = await WebMcp.instance.invokeTool(
        '$pageId.page.act',
        <String, Object?>{
          'pageId': pageId,
          'mountToken': read['mountToken'],
          'revision': read['revision'],
          'handle': node['handle'],
          'action': action,
          'requestId': requestId,
          'arguments': arguments,
        },
      );
      final Map<String, Object?> receipt = actResult as Map<String, Object?>;
      final bool actOk = receipt['ok'] == true;
      final String code = actOk ? 'ok' : (receipt['code']! as String);
      transcript.add(
        'attempt $attempt: act requestId=$requestId ok=$actOk code=$code',
      );
      if (actOk) {
        return transcript;
      }
      if (code != 'staleSnapshot') {
        return transcript;
      }
      // Otherwise fall through the loop for the retry.
    }
    return transcript;
  }
}
