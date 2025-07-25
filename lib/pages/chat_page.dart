import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String customerId;
  final User user;

  const ChatPage({super.key, required this.customerId, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  final TextEditingController messageController = TextEditingController();

  int? vendorId;
  String? token;

  @override
  void initState() {
    super.initState();
    initializeChat();
  }

  Future<void> initializeChat() async {
    final prefs = await SharedPreferences.getInstance();
    vendorId = prefs.getInt('userId');
    token = prefs.getString('token');

    if (vendorId == null || token == null) {
      setState(() => isLoading = false);
      return;
    }

    await fetchChatMessages();
  }

  Future<void> fetchChatMessages() async {
    setState(() => isLoading = true);

    final uri = Uri.parse(
      "https://vendor-admin-portal.netlify.app/api/MobileApp/vendor/chat",
    );
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'vendorId': vendorId, 'customerId': widget.customerId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        messages = List<Map<String, dynamic>>.from(data['data']);
        isLoading = false;
      });
    } else {
      print("Fetch failed: ${response.body}");
      setState(() => isLoading = false);
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || vendorId == null || token == null) return;

    final uri = Uri.parse(
      "https://vendor-admin-portal.netlify.app/api/MobileApp/vendor/sendmessage",
    );
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'vendorId': vendorId,
        'customerId': widget.customerId,
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      messageController.clear();
      await fetchChatMessages();
    } else {
      print("Send failed: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Column(
        children: [
          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/messages'),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Admin Support",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                _buildUserAvatar(widget.user),
              ],
            ),
          ),
          const Divider(height: 1),
          // Chat body
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isSentByMe =
                            message['senderId'].toString() != widget.customerId;
                        return ChatBubble(
                          text: message['text'] ?? '',
                          time: message['createdAt']?.toString() ?? '',
                          isSentByMe: isSentByMe,
                          avatarUrl:
                              isSentByMe
                                  ? 'https://i.pravatar.cc/150?img=11'
                                  : (widget.user.avatarUrl ??
                                      'https://i.pravatar.cc/150?img=1'),
                        );
                      },
                    ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
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
              controller: messageController,
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
          GestureDetector(
            onTap: sendMessage,
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF5E4AE3),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
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
                Text(
                  time,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
