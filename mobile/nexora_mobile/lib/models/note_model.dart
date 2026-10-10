import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';

enum VisibilityLevel { private, shared, partnerVisible }

class NoteModel {
  final String id;
  final String title;
  final String content;
  final bool isPinned;
  final VisibilityLevel visibility;
  final bool isArchived;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.visibility,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isPinned: json['isPinned'] as bool,
      visibility: VisibilityLevel.values[json['visibility'] as int],
      isArchived: json['isArchived'] as bool,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: DateTime.parse(json['updatedAtUtc'] as String),
    );
  }
}
