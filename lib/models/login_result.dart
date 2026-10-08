/// Representasi hasil login dari API.
class LoginResult {
  final bool success;
  final String? token;
  final String message;
  final int? retryAfterSeconds;
  final int statusCode;

  const LoginResult({
    required this.success,
    this.token,
    required this.message,
    this.retryAfterSeconds,
    required this.statusCode,
  });
}
