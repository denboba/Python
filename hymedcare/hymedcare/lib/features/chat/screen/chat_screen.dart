import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart' as ap;
import '../provider/chat_room_provider.dart';
import '../../../screens/video_call_screen.dart';
import '../../../provider/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String chatRoomId;

  const ChatScreen({
    required this.otherUserId,
    required this.otherUserName,
    required this.chatRoomId,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _messageController = TextEditingController();
  late ChatRoomProvider _chatProvider;
  late String _currentUserId;
  bool showPlayer = false;
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  Timer? _recordingTimer;
  int _recordDuration = 0;
  late ScrollController _scrollController;
  StreamSubscription? _chatSubscription;



  void _setupChat() async {
    try {
      // First mark messages as delivered
      await _chatProvider.markMessageAsRead(widget.chatRoomId, _currentUserId);

      // Then update chat state and mark messages as seen
      await _chatProvider.updateUserChatState(_currentUserId, widget.chatRoomId);
      _chatProvider.setInChatRoom(true, _currentUserId);
    } catch (e) {
      print('Error setting up chat: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _chatProvider = Provider.of<ChatRoomProvider>(context, listen: false);
    _currentUserId = Provider.of<HymedCareAuthProvider>(context, listen: false)
        .currentUserId;
    _setupChat();
    _setupPresence();
  }

  void _setupPresence() {
    _chatProvider.initializeUserPresence(_currentUserId);
  }

  @override
  void dispose() {
    _chatProvider.cleanupUserPresence(_currentUserId);
    _messageController.dispose();
    _scrollController.dispose();
    _chatSubscription?.cancel();
    super.dispose();
  }

  void _handleMessageInput(String text) {
    _chatProvider.handleTyping(_currentUserId, widget.chatRoomId, text);
  }
  void _cleanupChat() async {
    try {
      // First set the chat state to false to prevent any new "seen" updates
      _chatProvider.setInChatRoom(false, _currentUserId);
      
      // Then update the user's chat state to null and handle message status
      await _chatProvider.updateUserChatState(_currentUserId, null);
    } catch (e) {
      print('Error cleaning up chat: $e');
    }
  }

  Future<void> _startVideoCall() async {
    const temporaryToken = 'YOUR_TEMPORARY_TOKEN';
    final channelName = 'call_${widget.chatRoomId}';

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => VideoCallScreen(
          channelName: channelName,
          token: temporaryToken,
          remoteUserName: widget.otherUserName,
        ),
      ),
    );
  }

  Future<void> _startAudioCall() async {
    const temporaryToken = 'YOUR_TEMPORARY_TOKEN';
    final channelName = 'call_${widget.chatRoomId}';

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => VideoCallScreen(
          channelName: channelName,
          token: temporaryToken,
          remoteUserName: widget.otherUserName,
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    return DateFormat.jm().format(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final message = _messageController.text;
      _messageController.clear();

      await _chatProvider.sendMessage(
        widget.chatRoomId,
        _currentUserId,
        message,
      );

      // Scroll to bottom after sending message
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      // Show error to user
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to send message. Please try again.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'sent':
        return Icon(
          Icons.check,
          size: 16,
          color: CupertinoColors.systemGrey,
        );
      case 'delivered':
        return Icon(
          CupertinoIcons.check_mark,
          size: 16,
          color: CupertinoColors.systemGrey
        );
      case 'seen':
        return Icon(
          Icons.done_all,
          size: 16,
          color: CupertinoColors.systemBlue
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMessageInput() {
    final theme = CupertinoTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.barBackgroundColor,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: _showAttachmentOptions,
              child: Icon(
                CupertinoIcons.plus_circle_fill,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            Expanded(
              child: CupertinoTextField(
                controller: _messageController,
                placeholder: 'Type a message...',
                placeholderStyle: TextStyle(
                  color: theme.textTheme.textStyle.color!.withValues(
                    alpha: 0.5,
                  ),
                ),
                style: theme.textTheme.textStyle,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CupertinoColors.separator.withOpacity(0.2),
                  ),
                ),
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _sendMessage,
                  child: const Icon(CupertinoIcons.arrow_up_circle_fill),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Consumer<ChatRoomProvider>(
              builder: (context, provider, child) {
                if (provider.isRecording) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimer(),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _stopRecording,
                        child: const Icon(
                          CupertinoIcons.stop_fill,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _cancelRecording,
                        child: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  );
                }

                return _messageController.text.isEmpty
                    ? GestureDetector(
                        onTapDown: (_) async {
                          await _startRecording();
                        },
                        onTapUp: (_) async {
                          await _stopRecording();
                        },
                        onTapCancel: () async {
                          await _cancelRecording();
                        },

                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor,
                          ),
                          child: const Icon(
                            CupertinoIcons.mic_fill,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                        ),
                      )
                    : CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _sendMessage,
                        child: Icon(
                          CupertinoIcons.arrow_up_circle_fill,
                          color: theme.primaryColor,
                          size: 28,
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes:$seconds',
      style: const TextStyle(
        color: CupertinoColors.systemRed,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }
    return numberStr;
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  Future<void> _startRecording() async {
    await _chatProvider.startRecording();
    _recordDuration = 0;
    _startTimer();
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final path = await _chatProvider.stopRecording();
    if (path != null) {
      await _chatProvider.sendVoiceMessage(
        widget.chatRoomId,
        _currentUserId,
        path,
      );
    }
  }

  Future<void> _pauseRecording() async {
    _recordingTimer?.cancel();
    await _chatProvider.pauseRecording();
  }

  Future<void> _resumeRecording() async {
    await _chatProvider.resumeRecording();
    _startTimer();
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    _recordDuration = 0;
    await _chatProvider.cancelRecording();
  }

  void _showAttachmentOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _chatProvider.sendImageMessage(
                widget.chatRoomId,
                _currentUserId,
                source: ImageSource.camera,
              );
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _chatProvider.sendImageMessage(
                widget.chatRoomId,
                _currentUserId,
                source: ImageSource.gallery,
              );
            },
            child: const Text('Choose from Gallery'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _buildVoiceMessage(String url) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<ap.PlayerState>(
          stream: _audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ap.ProcessingState.loading ||
                processingState == ap.ProcessingState.buffering) {
              return const CupertinoActivityIndicator();
            }

            if (playing != true) {
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await _audioPlayer.setUrl(url);
                  await _audioPlayer.play();
                },
                child: const Icon(CupertinoIcons.play_fill, size: 24),
              );
            }

            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _audioPlayer.pause,
              child: const Icon(CupertinoIcons.pause_fill, size: 24),
            );
          },
        ),
        const SizedBox(width: 8),
        const Icon(CupertinoIcons.waveform, size: 24),
      ],
    );
  }

  Widget _buildImageMessage(String url) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CupertinoActivityIndicator();
          },
        ),
      ),
    );
  }

  String _formatLastSeen(String timestamp) {
    if (timestamp.isEmpty) return 'Offline';
    
    try {
      final lastSeenDate = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      final now = DateTime.now();
      final difference = now.difference(lastSeenDate);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${lastSeenDate.day}/${lastSeenDate.month}/${lastSeenDate.year}';
      }
    } catch (e) {
      return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: StreamBuilder<Map<String, dynamic>>(
          stream: _chatProvider.getUserOnlineStatus(widget.otherUserId),
          builder: (context, snapshot) {
            final isOnline = snapshot.data?['isOnline'] ?? false;
            final lastSeen = snapshot.data?['lastSeen'] ?? '';

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.otherUserName
                              .split(' ')
                              .map((e) => e[0])
                              .take(2)
                              .join(''),
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: CupertinoColors.activeGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CupertinoColors.systemBackground,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isOnline ? 'Online' : _formatLastSeen(lastSeen),
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _startVideoCall,
              child: const Icon(CupertinoIcons.video_camera_solid),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatProvider.getMessages(widget.chatRoomId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }

                  final messages = snapshot.data!.docs;
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet'),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index].data() as Map<String, dynamic>;
                      final isSentByMe = message['senderId'] == _currentUserId;

                      return _buildMessageBubble(message, isSentByMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isSentByMe) {
    int timestamp;
    try {
      final timestampValue = message['timestamp'];
      if (timestampValue is int) {
        timestamp = timestampValue;
      } else if (timestampValue is String) {
        timestamp = int.parse(timestampValue);
      } else {
        timestamp = DateTime.now().millisecondsSinceEpoch;
      }
    } catch (e) {
      timestamp = DateTime.now().millisecondsSinceEpoch;
    }

    final messageType = message['type'] as String? ?? 'text';
    final theme = CupertinoTheme.of(context);

    Widget messageContent;
    switch (messageType) {
      case 'voice':
        messageContent = _buildVoiceMessage(message['message']);
        break;
      case 'image':
        messageContent = _buildImageMessage(message['message']);
        break;
      default:
        messageContent = Text(
          message['message'] as String? ?? '',
          style: theme.textTheme.textStyle.copyWith(
            color: isSentByMe ? CupertinoColors.black : CupertinoColors.black,
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSentByMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? Color.fromARGB(237, 215, 195, 236)
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
                  bottomRight: Radius.circular(isSentByMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  messageContent,
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      if (isSentByMe) ...[
                        const SizedBox(width: 4),
                        _buildStatusIcon(message['status'] as String? ?? 'sent'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSentByMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
