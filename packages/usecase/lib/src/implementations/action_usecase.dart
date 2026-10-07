import 'package:usecase/src/interfaces/usecase.dart';

final class ActionUsecase implements Usecase<void> {
  ActionUsecase(this._action);

  final Future<void> Function() _action;

  @override
  Future<void> call() async => await _action();
}
