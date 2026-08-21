import '../../../../core/errors/exceptions.dart';

abstract class FirebaseAppException extends BaseException {
   FirebaseAppException(super.message);
}

class FirebaseAuthAppException extends FirebaseAppException {
  final String code;

   FirebaseAuthAppException({required this.code, required String message})
    : super(message);
}

class FirebaseFirestoreAppException extends FirebaseAppException {
  final String code;

   FirebaseFirestoreAppException({
    required this.code,
    required String message,
  }) : super(message);
}

class FirebaseNetworkAppException extends FirebaseAppException {
   FirebaseNetworkAppException(super.message);
}
