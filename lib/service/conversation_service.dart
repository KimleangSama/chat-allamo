import 'package:chat_allamo/model/conversation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

enum Table { conversation }

class ConversationService {
  final Database _db;

  ConversationService(this._db);

  Future<void> saveConversation(Conversation conversation) async {
    await _db.insert(
      Table.conversation.name,
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> renameConversationTitle(Conversation conversation) async {
    await _db.update(
      Table.conversation.name,
      conversation.toMap(),
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  Future<void> deleteConversation(Conversation conversation) async {
    await _db.delete(
      Table.conversation.name,
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  Future<List<Conversation>> loadConversations() async {
    final rawConversations =
        await _db.query(Table.conversation.name, orderBy: 'lastUpdate DESC');
    return rawConversations.map(Conversation.fromMap).toList();
  }

  Future<void> deleteAllConversations() {
    return _db.delete(Table.conversation.name);
  }

  Future<void> toggleFavorite(Conversation conversation) {
    return _db.update(
      Table.conversation.name,
      conversation.toMap(),
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  Future<void> toggleArchive(Conversation toConversation) {
    return _db.update(
      Table.conversation.name,
      toConversation.toMap(),
      where: 'id = ?',
      whereArgs: [toConversation.id],
    );
  }
}
