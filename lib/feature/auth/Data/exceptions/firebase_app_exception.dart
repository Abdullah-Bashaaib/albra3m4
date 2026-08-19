import '../../../../core/errors/exceptions.dart';

abstract class FirebaseAppException extends AppException {
  const FirebaseAppException(super.message);
}

class FirebaseAuthAppException extends FirebaseAppException {
  final String code;

  const FirebaseAuthAppException({required this.code, required String message})
    : super(message);
}

class FirebaseFirestoreAppException extends FirebaseAppException {
  final String code;

  const FirebaseFirestoreAppException({
    required this.code,
    required String message,
  }) : super(message);
}

class FirebaseNetworkAppException extends FirebaseAppException {
  const FirebaseNetworkAppException(super.message);
}
