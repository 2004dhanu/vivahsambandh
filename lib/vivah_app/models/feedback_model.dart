class FeedbackItemModel {
  final int id;
  final int fromId;
  final String? feedbackDate;
  final String? feedbackDescription;
  final String? fromUserName;
  final String? fromUserFaceImage;

  FeedbackItemModel({
    required this.id,
    required this.fromId,
    this.feedbackDate,
    this.feedbackDescription,
    this.fromUserName,
    this.fromUserFaceImage,
  });

  factory FeedbackItemModel.fromJson(Map<String, dynamic> json) {
    String? name;
    String? faceImg;
    if (json['from_user'] is Map) {
      name = json['from_user']['name']?.toString();
      faceImg = json['from_user']['face_image']?.toString();
    }

    return FeedbackItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fromId: json['from_id'] is int ? json['from_id'] : int.tryParse(json['from_id']?.toString() ?? '0') ?? 0,
      feedbackDate: json['feedback_date']?.toString(),
      feedbackDescription: json['feedback_description']?.toString(),
      fromUserName: name,
      fromUserFaceImage: faceImg,
    );
  }
}
