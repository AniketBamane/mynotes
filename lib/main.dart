import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/pages/loginpage.dart';
import 'package:mynotes/pages/registerationpage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    routes: {
      '/login/': (context) => const loginpage(),
      '/register/': (context) => const registerationpage(),
      '/verification/': (context) => const verifyview(),
    },
    debugShowCheckedModeBanner: false,
    title: 'MyNotes',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: navigation(),
  ));
}

class navigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (user.emailVerified) {
                  print('the email is verified !');
                } else {
                  return const verifyview();
                }
              } else {
                return const loginpage();
              }
              return const Center(
                child: Icon(Icons.done),
              );
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

class verifyview extends StatefulWidget {
  const verifyview({super.key});

  @override
  State<verifyview> createState() => _verifyviewState();
}

class _verifyviewState extends State<verifyview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("verification"),
      ),
      body: Center(
        child: Column(
          children: [
            Text('please verify your email !'),
            TextButton(
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  user?.sendEmailVerification();
                },
                child: Text('verify'))
          ],
        ),
      ),
    );
  }
}
