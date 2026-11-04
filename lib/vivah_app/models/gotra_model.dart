class GotraModel {
  final int id;
  final String gotraName;

  GotraModel({
    required this.id,
    required this.gotraName,
  });

  factory GotraModel.fromJson(Map<String, dynamic> json) {
    return GotraModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      gotraName: json['gotra_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gotra_name': gotraName,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GotraModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => gotraName;
}
