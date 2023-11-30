const dbName = 'user_database.db';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const contentColumn = 'content';
const isSyncWithCloudColumn = 'is_sync_with_cloud';
const createUserTable = '''
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL UNIQUE,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';
const createNoteTable = '''
CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL UNIQUE,
	"user_id"	INTEGER NOT NULL,
	"content"	TEXT,
	"is_sync_with_cloud"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';
const userTable = 'user';
const noteTable = 'note';
