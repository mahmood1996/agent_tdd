import 'dart:io';
import 'package:path/path.dart' as p;

import '../domain/tdd_config.dart';

abstract interface class ConfigDetection {
  factory ConfigDetection() = _DefaultConfigDetection;

  Future<TddConfig?> detectConfig(String projectDir);
}

final class _DefaultConfigDetection implements ConfigDetection {
  const _DefaultConfigDetection()
      : _chain = const _DetectionChain([
          _DartFlutterDetection(),
          _CargoDetection(),
          _GoDetection(),
          _NodeDetection(),
          _PythonDetection(),
          _FallbackDetection(),
        ]);

  final ConfigDetection _chain;

  @override
  Future<TddConfig?> detectConfig(
    String projectDir,
  ) =>
      _chain.detectConfig(projectDir);
}

final class _DetectionChain implements ConfigDetection {
  const _DetectionChain(this._detections);

  final List<ConfigDetection> _detections;

  @override
  Future<TddConfig?> detectConfig(String projectDir) async {
    for (final detection in _detections) {
      final config = await detection.detectConfig(projectDir);

      if (config != null) return config;
    }

    return null;
  }
}

final class _DartFlutterDetection implements ConfigDetection {
  const _DartFlutterDetection();

  @override
  Future<TddConfig?> detectConfig(String projectDir) async {
    final pubspecFile = File(p.join(projectDir, 'pubspec.yaml'));
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();

      return (content.contains('sdk: flutter') || content.contains('flutter:'))
          ? TddConfig.presets['flutter']!
          : TddConfig.presets['dart']!;
    }
    return null;
  }
}

final class _CargoDetection implements ConfigDetection {
  const _CargoDetection();

  @override
  Future<TddConfig?> detectConfig(String projectDir) async {
    if (await File(p.join(projectDir, 'Cargo.toml')).exists()) {
      return TddConfig.presets['cargo']!;
    }
    return null;
  }
}

final class _GoDetection implements ConfigDetection {
  const _GoDetection();

  @override
  Future<TddConfig?> detectConfig(String projectDir) async {
    if (await File(p.join(projectDir, 'go.mod')).exists()) {
      return TddConfig.presets['go']!;
    }
    return null;
  }
}

final class _NodeDetection implements ConfigDetection {
  const _NodeDetection();

  @override
  Future<TddConfig?> detectConfig(String projectDir) async {
    final pkgJsonFile = File(p.join(projectDir, 'package.json'));
    if (await pkgJsonFile.exists()) {
      final content = await pkgJsonFile.readAsString();

      return content.contains('vitest')
          ? TddConfig.presets['vitest']!
          : TddConfig.presets['jest']!;
    }
    return null;
  }
}

final class _PythonDetection implements ConfigDetection {
  const _PythonDetection();

  @override
  Future<TddConfig?> detectConfig(String projectDir) async {
    if (await File(p.join(projectDir, 'pytest.ini')).exists() ||
        await File(p.join(projectDir, 'requirements.txt')).exists() ||
        await File(p.join(projectDir, 'pyproject.toml')).exists()) {
      return TddConfig.presets['pytest']!;
    }
    return null;
  }
}

final class _FallbackDetection implements ConfigDetection {
  const _FallbackDetection();

  @override
  Future<TddConfig?> detectConfig(String projectDir) async {
    return TddConfig.presets['dart']!;
  }
}
