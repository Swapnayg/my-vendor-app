class Message {
  final int id;
  final String content;
  final bool isAdmin;
  final int ticketId;
  final int? userId;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.content,
    required this.isAdmin,
    required this.ticketId,
    this.userId,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      isAdmin: json['isAdmin'] ?? false,
      ticketId: json['ticketId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isAdmin': isAdmin,
      'ticketId': ticketId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
