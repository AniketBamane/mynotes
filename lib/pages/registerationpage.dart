import 'package:flutter/material.dart';
import 'package:mynotes/constant/constants.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
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
                    await AuthService.firebase()
                        .register(email: email, password: password);
                    AuthService.firebase().sendEmailNotification();
                    Navigator.of(context).pushNamed(verificationRoute);
                  } on EmailAlreadyInUseException {
                    await errorWindow(context, 'email is already in use');
                  } on InvalidEmailException {
                    await errorWindow(context, 'the email is not valid  !');
                  } on WeakPasswordException {
                    await errorWindow(
                        context, 'password is too weak  ! , change it .');
                  } on GenericException {
                    await errorWindow(context, 'user registeration failed !');
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
