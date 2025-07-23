import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '/common/common_layout.dart';
import '/models/ticket.dart';

final List<Map<String, dynamic>> _chatMock = [
  {
    'sender': 'ME',
    'message': 'Hello, I\'m experiencing a delay with my recent payment...',
    'time': '10:05 AM',
  },
  {
    'sender': 'TS',
    'message':
        'Hello! Thank you for reaching out. Could you provide the transaction ID?',
    'time': '10:07 AM',
  },
  {
    'sender': 'ME',
    'message': 'Certainly. The transaction ID is TXN-123456789.',
    'time': '10:08 AM',
  },
  {
    'sender': 'TS',
    'message':
        'Thank you. The payment is currently being processed. It will complete within 2 hours.',
    'time': '10:15 AM',
  },
  {
    'sender': 'ME',
    'message': 'Understood. Is there anything I need to do on my end?',
    'time': '10:18 AM',
  },
  {
    'sender': 'TS',
    'message':
        'No, we will notify you once completed. Thank you for your patience!',
    'time': '10:20 AM',
  },
  {
    'sender': 'ME',
    'message': 'Alright, great. Thanks for the update!',
    'time': '10:22 AM',
  },
];

class TicketDetailsPage extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar (inside body)
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/tickets'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ticket Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Issue Info
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF8F6FF),
              border: Border.all(color: Color(0xFFE4E1FA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Issue:', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Text(ticket.subject, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                const Text('Status:', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEAFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket.status.name,
                    style: const TextStyle(
                      color: Color(0xFF7A5CFA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Chat Thread with Support',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Chat Bubbles
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _chatMock.map((chat) => _buildMessage(chat)).toList(),
            ),
          ),

          const Divider(height: 1),
          // Input box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your reply here...',
                      filled: true,
                      fillColor: const Color(0xFFF4F4F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                  backgroundColor: const Color(0xFF7A5CFA),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> chat) {
    final bool isMe = chat['sender'] == 'ME';
    final bubbleColor = isMe ? const Color(0xFFF2F0FF) : Colors.white;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final avatarColor = isMe ? Colors.deepOrange : const Color(0xFF40B28C);
    final sender = chat['sender'];
    final time = chat['time'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: avatarColor,
                  child: const Text(
                    'TS',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              if (!isMe) const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(chat['message']),
                ),
              ),
              if (isMe) const SizedBox(width: 6),
              if (isMe)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: avatarColor,
                  child: const Text(
                    'ME',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
