// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// WebMcpDomainActionGenerator
// **************************************************************************

import 'package:webmcp_flutter/webmcp_flutter.dart' as _webmcp;

// ignore: unused_import
import 'example_task_service.dart';
import 'example_task_service.dart' as _input;

Never _$webMcpInvalid() =>
    throw const FormatException('Invalid WebMCP arguments.');

Object? _$webMcpRequired(Map<String, Object?> arguments, String name) {
  if (!arguments.containsKey(name)) _$webMcpInvalid();
  return arguments[name];
}

void _$webMcpCheckKeys(Map<String, Object?> arguments, Set<String> allowed) {
  if (arguments.keys.any((String key) => !allowed.contains(key))) {
    _$webMcpInvalid();
  }
}

String _$decodeExampleTaskService0P0(Object? value) {
  if (value == null) _$webMcpInvalid();
  if (value is! String) _$webMcpInvalid();
  return value;
}

/// Generated tools bound to one consumer-owned live instance.
final class ExampleTaskServiceWebMcpSource implements _webmcp.WebMcpToolSource {
  /// Creates an adapter without constructing the service.
  const ExampleTaskServiceWebMcpSource(this.instance);

  /// The live service instance supplied by the consumer.
  final _input.ExampleTaskService instance;

  @override
  List<_webmcp.WebMcpTool> getWebMcpTools() => <_webmcp.WebMcpTool>[
    _webmcp.WebMcpTool(
      name: "example.tasks.create",
      description: "Creates a task when the application authorizes it.",
      inputSchema: <String, Object?>{
        "type": "object",
        "additionalProperties": false,
        "properties": <String, Object?>{
          "title": <String, Object?>{"type": "string"},
        },
        "required": <Object?>["title"],
      },
      annotations: const _webmcp.WebMcpToolAnnotations(
        readOnlyHint: false,
        untrustedContentHint: false,
        consequentialHint: true,
      ),
      handler: _invoke0,
    ),
    _webmcp.WebMcpTool(
      name: "example.tasks.list",
      description: "Lists the current task titles.",
      inputSchema: <String, Object?>{
        "type": "object",
        "additionalProperties": false,
        "properties": <String, Object?>{},
      },
      annotations: const _webmcp.WebMcpToolAnnotations(
        readOnlyHint: true,
        untrustedContentHint: false,
        consequentialHint: false,
      ),
      handler: _invoke1,
    ),
  ];

  Object? _invoke0(Map<String, Object?> arguments) {
    try {
      _$webMcpCheckKeys(arguments, <String>{"title"});
      return instance.create(
        title: _$decodeExampleTaskService0P0(
          _$webMcpRequired(arguments, "title"),
        ),
      );
    } on FormatException {
      return const <String, Object?>{
        'ok': false,
        'error': <String, Object?>{
          'code': 'invalidArguments',
          'retryable': false,
        },
      };
    }
  }

  Object? _invoke1(Map<String, Object?> arguments) {
    try {
      _$webMcpCheckKeys(arguments, <String>{});
      return instance.list();
    } on FormatException {
      return const <String, Object?>{
        'ok': false,
        'error': <String, Object?>{
          'code': 'invalidArguments',
          'retryable': false,
        },
      };
    }
  }
}
