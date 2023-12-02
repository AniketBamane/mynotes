import 'package:flutter/material.dart';

const loginRoute = '/login/';
const registerationRoute = '/register/';
const verificationRoute = '/verification/';
const notesRoute = '/notesView/';
const notePageRoute = '/notePage/';

Future<void> errorScreen(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('error occured !'),
      content: Text(text),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('ok'))
      ],
    ),
  );
}
