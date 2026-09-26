abstract interface class Usecase<Result> {
  Future<Result> call();
}
