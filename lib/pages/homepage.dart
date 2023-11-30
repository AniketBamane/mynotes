import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:mynotes/constant/constants.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class notesView extends StatefulWidget {
  const notesView({super.key});

  @override
  State<notesView> createState() => _notesViewState();
}

enum menuitem {
  logout,
  signin,
  profile,
  notes,
}

class _notesViewState extends State<notesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const  Text('Notes'),
        actions: [
          PopupMenuButton<menuitem>(
            onSelected: (value) async {
              switch (value) {
                case menuitem.logout:
                  final shouldlogout = await logoutwindow(context);
                  devtools.log(shouldlogout.toString());
                  if(shouldlogout == true) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) =>false);
                  }
                case menuitem.signin:
                  break;
                case menuitem.profile:
                  break;
                case menuitem.notes:
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<menuitem>(
                value: menuitem.logout,
                child: Text('log out'),
              ),
              PopupMenuItem<menuitem>(
                value: menuitem.signin,
                child: Text('sign in'),
              ),
              PopupMenuItem<menuitem>(
                value: menuitem.profile,
                child: Text('profile'),
              ),
              PopupMenuItem<menuitem>(
                value: menuitem.notes,
                child: Text('notes'),
              ),
            ],
          )
        ],
      ),
      body: const Center(
        child: Text('no notes found !'),
      ),
    );
  }
}

Future<bool> logoutwindow(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('log out'),
            content: const Text('do you really want to log out !'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("log out"),
              ),
            ],
          )).then((value) => value ?? false);
}
