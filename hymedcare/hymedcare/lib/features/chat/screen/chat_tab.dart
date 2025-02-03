import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../provider/chat_room_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../model/userModel.dart';
import 'chat_screen.dart';
import 'user_list_screen.dart';
import '../chat_tile.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  late String currentUserId;
  late ChatRoomProvider chatProvider;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final authProvider = Provider.of<HymedCareAuthProvider>(context, listen: false);
    currentUserId = authProvider.currentUserId;
    chatProvider = Provider.of<ChatRoomProvider>(context, listen: false);
    setState(() => isLoading = false);
  }

  void _navigateToUserList() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const UserListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Chats'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _navigateToUserList,
          child: const Icon(CupertinoIcons.person_add),
        ),
      ),
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: chatProvider.getChatRooms(currentUserId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final chatRooms = snapshot.data!.docs;

            if (chatRooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      // TODO: displlay "No chats yet"
                      'No chats yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed: _navigateToUserList,
                      child: const Text('Start a New Chat'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
                final otherUserId = chatRoom['participants']
                    .firstWhere((userId) => userId != currentUserId);

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherUserId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const CupertinoActivityIndicator();
                    }

                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    final user = UserModel.fromMap(userData);
                    final lastMessage = chatRoom['last_message'] as String? ?? 'No messages yet';
                    final timestamp = chatRoom['timestamp'] as int? ?? 0;
                    final messageStatus = chatRoom['last_message_status'] as String? ?? 'sent';
                    final unreadCount = (chatRoom['unread_count'] as Map<String, dynamic>?)?[currentUserId] ?? 0;

                    return StreamBuilder<Map<String, dynamic>>(
                      stream: Provider.of<ChatRoomProvider>(context, listen: false)
                          .getUserOnlineStatus(user.uid),
                      builder: (context, snapshot) {
                        final isOnline = snapshot.data?['isOnline'] ?? false;

                        return ChatTile(
                          user: user,
                          lastMessage: lastMessage,
                          timestamp: timestamp,
                          messageStatus: messageStatus,
                          unreadCount: unreadCount,
                          chatRoomId: chatRooms[index].id,
                          isOnline: isOnline,
                          onTap: () {
                            // Mark messages as read when opening the chat
                            chatProvider.markMessageAsRead(chatRooms[index].id, currentUserId);
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ChatScreen(
                                  chatRoomId: chatRooms[index].id,
                                  otherUserName: '${user.firstName} ${user.lastName}',
                                  otherUserId: user.uid,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}


