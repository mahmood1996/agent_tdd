import 'dart:io';
import 'package:path/path.dart' as p;

import '../domain/tdd_config.dart';

abstract interface class ConfigDetection {
  factory ConfigDetection() = _DefaultConfigDetection;

  Future<TddConfig> detectedConfig(String projectDir);
}

final class _DefaultConfigDetection implements ConfigDetection {
  _DefaultConfigDetection([TddConfig fallback = const TddConfig.dart()])
      : _decorator = _DartFlutterDetection(
          _CargoDetection(
            _GoDetection(
              _NodeDetection(
                _PythonDetection(
                  _FallbackDetection(fallback),
                ),
              ),
            ),
          ),
        );

  final ConfigDetection _decorator;

  @override
  Future<TddConfig> detectedConfig(
    String projectDir,
  ) =>
      _decorator.detectedConfig(projectDir);
}

final class _DartFlutterDetection implements ConfigDetection {
  const _DartFlutterDetection(this._next);

  final ConfigDetection _next;

  @override
  Future<TddConfig> detectedConfig(String projectDir) async {
    final pubspecFile = File(p.join(projectDir, 'pubspec.yaml'));
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();

      return (content.contains('sdk: flutter') || content.contains('flutter:'))
          ? const TddConfig.flutter()
          : const TddConfig.dart();
    }
    return _next.detectedConfig(projectDir);
  }
}

final class _CargoDetection implements ConfigDetection {
  const _CargoDetection(this._next);

  final ConfigDetection _next;

  @override
  Future<TddConfig> detectedConfig(String projectDir) async {
    if (await File(p.join(projectDir, 'Cargo.toml')).exists()) {
      return const TddConfig.cargo();
    }
    return _next.detectedConfig(projectDir);
  }
}

final class _GoDetection implements ConfigDetection {
  const _GoDetection(this._next);

  final ConfigDetection _next;

  @override
  Future<TddConfig> detectedConfig(String projectDir) async {
    if (await File(p.join(projectDir, 'go.mod')).exists()) {
      return const TddConfig.go();
    }
    return _next.detectedConfig(projectDir);
  }
}

final class _NodeDetection implements ConfigDetection {
  const _NodeDetection(this._next);

  final ConfigDetection _next;

  @override
  Future<TddConfig> detectedConfig(String projectDir) async {
    final pkgJsonFile = File(p.join(projectDir, 'package.json'));
    if (await pkgJsonFile.exists()) {
      final content = await pkgJsonFile.readAsString();

      return content.contains('vitest')
          ? const TddConfig.vitest()
          : const TddConfig.jest();
    }
    return _next.detectedConfig(projectDir);
  }
}

final class _PythonDetection implements ConfigDetection {
  const _PythonDetection(this._next);

  final ConfigDetection _next;

  @override
  Future<TddConfig> detectedConfig(String projectDir) async {
    if (await File(p.join(projectDir, 'pytest.ini')).exists() ||
        await File(p.join(projectDir, 'requirements.txt')).exists() ||
        await File(p.join(projectDir, 'pyproject.toml')).exists()) {
      return const TddConfig.pytest();
    }
    return _next.detectedConfig(projectDir);
  }
}

final class _FallbackDetection implements ConfigDetection {
  const _FallbackDetection([this._fallback = const TddConfig.dart()]);

  final TddConfig _fallback;

  @override
  Future<TddConfig> detectedConfig(String projectDir) async {
    return _fallback;
  }
}
