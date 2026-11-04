import 'package:flutter/material.dart';

class PaymentHistoryItemModel {
  final int id;
  final int? userId;
  final String name;
  final String? faceImage;
  final String? paymentDate;
  final String? paymentAmount;
  final String? paymentOff;
  final String? paymentMethod;
  final String? paymentDetails;
  final String paymentStatus;

  PaymentHistoryItemModel({
    required this.id,
    this.userId,
    required this.name,
    this.faceImage,
    this.paymentDate,
    this.paymentAmount,
    this.paymentOff,
    this.paymentMethod,
    this.paymentDetails,
    required this.paymentStatus,
  });

  bool get isApproved =>
      paymentStatus.toLowerCase() == 'approved' ||
      paymentStatus.toLowerCase() == 'success' ||
      paymentStatus.toLowerCase() == 'completed';

  bool get isPending => paymentStatus.toLowerCase() == 'pending';

  bool get isFailed =>
      paymentStatus.toLowerCase() == 'failed' ||
      paymentStatus.toLowerCase() == 'rejected' ||
      paymentStatus.toLowerCase() == 'cancel';

  Color get statusColor {
    if (isApproved) return const Color(0xFF2E7D32); // Green
    if (isPending) return const Color(0xFFED6C02); // Amber/Orange
    if (isFailed) return const Color(0xFFD32F2F); // Red
    return Colors.blueGrey;
  }

  Color get statusBgColor {
    if (isApproved) return const Color(0xFFE8F5E9);
    if (isPending) return const Color(0xFFFFF3E0);
    if (isFailed) return const Color(0xFFFFEBEE);
    return const Color(0xFFECEFF1);
  }

  IconData get statusIcon {
    if (isApproved) return Icons.check_circle_outline_rounded;
    if (isPending) return Icons.access_time_rounded;
    if (isFailed) return Icons.highlight_off_rounded;
    return Icons.info_outline_rounded;
  }

  String get formattedAmount {
    if (paymentAmount == null || paymentAmount!.trim().isEmpty) return '₹0.00';
    final clean = paymentAmount!.trim();
    if (clean.startsWith('₹')) return clean;
    return '₹ $clean';
  }

  String get validityDisplay {
    if (paymentOff == null || paymentOff!.trim().isEmpty) return 'Membership Plan';
    final off = paymentOff!.trim();
    return '$off Days Plan';
  }

  String get formattedDate {
    if (paymentDate == null || paymentDate!.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(paymentDate!.trim());
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return paymentDate!;
    }
  }

  String getImageUrl(String? baseUserImageUrl) {
    if (faceImage == null || faceImage!.trim().isEmpty) return '';
    final base = (baseUserImageUrl != null && baseUserImageUrl.isNotEmpty)
        ? baseUserImageUrl
        : 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
    return base.endsWith('/') ? '$base$faceImage' : '$base/$faceImage';
  }

  factory PaymentHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? 'Member',
      faceImage: json['face_image']?.toString(),
      paymentDate: json['payment_date']?.toString(),
      paymentAmount: json['payment_amount']?.toString(),
      paymentOff: json['payment_off']?.toString(),
      paymentMethod: json['payment_method']?.toString() ?? 'UPI',
      paymentDetails: json['payment_details']?.toString(),
      paymentStatus: json['payment_status']?.toString() ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'face_image': faceImage,
    'payment_date': paymentDate,
    'payment_amount': paymentAmount,
    'payment_off': paymentOff,
    'payment_method': paymentMethod,
    'payment_details': paymentDetails,
    'payment_status': paymentStatus,
  };
}
