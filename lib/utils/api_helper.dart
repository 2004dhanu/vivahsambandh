import 'dart:convert';
import 'dart:developer';

import 'package:bsvt/models/budget_category_model.dart';
import 'package:bsvt/models/chidren_with_me_model.dart';
import 'package:bsvt/models/community_prefrence_model.dart';
import 'package:bsvt/models/divorce_status_mmodel.dart';
import 'package:bsvt/models/married_before_mmodel.dart';
import 'package:bsvt/models/profession_model.dart';
import 'package:bsvt/models/samaj_model.dart';
import 'package:bsvt/models/work_after_marriage_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getX;

import '../controllers/home_controller.dart';
import '../models/members_data_model.dart';
import '../models/user_data_model.dart';
import '../models/sponsors_model.dart';
import 'api.dart';
import 'shared_pref_helper.dart';
import '../vivah_app/core/api/api_client.dart';
import '../vivah_app/core/services/firebase_notification_service.dart';

class ApiHelper {
  ApiHelper._();

  static ApiHelper apiHelper = ApiHelper._();
  API api = API();
  String authorizationToken = '';

  void getAuthorizationToken() {
    HomeController homeController = getX.Get.put(HomeController());
    authorizationToken =
        homeController.userDataWithToken.value.data?.token ?? '';
    if (authorizationToken.isEmpty) {
      final legacy = SharedPrefHelper.sharedPreferences.getString('userData');
      if (legacy != null && legacy.isNotEmpty) {
        try {
          final map = jsonDecode(legacy);
          authorizationToken = map['data']?['token'] ?? '';
        } catch (_) {}
      }
    }
    if (authorizationToken.isEmpty) {
      try {
        final prefsToken = SharedPrefHelper.sharedPreferences.getString('vivah_auth_token');
        if (prefsToken != null && prefsToken.isNotEmpty) {
          authorizationToken = prefsToken;
        }
      } catch (_) {}
    }
    log("Active Auth Token: $authorizationToken");
  }

  Future<List> getCommunityDataList() async {
    try {
      getAuthorizationToken();
      // var data = FormData.fromMap({
      //   'school_id': schoolId,
      //   'current_std': currentStd,
      // });
      Response response = await api.dio.post(
        'comunity',
      );
      if (response.statusCode == 200) {
        var data = response.data;
        return data == null ? [] : data['data'] ?? [];
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<List<MembersDataModel>> getAllMembersDataList({
    required String heightFrom,
    required String heightTo,
    required List<String> educationCategory,
    required String haveMarriedBefore,
    required String ageFrom,
    required String ageTo,
    required String? incomeFrom,
    required String? incomeTo,
    required String isManglik,
    required String excludeGotra,
  }) async {
    getAuthorizationToken();
    debugPrint("${{
      'height_from': heightFrom,
      'height_to': heightTo,
      'have_married_before': haveMarriedBefore,
      'income_from': haveMarriedBefore,
      'income_to': haveMarriedBefore,
      'age_from': incomeFrom,
      'age_to': ageTo,
      'exclude_gotra': excludeGotra,
      'is_manglik': isManglik.toLowerCase(),
    }} ::::: filter data");
    var data = FormData.fromMap({
      'height_from': heightFrom,
      'height_to': heightTo,
      'have_married_before': haveMarriedBefore,
      'age_from': ageFrom,
      'age_to': ageTo,
      'income_from': incomeFrom,
      'income_to': incomeTo,
      'exclude_gotra': excludeGotra,
      'is_manglik': isManglik.toLowerCase(),
    });

    for (String category in educationCategory) {
      data.fields.add(MapEntry('education_category[]', category));
    }

    var headers = {
      'Authorization': 'Bearer $authorizationToken',
    };

    Response response = await api.dio.post('fetch-filter',
        data: data,
        options: Options(
          headers: headers,
        ));

    debugPrint('Members: ${data.fields}');
    if (response.statusCode == 200) {
      debugPrint('Response: ${response.data}');
      var data = response.data;
      debugPrint('Data: ${data.runtimeType} $data');
      return List.from(data == null
          ? []
          : data['data'] == null
          ? []
          : data['data'].map((e) => MembersDataModel.fromJson(e)).toList());
    } else {
      return [];
    }
  }

  Future<MembersDataModel> getSelectedembersDataList({
    required String id,
  }) async {
    getAuthorizationToken();
    try {
      var headers = {
        'Authorization': 'Bearer $authorizationToken',
      };
      var data = FormData.fromMap({'profile_id': id});

      Response response = await api.dio.post('fetch-profiles-by-id',
          data: data,
          options: Options(
            headers: headers,
          ));

      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('$data');
        return MembersDataModel.fromJson(data["data"][0]);
      } else {
        debugPrint('${response.statusMessage}');
        return MembersDataModel();
      }
    } catch (e) {
      return MembersDataModel();
    }
  }

  Future<List<SponsorItem>?> getSponsersList() async {
    getAuthorizationToken();
    try {
      var headers = {
        'Authorization': 'Bearer $authorizationToken',
      };

      Response response = await api.dio.post('fetch-sponsers',
          options: Options(
            headers: headers,
          ));

      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('$data');
        return SponsoredModel.fromJson(data).data ?? [];
      } else {
        debugPrint('${response.statusMessage}');
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<BudgetCategoriesModel> getBudgetCate() async {
    getAuthorizationToken();

    Response response = await api.dio.post(
      'budgetCategories',
    );

    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint('$data');
      return BudgetCategoriesModel.fromJson(data);
    } else {
      debugPrint('${response.statusMessage}');
      return BudgetCategoriesModel();
    }
  }

  Future<ProfessionModel> getProfession() async {
    getAuthorizationToken();

    Response response = await api.dio.post(
      'fetch-profession',
    );

    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint('$data');
      return ProfessionModel.fromJson(data);
    } else {
      debugPrint('${response.statusMessage}');
      return ProfessionModel();
    }
  }

  Future<CommunityPreModel> getCommunityPreferences() async {
    getAuthorizationToken();

    Response response = await api.dio.post(
      'fetch-community-preferences',
    );

    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint('$data');
      return CommunityPreModel.fromJson(data);
    } else {
      debugPrint('${response.statusMessage}');
      return CommunityPreModel();
    }
  }

  Future<MarriedBeforeModel> getMarriedBefore() async {
    getAuthorizationToken();

    Response response = await api.dio.post(
      'fetch-married-before',
    );

    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint('$data');
      return MarriedBeforeModel.fromJson(data);
    } else {
      debugPrint('${response.statusMessage}');
      return MarriedBeforeModel();
    }
  }

  Future<DivorceStatusModel> getDivorceStatus() async {
    getAuthorizationToken();

    Response response = await api.dio.post(
      'fetch-divorce-status',
    );

    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint('$data');
      return DivorceStatusModel.fromJson(data);
    } else {
      debugPrint('${response.statusMessage}');
      return DivorceStatusModel();
    }
  }

  Future<ChildrenWithModel> getChildrenWith() async {
    getAuthorizationToken();

    Response response = await api.dio.post(
      'fetch-childrenwith',
    );

    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint('$data');
      return ChildrenWithModel.fromJson(data);
    } else {
      debugPrint('${response.statusMessage}');
      return ChildrenWithModel();
    }
  }

  Future<SamajModel> getSamaj() async {
    getAuthorizationToken();

    var headers = {
      'Authorization': 'Bearer $authorizationToken',
    };
    Response response = await api.dio.post('fetch-samaj',
        options: Options(
          headers: headers,
        ));

    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint('$data');
      return SamajModel.fromJson(data);
    } else {
      debugPrint('${response.statusMessage}');
      return SamajModel();
    }
  }

  Future<WorkAfterMarriageModel> getWorkMarriage() async {
    getAuthorizationToken();

    Response response = await api.dio.post(
      'fetch-workmarriage',
    );

    if (response.statusCode == 200) {
      var data = response.data;
      debugPrint('$data');
      return WorkAfterMarriageModel.fromJson(data);
    } else {
      debugPrint('${response.statusMessage}');
      return WorkAfterMarriageModel();
    }
  }

  Future<User?> fetchProfile() async {
    try {
      getAuthorizationToken();

      var headers = {
        'Authorization': 'Bearer $authorizationToken',
      };

      Response response = await api.dio.post('fetch-profile',
          options: Options(
            headers: headers,
          ));
      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('Data: ${data.runtimeType} ${data['data']}');
        return User.fromJson(data["data"]);
      } else {
        return null;
      }
    } catch (error) {
      debugPrint('error $error');
      return null;
    }
  }

  Future postDeleteProfileApi() async {
    try {
      getAuthorizationToken();
      var headers = {
        'Authorization': 'Bearer $authorizationToken',
      };
      Response response = await api.dio.post(
        'app-delete-profile',
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('$data');
        debugPrint('Data: ${data.runtimeType} ${data['data'].runtimeType}');

        return data;
      } else {
        return {};
      }
    } catch (error) {
      debugPrint(error.toString());
      try {
        var headers = {
          'Authorization': 'Bearer $authorizationToken',
        };
        Response fallback = await api.dio.post(
          'delete-account',
          options: Options(
            headers: headers,
          ),
        );
        return fallback.data ?? {};
      } catch (_) {
        return {};
      }
    }
  }

  Future<String> editProfile({
    required String profession,
    required String compName,
    required String compType,
    required String incomeLakh,
    required String marriedBrother,
    required String unmarriedBrother,
    required String marriedSister,
    required String unmarriedSister,
    required String altContactName,
    required String alterCnctNum,
    required String fullPhoto,
    required String facePhoto,
    required String briefFatherProfession,
    required String sameGothra,
    required String matchGanna,
    required String isManglik,
    required String marryManglik,
    required String olderBy,
    required String youngerBy,
    required String bridebudget,
    required String groombudget,
    required String workAftrMarrige,
    required String numYraddrs,
    required String ownrent,
    required String marriedBfor,
    required String resAddress,
  }) async {
    try {
      getAuthorizationToken();
      var data = FormData.fromMap({
        'profession': profession,
        'compName': compName,
        'compType': compType,
        'incomeLakh': incomeLakh,
        'marriedbrother': marriedBrother,
        'unmarriedbrother': unmarriedBrother,
        'marriedsister': marriedSister,
        'unmarriedsister': unmarriedSister,
        'altContactName': altContactName,
        'alterCnctNum': alterCnctNum,
        'resAddress': resAddress,
        'numYraddrs': numYraddrs,
        'ownrent': ownrent,
        'marriedBfor': marriedBfor,
        /* 'divorceStatus': divorceStatus,
        'children': children,
        'childrenWith': childrenWith,*/
        'sameGothra': sameGothra,
        'matchGanna': matchGanna,
        'isManglik': isManglik,
        'marryManglik': marryManglik,
        'olderBy': olderBy,
        'youngerBy': youngerBy,
        'bridebudget': bridebudget,
        'groombudget': groombudget,
        'workAftrMarrige': workAftrMarrige,
        //'resaftrMarrige':  resaftrMarrige,
        'brief_father_profession': briefFatherProfession,
        /* 'fullPhoto': fullPhoto.isEmpty
            ? ''
            : await MultipartFile.fromFile(
                fullPhoto,
                filename: fullPhoto.split('/').last,
              ),
        'facePhoto': facePhoto.isEmpty
            ? ''
            : await MultipartFile.fromFile(
                facePhoto,
                filename: facePhoto.split('/').last,
              ),*/
      });
      debugPrint({
        'profession': profession,
        'compName': compName,
        'compType': compType,
        'incomeLakh': incomeLakh,
        'marriedbrother': marriedBrother,
        'unmarriedbrother': unmarriedBrother,
        'marriedsister': marriedSister,
        'unmarriedsister': unmarriedSister,
        'altContactName': altContactName,
        'alterCnctNum': alterCnctNum,
        'resAddress': resAddress,
        'numYraddrs': numYraddrs,
        'ownrent': ownrent,
        'marriedBfor': marriedBfor,
        'sameGothra': sameGothra,
        'matchGanna': matchGanna,
        'isManglik': isManglik,
        'marryManglik': marryManglik,
        'olderBy': olderBy,
        'youngerBy': youngerBy,
        'bridebudget': bridebudget,
        'groombudget': groombudget,
        'workAftrMarrige': workAftrMarrige,
        'brief_father_profession': briefFatherProfession,
      }.toString());
      var headers = {
        'Authorization': 'Bearer $authorizationToken',
      };

      Response response = await api.dio.post(
        'update-profile',
        data: data,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        var data = response.data;

        debugPrint('Response Type: ${data.runtimeType}, Data: ${data['data']}');
        debugPrint('Response Type: ${data.runtimeType}, Data: $data');
        return data["msg"].toString();
      } else {
        return "";
      }
    } catch (error) {
      debugPrint('Error: $error');
      return "";
    }
  }

  Future<String> editProfilePhoto({
    required String fullPhoto,
    required String facePhoto,
  }) async {
    try {
      getAuthorizationToken();
      var data = FormData.fromMap({
        'fullPhoto': fullPhoto.isEmpty
            ? ''
            : await MultipartFile.fromFile(
          fullPhoto,
          filename: fullPhoto.split('/').last,
        ),
        'facePhoto': facePhoto.isEmpty
            ? ''
            : await MultipartFile.fromFile(
          facePhoto,
          filename: facePhoto.split('/').last,
        ),
      });
      debugPrint('${{
        'fullPhoto': fullPhoto.isEmpty
            ? ''
            : await MultipartFile.fromFile(
          fullPhoto,
          filename: fullPhoto.split('/').last,
        ),
        'facePhoto': facePhoto.isEmpty
            ? ''
            : await MultipartFile.fromFile(
          facePhoto,
          filename: facePhoto.split('/').last,
        ),
      }}');
      debugPrint('$data');
      debugPrint('update-profile-image');
      var headers = {
        'Authorization': 'Bearer $authorizationToken',
      };

      Response response = await api.dio.post(
        'update-profile-image',
        data: data,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('editProfilePhoto Response Data: $data');
        debugPrint(
            'editProfilePhoto Response Type: ${data.runtimeType}, Data: ${data['data']}');
        return data["msg"].toString();
      } else {
        return "";
      }
    } catch (error) {
      debugPrint('editProfilePhoto Error: $error');
      return "";
    }
  }

  Future<String> insertFeedback({
    required String profileId,
    required String description,
  }) async {
    try {
      getAuthorizationToken();
      debugPrint(jsonEncode({
        'to_profile_id': profileId,
        'description': description,
      }));
      var data = FormData.fromMap({
        'to_profile_id': profileId,
        'description': description,
      });

      var headers = {
        'Authorization': 'Bearer $authorizationToken',
      };

      Response response = await api.dio.post(
        'create-feedback',
        data: data,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('Success : ${response.data}');
        return data == null
            ? ''
            : data['msg'] == null
            ? ''
            : data['msg'].toString();
      } else {
        debugPrint('Success : ${response.statusMessage}');
        return '';
      }
    } catch (error) {
      debugPrint('error $error');
      return '';
    }
  }

  Future<String> insertComplainFeedback({
    required String profileId,
    required String description,
  }) async {
    try {
      getAuthorizationToken();
      debugPrint(jsonEncode({
        'to_profile_id': profileId,
        'description': description,
      }));
      var data = FormData.fromMap({
        'to_profile_id': profileId,
        'description': description,
      });

      var headers = {
        'Authorization': 'Bearer $authorizationToken',
      };

      Response response = await api.dio.post(
        'create-feedback',
        data: data,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('Success : ${response.data}');
        return data == null
            ? ''
            : data['msg'] == null
            ? ''
            : data['msg'].toString();
      } else {
        debugPrint('Success : ${response.statusMessage}');
        return '';
      }
    } catch (error) {
      debugPrint('error $error');
      return '';
    }
  }

  Future<List> getGotraDataListCommunityWise({
    required String comunityId,
  }) async {
    try {
      getAuthorizationToken();
      var data = FormData.fromMap({
        'community': comunityId,
      });
      Response response = await api.dio.post(
        'gotra',
        data: data,
      );
      debugPrint('${response.data}');
      if (response.statusCode == 200) {
        var data = response.data;
        return data == null ? [] : data['data'] ?? [];
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<List<String>> getGotraDataList() async {
    try {
      getAuthorizationToken();
      var headers = {'Authorization': 'Bearer $authorizationToken'};
      Response response = await api.dio.post(
        'fetch-gotra-filter',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        var data = response.data;
        List<String> dataList = [];
        if (data != null) {
          for (int i = 0; i < data["data"].length; i++) {
            dataList.add(data["data"][i]["gotra_name"]);
          }
        }
        return dataList;
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<List> getEducationDataList() async {
    try {
      getAuthorizationToken();
      // var data = FormData.fromMap({
      //   'school_id': schoolId,
      //   'current_std': currentStd,
      // });
      var headers = {'Authorization': 'Bearer $authorizationToken'};
      Response response = await api.dio.post(
        'education',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('Data: $data');
        return data == null ? [] : data['data'] ?? [];
      } else {
        return [];
      }
    } catch(error) {
      debugPrint('Error: $error');
      return [];
    }
  }

    Future<Map> newSignup({
    required String fname,
    required String gender,
    required String dobs,
    required String birthtime,
    required String placeofBirth,
    required String heightFeet,
    required String heightInch,
    required String email,
    required String eduQualification,
    required String eduQualificationOther,
    required String profession,
    required String otherProfession,
    required String businessName,
    required String businessType,
    required String compName,
    required String compType,
    required String incomeLakh,
    required String profilePhysicalDisablity,
    required String fatherName,
    required String motherName,
    required String community,
    required String gotra,
    required String profileMarryInCommunity,
    required String marriedBrother,
    required String unmarriedBrother,
    required String marriedSister,
    required String unmarriedSister,
    required String sameGothra,
    required String matchGanna,
    required String isManglik,
    required String marryManglik,
    required String mainContactName,
    required String mainContactNum,
    required String altContactName,
    required String alterCnctNum,
    required String resAddress,
    required String numYraddrs,
    required String ownrent,
    required String marriedBfor,
    required String divorceStatus,
    required String children,
    required String childrenWith,
    required String olderBy,
    required String youngerBy,
    required String resaftrMarrige,
    required String bridebudget,
    required String groombudget,
    required String workAftrMarrige,
    required String briefFatherProfession,
    required String fullPhoto,
    required String facePhoto,
    }) async {
    try {
    getAuthorizationToken();
    var data = FormData.fromMap({
    'fname': fname,
    'gender': gender,
    'dobs': dobs,
    'birthtime': birthtime,
    'placeofBirth': placeofBirth,
    'heightFeet': heightFeet,
    'heightInch': heightInch,
    'email': email,
    'eduqualification': eduQualification,
    'eduqualification_other': eduQualificationOther,
    'profession': profession,
    'otherProfession': otherProfession,
    'businessName': businessName,
    'businessType': businessType,
    'compName': compName,
    'compType': compType,
    'incomeLakh': incomeLakh,
    'profile_physical_disablity': profilePhysicalDisablity,
    'fatherName': fatherName,
    'motherName': motherName,
    'community': community,
    'gotra': gotra,
    'profile_marry_in_comunity': profileMarryInCommunity,
    'marriedbrother': marriedBrother,
    'unmarriedbrother': unmarriedBrother,
    'marriedsister': marriedSister,
    'unmarriedsister': unmarriedSister,
    'sameGothra': sameGothra,
    'matchGanna': matchGanna,
    'isManglik': isManglik,
    'marryManglik': marryManglik,
    'mainContactName': mainContactName,
    'mainContactNum': mainContactNum,
    'altContactName': altContactName,
    'alterCnctNum': alterCnctNum,
    'resAddress': resAddress,
    'numYraddrs': numYraddrs,
    'ownrent': ownrent,
    'marriedBfor': marriedBfor,
    'divorceStatus': divorceStatus,
    'children': children,
    'childrenWith': childrenWith,
    'olderBy': olderBy,
    'youngerBy': youngerBy,
    'resaftrMarrige': resaftrMarrige,
    'bridebudget': bridebudget,
    'groombudget': groombudget,
    'workAftrMarrige': workAftrMarrige,
    'brief_father_profession': briefFatherProfession,
    'fullPhoto': fullPhoto.isEmpty
    ? ''
        : await MultipartFile.fromFile(
    fullPhoto,
    filename: fullPhoto.split('/').isEmpty
    ? null
        : fullPhoto.split('/').last,
    ),
    'facePhoto': facePhoto.isEmpty
    ? ''
        : await MultipartFile.fromFile(
    facePhoto,
    filename: facePhoto.split('/').isEmpty
    ? null
        : facePhoto.split('/').last,
    ),
    });
    log(data.files.toString());
    log(data.fields.toString());
    // Response response;
    /* Response response = await api.dio.post(
        'signup',
        data: data,
      );*/

    /*if (response.statusCode == 200) {
        var data = response.data;
        print('Success: ${response.data}');
        return data;
      } else {
        print('Error: ${response.statusCode} ${response.statusMessage}');
        return {};
      }*/
    return {};
    } catch (error) {
    debugPrint('Error: $error');
    return {};
    }
    }

    Future<Map> loginUser({
    required String profileId,
    required String password,
    required String deviceId,
    }) async {
    try {
    getAuthorizationToken();
    final cleanDeviceId = (deviceId.trim().isNotEmpty &&
            deviceId.trim() != 'r' &&
            deviceId.trim().length > 3 &&
            !deviceId.contains('test_dev') &&
            !deviceId.contains('android_dev_'))
        ? deviceId.trim()
        : await FirebaseNotificationService.instance.getFcmToken();
    var data = FormData.fromMap({
      'profile_id': profileId.trim(),
      'mobile': profileId.trim(),
      'password': password.trim(),
      'device_id': cleanDeviceId,
      'profile_device_id': cleanDeviceId,
      'device_token': cleanDeviceId,
      'fcm_token': cleanDeviceId,
    });
    debugPrint('Data Fields: ${data.fields}');
    Response response;
    try {
      response = await api.dio.post(
        'app-login',
        data: data,
      );
    } catch (_) {
      response = await api.dio.post(
        'login',
        data: data,
      );
    }
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Data: ${response.data}');
    if (response.statusCode == 200 && response.data != null) {
      var data = response.data;
      debugPrint('Success: ${response.data}');
      try {
        String? t;
        if (data is Map && data['data'] is Map) {
          t = data['data']['token']?.toString();
        }
        if (t != null && t.isNotEmpty) {
          authorizationToken = t;
          await ApiClient().setToken(t);
        }
      } catch (_) {}
      return data;
    } else {
    debugPrint('Error== ${response.statusMessage}');
    return {};
    }
    } catch (error) {
    debugPrint('Error--: $error');
    return {};
    }
    }

    Future<List<MembersDataModel>> getAllShortlistedDataList() async {
    getAuthorizationToken();

    var headers = {
    'Authorization': 'Bearer $authorizationToken',
    };

    Response response = await api.dio.post(
    'fetch-shortlist-profile',
    options: Options(
    headers: headers,
    ),
    );
    if (response.statusCode == 200) {
    var data = response.data;
    debugPrint('Data: ${data.runtimeType} ${data['data'].runtimeType}');
    return List.from(data == null
    ? []
        : data['data'] == null
    ? []
        : data['data'].map((e) => MembersDataModel.fromJson(e)).toList());
    } else {
    return [];
    }
    }

    Future<Map> setMyShortlistProfile({
    required String profileId,
    }) async {
    try {
    getAuthorizationToken();
    var data = FormData.fromMap({
    'shortlisted_profile_id': profileId,
    });

    var headers = {
    'Authorization': 'Bearer $authorizationToken',
    };

    debugPrint('Data Fields: ${data.fields}');
    Response response = await api.dio.post(
    'update-set-shortlist-profile',
    data: data,
    options: Options(
    headers: headers,
    ),
    );
    debugPrint('Data: ${response.statusCode}');
    if (response.statusCode == 200) {
    var data = response.data;
    debugPrint('Success: ${response.data}');
    return data;
    } else {
    debugPrint('Error== ${response.statusMessage}');
    return {};
    }
    } catch (error) {
    debugPrint('Error--: $error');
    return {};
    }
    }

    Future<Map> unSetMyShortlistProfile({
    required String profileId,
    }) async {
    try {
    getAuthorizationToken();
    var data = FormData.fromMap({
    'shortlisted_profile_id': profileId,
    });

    var headers = {
    'Authorization': 'Bearer $authorizationToken',
    };

    debugPrint('Data: ${data.fields}');
    Response response = await api.dio.post(
    'update-un-shortlist-profile',
    data: data,
    options: Options(
    headers: headers,
    ),
    );
    debugPrint('Data: ${response.statusCode}');
    if (response.statusCode == 200) {
    var data = response.data;
    debugPrint('Success: ${response.data}');
    return data;
    } else {
    debugPrint('Error== ${response.statusMessage}');
    return {};
    }
    } catch (error) {
    debugPrint('Error--: $error');
    return {};
    }
    }
  }
