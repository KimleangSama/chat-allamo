import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const dbFileName = 'db.db';

enum Table { conversation }

/// sqlite DB abstraction
Future<Database> initDB() async {
  sqfliteFfiInit();
  databaseFactoryOrNull = databaseFactoryFfi;

  final documentsDirectory = await getApplicationDocumentsDirectory();
  final path = join(documentsDirectory.path, dbFileName);
  // deleteDatabase(path); // for testing purpose (remove this line in production)
  return openDatabase(path, onCreate: _createDb, version: 1);
}

Future<void> _createDb(Database db, [int? version]) => db.execute('''
CREATE TABLE IF NOT EXISTS ${Table.conversation.name}(
  id TEXT NOT NULL PRIMARY KEY,
  model TEXT NOT NULL,
  temperature REAL NOT NULL,
  lastUpdate TEXT NOT NULL,
  title TEXT NOT NULL,
  messages TEXT,
  isFavorite BOOLEAN DEFAULT FALSE,
  isArchived BOOLEAN DEFAULT FALSE
)
''');
