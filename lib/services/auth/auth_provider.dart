import 'package:mynotes/services/auth/auth_user.dart';

abstract class  AuthProviderr {
  AuthUser? get currentUser;
  Future<AuthUser> register({
    required String email,
    required String password,
  });
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  Future<void> initialized();
  Future<void> logOut();
  Future<void> sendEmailNotification();
}
