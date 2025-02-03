import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/chat_constants.dart';

class ChatMessages {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  int type;

  ChatMessages(
      {required this.idFrom,
        required this.idTo,
        required this.timestamp,
        required this.content,
        required this.type});

  Map<String, dynamic> toJson() {
    return {
      ChatConstants.idFrom: idFrom,
      ChatConstants.idTo: idTo,
      ChatConstants.timestamp: timestamp,
      ChatConstants.content: content,
      ChatConstants.type: type,
    };
  }

  factory ChatMessages.fromDocument(DocumentSnapshot documentSnapshot) {
    String idFrom = documentSnapshot.get(ChatConstants.idFrom);
    String idTo = documentSnapshot.get(ChatConstants.idTo);
    String timestamp = documentSnapshot.get(ChatConstants.timestamp);
    String content = documentSnapshot.get(ChatConstants.content);
    int type = documentSnapshot.get(ChatConstants.type);

    return ChatMessages(
        idFrom: idFrom,
        idTo: idTo,
        timestamp: timestamp,
        content: content,
        type: type);
  }
}