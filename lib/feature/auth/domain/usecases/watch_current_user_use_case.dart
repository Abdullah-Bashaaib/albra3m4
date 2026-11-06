import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class WatchCurrentUserUseCase {
  final AuthRepository repository;
  const WatchCurrentUserUseCase(this.repository);

  Stream<UserEntity?> call(String uid) => repository.watchCurrentUser(uid);
}
