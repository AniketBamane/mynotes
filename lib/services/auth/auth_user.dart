import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({this.email,required this.isEmailVerified});

  factory AuthUser.firebase(User user) => AuthUser(email:user.email,isEmailVerified: user.emailVerified);
}
