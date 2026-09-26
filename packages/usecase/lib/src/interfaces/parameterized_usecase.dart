abstract interface class ParameterizedUsecase<Result, Params> {
  Future<Result> call(Params params);
}
