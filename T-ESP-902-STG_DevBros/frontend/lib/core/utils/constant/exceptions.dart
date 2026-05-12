class ServerException implements Exception {
  ServerException({
    this.message = 'Une erreur serveur est survenue.',
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() {
    return 'ServerException: $message (Status: $statusCode)';
  }
}

class CacheException implements Exception {
  CacheException({this.message = 'Une erreur de cache est survenue.'});

  final String message;

  @override
  String toString() {
    return 'CacheException: $message';
  }
}
