import 'package:test/test.dart';
import 'package:usecase/usecase.dart';

void main() {
  test('Multi Usecase calls each usecase', () async {
    int actionCounter = 0;

    final usecase = MultiUsecase([
      _Usecase(() async => actionCounter++),
      _Usecase(() async => actionCounter++),
    ]);

    expect(actionCounter, 0);

    await usecase();

    expect(actionCounter, 2);
  });
}

final class _Usecase implements Usecase<void> {
  const _Usecase(this._action);

  final Future<void> Function() _action;

  @override
  Future<void> call() async => _action();
}
