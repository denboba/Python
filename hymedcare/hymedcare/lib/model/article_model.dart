import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String? summary;
  final String imageUrl;
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final List<String> categories;
  final List<String> likes;
  final int views;
  final int readTime;
  final DateTime createdAt;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    required this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.categories,
    required this.likes,
    required this.views,
    required this.readTime,
    required this.createdAt,
  });

  QuillController get contentController {
    try {
      final List<dynamic> jsonData = json.decode(content);
      return QuillController(
        document: Document.fromJson(jsonData),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // Fallback for plain text content
      return QuillController(
        document: Document()..insert(0, content),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  String get plainTextContent {
    try {
      final contentMap = json.decode(content);
      if (contentMap is List) {
        // Handle direct Delta format
        final doc = Document.fromJson(contentMap);
        return doc.toPlainText();
      } else if (contentMap is Map && contentMap.containsKey('ops')) {
        // Handle wrapped Delta format
        final doc = Document.fromJson(contentMap['ops']);
        return doc.toPlainText();
      } else if (contentMap is Map) {
        // Handle any other map format
        return contentMap.toString();
      }
      return content;
    } catch (e) {
      // If we can't parse the JSON, return the content as is
      return content;
    }
  }

  ArticleModel copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    String? imageUrl,
    String? authorId,
    String? authorName,
    String? authorImageUrl,
    List<String>? categories,
    List<String>? likes,
    int? views,
    int? readTime,
    DateTime? createdAt,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      categories: categories ?? List<String>.from(this.categories),
      likes: likes ?? List<String>.from(this.likes),
      views: views ?? this.views,
      readTime: readTime ?? this.readTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw Exception('Document does not exist');
    }

    final data = doc.data() as Map<String, dynamic>;
    if (data == null) {
      throw Exception('Document data is null');
    }

    try {
      // Handle different content formats
      final rawContent = data['content'];
      String contentString;
      
      if (rawContent is String) {
        // If content is already a string, use it directly
        contentString = rawContent;
      } else if (rawContent is List) {
        // If content is a Delta array
        contentString = json.encode({'ops': rawContent});
      } else if (rawContent is Map<String, dynamic>) {
        // If content is a Delta map
        contentString = json.encode(rawContent);
      } else {
        // Fallback for any other format
        contentString = rawContent.toString();
      }

      return ArticleModel(
        id: doc.id,
        title: data['title'] ?? '',
        content: contentString,
        summary: data['summary'],
        imageUrl: data['imageUrl'] ?? '',
        authorId: data['authorId'] ?? '',
        authorName: data['authorName'] ?? '',
        authorImageUrl: data['authorImageUrl'] ?? '',
        categories: List<String>.from(data['categories'] ?? []),
        likes: List<String>.from(data['likes'] ?? []),
        views: data['views']?.toInt() ?? 0,
        readTime: data['readTime']?.toInt() ?? 5,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Error creating ArticleModel from Firestore: $e');
      rethrow;
    }
  }

  factory ArticleModel.fromMap(Map<String, dynamic> map, String id) {
    return ArticleModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] is String 
          ? map['content'] 
          : json.encode(map['content']), // Handle both string and map content
      summary: map['summary'],
      imageUrl: map['imageUrl'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorImageUrl: map['authorImageUrl'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      likes: List<String>.from(map['likes'] ?? []),
      views: map['views']?.toInt() ?? 0,
      readTime: map['readTime']?.toInt() ?? 5,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'categories': categories,
      'likes': likes,
      'views': views,
      'readTime': readTime,
      'createdAt': Timestamp.fromDate(createdAt),
    };
    
    try {
      // Try to parse content as JSON
      final contentJson = json.decode(content);
      map['content'] = contentJson;
    } catch (e) {
      // If content is not valid JSON, store it as plain text
      map['content'] = {'ops': [{'insert': content}]};
    }

    if (summary != null) {
      map['summary'] = summary as String;
    }

    return map;
  }
}
