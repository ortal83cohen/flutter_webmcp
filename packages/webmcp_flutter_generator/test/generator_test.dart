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
  });

  final String description;
  final String? name;
  final bool readOnlyHint;
  final bool untrustedContentHint;
  final bool consequentialHint;
}
''';

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
}
