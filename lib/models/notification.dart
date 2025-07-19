class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool read;
  final String type;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.type,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      read: json['read'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
