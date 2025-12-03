class NotificationModel {
  final String id;
  final String type; // ticket_purchased, event_reminder...
  final String title;
  final String message;
  final bool isRead;
  final Map<String, dynamic>? data; // Dữ liệu đi kèm (eventId, orderId...)
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
