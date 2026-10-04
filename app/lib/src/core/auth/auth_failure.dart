import 'package:babel_api_client/api.dart';

/// Why an authentication request failed, as shown to the user.
enum AuthFailure {
  invalidCredentials,
  emailTaken,
  wrongPassword,
  network,
  generic;

  static AuthFailure of(Object error) {
    if (error is! ApiException) return AuthFailure.generic;
    // The generated client wraps transport errors (offline, DNS, TLS) with an inner exception.
    if (error.innerException != null) return AuthFailure.network;
    return switch (error.code) {
      401 => AuthFailure.invalidCredentials,
      403 => AuthFailure.wrongPassword,
      409 => AuthFailure.emailTaken,
      _ => AuthFailure.generic,
    };
  }
}
