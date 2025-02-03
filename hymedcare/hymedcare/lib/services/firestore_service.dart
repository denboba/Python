import 'package:firebase_database/firebase_database.dart';

class FirestoreService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<bool> getUserOnlineStatus(String userId) async {
    final snapshot = await _database.child('users/$userId/online').get();
    if (snapshot.exists) {
      return snapshot.value as bool;
    }
    return false;
  }

  Future<void> setUserOnline(String userId) async {
    await _database.child('users/$userId').update({'online': true});
  }

  Future<void> enterChatRoom(String userId) async {
    await setUserOnline(userId);
    // Additional logic for entering chat room...
  }

  Future<void> leaveChatRoom(String userId) async {
    await _database.child('users/$userId').update({'online': false});
    // Additional logic for leaving chat room...
  }
}