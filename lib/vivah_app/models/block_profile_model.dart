class BlockProfileItemModel {
  final int id;
  final int fromId;
  final int toId;
  final String? blockDate;
  final String? description;
  final String? toUserName;
  final String? toUserFaceImage;

  BlockProfileItemModel({
    required this.id,
    required this.fromId,
    required this.toId,
    this.blockDate,
    this.description,
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

  factory BlockProfileItemModel.fromJson(Map<String, dynamic> json) {
    String? name;
    String? faceImg;
    if (json['to_user'] is Map) {
      name = json['to_user']['name']?.toString();
      faceImg = json['to_user']['face_image']?.toString();
    }

    return BlockProfileItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fromId: json['from_id'] is int ? json['from_id'] : int.tryParse(json['from_id']?.toString() ?? '0') ?? 0,
      toId: json['to_id'] is int ? json['to_id'] : int.tryParse(json['to_id']?.toString() ?? '0') ?? 0,
      blockDate: json['blockprofile_date']?.toString(),
      description: json['blockprofile_description']?.toString(),
      toUserName: name,
      toUserFaceImage: faceImg,
    );
  }
}
