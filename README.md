# Parses a runtimeType.
I hope that you are aware that this is dangerous!
In other words, don't ever rely on this library to return something meaningful.
Consider using the "try..." methods as they will return null instead of throwing.
## Usage

A simple usage example:

```dart
import 'package:runtime_type_parser/runtime_type_parser.dart';

main() {
  final awesome = Object();
  final type = RuntimeType.tryFromType(awesome.runtimeType);
}
```
