const _runningInNullSafeMode = <Object?>[] is! List<Object>;

/// A representation of a Type emitted from [runtimeType]
abstract class RuntimeType {
  RuntimeType(bool isNullable)
      : isNullable = isNullable || !_runningInNullSafeMode;
  bool isNullable;

  static RuntimeType fromGeneric<T>() {
    return fromType(T);
  }

  static RuntimeType fromType(Type t) {
    return fromString(t.toString());
  }

  static RuntimeType fromString(String type) {
    return _RuntimeTypeParser(type).parseRuntimeType();
  }

  static RuntimeType? tryFromGeneric<T>() {
    return tryFromType(T);
  }

  static RuntimeType? tryFromType(Type t) {
    return tryFromString(t.toString());
  }

  static RuntimeType? tryFromString(String type) {
    try {
      return _RuntimeTypeParser(type).parseRuntimeType();
    } catch (_) {
      return null;
    }
  }
}

/// A representation of an ordinary class
class ClassType extends RuntimeType {
  ClassType(this.name, this.genericParameters, bool isNullable)
      : super(isNullable);
  String name;
  List<RuntimeType> genericParameters;
}

/// A representation of a callback
class FunctionType extends RuntimeType {
  FunctionType(
    this.returnType,
    this.args,
    this.positionalArgs,
    this.namedArgs,
    bool isNullable,
  ) : super(isNullable);

  List<RuntimeType> args;
  List<RuntimeType> positionalArgs;
  Map<String, RuntimeType> namedArgs;
  RuntimeType returnType;
}

/// Parses the representation emitted from [runtimeType]
class _RuntimeTypeParser {
  _RuntimeTypeParser(this.source);

  final String source;
  int position = 0;

  String? get current {
    if (source.length > position) {
      return source[position];
    }
    return null;
  }

  RuntimeType parseRuntimeType() {
    if (current == '(') {
      return parseFunction();
    } else {
      return parseClass();
    }
  }

  FunctionType parseFunction() {
    position++;
    final args = <RuntimeType>[];
    var positionalArgs = <RuntimeType>[];
    var namedArgs = <String, RuntimeType>{};
    if (current != ')') {
      while (true) {
        switch (current) {
          case '[':
            positionalArgs = parsePositionalFunctionArgs();
            break;
          case '{':
            namedArgs = parseNamedFunctionArgs();
            break;
          default:
            args.add(parseRuntimeType());
            break;
        }
        if (current == ')') {
          position++;
          break;
        } else {
          position += 2;
        }
      }
    } else {
      position++;
    }
    if (current == '?') {
      // ((String, [bool, bool]) => void)?
      // we were parsing "((String, [bool, bool]) => void)" as an argument,
      // but it is a nullable callback
      position++;
      return (args[0]..isNullable = true) as FunctionType;
    }

    position += 4;
    final returnType = parseRuntimeType();
    return FunctionType(returnType, args, positionalArgs, namedArgs, false);
  }

  List<RuntimeType> parsePositionalFunctionArgs() {
    position++;
    final args = <RuntimeType>[];
    while (true) {
      args.add(parseRuntimeType());
      if (current == ']') {
        position++;
        break;
      }
      position += 2;
    }
    assert(args.isNotEmpty);
    return args;
  }

  Map<String, RuntimeType> parseNamedFunctionArgs() {
    position++;
    final args = <String, RuntimeType>{};
    while (true) {
      final type = parseRuntimeType();
      position++;
      final name = parseIdentifier();
      args[name] = type;
      if (current == '}') {
        position++;
        break;
      }
      position += 2;
    }
    assert(args.isNotEmpty);
    return args;
  }

  ClassType parseClass() {
    final name = parseIdentifier();
    final generics = parseGenerics();
    final isNullable = parseNullable();
    return ClassType(name, generics, isNullable);
  }

  String parseIdentifier() {
    var endIndex = source.indexOf(RegExp(r'[\]<>)?,} ]'), position);
    if (endIndex == -1) {
      endIndex = source.length;
    }
    final name = source.substring(position, endIndex);
    position = endIndex;
    return name;
  }

  bool parseNullable() {
    if (current == '?') {
      position++;
      return true;
    }
    return false;
  }

  List<RuntimeType> parseGenerics() {
    if (current != '<') {
      return [];
    }
    position++;
    final generics = <RuntimeType>[];
    while (true) {
      generics.add(parseRuntimeType());
      if (current == '>') {
        position++;
        break;
      }
      position += 2;
    }
    return generics;
  }
}
