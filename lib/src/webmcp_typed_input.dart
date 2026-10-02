import 'webmcp_exceptions.dart';

/// Inclusive lower bound for a safe integer field.
const int webMcpSafeIntegerMinimum = -9007199254740991;

/// Inclusive upper bound for a safe integer field.
const int webMcpSafeIntegerMaximum = 9007199254740991;

/// The value shape accepted by one declared input field.
enum WebMcpInputShape {
  /// A string.
  string,

  /// A boolean.
  boolean,

  /// An integer inside the safe inclusive range.
  safeInteger,

  /// A finite double. Integers are accepted and converted.
  finiteDouble,

  /// One of the names listed on the field.
  enumeration,

  /// A list whose elements match [WebMcpInputField.child].
  list,

  /// A string-keyed map whose values match [WebMcpInputField.child].
  map,
}

/// One declared key in a manual tool's input.
final class WebMcpInputField {
  /// Creates a field named [key] with [shape].
  const WebMcpInputField({
    required this.key,
    required this.shape,
    this.isRequired = true,
    this.nullable = false,
    this.allowedNames = const <String>[],
    this.child,
  });

  /// The argument key.
  final String key;

  /// The value shape.
  final WebMcpInputShape shape;

  /// Whether the key must be present.
  final bool isRequired;

  /// Whether a present null value is accepted.
  final bool nullable;

  /// Enumeration names accepted when [shape] is [WebMcpInputShape.enumeration].
  final List<String> allowedNames;

  /// The element or map-value field for a nested list or map.
  final WebMcpInputField? child;
}

/// Returns a new object schema describing [fields].
///
/// The schema is descriptive only; invocation never validates arguments against
/// it. Every call allocates fresh nested maps and lists. A list or map field
/// with no child emits only its base type. When two fields share a key, the
/// later declaration wins in the properties map.
Map<String, Object?> webMcpSchemaFromFields(List<WebMcpInputField> fields) {
  final Map<String, Object?> properties = <String, Object?>{};
  final List<String> required = <String>[];
  for (final WebMcpInputField field in fields) {
    properties[field.key] = _schemaForField(field);
    if (field.isRequired) {
      required.add(field.key);
    }
  }
  return <String, Object?>{
    'type': 'object',
    'additionalProperties': false,
    'properties': properties,
    if (required.isNotEmpty) 'required': required,
  };
}

// Builds the schema for one field. Only shape, nullable, allowedNames and
// child are read, so the same code serves top-level and nested fields.
Map<String, Object?> _schemaForField(WebMcpInputField field) {
  final Map<String, Object?> base;
  switch (field.shape) {
    case WebMcpInputShape.string:
      base = <String, Object?>{'type': 'string'};
    case WebMcpInputShape.boolean:
      base = <String, Object?>{'type': 'boolean'};
    case WebMcpInputShape.safeInteger:
      base = <String, Object?>{
        'type': 'integer',
        'minimum': webMcpSafeIntegerMinimum,
        'maximum': webMcpSafeIntegerMaximum,
      };
    case WebMcpInputShape.finiteDouble:
      base = <String, Object?>{'type': 'number'};
    case WebMcpInputShape.enumeration:
      base = <String, Object?>{
        'type': 'string',
        'enum': List<String>.of(field.allowedNames),
      };
    case WebMcpInputShape.list:
      final WebMcpInputField? child = field.child;
      base = <String, Object?>{
        'type': 'array',
        if (child != null) 'items': _schemaForField(child),
      };
    case WebMcpInputShape.map:
      final WebMcpInputField? child = field.child;
      base = <String, Object?>{
        'type': 'object',
        if (child != null) 'additionalProperties': _schemaForField(child),
      };
  }
  if (!field.nullable) {
    return base;
  }
  return <String, Object?>{
    'anyOf': <Object?>[
      base,
      <String, Object?>{'type': 'null'},
    ],
  };
}

/// Returns a new map containing only the keys declared by [fields].
///
/// Throws [WebMcpInvalidArgumentsException] before any author callback when
/// [arguments] contain an unknown key, omit a required key, or fail a shape.
/// The exception carries the failed top-level key and a closed reason.
Map<String, Object?> webMcpDecodeArguments(
  List<WebMcpInputField> fields,
  Map<String, Object?> arguments,
) {
  final Map<String, WebMcpInputField> declared = <String, WebMcpInputField>{
    for (final WebMcpInputField field in fields) field.key: field,
  };
  for (final String key in arguments.keys) {
    if (!declared.containsKey(key)) {
      throw WebMcpInvalidArgumentsException.withFailure(
        key: key,
        reason: WebMcpDecodeFailureReason.unknown,
      );
    }
  }
  final Map<String, Object?> decoded = <String, Object?>{};
  for (final WebMcpInputField field in fields) {
    if (!arguments.containsKey(field.key)) {
      if (field.isRequired) {
        throw WebMcpInvalidArgumentsException.withFailure(
          key: field.key,
          reason: WebMcpDecodeFailureReason.missing,
        );
      }
      continue;
    }
    decoded[field.key] = _decodeValue(field, arguments[field.key], field.key);
  }
  return decoded;
}

// Decodes one value. [topKey] is always the top-level argument key, so a
// nested failure names a key the caller actually sent.
Object? _decodeValue(WebMcpInputField field, Object? value, String topKey) {
  Never reject() => throw WebMcpInvalidArgumentsException.withFailure(
    key: topKey,
    reason: WebMcpDecodeFailureReason.type,
  );

  if (value == null) {
    if (field.nullable) {
      return null;
    }
    reject();
  }
  switch (field.shape) {
    case WebMcpInputShape.string:
      if (value is! String) {
        reject();
      }
      return value;
    case WebMcpInputShape.boolean:
      if (value is! bool) {
        reject();
      }
      return value;
    case WebMcpInputShape.safeInteger:
      if (value is! int ||
          value < webMcpSafeIntegerMinimum ||
          value > webMcpSafeIntegerMaximum) {
        reject();
      }
      return value;
    case WebMcpInputShape.finiteDouble:
      if (value is! num) {
        reject();
      }
      final double decoded = value.toDouble();
      if (!decoded.isFinite) {
        reject();
      }
      return decoded;
    case WebMcpInputShape.enumeration:
      if (value is! String || !field.allowedNames.contains(value)) {
        reject();
      }
      return value;
    case WebMcpInputShape.list:
      final WebMcpInputField? child = field.child;
      if (child == null || value is! List<Object?>) {
        reject();
      }
      return value
          .map((Object? item) => _decodeValue(child, item, topKey))
          .toList(growable: false);
    case WebMcpInputShape.map:
      final WebMcpInputField? child = field.child;
      if (child == null || value is! Map<Object?, Object?>) {
        reject();
      }
      final Map<String, Object?> decoded = <String, Object?>{};
      for (final MapEntry<Object?, Object?> entry in value.entries) {
        final Object? key = entry.key;
        if (key is! String) {
          reject();
        }
        decoded[key] = _decodeValue(child, entry.value, topKey);
      }
      return decoded;
  }
}
