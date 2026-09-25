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

/// Returns a new map containing only the keys declared by [fields].
///
/// Throws [WebMcpInvalidArgumentsException] before any author callback when
/// [arguments] contain an unknown key, omit a required key, or fail a shape.
Map<String, Object?> webMcpDecodeArguments(
  List<WebMcpInputField> fields,
  Map<String, Object?> arguments,
) {
  final Map<String, WebMcpInputField> declared = <String, WebMcpInputField>{
    for (final WebMcpInputField field in fields) field.key: field,
  };
  for (final String key in arguments.keys) {
    if (!declared.containsKey(key)) {
      throw const WebMcpInvalidArgumentsException();
    }
  }
  final Map<String, Object?> decoded = <String, Object?>{};
  for (final WebMcpInputField field in fields) {
    if (!arguments.containsKey(field.key)) {
      if (field.isRequired) {
        throw const WebMcpInvalidArgumentsException();
      }
      continue;
    }
    decoded[field.key] = _decodeValue(field, arguments[field.key]);
  }
  return decoded;
}

Object? _decodeValue(WebMcpInputField field, Object? value) {
  if (value == null) {
    if (field.nullable) {
      return null;
    }
    throw const WebMcpInvalidArgumentsException();
  }
  switch (field.shape) {
    case WebMcpInputShape.string:
      if (value is! String) {
        throw const WebMcpInvalidArgumentsException();
      }
      return value;
    case WebMcpInputShape.boolean:
      if (value is! bool) {
        throw const WebMcpInvalidArgumentsException();
      }
      return value;
    case WebMcpInputShape.safeInteger:
      if (value is! int ||
          value < webMcpSafeIntegerMinimum ||
          value > webMcpSafeIntegerMaximum) {
        throw const WebMcpInvalidArgumentsException();
      }
      return value;
    case WebMcpInputShape.finiteDouble:
      if (value is! num) {
        throw const WebMcpInvalidArgumentsException();
      }
      final double decoded = value.toDouble();
      if (!decoded.isFinite) {
        throw const WebMcpInvalidArgumentsException();
      }
      return decoded;
    case WebMcpInputShape.enumeration:
      if (value is! String || !field.allowedNames.contains(value)) {
        throw const WebMcpInvalidArgumentsException();
      }
      return value;
    case WebMcpInputShape.list:
      final WebMcpInputField? child = field.child;
      if (child == null || value is! List<Object?>) {
        throw const WebMcpInvalidArgumentsException();
      }
      return value
          .map((Object? item) => _decodeValue(child, item))
          .toList(growable: false);
    case WebMcpInputShape.map:
      final WebMcpInputField? child = field.child;
      if (child == null || value is! Map<Object?, Object?>) {
        throw const WebMcpInvalidArgumentsException();
      }
      final Map<String, Object?> decoded = <String, Object?>{};
      for (final MapEntry<Object?, Object?> entry in value.entries) {
        final Object? key = entry.key;
        if (key is! String) {
          throw const WebMcpInvalidArgumentsException();
        }
        decoded[key] = _decodeValue(child, entry.value);
      }
      return decoded;
  }
}
