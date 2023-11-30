import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;
import 'package:mynotes/constant/constants.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                hintText: 'enter your email',
              ),
            ),
            TextField(
              controller: _password,
              keyboardType: TextInputType.number,
              autocorrect: false,
              obscureText: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: 'enter your password',
              ),
            ),
            TextButton(
                onPressed: () async {
                  try {
                    final email = _email.text;
                    final password = _password.text;
                    await AuthService.firebase()
                        .login(email: email, password: password);
                    final user = AuthService.firebase().currentUser;
                    if (user?.isEmailVerified ?? false) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute, (route) => false);
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          verificationRoute, (route) => false);
                    }
                  } on UserNotFoundEXception {
                    await errorWindow(context, 'user not found !');
                  } on WrongPasswordException {
                    await errorWindow(context, 'password is wrong !');
                  } on GenericException {
                    await errorWindow(context,
                        'authentication error, please check your credentials !');
                  }
                },
                child: Text('login')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      registerationRoute, (route) => false);
                },
                child: Text('have not registered? register here ? '))
          ],
        ),
      ),
    );
  }
}

Future<bool> errorWindow(BuildContext context, String message) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error !'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text('ok'),
        ),
      ],
    ),
  ).then((value) => value ?? true);
}
