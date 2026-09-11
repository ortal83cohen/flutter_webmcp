import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:webmcp_flutter_annotations/webmcp_flutter_annotations.dart';

const TypeChecker _actionChecker = TypeChecker.typeNamed(WebMcpDomainAction);

/// Generates one live-instance source for each class with annotated methods.
final class WebMcpDomainActionGenerator extends Generator {
  /// Creates the generator.
  const WebMcpDomainActionGenerator();

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) {
    final List<_ExposedClass> exposed = <_ExposedClass>[];
    final Set<String> toolNames = <String>{};
    for (final ClassElement type in library.element.classes) {
      final List<_ExposedMethod> methods = <_ExposedMethod>[];
      for (final MethodElement method in type.methods) {
        final annotation = _actionChecker.firstAnnotationOf(
          method,
          throwOnUnresolved: true,
        );
        if (annotation == null) {
          continue;
        }
        final ConstantReader reader = ConstantReader(annotation);
        final _ExposedMethod exposedMethod = _readMethod(type, method, reader);
        if (!toolNames.add(exposedMethod.toolName)) {
          throw InvalidGenerationSource(
            'Generated WebMCP tool name "${exposedMethod.toolName}" is '
            'duplicated in this library.',
            element: method,
          );
        }
        methods.add(exposedMethod);
      }
      if (methods.isNotEmpty) {
        final String? typeName = type.name;
        if (!type.isPublic || type.typeParameters.isNotEmpty) {
          throw InvalidGenerationSource(
            'Annotated WebMCP methods require a public, non-generic class.',
            element: type,
          );
        }
        if (typeName == null) {
          throw InvalidGenerationSource(
            'Annotated WebMCP classes must have a source name.',
            element: type,
          );
        }
        exposed.add(_ExposedClass(typeName, methods));
      }
    }
    if (exposed.isEmpty) {
      return null;
    }

    final String inputName = buildStep.inputId.path.split('/').last;
    final StringBuffer output = StringBuffer()
      ..writeln(
        "import 'package:webmcp_flutter/webmcp_flutter.dart' as _webmcp;",
      )
      ..writeln('// ignore: unused_import')
      ..writeln("import '$inputName';")
      ..writeln("import '$inputName' as _input;")
      ..writeln()
      ..writeln(
        "Never _\$webMcpInvalid() => throw const FormatException("
        "'Invalid WebMCP arguments.');",
      )
      ..writeln()
      ..writeln(
        'Object? _\$webMcpRequired(Map<String, Object?> arguments, '
        'String name) {',
      )
      ..writeln('  if (!arguments.containsKey(name)) _\$webMcpInvalid();')
      ..writeln('  return arguments[name];')
      ..writeln('}')
      ..writeln()
      ..writeln(
        'void _\$webMcpCheckKeys(Map<String, Object?> arguments, '
        'Set<String> allowed) {',
      )
      ..writeln(
        '  if (arguments.keys.any((String key) => !allowed.contains(key))) {',
      )
      ..writeln('    _\$webMcpInvalid();')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();

    for (final _ExposedClass type in exposed) {
      _emitClass(output, type);
    }
    return output.toString();
  }

  _ExposedMethod _readMethod(
    ClassElement owner,
    MethodElement method,
    ConstantReader annotation,
  ) {
    if (!method.isPublic ||
        method.isStatic ||
        method.isOperator ||
        method.typeParameters.isNotEmpty) {
      throw InvalidGenerationSource(
        'WebMCP domain actions must be public, non-static, non-generic '
        'instance methods and cannot be operators.',
        element: method,
      );
    }
    final String description = annotation.read('description').stringValue;
    if (description.trim().isEmpty) {
      throw InvalidGenerationSource(
        'WebMCP domain action descriptions cannot be empty.',
        element: method,
      );
    }
    final String? overrideName = annotation.peek('name')?.stringValue;
    final String toolName = overrideName ?? '${owner.name}.${method.name}';
    if (!RegExp(r'^[A-Za-z0-9_.-]{1,128}$').hasMatch(toolName)) {
      throw InvalidGenerationSource(
        'WebMCP tool name "$toolName" must match the registry name contract.',
        element: method,
      );
    }

    final List<_ExposedParameter> parameters = <_ExposedParameter>[];
    for (final FormalParameterElement parameter in method.formalParameters) {
      final String? name = parameter.name;
      if (name == null || name.isEmpty) {
        throw InvalidGenerationSource(
          'Every exposed parameter must have a source name.',
          element: parameter,
        );
      }
      parameters.add(
        _ExposedParameter(
          name: name,
          shape: _readShape(parameter.type, parameter),
          isNamed: parameter.isNamed,
          isRequired: parameter.isRequired,
          defaultValueCode: parameter.defaultValueCode,
        ),
      );
    }
    final _ReturnShape returnShape = _readReturnShape(
      method.returnType,
      method,
    );
    return _ExposedMethod(
      methodName: method.name!,
      toolName: toolName,
      description: description,
      readOnlyHint: annotation.read('readOnlyHint').boolValue,
      untrustedContentHint: annotation.read('untrustedContentHint').boolValue,
      consequentialHint: annotation.read('consequentialHint').boolValue,
      parameters: parameters,
      returnShape: returnShape,
    );
  }

  _ReturnShape _readReturnShape(DartType type, Element source) {
    if (type is VoidType) {
      return const _ReturnShape(isVoid: true, isFuture: false);
    }
    if (type is InterfaceType &&
        type.element.library.uri.toString() == 'dart:async' &&
        type.element.name == 'Future') {
      if (type.typeArguments.length != 1) {
        throw InvalidGenerationSource(
          'Raw Future return types are not supported.',
          element: source,
        );
      }
      final DartType valueType = type.typeArguments.single;
      if (valueType is VoidType) {
        return const _ReturnShape(isVoid: true, isFuture: true);
      }
      _readShape(valueType, source);
      return const _ReturnShape(isVoid: false, isFuture: true);
    }
    _readShape(type, source);
    return const _ReturnShape(isVoid: false, isFuture: false);
  }

  _TypeShape _readShape(DartType type, Element source) {
    final bool nullable = type.nullabilitySuffix == NullabilitySuffix.question;
    if (type is! InterfaceType) {
      throw InvalidGenerationSource(
        'Unsupported WebMCP type ${type.getDisplayString()}.',
        element: source,
      );
    }
    final String library = type.element.library.uri.toString();
    final String name = type.element.name!;
    if (library == 'dart:core') {
      if (name == 'String' || name == 'bool' || name == 'int') {
        return _TypeShape.scalar(name, nullable: nullable);
      }
      if (name == 'double') {
        return _TypeShape.scalar('double', nullable: nullable);
      }
      if (name == 'List' && type.typeArguments.length == 1) {
        return _TypeShape.list(
          _readShape(type.typeArguments.single, source),
          nullable: nullable,
        );
      }
      if (name == 'Map' && type.typeArguments.length == 2) {
        final _TypeShape key = _readShape(type.typeArguments.first, source);
        if (key.kind != _ShapeKind.string || key.nullable) {
          throw InvalidGenerationSource(
            'WebMCP maps require non-nullable String keys.',
            element: source,
          );
        }
        return _TypeShape.map(
          _readShape(type.typeArguments.last, source),
          nullable: nullable,
        );
      }
    }
    if (type.element is EnumElement && type.typeArguments.isEmpty) {
      final EnumElement enumElement = type.element as EnumElement;
      final String displayed = type.getDisplayString();
      final String enumType = nullable && displayed.endsWith('?')
          ? displayed.substring(0, displayed.length - 1)
          : displayed;
      return _TypeShape.enumeration(
        enumType,
        enumElement.constants
            .map((FieldElement field) => field.name)
            .whereType<String>()
            .toList(),
        nullable: nullable,
      );
    }
    throw InvalidGenerationSource(
      'Unsupported WebMCP type ${type.getDisplayString()}. Supported values '
      'are String, bool, safe int, finite double, enum, nullable forms, and '
      'recursive List or Map<String, T> collections.',
      element: source,
    );
  }

  void _emitClass(StringBuffer output, _ExposedClass type) {
    final String generatedName = '${type.name}WebMcpSource';
    for (
      int methodIndex = 0;
      methodIndex < type.methods.length;
      methodIndex++
    ) {
      final _ExposedMethod method = type.methods[methodIndex];
      for (
        int parameterIndex = 0;
        parameterIndex < method.parameters.length;
        parameterIndex++
      ) {
        _emitDecoder(
          output,
          method.parameters[parameterIndex].shape,
          '_\$decode${type.name}${methodIndex}P$parameterIndex',
        );
      }
    }
    output
      ..writeln(
        '/// Generated tools bound to one consumer-owned live instance.',
      )
      ..writeln(
        'final class $generatedName implements _webmcp.WebMcpToolSource {',
      )
      ..writeln('  /// Creates an adapter without constructing the service.')
      ..writeln('  const $generatedName(this.instance);')
      ..writeln()
      ..writeln('  /// The live service instance supplied by the consumer.')
      ..writeln('  final _input.${type.name} instance;')
      ..writeln()
      ..writeln('  @override')
      ..writeln(
        '  List<_webmcp.WebMcpTool> getWebMcpTools() => '
        '<_webmcp.WebMcpTool>[',
      );
    for (int index = 0; index < type.methods.length; index++) {
      final _ExposedMethod method = type.methods[index];
      output
        ..writeln('    _webmcp.WebMcpTool(')
        ..writeln('      name: ${jsonEncode(method.toolName)},')
        ..writeln('      description: ${jsonEncode(method.description)},')
        ..writeln('      inputSchema: ${_dartLiteral(_schemaFor(method))},')
        ..writeln('      annotations: const _webmcp.WebMcpToolAnnotations(')
        ..writeln('        readOnlyHint: ${method.readOnlyHint},')
        ..writeln(
          '        untrustedContentHint: ${method.untrustedContentHint},',
        )
        ..writeln('        consequentialHint: ${method.consequentialHint},')
        ..writeln('      ),')
        ..writeln('      handler: _invoke$index,')
        ..writeln('    ),');
    }
    output
      ..writeln('  ];')
      ..writeln();
    for (int index = 0; index < type.methods.length; index++) {
      _emitInvoker(output, type, type.methods[index], index);
    }
    output
      ..writeln('}')
      ..writeln();
  }

  void _emitInvoker(
    StringBuffer output,
    _ExposedClass owner,
    _ExposedMethod method,
    int methodIndex,
  ) {
    final Set<String> allowed = method.parameters
        .map((_ExposedParameter parameter) => parameter.name)
        .toSet();
    final String allowedLiteral =
        '<String>{${allowed.map(jsonEncode).join(', ')}}';
    output
      ..writeln(
        '  Object? _invoke$methodIndex(Map<String, Object?> arguments) {',
      )
      ..writeln('    try {')
      ..writeln('      _\$webMcpCheckKeys(arguments, $allowedLiteral);');

    final List<String> positional = <String>[];
    final List<String> named = <String>[];
    for (int index = 0; index < method.parameters.length; index++) {
      final _ExposedParameter parameter = method.parameters[index];
      final String decoder = '_\$decode${owner.name}${methodIndex}P$index';
      final String raw = parameter.isRequired
          ? '_\$webMcpRequired(arguments, ${jsonEncode(parameter.name)})'
          : "arguments[${jsonEncode(parameter.name)}]";
      String expression = '$decoder($raw)';
      if (!parameter.isRequired) {
        final String fallback =
            parameter.defaultValueCode ??
            (parameter.shape.nullable ? 'null' : '_\$webMcpInvalid()');
        expression =
            'arguments.containsKey(${jsonEncode(parameter.name)}) '
            '? $expression : $fallback';
      }
      if (parameter.isNamed) {
        named.add('${parameter.name}: $expression');
      } else {
        positional.add(expression);
      }
    }
    final String invocation =
        'instance.${method.methodName}('
        '${<String>[...positional, ...named].join(', ')})';
    if (method.returnShape.isFuture && method.returnShape.isVoid) {
      output.writeln('      return $invocation.then<Object?>((_) => null);');
    } else if (method.returnShape.isVoid) {
      output
        ..writeln('      $invocation;')
        ..writeln('      return null;');
    } else {
      output.writeln('      return $invocation;');
    }
    output
      ..writeln('    } on FormatException {')
      ..writeln('      return const <String, Object?>{')
      ..writeln("        'ok': false,")
      ..writeln("        'error': <String, Object?>{")
      ..writeln("          'code': 'invalidArguments',")
      ..writeln("          'retryable': false,")
      ..writeln('        },')
      ..writeln('      };')
      ..writeln('    }')
      ..writeln('  }')
      ..writeln();
  }

  void _emitDecoder(StringBuffer output, _TypeShape shape, String name) {
    final String childName = '${name}Item';
    if (shape.child != null) {
      _emitDecoder(output, shape.child!, childName);
    }
    output.writeln('${shape.typeCode} $name(Object? value) {');
    if (shape.nullable) {
      output.writeln('  if (value == null) return null;');
    } else {
      output.writeln('  if (value == null) _\$webMcpInvalid();');
    }
    switch (shape.kind) {
      case _ShapeKind.string:
        output
          ..writeln('  if (value is! String) _\$webMcpInvalid();')
          ..writeln('  return value;');
      case _ShapeKind.boolean:
        output
          ..writeln('  if (value is! bool) _\$webMcpInvalid();')
          ..writeln('  return value;');
      case _ShapeKind.integer:
        output
          ..writeln(
            '  if (value is! int || '
            'value < -9007199254740991 || value > 9007199254740991) {',
          )
          ..writeln('    _\$webMcpInvalid();')
          ..writeln('  }')
          ..writeln('  return value;');
      case _ShapeKind.doubleValue:
        output
          ..writeln('  if (value is! num) _\$webMcpInvalid();')
          ..writeln('  final double decoded = value.toDouble();')
          ..writeln('  if (!decoded.isFinite) _\$webMcpInvalid();')
          ..writeln('  return decoded;');
      case _ShapeKind.enumeration:
        output
          ..writeln('  if (value is! String) _\$webMcpInvalid();')
          ..writeln(
            '  for (final ${shape.baseTypeCode} item '
            'in ${shape.baseTypeCode}.values) {',
          )
          ..writeln('    if (item.name == value) return item;')
          ..writeln('  }')
          ..writeln('  _\$webMcpInvalid();');
      case _ShapeKind.list:
        output
          ..writeln('  if (value is! List<Object?>) _\$webMcpInvalid();')
          ..writeln('  return value.map($childName).toList(growable: false);');
      case _ShapeKind.map:
        output
          ..writeln(
            '  if (value is! Map<Object?, Object?>) _\$webMcpInvalid();',
          )
          ..writeln('  final result = <String, ${shape.child!.typeCode}>{};')
          ..writeln('  for (final entry in value.entries) {')
          ..writeln('    if (entry.key is! String) _\$webMcpInvalid();')
          ..writeln(
            '    result[entry.key! as String] = $childName(entry.value);',
          )
          ..writeln('  }')
          ..writeln('  return result;');
    }
    output
      ..writeln('}')
      ..writeln();
  }

  Map<String, Object?> _schemaFor(_ExposedMethod method) {
    final Map<String, Object?> properties = <String, Object?>{};
    final List<String> required = <String>[];
    for (final _ExposedParameter parameter in method.parameters) {
      properties[parameter.name] = parameter.shape.schema;
      if (parameter.isRequired) {
        required.add(parameter.name);
      }
    }
    return <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': properties,
      if (required.isNotEmpty) 'required': required,
    };
  }

  String _dartLiteral(Object? value) {
    if (value is Map<String, Object?>) {
      return '<String, Object?>{${value.entries.map((entry) {
        return '${jsonEncode(entry.key)}: ${_dartLiteral(entry.value)}';
      }).join(', ')}}';
    }
    if (value is List) {
      return '<Object?>[${value.map(_dartLiteral).join(', ')}]';
    }
    return jsonEncode(value);
  }
}

enum _ShapeKind {
  string,
  boolean,
  integer,
  doubleValue,
  enumeration,
  list,
  map,
}

final class _TypeShape {
  const _TypeShape._(
    this.kind,
    this.baseTypeCode, {
    required this.nullable,
    this.child,
    this.enumValues = const <String>[],
  });

  factory _TypeShape.scalar(String name, {required bool nullable}) {
    final _ShapeKind kind = switch (name) {
      'String' => _ShapeKind.string,
      'bool' => _ShapeKind.boolean,
      'int' => _ShapeKind.integer,
      'double' => _ShapeKind.doubleValue,
      _ => throw StateError('Unsupported scalar $name'),
    };
    return _TypeShape._(kind, name, nullable: nullable);
  }

  factory _TypeShape.enumeration(
    String type,
    List<String> values, {
    required bool nullable,
  }) => _TypeShape._(
    _ShapeKind.enumeration,
    '_input.$type',
    nullable: nullable,
    enumValues: values,
  );

  factory _TypeShape.list(_TypeShape child, {required bool nullable}) =>
      _TypeShape._(
        _ShapeKind.list,
        'List<${child.typeCode}>',
        nullable: nullable,
        child: child,
      );

  factory _TypeShape.map(_TypeShape child, {required bool nullable}) =>
      _TypeShape._(
        _ShapeKind.map,
        'Map<String, ${child.typeCode}>',
        nullable: nullable,
        child: child,
      );

  final _ShapeKind kind;
  final String baseTypeCode;
  final bool nullable;
  final _TypeShape? child;
  final List<String> enumValues;

  String get typeCode => nullable ? '$baseTypeCode?' : baseTypeCode;

  Map<String, Object?> get schema {
    final Map<String, Object?> nonNull = switch (kind) {
      _ShapeKind.string => <String, Object?>{'type': 'string'},
      _ShapeKind.boolean => <String, Object?>{'type': 'boolean'},
      _ShapeKind.integer => <String, Object?>{
        'type': 'integer',
        'minimum': -9007199254740991,
        'maximum': 9007199254740991,
      },
      _ShapeKind.doubleValue => <String, Object?>{'type': 'number'},
      _ShapeKind.enumeration => <String, Object?>{
        'type': 'string',
        'enum': enumValues,
      },
      _ShapeKind.list => <String, Object?>{
        'type': 'array',
        'items': child!.schema,
      },
      _ShapeKind.map => <String, Object?>{
        'type': 'object',
        'additionalProperties': child!.schema,
      },
    };
    if (!nullable) {
      return nonNull;
    }
    return <String, Object?>{
      'anyOf': <Object?>[
        nonNull,
        const <String, Object?>{'type': 'null'},
      ],
    };
  }
}

final class _ReturnShape {
  const _ReturnShape({required this.isVoid, required this.isFuture});

  final bool isVoid;
  final bool isFuture;
}

final class _ExposedParameter {
  const _ExposedParameter({
    required this.name,
    required this.shape,
    required this.isNamed,
    required this.isRequired,
    required this.defaultValueCode,
  });

  final String name;
  final _TypeShape shape;
  final bool isNamed;
  final bool isRequired;
  final String? defaultValueCode;
}

final class _ExposedMethod {
  const _ExposedMethod({
    required this.methodName,
    required this.toolName,
    required this.description,
    required this.readOnlyHint,
    required this.untrustedContentHint,
    required this.consequentialHint,
    required this.parameters,
    required this.returnShape,
  });

  final String methodName;
  final String toolName;
  final String description;
  final bool readOnlyHint;
  final bool untrustedContentHint;
  final bool consequentialHint;
  final List<_ExposedParameter> parameters;
  final _ReturnShape returnShape;
}

final class _ExposedClass {
  const _ExposedClass(this.name, this.methods);

  final String name;
  final List<_ExposedMethod> methods;
}
