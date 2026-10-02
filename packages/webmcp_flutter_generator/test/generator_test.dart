import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';
import 'package:webmcp_flutter_generator/builder.dart';

const String _annotationSource = r'''
class WebMcpDomainAction {
  const WebMcpDomainAction({
    required this.description,
    this.name,
    this.readOnlyHint = false,
    this.untrustedContentHint = false,
    this.consequentialHint = false,
    this.title,
    this.debugging,
    this.exposedTo,
  });

  final String description;
  final String? name;
  final bool readOnlyHint;
  final bool untrustedContentHint;
  final bool consequentialHint;
  final String? title;
  final bool? debugging;
  final List<String>? exposedTo;
}
''';

const String _annotationImport =
    "import 'package:webmcp_flutter_annotations/"
    "webmcp_flutter_annotations.dart';";

void main() {
  test(
    'generates schemas, strict decoders, hints, and a live instance source',
    () async {
      await testBuilder(
        webMcpDomainActionBuilder(BuilderOptions.empty),
        <String, String>{
          'webmcp_flutter_annotations|lib/webmcp_flutter_annotations.dart':
              _annotationSource,
          'webmcp_flutter_generator|lib/service.dart': r'''
import 'package:webmcp_flutter_annotations/webmcp_flutter_annotations.dart';

enum Mode { safe, fast }

class InventoryService {
  InventoryService(this.authorized);

  bool authorized;

  @WebMcpDomainAction(
    name: 'inventory.update',
    description: 'Updates authorized inventory.',
    consequentialHint: true,
  )
  Future<void> update(
    String sku, {
    required int amount,
    Mode? mode,
    List<Map<String, bool>> flags = const <Map<String, bool>>[],
  }) async {}

  @WebMcpDomainAction(
    description: 'Reads one value.',
    readOnlyHint: true,
  )
  String read([String prefix = 'item']) => prefix;

  void hidden() {}
}
''',
        },
        generateFor: <String>{'webmcp_flutter_generator|lib/service.dart'},
        outputs: <String, Object>{
          'webmcp_flutter_generator|lib/service.webmcp.g.dart': decodedMatches(
            allOf(
              contains('final class InventoryServiceWebMcpSource'),
              contains('const InventoryServiceWebMcpSource(this.instance)'),
              contains('name: "inventory.update"'),
              contains('name: "InventoryService.read"'),
              contains('consequentialHint: true'),
              contains('readOnlyHint: true'),
              allOf(
                contains('List<Map<String, bool>>'),
                isNot(contains('hidden(')),
              ),
            ),
          ),
        },
      );
    },
  );

  test('rejects unsupported annotated signatures at build time', () async {
    final List<String> logs = <String>[];
    await testBuilder(
      webMcpDomainActionBuilder(BuilderOptions.empty),
      <String, String>{
        'webmcp_flutter_annotations|lib/webmcp_flutter_annotations.dart':
            _annotationSource,
        'webmcp_flutter_generator|lib/unsupported.dart': r'''
import 'package:webmcp_flutter_annotations/webmcp_flutter_annotations.dart';

class UnsupportedService {
  @WebMcpDomainAction(description: 'Must fail.')
  DateTime run(DateTime value) => value;
}
''',
      },
      generateFor: <String>{'webmcp_flutter_generator|lib/unsupported.dart'},
      onLog: (log) => logs.add(log.message),
    );
    expect(logs.join('\n'), contains('Unsupported WebMCP type DateTime'));
  });

  test('rejects duplicate explicit tool names', () async {
    final List<String> logs = <String>[];
    await testBuilder(
      webMcpDomainActionBuilder(BuilderOptions.empty),
      <String, String>{
        'webmcp_flutter_annotations|lib/webmcp_flutter_annotations.dart':
            _annotationSource,
        'webmcp_flutter_generator|lib/duplicate.dart': r'''
import 'package:webmcp_flutter_annotations/webmcp_flutter_annotations.dart';

class DuplicateService {
  @WebMcpDomainAction(name: 'same.name', description: 'First.')
  void first() {}

  @WebMcpDomainAction(name: 'same.name', description: 'Second.')
  void second() {}
}
''',
      },
      generateFor: <String>{'webmcp_flutter_generator|lib/duplicate.dart'},
      onLog: (log) => logs.add(log.message),
    );
    expect(logs.join('\n'), contains('is duplicated in this library'));
  });

  test('emits title, debugging, and origins only when they are set', () async {
    await testBuilder(
      webMcpDomainActionBuilder(BuilderOptions.empty),
      <String, String>{
        'webmcp_flutter_annotations|lib/webmcp_flutter_annotations.dart':
            _annotationSource,
        'webmcp_flutter_generator|lib/metadata.dart':
            '''
$_annotationImport

class MetadataService {
  @WebMcpDomainAction(
    description: 'Sets all three.',
    title: 'Update stock',
    debugging: true,
    exposedTo: ['https://a.example', 'https://b.example'],
  )
  void full() {}

  @WebMcpDomainAction(
    description: 'Sets an empty origin list and an explicit false hint.',
    debugging: false,
    exposedTo: [],
  )
  void emptyOrigins() {}

  @WebMcpDomainAction(description: 'Sets none of the three.')
  void bare() {}
}
''',
      },
      generateFor: <String>{'webmcp_flutter_generator|lib/metadata.dart'},
      outputs: <String, Object>{
        'webmcp_flutter_generator|lib/metadata.webmcp.g.dart': decodedMatches(
          predicate<String>((String source) {
            // Chunk 0 is the preamble; chunks 1..3 follow the method order.
            final List<String> chunks = source.split('_webmcp.WebMcpTool(');
            if (chunks.length != 4) {
              return false;
            }
            final String full = chunks[1];
            final String emptyOrigins = chunks[2];
            final String bare = chunks[3];
            return full.contains('title: "Update stock",') &&
                full.contains('debugging: true,') &&
                full.contains(
                  'exposedTo: const <String>'
                  '["https://a.example", "https://b.example"],',
                ) &&
                // Debugging sits inside the annotations literal.
                full.indexOf('WebMcpToolAnnotations(') <
                    full.indexOf('debugging: true,') &&
                !emptyOrigins.contains('title:') &&
                emptyOrigins.contains('exposedTo: const <String>[],') &&
                emptyOrigins.contains('debugging: false,') &&
                !bare.contains('title:') &&
                !bare.contains('debugging:') &&
                !bare.contains('exposedTo:');
          }, 'emits each metadata member only for the method that sets it'),
        ),
      },
    );
  });

  test('emits none of the metadata members when none are set', () async {
    await testBuilder(
      webMcpDomainActionBuilder(BuilderOptions.empty),
      <String, String>{
        'webmcp_flutter_annotations|lib/webmcp_flutter_annotations.dart':
            _annotationSource,
        'webmcp_flutter_generator|lib/plain.dart':
            '''
$_annotationImport

class PlainService {
  @WebMcpDomainAction(description: 'Plain.', readOnlyHint: true)
  void plain() {}
}
''',
      },
      generateFor: <String>{'webmcp_flutter_generator|lib/plain.dart'},
      outputs: <String, Object>{
        'webmcp_flutter_generator|lib/plain.webmcp.g.dart': decodedMatches(
          allOf(
            contains('name: "PlainService.plain"'),
            isNot(contains('title')),
            isNot(contains('debugging')),
            isNot(contains('exposedTo')),
          ),
        ),
      },
    );
  });

  for (final String blankTitle in <String>['', '   ']) {
    test(
      'reports a blank title (${blankTitle.length} chars) through the log',
      () async {
        final List<String> logs = <String>[];
        await testBuilder(
          webMcpDomainActionBuilder(BuilderOptions.empty),
          <String, String>{
            'webmcp_flutter_annotations|lib/webmcp_flutter_annotations.dart':
                _annotationSource,
            'webmcp_flutter_generator|lib/blank.dart':
                '''
$_annotationImport

class BlankService {
  @WebMcpDomainAction(description: 'Blank title.', title: '$blankTitle')
  void blankTitled() {}
}
''',
          },
          generateFor: <String>{'webmcp_flutter_generator|lib/blank.dart'},
          onLog: (log) => logs.add(log.message),
        );
        final String joined = logs.join('\n');
        expect(joined, contains('title'));
        expect(joined, contains('blankTitled'));
        expect(joined, contains('cannot be empty'));
      },
    );
  }

  test('does not report a valid non-empty title', () async {
    final List<String> logs = <String>[];
    await testBuilder(
      webMcpDomainActionBuilder(BuilderOptions.empty),
      <String, String>{
        'webmcp_flutter_annotations|lib/webmcp_flutter_annotations.dart':
            _annotationSource,
        'webmcp_flutter_generator|lib/titled.dart':
            '''
$_annotationImport

class TitledService {
  @WebMcpDomainAction(description: 'Titled.', title: 'Readable title')
  void titled() {}
}
''',
      },
      generateFor: <String>{'webmcp_flutter_generator|lib/titled.dart'},
      onLog: (log) => logs.add(log.message),
    );
    expect(logs.join('\n'), isNot(contains('cannot be empty')));
  });
}
