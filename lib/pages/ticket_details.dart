import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/models/message.dart';
import '/common/common_layout.dart';
import '/models/ticket.dart';

class TicketDetailsPage extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsPage({super.key, required this.ticket});

  Widget _buildMessageFromMessage(BuildContext context, Message msg) {
    final bool isMe = !msg.isAdmin;
    final bubbleColor = isMe ? const Color(0xFFF2F0FF) : Colors.white;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final avatarColor = isMe ? Colors.deepOrange : const Color(0xFF40B28C);
    final senderLabel = isMe ? 'ME' : 'TS';
    final time = TimeOfDay.fromDateTime(msg.createdAt).format(context);

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
                  child: Text(
                    senderLabel,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
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
                  child: Text(msg.content),
                ),
              ),
              if (isMe) const SizedBox(width: 6),
              if (isMe)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: avatarColor,
                  child: Text(
                    senderLabel,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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

          // Ticket Info Card
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

          // Instruction Note
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Color(0xFFFFF9C4), // Light yellow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '📩 For any further questions or communication regarding this ticket, please respond directly to the email you received.',
                  style: TextStyle(fontSize: 13.5, color: Colors.black87),
                ),
              ),
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

          // Message Bubbles
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children:
                  ticket.messages
                      .map((msg) => _buildMessageFromMessage(context, msg))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
