class CommunityModel {
  final int id;
  final String communityName;

  CommunityModel({
    required this.id,
    required this.communityName,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      communityName: json['community_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'community_name': communityName,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunityModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => communityName;
}
