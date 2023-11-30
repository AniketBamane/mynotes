import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProviderr {
  final AuthProviderr provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());
  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> initialized() {
    return provider.initialized();
  }

  @override
  Future<void> logOut() {
    return provider.logOut();
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    return provider.login(email: email, password: password);
  }

  @override
  Future<AuthUser> register({required String email, required String password}) {
    return provider.register(email: email, password: password);
  }

  @override
  Future<void> sendEmailNotification() {
    return provider.sendEmailNotification();
  }
}
