/// Base exception for all Firebase-related errors in the auth feature.
abstract class FirebaseAppException implements Exception {
  final String message;
  const FirebaseAppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a [FirebaseAuthException] is caught (login, register, etc.).
class FirebaseAuthAppException extends FirebaseAppException {
  final String code;

  const FirebaseAuthAppException({required this.code, required String message})
    : super(message);
}

/// Thrown when a network-related Firebase error occurs.
class FirebaseNetworkAppException extends FirebaseAppException {
  const FirebaseNetworkAppException(super.message);
}

/// Thrown when a [FirebaseException] from Firestore is caught.
class FirebaseFirestoreAppException extends FirebaseAppException {
  final String code;

  const FirebaseFirestoreAppException({
    required this.code,
    required String message,
  }) : super(message);
}
