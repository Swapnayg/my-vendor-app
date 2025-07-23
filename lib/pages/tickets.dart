import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/ticket.dart';
import '/common/common_layout.dart';
import 'package:go_router/go_router.dart';

class TicketManagementPage extends StatelessWidget {
  const TicketManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Ticket> tickets = [
      Ticket(
        id: 101,
        subject: 'Issue with Payment Gateway Integration',
        message: 'Payment not processing properly',
        type: TicketType.PAYMENT_ISSUE,
        status: TicketStatus.OPEN,
        createdAt: DateTime(2023, 10, 26),
        updatedAt: DateTime.now(),
      ),
      Ticket(
        id: 102,
        subject: 'Order Fulfillment Error on Recent Shipment',
        message: 'Wrong item delivered',
        type: TicketType.ORDER_NOT_RECEIVED,
        status: TicketStatus.CLOSED,
        createdAt: DateTime(2023, 10, 20),
        updatedAt: DateTime.now(),
      ),
      Ticket(
        id: 103,
        subject: 'Login Credentials Not Working for New User',
        message: 'Unable to log in',
        type: TicketType.TECHNICAL_ISSUE,
        status: TicketStatus.RESPONDED,
        createdAt: DateTime(2023, 10, 25),
        updatedAt: DateTime.now(),
      ),
    ];

    return CommonLayout(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Support Tickets",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 12),
          // Raise New Ticket Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/tickets/raise');
                },

                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Raise New Ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

          // Tickets List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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

  Color _getPriorityColor(Ticket ticket) {
    if (ticket.id == 101) return Colors.red;
    if (ticket.id == 102) return Colors.amber;
    return Colors.green;
  }

  String _getPriorityLabel(Ticket ticket) {
    if (ticket.id == 101) return 'High';
    if (ticket.id == 102) return 'Medium';
    return 'Low';
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.OPEN:
        return const Color(0xFFEEF0FF); // Light purple
      case TicketStatus.RESPONDED:
        return const Color(0xFFFFF3E6); // Light orange
      case TicketStatus.CLOSED:
        return const Color(0xFFF3F4F6); // Light gray
    }
  }

  String _getStatusLabel(TicketStatus status) {
    switch (status) {
      case TicketStatus.OPEN:
        return 'Open';
      case TicketStatus.RESPONDED:
        return 'Pending';
      case TicketStatus.CLOSED:
        return 'Closed';
    }
  }

  IconData _getIconForType(TicketType type) {
    switch (type) {
      case TicketType.PAYMENT_ISSUE:
        return Icons.credit_card;
      case TicketType.ORDER_NOT_RECEIVED:
        return Icons.shopping_cart;
      case TicketType.TECHNICAL_ISSUE:
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon + Ticket ID + Status Chip
          Row(
            children: [
              Icon(
                _getIconForType(ticket.type),
                size: 18,
                color: const Color(0xFF7A5CFA),
              ),
              const SizedBox(width: 6),
              Text(
                'Ticket #${ticket.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(ticket.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(ticket.status),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Subject
          Text(
            ticket.subject,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),

          // Date and Priority
          Row(
            children: [
              Text(
                'Created: ${DateFormat('yyyy-MM-dd').format(ticket.createdAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: _getPriorityColor(ticket)),
                  const SizedBox(width: 4),
                  Text(
                    'Priority: ${_getPriorityLabel(ticket)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // View Details
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                context.go(
                  '/tickets/details',
                  extra:
                      ticket
                          .toJson(), // assuming `ticket` is the current Ticket object
                );
              },
              icon: const Icon(Icons.arrow_forward_ios, size: 14),
              label: const Text('View Details'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7A5CFA),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
