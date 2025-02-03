import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hymedcare/services/firestore_service.dart';

class ChatRoomProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  final _imagePicker = ImagePicker();
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentRoomId;
  bool _isRecording = false;
  bool _isPaused = false;
  String? _recordingPath;
  bool _isInChatRoom = false;
  String? _currentUserId;

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;

  void setInChatRoom(bool value, String userId) {
    if (_isInChatRoom != value) {
      _isInChatRoom = value;
      _currentUserId = userId;
      if (value) {
        _firestoreService.enterChatRoom(userId);
      } else {
        _firestoreService.leaveChatRoom(userId);
      }
      notifyListeners();
    }
  }

  Stream<DocumentSnapshot> listenToChatRoom(String chatId) {
    return _firestore.collection('chatrooms').doc(chatId).snapshots();
  }

  Future<String> createOrGetChatRoom(String senderId, String receiverId) async {
    if (senderId.isEmpty || receiverId.isEmpty) {
      throw ArgumentError('Sender ID and Receiver ID cannot be empty');
    }
    
    try {
      final chatRoomRef = _firestore.collection('chatrooms');
      
      // Query for existing chat room
      final existingChatRooms = await chatRoomRef
          .where('participants', arrayContains: senderId)
          .get();

      // Check all rooms where sender is a participant
      for (var doc in existingChatRooms.docs) {
        List<dynamic> participants = doc.data()['participants'] as List<dynamic>;
        if (participants.contains(receiverId)) {
          _currentRoomId = doc.id;
          notifyListeners();
          return doc.id;
        }
      }

      // If no existing chat room found, create a new one
      final newChatRoom = await chatRoomRef.add({
        'participants': [senderId, receiverId],
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'last_message': '',
        'last_message_time': DateTime.now().millisecondsSinceEpoch,
        'unread_count': {
          senderId: 0,
          receiverId: 0,
        },
        'last_message_status': 'sent',
      });

      _currentRoomId = newChatRoom.id;
      notifyListeners();
      return newChatRoom.id;
    } catch (e) {
      debugPrint("Error in createOrGetChatRoom: $e");
      return '';
    }
  }

  Stream<QuerySnapshot> getChatRooms(String userId) {
    try {
      return _firestore
          .collection('chatrooms')
          .where('participants', arrayContains: userId)
          .orderBy('last_message_time', descending: true)
          .snapshots();
    } catch (e) {
      debugPrint('Error in getChatRooms: $e');
      return _firestore
          .collection('chatrooms')
          .where('participants', arrayContains: userId)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    if (chatId.isEmpty) return Stream.empty();
    try {
      return _firestore
          .collection('chatrooms')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      debugPrint("Error in getMessages: $e");
      return const Stream.empty();
    }
  }

  Future<void> markMessageAsRead(String chatId, String userId) async {
    try {
      final chatDoc = await _firestore.collection('chatrooms').doc(chatId).get();
      if (!chatDoc.exists) return;

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final unreadCount = Map<String, dynamic>.from(chatData['unread_count'] ?? {});
      final participants = List<String>.from(chatData['participants'] ?? {});

      final otherUserId = participants.firstWhere((id) => id != userId, orElse: () => '');

      // Reset unread count for current user
      if (unreadCount[userId] != 0) {
        unreadCount[userId] = 0;
        await _firestore.collection('chatrooms').doc(chatId).update({
          'unread_count': unreadCount,
        });
      }

      // Only mark messages as delivered if we're online
      final batch = _firestore.batch();
      final messagesQuery = await _firestore
          .collection('chatrooms')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('status', isEqualTo: 'seen')
          .get();

      for (var doc in messagesQuery.docs) {
        batch.update(doc.reference, {'status': 'delivered'});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String chatId, String senderId, String message) async {
    if (chatId.isEmpty || message.trim().isEmpty) return;

    try {
      final chatDoc = await _firestore.collection('chatrooms').doc(chatId).get();
      if (!chatDoc.exists) return;

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final participants = List<String>.from(chatData['participants'] ?? {});
      final receiverId = participants.firstWhere((id) => id != senderId, orElse: () => '');

      // Get receiver's online status and current chat
      final receiverDoc = await _firestore.collection('users').doc(receiverId).get();
      final receiverData = receiverDoc.data();
      final isReceiverInChat = receiverData?['current_chat_id'] == chatId;
      final isReceiverOnline = receiverData?['online'] ?? false;

      // Always start with 'sent' status
      String messageStatus = 'sent';
      if (isReceiverOnline) {
        messageStatus = 'delivered';
      }

      // Update unread count for receiver
      final unreadCount = Map<String, dynamic>.from(chatData['unread_count'] ?? {});
      unreadCount[receiverId] = (unreadCount[receiverId] ?? 0) + 1;

      // Create message document
      final messageRef = _firestore
          .collection('chatrooms')
          .doc(chatId)
          .collection('messages')
          .doc();

      final messageData = {
        'messageId': messageRef.id,
        'senderId': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': messageStatus,
        'type': 'text'
      };

      // Update both message and chat room in a batch
      final batch = _firestore.batch();
      batch.set(messageRef, messageData);
      batch.update(_firestore.collection('chatrooms').doc(chatId), {
        'last_message': message,
        'last_message_time': FieldValue.serverTimestamp(),
        'last_message_sender': senderId,
        'last_message_status': messageStatus,
        'unread_count': unreadCount,
      });

      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> updateMessageStatus(String chatId, String userId, bool entering) async {
    try {
      if (entering) {
        // When entering chat, mark delivered messages as seen
        final batch = _firestore.batch();
        final messagesQuery = await _firestore
            .collection('chatrooms')
            .doc(chatId)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('status', isEqualTo: 'delivered')
            .get();

        for (var doc in messagesQuery.docs) {
          batch.update(doc.reference, {'status': 'seen'});
        }

        if (messagesQuery.docs.isNotEmpty) {
          await batch.commit();
        }
      } else {
        // When leaving chat, mark seen messages as delivered
        final batch = _firestore.batch();
        final messagesQuery = await _firestore
            .collection('chatrooms')
            .doc(chatId)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('status', isEqualTo: 'seen')
            .get();

        for (var doc in messagesQuery.docs) {
          batch.update(doc.reference, {'status': 'delivered'});
        }

        if (messagesQuery.docs.isNotEmpty) {
          await batch.commit();
        }
      }
    } catch (e) {
      print('Error updating message status: $e');
      rethrow;
    }
  }

  Future<void> updateUserChatState(String userId, String? chatId) async {
    try {
      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(userId);
      
      // Get current chat ID before updating
      final userDoc = await userRef.get();
      final currentChatId = userDoc.data()?['current_chat_id'];

      if (chatId == null && currentChatId != null) {
        // User is leaving chat, update message status
        await updateMessageStatus(currentChatId, userId, false);
      }

      // Update user state
      batch.update(userRef, {
        'current_chat_id': chatId,
        'online': true,
        'last_seen': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (chatId != null) {
        // User is entering chat, update message status
        await updateMessageStatus(chatId, userId, true);
      }
    } catch (e) {
      print('Error updating user chat state: $e');
      rethrow;
    }
  }

  Future<void> startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        debugPrint('Microphone permission not granted');
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        // Use the application documents directory for recording
        final directory = await getApplicationDocumentsDirectory();
        final String path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _recordingPath = path;
        
        // Start recording with the generated path
        await _audioRecorder.start(path: path);
        _isRecording = true;
        _isPaused = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;
      
      final path = await _audioRecorder.stop();
      _isRecording = false;
      _isPaused = false;
      notifyListeners();
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      _isPaused = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _audioRecorder.pause();
      _isPaused = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing recording: $e');
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _audioRecorder.resume();
      _isPaused = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resuming recording: $e');
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _audioRecorder.stop();
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _isRecording = false;
      _isPaused = false;
      _recordingPath = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  Future<void> sendVoiceMessage(String chatId, String senderId, String filePath) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Upload audio file to Firebase Storage
      final storageRef = _storage.ref().child('voice_messages/$chatId/$timestamp.m4a');
      final uploadTask = storageRef.putFile(File(filePath));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Add message to messages collection
      await _firestore
          .collection('chatrooms')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'message': downloadUrl,
        'timestamp': timestamp,
        'type': 'voice',
        'status': 'sent',
      });

      // Update chat room with last message info
      await _firestore.collection('chatrooms').doc(chatId).update({
        'last_message': '🎤 Voice message',
        'last_message_time': timestamp,
        'last_message_status': 'sent',
      });
    } catch (e) {
      debugPrint('Error sending voice message: $e');
    }
  }

  Future<void> sendImageMessage(String chatId, String senderId, {required ImageSource source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image == null) return;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File(image.path);
      
      // Upload image to Firebase Storage
      final storageRef = _storage.ref().child('chat_images/$chatId/$timestamp.jpg');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Add message to messages collection
      await _firestore
          .collection('chatrooms')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'message': downloadUrl,
        'timestamp': timestamp,
        'type': 'image',
        'status': 'sent',
      });

      // Update chat room with last message info
      await _firestore.collection('chatrooms').doc(chatId).update({
        'last_message': '📷 Image',
        'last_message_time': timestamp,
        'last_message_status': 'sent',
      });
    } catch (e) {
      debugPrint('Error sending image message: $e');
    }
  }

  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }

  Stream<Map<String, dynamic>> getUserOnlineStatus(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return {'isOnline': false, 'lastSeen': DateTime.now().millisecondsSinceEpoch.toString()};
          }
          final data = snapshot.data()!;
          return {
            'isOnline': data['isOnline'] ?? false,
            'lastSeen': (data['lastSeen'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
          };
        });
  }

  String? get currentRoomId => _currentRoomId;
}