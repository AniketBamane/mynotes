import 'package:mynotes/services/crud/constants.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';



class NoteService {
  Database? _db;
  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    final db = getDatabase();
    await getNote(id: note.id);
    final updatedCount = await db.update(noteTable, {
      contentColumn: text,
      isSyncWithCloudColumn: 0,
    });
    if (updatedCount == 0) {
      throw CouldNoteUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = getDatabase();
    final results = await db.query(noteTable);
    return results.map((row) => DatabaseNote.fromrow(row));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = getDatabase();
    final results = await db.query(noteTable, where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromrow(results.first);
    }
  }

  Future<int> deleteAll() async {
    final db = getDatabase();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = getDatabase();
    final deletedCount =
        await db.delete(noteTable, where: 'id =?', whereArgs: [id]);
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> addNote({required DatabaseUser user}) async {
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
    return DatabaseNote(
        id: noteId, userId: user.id, content: text, isSyncWithCloud: true);
  }

  Future<DatabaseUser> findUser({required String email}) async {
    final db = getDatabase();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw CouldNotFindUser();
    }
    return DatabaseUser.fromrow(results.first);
  }

  Future<DatabaseUser> addUser({required String email}) async {
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
