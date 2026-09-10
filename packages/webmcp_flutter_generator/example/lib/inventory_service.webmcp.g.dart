// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// WebMcpDomainActionGenerator
// **************************************************************************

import 'package:webmcp_flutter/webmcp_flutter.dart' as _webmcp;

import 'inventory_service.dart';
import 'inventory_service.dart' as _input;

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

String _$decodeInventoryService0P0(Object? value) {
  if (value == null) _$webMcpInvalid();
  if (value is! String) _$webMcpInvalid();
  return value;
}

int _$decodeInventoryService0P1(Object? value) {
  if (value == null) _$webMcpInvalid();
  if (value is! int || value < -9007199254740991 || value > 9007199254740991) {
    _$webMcpInvalid();
  }
  return value;
}

_input.FulfillmentMode _$decodeInventoryService0P2(Object? value) {
  if (value == null) _$webMcpInvalid();
  if (value is! String) _$webMcpInvalid();
  for (final _input.FulfillmentMode item in _input.FulfillmentMode.values) {
    if (item.name == value) return item;
  }
  _$webMcpInvalid();
}

bool _$decodeInventoryService0P3ItemItem(Object? value) {
  if (value == null) _$webMcpInvalid();
  if (value is! bool) _$webMcpInvalid();
  return value;
}

Map<String, bool> _$decodeInventoryService0P3Item(Object? value) {
  if (value == null) _$webMcpInvalid();
  if (value is! Map<Object?, Object?>) _$webMcpInvalid();
  final result = <String, bool>{};
  for (final entry in value.entries) {
    if (entry.key is! String) _$webMcpInvalid();
    result[entry.key! as String] = _$decodeInventoryService0P3ItemItem(
      entry.value,
    );
  }
  return result;
}

List<Map<String, bool>> _$decodeInventoryService0P3(Object? value) {
  if (value == null) _$webMcpInvalid();
  if (value is! List<Object?>) _$webMcpInvalid();
  return value.map(_$decodeInventoryService0P3Item).toList(growable: false);
}

/// Generated tools bound to one consumer-owned live instance.
final class InventoryServiceWebMcpSource implements _webmcp.WebMcpToolSource {
  /// Creates an adapter without constructing the service.
  const InventoryServiceWebMcpSource(this.instance);

  /// The live service instance supplied by the consumer.
  final _input.InventoryService instance;

  @override
  List<_webmcp.WebMcpTool> getWebMcpTools() => <_webmcp.WebMcpTool>[
    _webmcp.WebMcpTool(
      name: "inventory.update",
      description: "Updates inventory when application policy allows it.",
      inputSchema: <String, Object?>{
        "type": "object",
        "additionalProperties": false,
        "properties": <String, Object?>{
          "sku": <String, Object?>{"type": "string"},
          "amount": <String, Object?>{
            "type": "integer",
            "minimum": -9007199254740991,
            "maximum": 9007199254740991,
          },
          "mode": <String, Object?>{
            "type": "string",
            "enum": <Object?>["preview", "commit"],
          },
          "checks": <String, Object?>{
            "type": "array",
            "items": <String, Object?>{
              "type": "object",
              "additionalProperties": <String, Object?>{"type": "boolean"},
            },
          },
        },
        "required": <Object?>["sku", "amount"],
      },
      annotations: const _webmcp.WebMcpToolAnnotations(
        readOnlyHint: false,
        untrustedContentHint: false,
        consequentialHint: true,
      ),
      handler: _invoke0,
    ),
    _webmcp.WebMcpTool(
      name: "inventory.read",
      description: "Reads the current live inventory quantity.",
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
      _$webMcpCheckKeys(arguments, <String>{"sku", "amount", "mode", "checks"});
      return instance.update(
        _$decodeInventoryService0P0(_$webMcpRequired(arguments, "sku")),
        amount: _$decodeInventoryService0P1(
          _$webMcpRequired(arguments, "amount"),
        ),
        mode: arguments.containsKey("mode")
            ? _$decodeInventoryService0P2(arguments["mode"])
            : FulfillmentMode.commit,
        checks: arguments.containsKey("checks")
            ? _$decodeInventoryService0P3(arguments["checks"])
            : const <Map<String, bool>>[],
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
      return instance.read();
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
