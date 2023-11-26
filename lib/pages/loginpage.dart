import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/constants.dart';

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
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email, password: password);
                    // ignore: uske_build_context_synchronously
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                    // devtools.log(credential.toString());
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'invalid-credential') {
                      return errorScreen(context, 'credentials are invalid  !');
                    } else if (e.code == 'invalid-email') {
                      return errorScreen(context, 'email is invalid');
                    } else {
                      return errorScreen(context, e.code);
                    }
                  } catch (e) {
                    return errorScreen(context, e.toString());
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
