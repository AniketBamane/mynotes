import 'package:flutter/material.dart';
import 'package:mynotes/constant/constants.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/pages/homepage.dart';
import 'package:mynotes/pages/loginpage.dart';
import 'package:mynotes/pages/registerationpage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    routes: {
      loginRoute: (context) => const loginpage(),
      registerationRoute: (context) => const registerationpage(),
      verificationRoute: (context) => const verifyview(),
      notesRoute: (context) => const notesView(),
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
        future: AuthService.firebase().initialized(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return const notesView();
                } else {
                  return const loginpage();
                }
              } else {
                return const registerationpage();
              }
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
                  AuthService.firebase().sendEmailNotification();
                },
                child: Text('verify')),
            TextButton(
                onPressed: () {
                  AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      registerationRoute, (route) => false);
                },
                child: Text('restart'))
          ],
        ),
      ),
    );
  }
}
