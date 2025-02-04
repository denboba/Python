// import 'package:firebase_database/firebase_database.dart';
//
// class FirestoreService {
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//
//   Future<bool> getUserOnlineStatus(String userId) async {
//     final snapshot = await _database.child('users/$userId/online').get();
//     if (snapshot.exists) {
//       return snapshot.value as bool;
//     }
//     return false;
//   }
//
//   Future<void> setUserOnline(String userId) async {
//     await _database.child('users/$userId').update({'online': true});
//   }
//
//   Future<void> enterChatRoom(String userId) async {
//     await setUserOnline(userId);
//     // Additional logic for entering chat room...
//   }
//
//   Future<void> leaveChatRoom(String userId) async {
//     await _database.child('users/$userId').update({'online': false});
//     // Additional logic for leaving chat room...
//   }
// }

// lib/services/firestore_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class FirestoreService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  StreamSubscription? _connectionSub;
  // ... existing methods ...

  Future<void> enterChatRoom(String userId) async {
    try {
      final userStatusRef = _database.child('status/$userId');
      final lastOnlineRef = _database.child('lastOnline/$userId');

      // Set user as online
      await userStatusRef.set(true);

      // Setup onDisconnect hooks
      await userStatusRef.onDisconnect().set(false);
      await lastOnlineRef.onDisconnect().set(ServerValue.timestamp);
    } catch (e) {
      print('Error entering chat room: $e');
      rethrow;
    }
  }

  Future<void> leaveChatRoom(String userId) async {
    try {
      final userStatusRef = _database.child('status/$userId');
      final lastOnlineRef = _database.child('lastOnline/$userId');

      // Set user as offline
      await userStatusRef.set(false);
      await lastOnlineRef.set(ServerValue.timestamp);

      // Remove onDisconnect hooks
      await userStatusRef.onDisconnect().cancel();
      await lastOnlineRef.onDisconnect().cancel();
    } catch (e) {
      print('Error leaving chat room: $e');
      rethrow;
    }
  }
  Future<void> initUserPresence(String userId) async {
    // Reference to user's status
    final userStatusRef = _database.child('status/$userId');
    final lastOnlineRef = _database.child('lastOnline/$userId');

    // Special '.info/connected' reference
    final connectedRef = _database.child('.info/connected');

    _connectionSub = connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value as bool? ?? false;
      if (!connected) return;

      // When user disconnects, update status and last online
      await userStatusRef.onDisconnect().set(false);
      await lastOnlineRef.onDisconnect().set(ServerValue.timestamp);

      // Set user as online
      await userStatusRef.set(true);
    });
  }

  Future<void> cleanupPresence(String userId) async {
    await _connectionSub?.cancel();
    await _database.child('status/$userId').set(false);
    await _database.child('lastOnline/$userId').set(ServerValue.timestamp);
  }

  Stream<DatabaseEvent> getUserPresenceStream(String userId) {
    return _database.child('status/$userId').onValue;
  }

  Future<void> setUserTyping(String userId, String chatRoomId, bool isTyping) async {
    await _database.child('typing/$chatRoomId/$userId').set(isTyping);
  }

  Stream<DatabaseEvent> getTypingStream(String chatRoomId, String userId) {
    return _database.child('typing/$chatRoomId/$userId').onValue;
  }
  Future<bool> isUserOnline(String userId) async {
    final snapshot = await _database.child('status/$userId').get();
    if (snapshot.exists) {
      return snapshot.value as bool;
    }
    return false;
  }


}