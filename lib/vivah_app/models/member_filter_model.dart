class MemberFilterModel {
  String? heightFrom;
  String? heightTo;
  int? gotraId;
  String? gotraName;
  String? physicalDisability; // 'Yes', 'No', or null
  String? isManglik;          // 'Yes', 'No', or null
  List<int> educationIds;
  List<String> educationNames;
  String? marriedBefore;      // 'Yes', 'No', or null

  MemberFilterModel({
    this.heightFrom,
    this.heightTo,
    this.gotraId,
    this.gotraName,
    this.physicalDisability,
    this.isManglik,
    List<int>? educationIds,
    List<String>? educationNames,
    this.marriedBefore,
  })  : educationIds = educationIds ?? [],
        educationNames = educationNames ?? [];

  bool get hasActiveFilters {
    return (heightFrom != null && heightFrom!.isNotEmpty) ||
        (heightTo != null && heightTo!.isNotEmpty) ||
        gotraId != null ||
        (physicalDisability != null && physicalDisability!.isNotEmpty) ||
        (isManglik != null && isManglik!.isNotEmpty) ||
        educationIds.isNotEmpty ||
        (marriedBefore != null && marriedBefore!.isNotEmpty);
  }

  int get activeFilterCount {
    int count = 0;
    if (heightFrom != null && heightFrom!.isNotEmpty) count++;
    if (heightTo != null && heightTo!.isNotEmpty) count++;
    if (gotraId != null) count++;
    if (physicalDisability != null && physicalDisability!.isNotEmpty) count++;
    if (isManglik != null && isManglik!.isNotEmpty) count++;
    if (educationIds.isNotEmpty) count++;
    if (marriedBefore != null && marriedBefore!.isNotEmpty) count++;
    return count;
  }

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    if (heightFrom != null && heightFrom!.trim().isNotEmpty) {
      params['height_from'] = heightFrom!.trim();
    }
    if (heightTo != null && heightTo!.trim().isNotEmpty) {
      params['height_to'] = heightTo!.trim();
    }
    if (gotraId != null) {
      params['gotra'] = gotraId.toString();
    }
    if (physicalDisability != null && physicalDisability!.trim().isNotEmpty) {
      params['physical_disablity'] = physicalDisability!.trim();
    }
    if (isManglik != null && isManglik!.trim().isNotEmpty) {
      params['is_manglik'] = isManglik!.trim();
    }
    if (educationIds.isNotEmpty) {
      params['education_id'] = educationIds.join(',');
    }
    if (marriedBefore != null && marriedBefore!.trim().isNotEmpty) {
      params['married_before'] = marriedBefore!.trim();
    }
    return params;
  }

  void clear() {
    heightFrom = null;
    heightTo = null;
    gotraId = null;
    gotraName = null;
    physicalDisability = null;
    isManglik = null;
    educationIds.clear();
    educationNames.clear();
    marriedBefore = null;
  }

  MemberFilterModel copy() {
    return MemberFilterModel(
      heightFrom: heightFrom,
      heightTo: heightTo,
      gotraId: gotraId,
      gotraName: gotraName,
      physicalDisability: physicalDisability,
      isManglik: isManglik,
      educationIds: List<int>.from(educationIds),
      educationNames: List<String>.from(educationNames),
      marriedBefore: marriedBefore,
    );
  }
}
