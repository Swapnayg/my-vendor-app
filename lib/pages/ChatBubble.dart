import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isSentByMe;
  final String avatarUrl;
  final String? username;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isSentByMe,
    required this.avatarUrl,
    this.username,
  });

  String getInitial() {
    if (username != null && username!.isNotEmpty) {
      return username![0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) _buildAvatarOrInitial(),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSentByMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSentByMe ? const Color(0xFF5E4AE3) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isSentByMe ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (isSentByMe) _buildAvatarOrInitial(),
        ],
      ),
    );
  }

  Widget _buildAvatarOrInitial() {
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(radius: 14, backgroundImage: NetworkImage(avatarUrl));
    } else {
      return CircleAvatar(
        radius: 14,
        backgroundColor: Colors.grey[300],
        child: Text(
          getInitial(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }
  }
}
