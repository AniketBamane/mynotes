import 'dart:async';

import 'package:mynotes/services/crud/constants.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NoteService {
  Database? _db;
  List<DatabaseNote> _notes = [];
  final _notesStreamController = StreamController<List<DatabaseNote>>();

  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance();
  factory NoteService() => _shared;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpened {
      //empty
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await findUser(email: email);
      return user;
    } on CouldNotFindUser {
      return await createUser(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDbIsOpen();
    final db = getDatabase();
    await getNote(id: note.id);
    final updatedCount = await db.update(noteTable, {
      contentColumn: text,
      isSyncWithCloudColumn: 0,
    });
    if (updatedCount == 0) {
      throw CouldNoteUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((notes) => notes.id == note.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = getDatabase();
    final results = await db.query(noteTable);
    return results.map((row) => DatabaseNote.fromrow(row));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = getDatabase();
    final results = await db.query(noteTable, where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromrow(results.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAll() async {
    await _ensureDbIsOpen();
    final db = getDatabase();
    final deletedCount = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deletedCount;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = getDatabase();
    final deletedCount =
        await db.delete(noteTable, where: 'id =?', whereArgs: [id]);
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser user}) async {
    await _ensureDbIsOpen();
    final db = getDatabase();
    final owner = await findUser(email: user.email);
    if (user != owner) {
      throw UserNotExists();
    }
    final text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: user.id,
      contentColumn: text,
      isSyncWithCloudColumn: 1,
    });
    final note = DatabaseNote(
        id: noteId, userId: user.id, content: text, isSyncWithCloud: true);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseUser> findUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = getDatabase();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw CouldNotFindUser();
    }
    return DatabaseUser.fromrow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = getDatabase();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final id = await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: id, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = getDatabase();
    final deletecount = await db
        .delete(userTable, where: 'email =?', whereArgs: [email.toLowerCase()]);
    if (deletecount == 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database getDatabase() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpened();
    } else {
      try {
        final docPath = await getApplicationCacheDirectory();
        final dbpath = join(docPath.path, dbName);
        final db = await openDatabase(dbpath);
        _db = db;
        // create user table
        await db.execute(createUserTable);
        // create note table
        await db.execute(createNoteTable);
        await _cacheNotes();
      } on MissingPlatformDirectoryException {
        throw UnableToGetDatabase();
      }
    }
  }
}

class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromrow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;
  @override
  String toString() => 'person : id = = $id and email = $email ';

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String content;
  final bool isSyncWithCloud;

  DatabaseNote(
      {required this.id,
      required this.userId,
      required this.content,
      required this.isSyncWithCloud});

  DatabaseNote.fromrow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        content = map[contentColumn] as String,
        isSyncWithCloud =
            (map[isSyncWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'note : id = $id, userid = $userId , content = $content , issyncwithcloud = $isSyncWithCloud ';

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
}

//function to greet user with good morning message
