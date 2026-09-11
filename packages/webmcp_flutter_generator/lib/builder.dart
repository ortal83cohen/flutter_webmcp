import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/webmcp_domain_action_generator.dart';

/// Creates the standalone annotated domain-action builder.
Builder webMcpDomainActionBuilder(BuilderOptions options) => LibraryBuilder(
  const WebMcpDomainActionGenerator(),
  generatedExtension: '.webmcp.g.dart',
);
