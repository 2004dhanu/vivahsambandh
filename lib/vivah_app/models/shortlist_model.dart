class ShortlistItemModel {
  final int id;
  final int fromId;
  final int toId;
  final String? shortlistDate;
  final String? toUserName;
  final String? toUserFaceImage;

  ShortlistItemModel({
    required this.id,
    required this.fromId,
    required this.toId,
    this.shortlistDate,
    this.toUserName,
    this.toUserFaceImage,
  });

  String getImageUrl(String? baseUserImageUrl) {
    if (toUserFaceImage == null || toUserFaceImage!.isEmpty) {
      return '';
    }
    final base = (baseUserImageUrl != null && baseUserImageUrl.isNotEmpty)
        ? baseUserImageUrl
        : 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
    return base.endsWith('/') ? '$base$toUserFaceImage' : '$base/$toUserFaceImage';
  }

  factory ShortlistItemModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    String? name;
    String? faceImg;
    if (json['to_user'] is Map) {
      name = json['to_user']['name']?.toString();
      faceImg = json['to_user']['face_image']?.toString();
    } else if (json['member'] is Map) {
      name = json['member']['name']?.toString();
      faceImg = json['member']['face_image']?.toString();
    }

    return ShortlistItemModel(
      id: parseId(json['id']),
      fromId: parseId(json['from_id'] ?? json['user_id']),
      toId: parseId(json['to_id'] ?? json['to_user_id'] ?? json['member_id']),
      shortlistDate: json['shortlist_date']?.toString() ?? json['created_at']?.toString(),
      toUserName: name,
      toUserFaceImage: faceImg,
    );
  }
}
