class UserModel {
  final int id;
  final String name;
  final String? email;
  final String mobile;
  final String? gender;
  final int userType; // 1: User, 2: Admin, 3: Super Admin
  final String status; // Pending, Approved, Hold, Married, Cancel
  final String? faceImage;
  final String? registerDate;
  final String? userCurrentCity;
  final dynamic paymentDetails;
  final String? deviceId;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.mobile,
    this.gender,
    required this.userType,
    required this.status,
    this.faceImage,
    this.registerDate,
    this.userCurrentCity,
    this.paymentDetails,
    this.deviceId,
  });

  bool get isUser => userType == 1;
  bool get isAdmin => userType == 2;
  bool get isSuperAdmin => userType == 3;
  bool get isAdminOrSuperAdmin => userType == 2 || userType == 3;

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';

  /// Check if the user has an active subscription based on payment_details
  bool get isSubscribed {
    // Admin & Super Admin are never blocked
    if (isAdminOrSuperAdmin) return true;
    if (paymentDetails == null) return false;
    if (paymentDetails is Map) return (paymentDetails as Map).isNotEmpty;
    if (paymentDetails is List) return (paymentDetails as List).isNotEmpty;
    if (paymentDetails is String) {
      final str = (paymentDetails as String).trim();
      return str.isNotEmpty && str != 'null' && str != '{}' && str != '[]';
    }
    if (paymentDetails is bool) return paymentDetails as bool;
    if (paymentDetails is num) return paymentDetails > 0;
    return true;
  }

  String get roleName {
    switch (userType) {
      case 3:
        return 'Super Admin';
      case 2:
        return 'Admin';
      case 1:
      default:
        return 'Member';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString() ?? '',
      gender: json['gender']?.toString(),
      userType: json['user_type'] is int
          ? json['user_type']
          : int.tryParse(json['user_type']?.toString() ?? '1') ?? 1,
      status: json['status']?.toString() ?? 'Pending',
      faceImage: json['face_image']?.toString(),
      registerDate: json['register_date']?.toString(),
      userCurrentCity: json['user_current_city']?.toString(),
      paymentDetails: json['payment_details'] ?? json['payments'] ?? json['paymentDetails'],
      deviceId: json['device_id']?.toString() ?? json['profile_device_id']?.toString(),
    );
  }

  factory UserModel.fromMember(dynamic member) {
    return UserModel(
      id: member.id ?? 0,
      name: member.name ?? '',
      email: member.email,
      mobile: member.mobile ?? '',
      gender: member.gender,
      userType: member.userType ?? 1,
      status: member.status ?? 'Pending',
      faceImage: member.faceImage,
      registerDate: member.registerDate,
      userCurrentCity: member.userCurrentCity,
      paymentDetails: member.paymentDetails,
      deviceId: (member is Map ? (member['device_id'] ?? member['profile_device_id']) : null)?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'gender': gender,
    'user_type': userType,
    'status': status,
    'face_image': faceImage,
    'register_date': registerDate,
    'user_current_city': userCurrentCity,
    'payment_details': paymentDetails,
    'device_id': deviceId,
    'profile_device_id': deviceId,
  };
}
