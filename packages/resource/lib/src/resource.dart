abstract interface class Resource<Content> {
  Future<void> delete();

  Future<Content> content();

  Future<void> save(Content content);
}

final class ResourceNotFoundException implements Exception {
  ResourceNotFoundException([this.message = 'Resource not found']);

  final String message;

  @override
  String toString() => 'ResourceNotFoundException: $message';
}
