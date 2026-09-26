import '../interfaces/usecase.dart';

final class MultiUsecase implements Usecase<void> {
  const MultiUsecase(this._usecases);

  final Iterable<Usecase<void>> _usecases;

  @override
  Future<void> call() async {
    for (final usecase in _usecases) {
      await usecase();
    }
  }
}
