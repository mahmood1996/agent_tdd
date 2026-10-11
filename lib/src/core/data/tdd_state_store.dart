import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:resource/resource.dart';
import '../domain/tdd_state.dart';

abstract interface class TddStateStore {
  factory TddStateStore({
    required String projectDir,
    Resource<dynamic>? resource,
  }) = _FileTddStateStore;

  Future<TddState> currentState();

  Future<void> save(TddState state);

  Future<void> reset();
}

final class _FileTddStateStore implements TddStateStore {
  _FileTddStateStore({
    required String projectDir,
    Resource<dynamic>? resource,
  }) : _resource = resource ??
            JsonResource(File(p.join(projectDir, TddState.stateFileName)));

  final Resource<dynamic> _resource;

  @override
  Future<TddState> currentState() async {
    try {
      return await _tryLoadSavedState();
    } catch (_) {
      return TddState.idle();
    }
  }

  Future<TddState> _tryLoadSavedState() async =>
      switch (await _resource.content()) {
        final Map json => TddState.fromJson(Map<String, dynamic>.from(json)),
        _ => TddState.idle(),
      };

  @override
  Future<void> save(TddState state) async =>
      await _resource.save(state.toJson());

  @override
  Future<void> reset() async => await _resource.delete();
}
