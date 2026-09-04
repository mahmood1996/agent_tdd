import 'base_presenter.dart';

final class FallbackPresenter extends BasePresenter {
  const FallbackPresenter();

  void renderUnknownCommand(String command, String phase) {
    final msg =
        'Unknown command: "$command". Available commands: init, specs, next, verify-red, verify-green, verify-refactor, complete, status, reset.';
    renderError(message: msg, phase: phase);
  }
}
