import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:uuid/uuid.dart';

extension ModelExtensions on Model {
  DateTime? get lastUpdate =>
      modifiedAt == null ? null : DateTime.tryParse(modifiedAt!);

  String get formattedLastUpdate =>
      lastUpdate != null ? DateFormat('dd/MM/yyyy').format(lastUpdate!) : '';
}

class Conversation {
  final String id;

  final String model;

  final double temperature;

  final DateTime lastUpdate;

  String get formattedDate => DateFormat('dd/MM/yyyy').format(lastUpdate);

  final String title;

  final List<(String, String, String?, String)> messages;

  final bool isFavorite;

  final bool isArchived;

  Conversation({
    required this.lastUpdate,
    required this.model,
    required this.title,
    required this.messages,
    this.isFavorite = false,
    this.isArchived = false,
    this.temperature = 1.0,
    String? id,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'model': model,
        'temperature': temperature,
        'lastUpdate': lastUpdate.toIso8601String(),
        'title': title,
        'messages': jsonEncode(
          messages.map((e) => [e.$1, e.$2, e.$3, e.$4]).toList(),
        ),
        'isFavorite': isFavorite ? 1 : 0,
        'isArchived': isArchived ? 1 : 0,
      };

  factory Conversation.fromMap(Map<String, dynamic> data) {
    final messages = List.from(jsonDecode(data['messages']))
        .map((e) =>
            (e[0] as String, e[1] as String, e[2] as String?, e[3] as String))
        .toList();

    return Conversation(
      id: data['id'],
      model: data['model'],
      temperature: data['temperature'],
      lastUpdate: DateTime.parse(data['lastUpdate']),
      title: data['title'],
      messages: messages,
      isFavorite: data['isFavorite'] == 1,
      isArchived: data['isArchived'] == 1,
    );
  }

  Conversation copyWith({
    String? newTitle,
    String? newModel,
    List<(String, String, String?, String)>? newMessages,
  }) =>
      Conversation(
        id: id,
        model: newModel ?? model,
        lastUpdate: lastUpdate,
        title: newTitle ?? title,
        messages: newMessages ?? messages,
        isFavorite: isFavorite,
        isArchived: isArchived,
      );

  Conversation copyFavoriteWith({bool? isFavorite}) => Conversation(
        id: id,
        model: model,
        lastUpdate: lastUpdate,
        title: title,
        messages: messages,
        isFavorite: isFavorite ?? this.isFavorite,
        isArchived: isArchived,
      );

  Conversation copyIsArchivedWith({bool? isArchived}) => Conversation(
        id: id,
        model: model,
        lastUpdate: lastUpdate,
        title: title,
        messages: messages,
        isFavorite: isFavorite,
        isArchived: isArchived ?? this.isArchived,
      );

  void replaceMessageAt(int index, (String, String, String?, String) message) {
    messages.removeRange(index, messages.length);
    messages.add(message);
  }

  @override
  String toString() {
    return 'Conversation{id: $id, model: $model, temperature: $temperature, lastUpdate: $lastUpdate, title: $title, messages: $messages}';
  }
}
