import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/user.dart'; // ensure User class is imported here

class ChatPage extends StatelessWidget {
  final String ticketId;
  final User user;

  const ChatPage({super.key, required this.ticketId, required this.user});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Column(
        children: [
          // AppBar content moved here
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap:
                      () => context.go('/messages'), // ✅ go back to chat list
                  child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Admin Support",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildUserAvatar(user),
              ],
            ),
          ),

          const Divider(height: 1),
          // Chat messages
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: const [
                ChatBubble(
                  text: "Hello, please confirm shipping status for order #007.",
                  time: "10:05 AM",
                  isSentByMe: false,
                  avatarUrl: 'https://i.pravatar.cc/150?img=2',
                ),
                ChatBubble(
                  text:
                      "Confirmed. Item shipped on 12th January. Tracking ID: TRACK-ABC-123. ETA is 3-5 business days.",
                  time: "10:07 AM",
                  isSentByMe: true,
                  avatarUrl: 'https://i.pravatar.cc/150?img=3',
                ),
                ChatBubble(
                  text:
                      "Thank you for the quick update. Is there a way to prioritize express shipping?",
                  time: "10:08 AM",
                  isSentByMe: false,
                  avatarUrl: 'https://i.pravatar.cc/150?img=4',
                ),
                ChatBubble(
                  text:
                      "Let me check the options for express shipping. I'll get back to you within the hour.",
                  time: "10:10 AM",
                  isSentByMe: true,
                  avatarUrl: 'https://i.pravatar.cc/150?img=5',
                ),
                ChatBubble(
                  text: "Sounds good. Appreciate your help!",
                  time: "10:11 AM",
                  isSentByMe: false,
                  avatarUrl: 'https://i.pravatar.cc/150?img=6',
                ),
                ChatBubble(
                  text:
                      "Following up on express shipping. I've found an option for next-day delivery at an additional cost. Shall I proceed?",
                  time: "11:05 AM",
                  isSentByMe: true,
                  avatarUrl: 'https://i.pravatar.cc/150?img=7',
                ),
              ],
            ),
          ),
          const ChatInputBar(),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(User user) {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(user.avatarUrl!),
      );
    } else {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey[300],
        child: Text(
          user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isSentByMe;
  final String avatarUrl;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isSentByMe,
    required this.avatarUrl,
  });

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
          if (!isSentByMe)
            CircleAvatar(radius: 14, backgroundImage: NetworkImage(avatarUrl)),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    if (isSentByMe)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (isSentByMe)
            CircleAvatar(radius: 14, backgroundImage: NetworkImage(avatarUrl)),
        ],
      ),
    );
  }
}

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ).copyWith(bottom: 16, top: 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: "Type your message...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF5E4AE3),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
