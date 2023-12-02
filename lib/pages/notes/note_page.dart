import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class notePage extends StatefulWidget {
  const notePage({super.key});

  @override
  State<notePage> createState() => _notePageState();
}

class _notePageState extends State<notePage> {
  DatabaseNote? _note;
  late TextEditingController _titleController;
  late TextEditingController _textController;
  late NoteService _noteService;
  String noteTitle = 'Your Note';

  Future<DatabaseNote> getOrCreateNote() async {
    final note = _note;
    if (note != null) {
      return note;
    } else {
      final email = AuthService.firebase().currentUser!.email!;
      final user = await _noteService.findUser(email: email);
      return await _noteService.createNote(user: user);
    }
  }

  void _deleteIfNoteIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _noteService.deleteNote(id: note.id);
    }
  }

  void _saveIfNoteIsNotEmpty() async {
    final note = _note;
    if (_textController.text.isNotEmpty && note != null) {
      await _noteService.updateNote(note: note, text: _textController.text);
    }
  }

  void _textEditingListener() async {
    final note = _note;
    if (note == null) {
      return;
    } else {
      await _noteService.updateNote(note: note, text: _textController.text);
    }
  }

  void _setupTextEditingController() {
    _textController.addListener(_textEditingListener);
    _textController.removeListener(_textEditingListener);
  }

  @override
  void initState() {
    _textController = TextEditingController();
    _titleController = TextEditingController();
    _noteService = NoteService();
    super.initState();
  }

  @override
  void dispose() {
    _saveIfNoteIsNotEmpty();
    _deleteIfNoteIsEmpty();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(noteTitle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.done),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  label: Text('title'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                  hintText: "enter your text here......",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
