import '../../domain/models/readable_config.dart';

final class JsonConfig implements ReadableConfig {
  /// Creates a [JsonConfig] from a map.
  JsonConfig(this._map);

  final Map<String, dynamic> _map;

  @override
  V valueBy<V>(String key, V fallback) => switch (_map[key]) {
    final value when value is V => value,
    _ => fallback,
  };
}
