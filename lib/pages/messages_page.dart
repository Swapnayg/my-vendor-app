import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/user.dart';
import 'package:my_vendor_app/models/message.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late List<User> users;
  late List<Message> messages;
  String searchText = '';

  @override
  void initState() {
    super.initState();

    users = List.generate(5, (index) {
      return User(
        id: index + 1,
        email: 'user$index@email.com',
        username: 'User$index',
        password: '',
        tempPassword: null,
        role: UserRole.CUSTOMER,
        isActive: index % 2 == 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reviews: [],
        notifications: [],
        vendor: null,
        customer: null,
        admin: null,
        tickets: [],
        messages: [],
        apiKeys: [],
        auditLogs: [],
        passwordReset: [],
        usages: [],
        pages: [],
      );
    });

    messages = List.generate(10, (index) {
      final userId = (index % users.length) + 1;
      return Message(
        id: index + 1,
        ticketId: (index ~/ 2) + 1,
        userId: userId,
        content: 'Mock message #$index from User$userId',
        createdAt: DateTime.now().subtract(Duration(minutes: index * 15)),
        isRead: index % 3 != 0,
        isAdmin: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ticketMessages = <int, Message>{};
    for (var message in messages) {
      final existing = ticketMessages[message.ticketId];
      if (existing == null || message.createdAt.isAfter(existing.createdAt)) {
        ticketMessages[message.ticketId] = message;
      }
    }

    var sortedTickets =
        ticketMessages.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (searchText.isNotEmpty) {
      sortedTickets =
          sortedTickets.where((msg) {
            final user = users.firstWhere(
              (u) => u.id == msg.userId,
              orElse:
                  () => User(
                    id: 0,
                    email: 'admin@system.com',
                    username: 'Admin',
                    password: '',
                    tempPassword: null,
                    role: UserRole.ADMIN,
                    isActive: true,
                    createdAt: msg.createdAt,
                    updatedAt: msg.createdAt,
                    reviews: [],
                    notifications: [],
                    vendor: null,
                    customer: null,
                    admin: null,
                    tickets: [],
                    messages: [],
                    apiKeys: [],
                    auditLogs: [],
                    passwordReset: [],
                    usages: [],
                    pages: [],
                  ),
            );

            return user.username.toLowerCase().contains(
                  searchText.toLowerCase(),
                ) ||
                msg.content.toLowerCase().contains(searchText.toLowerCase());
          }).toList();
    }

    return CommonLayout(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Messages",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) => setState(() => searchText = value),
                      decoration: InputDecoration(
                        hintText: "Search contacts or messages...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            searchText.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed:
                                      () => setState(() => searchText = ''),
                                )
                                : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedTickets.length,
                  itemBuilder: (_, index) {
                    final message = sortedTickets[index];
                    final user = users.firstWhere(
                      (u) => u.id == message.userId,
                    );

                    final unreadCount =
                        messages
                            .where(
                              (m) =>
                                  m.ticketId == message.ticketId &&
                                  !m.isRead &&
                                  m.userId == user.id,
                            )
                            .length;

                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: _colorForIndex(index),
                            child: Text(
                              user.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (user.isActive)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        message.content,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(message.createdAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        context.push(
                          '/chat',
                          extra: {'ticketId': message.ticketId, 'user': user},
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForIndex(int index) {
    final colors = [
      Colors.green[100],
      Colors.amber[100],
      Colors.purple[100],
      Colors.brown[100],
      Colors.pink[100],
      Colors.teal[100],
      Colors.red[100],
      Colors.indigo[100],
    ];
    return colors[index % colors.length]!;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return "Yesterday";
    return "${time.month}/${time.day}";
  }
}
