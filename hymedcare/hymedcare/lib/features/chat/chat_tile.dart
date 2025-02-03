import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/userModel.dart';

class ChatTile extends StatelessWidget {
  final UserModel user;
  final String lastMessage;
  final int timestamp;
  final String messageStatus;
  final int unreadCount;
  final String chatRoomId;
  final bool isOnline;
  final VoidCallback onTap;

  const ChatTile({
    required this.user,
    required this.lastMessage,
    required this.timestamp,
    required this.messageStatus,
    required this.unreadCount,
    required this.chatRoomId,
    required this.isOnline,
    required this.onTap,
  });

  String _formatTimestamp(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildStatusIcon() {
    switch (messageStatus) {
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
          // double check mark
            Icons.done_all,
            size: 16,
            color: CupertinoColors.systemBlue
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              shape: BoxShape.circle,
              border: Border.all(
                color: CupertinoColors.systemBackground,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${user.firstName[0]}${user.lastName[0]}',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
      title: Row(
        children: [
          Expanded(
            child: Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            _formatTimestamp(timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: unreadCount > 0
                    ? CupertinoColors.black
                    : CupertinoColors.systemGrey,
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}