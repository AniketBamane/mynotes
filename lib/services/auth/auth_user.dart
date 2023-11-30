import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

@immutable
class AuthUser {
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified);

  factory AuthUser.firebase(User user) => AuthUser(user.emailVerified);
}
