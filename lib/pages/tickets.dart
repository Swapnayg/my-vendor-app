import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/common/common_layout.dart';
import '/models/ticket.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TicketManagementPage extends StatefulWidget {
  const TicketManagementPage({super.key});

  @override
  State<TicketManagementPage> createState() => _TicketManagementPageState();
}

class _TicketManagementPageState extends State<TicketManagementPage> {
  List<Ticket> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token not found');

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/MobileApp/vendor/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Ticket> loaded =
            (data['tickets'] as List)
                .map((json) => Ticket.fromJson(json))
                .toList();

        setState(() {
          tickets = loaded;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      print('Error fetching tickets: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 12, 0, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Support Tickets",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/tickets/raise'),
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
            const SizedBox(height: 12),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : tickets.isEmpty
                      ? const Center(child: Text("No tickets found"))
                      : ListView.separated(
                        itemCount: tickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return TicketCard(ticket: tickets[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({super.key, required this.ticket});

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
          // Row: Icon + Ticket ID + Status
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
          Text(
            ticket.subject,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),
          Text(
            'Created: ${DateFormat('yyyy-MM-dd').format(ticket.createdAt)}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed:
                  () => context.go('/tickets/details', extra: ticket.toJson()),
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
