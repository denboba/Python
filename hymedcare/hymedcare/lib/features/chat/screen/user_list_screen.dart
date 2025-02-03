import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';
import '../provider/chat_room_provider.dart';
import 'chat_screen.dart';
import '../../../model/userModel.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late String currentUserId;
  late ChatRoomProvider chatProvider;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<HymedCareAuthProvider>(context, listen: false);
    currentUserId = authProvider.currentUserId;
    chatProvider = Provider.of<ChatRoomProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startChat(UserModel user) async {
    // TODO all tunread chat should be deleted
    final chatRoomId = await chatProvider.createOrGetChatRoom(
      currentUserId,
      user.uid,
    );

    if (mounted) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId,
            otherUserName: '${user.firstName} ${user.lastName}',
            otherUserId: user.uid,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('New Chat'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search users...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final users = snapshot.data!.docs
                      .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
                      .where((user) => user.uid != currentUserId)
                      .where((user) {
                        final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
                        return _searchQuery.isEmpty ||
                            fullName.contains(_searchQuery) ||
                            user.email.toLowerCase().contains(_searchQuery);
                      })
                      .toList();

                  if (users.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return CupertinoListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: CupertinoColors.systemBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${user.firstName[0]}${user.lastName[0]}',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text('${user.firstName} ${user.lastName}'),
                        subtitle: Text(user.email),
                        trailing: const Icon(CupertinoIcons.chat_bubble_2),
                        onTap: () => _startChat(user),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
