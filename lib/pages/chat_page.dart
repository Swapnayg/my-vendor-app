import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final TextEditingController messageController = TextEditingController();

  int? vendorId;

  @override
  void initState() {
    super.initState();
    initializeVendor();
  }

  Future<void> initializeVendor() async {
    final prefs = await SharedPreferences.getInstance();
    vendorId = prefs.getInt('userId');
    setState(() {});
  }

  String get chatId => '$vendorId-${widget.customerId}';

  Stream<QuerySnapshot> getChatMessagesStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots();
  }

  Future<void> sendMessageToFirestore(String text) async {
    if (vendorId == null || text.trim().isEmpty) return;

    final messageData = {
      'senderId': vendorId.toString(),
      'content': text.trim(),
      'sentAt': Timestamp.now(),
    };

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Ensure chat document exists
    await chatRef.set({
      'vendorId': vendorId,
      'customerId': widget.customerId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Add the message
    await chatRef.collection('messages').add(messageData);
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
                vendorId == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                      stream: getChatMessagesStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final isSentByMe =
                                data['senderId'] != widget.customerId;

                            return ChatBubble(
                              text: data['content'] ?? '',
                              time:
                                  (data['sentAt'] as Timestamp?)
                                      ?.toDate()
                                      .toLocal()
                                      .toString() ??
                                  '',
                              isSentByMe: isSentByMe,
                              avatarUrl:
                                  isSentByMe
                                      ? 'https://i.pravatar.cc/150?img=11'
                                      : (widget.user.avatarUrl ??
                                          'https://i.pravatar.cc/150?img=1'),
                            );
                          },
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
            onTap: () {
              sendMessageToFirestore(messageController.text);
              messageController.clear();
            },
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
