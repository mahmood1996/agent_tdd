import 'package:config/config.dart';

class SampleConfig implements Config {
  @override
  V valueBy<V>(String key, V fallback) => fallback;

  @override
  Map<String, dynamic> toMap() => {};
}

void main() {
  final config = SampleConfig();
  print(config.valueBy('key', 'default'));
}
