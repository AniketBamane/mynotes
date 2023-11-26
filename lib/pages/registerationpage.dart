import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants.dart';
import 'package:mynotes/pages/loginpage.dart';

class registerationpage extends StatefulWidget {
  const registerationpage({super.key});

  @override
  State<registerationpage> createState() => _registerationpageState();
}

class _registerationpageState extends State<registerationpage> {
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
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email, password: password);
                    final user = FirebaseAuth.instance.currentUser;
                    user?.sendEmailVerification();
                    Navigator.of(context).pushNamed(verificationRoute);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'email-already-in-use') {
                      return errorScreen(context, e.code);
                    } else {
                      return errorScreen(context, e.code);
                    }
                  } catch (e) {
                    return errorScreen(context, e.toString());
                  }
                },
                child: Text('Register')),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: Text('have already registered ? login here?'))
          ],
        ),
      ),
    );
  }
}
