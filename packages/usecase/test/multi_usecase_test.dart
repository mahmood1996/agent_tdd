import 'package:test/test.dart';
import 'package:usecase/usecase.dart';

void main() {
  test('Multi Usecase calls each usecase', () async {
    int actionCounter = 0;

    final usecase = MultiUsecase([
      ActionUsecase(() async => actionCounter++),
      ActionUsecase(() async => actionCounter++),
    ]);

    expect(actionCounter, 0);

    await usecase();

    expect(actionCounter, 2);
  });
}
