import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_vendor_app/models/ticket.dart';
import '/common/common_layout.dart';

class TicketManagementPage extends StatelessWidget {
  const TicketManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Ticket> tickets = [
      Ticket(
        id: 101,
        subject: "Issue with Payment Gateway Integration",
        message: "Gateway failing on checkout",
        type: TicketType.PAYMENT_ISSUE,
        status: TicketStatus.OPEN,
        createdAt: DateTime(2023, 10, 26),
        updatedAt: DateTime(2023, 10, 26),
      ),
      Ticket(
        id: 102,
        subject: "Order Fulfillment Error on Recent Shipment",
        message: "Customer didn't receive item",
        type: TicketType.ORDER_NOT_RECEIVED,
        status: TicketStatus.CLOSED,
        createdAt: DateTime(2023, 10, 20),
        updatedAt: DateTime(2023, 10, 21),
      ),
      Ticket(
        id: 103,
        subject: "Login Credentials Not Working for New User",
        message: "Unable to access dashboard",
        type: TicketType.TECHNICAL_ISSUE,
        status: TicketStatus.RESPONDED,
        createdAt: DateTime(2023, 10, 25),
        updatedAt: DateTime(2023, 10, 26),
      ),
    ];

    return CommonLayout(
      body: Column(
        children: [
          // Inline App Bar content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.menu, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Support Tickets',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.notifications_none),
                const SizedBox(width: 12),
                const CircleAvatar(radius: 16, child: Text('TS')),
              ],
            ),
          ),

          // Raise new ticket button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Raise New Ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5CFA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Tickets list
          Expanded(
            child: ListView.separated(
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return TicketCard(ticket: tickets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({super.key, required this.ticket});

  Color _priorityColor(TicketType type) {
    switch (type) {
      case TicketType.PAYMENT_ISSUE:
      case TicketType.TECHNICAL_ISSUE:
        return Colors.red;
      case TicketType.ORDER_NOT_RECEIVED:
      case TicketType.RETURN_ISSUE:
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.RESPONDED:
        return Colors.orange.shade100;
      case TicketStatus.CLOSED:
        return Colors.grey.shade300;
      default:
        return Colors.grey.shade200;
    }
  }

  IconData _ticketIcon(TicketType type) {
    switch (type) {
      case TicketType.PAYMENT_ISSUE:
        return Icons.credit_card;
      case TicketType.TECHNICAL_ISSUE:
        return Icons.memory;
      case TicketType.ORDER_NOT_RECEIVED:
      case TicketType.RETURN_ISSUE:
        return Icons.local_shipping;
      case TicketType.DOCUMENTS:
        return Icons.insert_drive_file_outlined;
      default:
        return Icons.support_agent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('yyyy-MM-dd').format(ticket.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _ticketIcon(ticket.type),
                size: 18,
                color: const Color(0xFF7A5CFA),
              ),
              const SizedBox(width: 8),
              Text(
                'Ticket #${ticket.id}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(ticket.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ticket.status.name
                      .toLowerCase()
                      .replaceAll('_', ' ')
                      .capitalize(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ticket.subject,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Created: $dateFormatted',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: _priorityColor(ticket.type)),
              const SizedBox(width: 6),
              Text(
                'Type: ${ticket.type.name.replaceAll('_', ' ').capitalize()}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View Details'),
                  Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Capitalization extension
extension CapExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}
