class ServerException implements Exception {
  final String? message;

  ServerException([this.message]);
}

class CacheException implements Exception {
  final String? message;

  CacheException([this.message]);
}

class BiometricException implements Exception {
  final String? message;

  BiometricException([this.message]);
}
