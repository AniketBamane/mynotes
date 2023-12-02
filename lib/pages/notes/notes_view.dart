import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:mynotes/constant/constants.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

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
  late final NoteService _noteService;
  final user = AuthService.firebase().currentUser!.email!;
  @override
  void initState() {
    _noteService = NoteService();
    super.initState();
  }

  @override
  void dispose() {
    _noteService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(notePageRoute);
              },
              icon: Icon(Icons.add)),
          PopupMenuButton<menuitem>(
            onSelected: (value) async {
              switch (value) {
                case menuitem.logout:
                  final shouldlogout = await logoutwindow(context);
                  devtools.log(shouldlogout.toString());
                  if (shouldlogout == true) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
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
          ),
        ],
      ),
      body: FutureBuilder(
        future: _noteService.getOrCreateUser(email: user),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _noteService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const Text('waiting for all notes.....');
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
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
