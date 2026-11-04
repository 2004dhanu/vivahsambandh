class ProfessionModel {
  final int id;
  final String professionName;

  ProfessionModel({
    required this.id,
    required this.professionName,
  });

  factory ProfessionModel.fromJson(Map<String, dynamic> json) {
    return ProfessionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      professionName: json['profession_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'profession_name': professionName,
  };

  /// Conditional checks for dynamic UI fields matching user requirements:
  /// 1. Private / Govt Sector: Company Name, Company Type, Annual Income
  /// 2. Own / Family Business: Business Name, Business Type, Annual Income
  /// 3. Self Employed (CA, CS, Lawyer, etc.): Annual Income
  /// 4. Others: Other Profession, Annual Income
  /// 5. Not in any Profession: None

  bool get isPrivateOrGovt {
    final lower = professionName.toLowerCase();
    return lower.contains('private') || lower.contains('govt');
  }

  bool get isBusiness {
    final lower = professionName.toLowerCase();
    return lower.contains('business');
  }

  bool get isSelfEmployed {
    final lower = professionName.toLowerCase();
    return lower.contains('self employed');
  }

  bool get isOthers {
    final lower = professionName.toLowerCase();
    return lower.contains('other');
  }

  bool get isNone {
    final lower = professionName.toLowerCase();
    return lower.contains('not in any') || lower.contains('none');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => professionName;
}
