class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String date;
  final bool isRead;
  final Map<String, dynamic>? extraData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    this.extraData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    final id = parseId(json['id']);
    final title = json['title']?.toString() ??
        json['notification']?.toString() ??
        json['subject']?.toString() ??
        'Notification';
    final message = json['message']?.toString() ??
        json['body']?.toString() ??
        json['description']?.toString() ??
        json['content']?.toString() ??
        '';
    final date = json['created_at']?.toString() ??
        json['date']?.toString() ??
        json['timestamp']?.toString() ??
        'Just now';
    final isRead = json['is_read'] == 1 || json['is_read'] == true || json['read_at'] != null;

    return NotificationModel(
      id: id,
      title: title,
      message: message,
      date: date,
      isRead: isRead,
      extraData: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
    );
  }
}
