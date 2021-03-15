import 'package:runtime_type_parser/runtime_type_parser.dart';
import 'package:test/test.dart';

class Simple {}

class Generics<T, U extends bool?> {}

Type getType<T>() => T;

void main() {
  test('simple class', () {
    final type = RuntimeType.fromType(Simple);
    expect(type, isA<ClassType>());
    type as ClassType;
    expect(type.name, 'Simple');
    expect(type.genericParameters, isEmpty);
    expect(type.isNullable, false);
  });

  test('generics', () {
    final type = RuntimeType.fromGeneric<
        Generics<Generics<String?, bool>?, bool>>();
    expect(type, isA<ClassType>());
    type as ClassType;
    expect(type.name, 'Generics');

    expect(type.genericParameters.length, 2);
    final firstGeneric = type.genericParameters[0];
    expect(firstGeneric, isA<ClassType>());
    firstGeneric as ClassType;
    expect(firstGeneric.isNullable, isTrue);
    expect(firstGeneric.name, 'Generics');

    expect(firstGeneric.genericParameters.length, 2);
    final firstNestedGeneric = firstGeneric.genericParameters[0];
    expect(firstNestedGeneric, isA<ClassType>());
    firstNestedGeneric as ClassType;
    expect(firstNestedGeneric.isNullable, isTrue);
    expect(firstNestedGeneric.name, 'String');
    expect(firstNestedGeneric.genericParameters, isEmpty);

    final secondNestedGeneric = firstGeneric.genericParameters[1];
    expect(secondNestedGeneric, isA<ClassType>());
    secondNestedGeneric as ClassType;
    expect(secondNestedGeneric.isNullable, isFalse);
    expect(secondNestedGeneric.name, 'bool');
    expect(secondNestedGeneric.genericParameters, isEmpty);

    final secondGeneric = type.genericParameters[1];
    expect(secondGeneric, isA<ClassType>());
    secondGeneric as ClassType;
    expect(secondGeneric.isNullable, isFalse);
    expect(secondGeneric.name, 'bool');
    expect(secondGeneric.genericParameters, isEmpty);

    expect(type.isNullable, false);
  });

  test('void callback', () {
    final type = RuntimeType.fromGeneric<void Function()>();
    expect(type, isA<FunctionType>());
    type as FunctionType;
    expect(type.args, isEmpty);
    expect(type.namedArgs, isEmpty);
    expect(type.positionalArgs, isEmpty);
    expect(type.returnType, isA<ClassType>());
    expect((type.returnType as ClassType).name, 'void');
  });
  test('void callback with one arg', () {
    final type = RuntimeType.fromGeneric<void Function(bool)>();
    expect(type, isA<FunctionType>());
    expect((type as FunctionType).positionalArgs, isEmpty);
    expect(type.namedArgs, isEmpty);
    expect(type.args.length, 1);
    expect((type.args[0] as ClassType).name, 'bool');
    expect((type.returnType as ClassType).name, 'void');
  });
  test('void callback with args', () {
    final type = RuntimeType.fromGeneric<void Function(bool, bool)>();
    expect(type, isA<FunctionType>());
    expect((type as FunctionType).positionalArgs, isEmpty);
    expect(type.namedArgs, isEmpty);
    expect(type.args.length, 2);
    expect((type.args[0] as ClassType).name, 'bool');
    expect((type.args[1] as ClassType).name, 'bool');
    expect((type.returnType as ClassType).name, 'void');
  });
  test('void callback with one positional arg', () {
    final type = RuntimeType.fromGeneric<void Function([bool])>();
    expect(type, isA<FunctionType>());
    expect((type as FunctionType).args, isEmpty);
    expect(type.namedArgs, isEmpty);
    expect(type.positionalArgs.length, 1);
    expect((type.positionalArgs[0] as ClassType).name, 'bool');
    expect((type.returnType as ClassType).name, 'void');
  });
  test('void callback with positional args', () {
    final type = RuntimeType.fromGeneric<void Function([bool, bool])>();
    expect(type, isA<FunctionType>());
    expect((type as FunctionType).args, isEmpty);
    expect(type.namedArgs, isEmpty);
    expect(type.positionalArgs.length, 2);
    expect((type.positionalArgs[0] as ClassType).name, 'bool');
    expect((type.positionalArgs[1] as ClassType).name, 'bool');
    expect((type.returnType as ClassType).name, 'void');
  });
  test('void callback with args and positional args', () {
    final type =
        RuntimeType.fromGeneric<void Function(String, [bool, bool])>();
    expect((type as FunctionType).args.length, 1);
    expect(type.namedArgs, isEmpty);
    expect(type.positionalArgs.length, 2);
    expect((type.positionalArgs[0] as ClassType).name, 'bool');
    expect((type.positionalArgs[1] as ClassType).name, 'bool');
    expect((type.returnType as ClassType).name, 'void');
  });
  test('nullable void callback with args and positional args', () {
    final type =
        RuntimeType.fromGeneric<void Function(String, [bool, bool])?>();
    expect((type as FunctionType).args.length, 1);
    expect(type.isNullable, isTrue);
    expect(type.namedArgs, isEmpty);
    expect(type.positionalArgs.length, 2);
    expect((type.positionalArgs[0] as ClassType).name, 'bool');
    expect((type.positionalArgs[1] as ClassType).name, 'bool');
    expect((type.returnType as ClassType).name, 'void');
  });
  test('void callback with one named arg', () {
    final type = RuntimeType.fromGeneric<void Function({bool a1})>();
    expect(type, isA<FunctionType>());
    expect((type as FunctionType).args, isEmpty);
    expect(type.positionalArgs, isEmpty);
    expect(type.namedArgs.length, 1);
    expect((type.namedArgs['a1'] as ClassType).name, 'bool');
    expect((type.returnType as ClassType).name, 'void');
  });
  test('void callback with named args', () {
    final type =
        RuntimeType.fromGeneric<void Function({bool a1, bool a2})>();
    expect(type, isA<FunctionType>());
    expect((type as FunctionType).args, isEmpty);
    expect(type.positionalArgs, isEmpty);
    expect(type.namedArgs.length, 2);
    expect((type.namedArgs['a1'] as ClassType).name, 'bool');
    expect((type.namedArgs['a2'] as ClassType).name, 'bool');
    expect((type.returnType as ClassType).name, 'void');
  });
  test('void callback with args and named args', () {
    final type = RuntimeType.fromGeneric<
        void Function(String, {bool a1, bool a2})>();
    expect((type as FunctionType).args.length, 1);
    expect(type.positionalArgs, isEmpty);
    expect(type.namedArgs.length, 2);
    expect((type.namedArgs['a1'] as ClassType).name, 'bool');
    expect((type.namedArgs['a2'] as ClassType).name, 'bool');
    expect((type.returnType as ClassType).name, 'void');
  });
}
