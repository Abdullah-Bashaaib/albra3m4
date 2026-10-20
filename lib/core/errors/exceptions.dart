import 'package:albra3m4/core/messages.dart';

abstract class BaseException implements Exception {
  final String message;

  BaseException([this.message = error]);
}

class ServerException extends BaseException {
  ServerException(dynamic e) : super(e.toString());
}

class OfflineException extends BaseException {
  OfflineException([dynamic e])
    : super(e?.toString() ?? 'No Internet Connection');
}

class LocalException extends BaseException {
  LocalException([dynamic e]) : super(e?.toString() ?? 'Local Error');
}

class NonUserException extends BaseException {
  NonUserException([dynamic e]) : super(e?.toString() ?? 'User does not exist');
}

class EmptyLocalDatabaseException extends BaseException {
  EmptyLocalDatabaseException([dynamic e])
    : super(e?.toString() ?? 'Local database is empty');
}

class FirebaseException extends BaseException {
  FirebaseException(dynamic e) : super(e.toString());
}
