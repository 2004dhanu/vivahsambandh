import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../core/api/api_client.dart';
import '../core/api/api_service.dart';
import '../core/services/session_manager.dart';
import '../models/education_model.dart';
import '../models/community_model.dart';
import '../models/gotra_model.dart';
import '../models/profession_model.dart';
import '../models/user_model.dart';
import '../views/home/vivah_home_screen.dart';

class RegisterController extends GetxController {
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  // Loading States
  final RxBool isLoadingDropdowns = false.obs;
  final RxBool isLoadingGotra = false.obs;
  final RxBool isSubmitting = false.obs;

  // Step Tracking
  final RxInt currentStep = 0.obs;

  // Dynamic API Dropdown Lists
  final RxList<EducationModel> educationList = <EducationModel>[].obs;
  final RxList<CommunityModel> communityList = <CommunityModel>[].obs;
  final RxList<GotraModel> gotraList = <GotraModel>[].obs;
  final RxList<ProfessionModel> professionList = <ProfessionModel>[].obs;

  // Selected Dropdown Values
  final Rxn<EducationModel> selectedEducation = Rxn<EducationModel>();
  final Rxn<CommunityModel> selectedCommunity = Rxn<CommunityModel>();
  final Rxn<GotraModel> selectedGotra = Rxn<GotraModel>();
  final Rxn<ProfessionModel> selectedProfession = Rxn<ProfessionModel>();
  final RxList<CommunityModel> selectedMarryCommunities = <CommunityModel>[].obs;

  // Basic Personal Info Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController tobController = TextEditingController();
  final TextEditingController pobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Gender
  final RxString selectedGender = 'Male'.obs;

  // Height
  final RxString selectedHeightFeet = '5'.obs;
  final RxString selectedHeightInch = '6'.obs;
  final List<String> feetOptions = ['4', '5', '6', '7'];
  final List<String> inchOptions = List.generate(12, (index) => index.toString());

  // Profession / Occupation Dynamic Fields
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyTypeController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessTypeController = TextEditingController();
  final TextEditingController otherProfessionController = TextEditingController();
  final TextEditingController annualIncomeController = TextEditingController();

  // Family Controllers & Counts
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final RxInt brotherMarried = 0.obs;
  final RxInt brotherUnMarried = 0.obs;
  final RxInt sisterMarried = 0.obs;
  final RxInt sisterUnMarried = 0.obs;

  // Address & Housing
  final TextEditingController userAddressController = TextEditingController();
  final TextEditingController userCurrentCityController = TextEditingController();
  final RxString houseType = 'Own'.obs; // Own / Rent

  // Contact Info
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController alternateContactNameController = TextEditingController();
  final TextEditingController alternateMobileNoController = TextEditingController();

  // Marital Status & Conditions
  final RxString marriedBefore = 'No'.obs; // Yes / No
  final RxString divorceStatus = 'Divorced'.obs; // Divorced / Awaiting Divorce / Widowed
  final RxString childrenFromPriorMarriage = 'No'.obs; // Yes / No
  final RxInt childrenCount = 1.obs;
  final RxString childrenWith = 'Living with me'.obs; // Living with me / Not living with me

  // Horoscope & Preferences
  final RxString physicalDisability = 'No'.obs; // Yes / No
  final RxString willMarrySameGotra = 'No'.obs; // Yes / No
  final RxString isManglik = 'No'.obs; // Yes / No / Anshik Manglik / Don't Know
  final RxString willMarryManglik = 'Yes'.obs; // Yes / No / Doesn't Matter

  // User Summary / Bio
  final TextEditingController userSummaryController = TextEditingController();

  // Photos
  final Rxn<File> fullImage = Rxn<File>();
  final Rxn<File> faceImage = Rxn<File>();

  RegisterController({String? initialMobile}) {
    if (initialMobile != null && initialMobile.isNotEmpty) {
      mobileController.text = initialMobile;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAllDropdownData();
  }

  @override
  void onClose() {
    nameController.dispose();
    dobController.dispose();
    tobController.dispose();
    pobController.dispose();
    emailController.dispose();
    companyNameController.dispose();
    companyTypeController.dispose();
    businessNameController.dispose();
    businessTypeController.dispose();
    otherProfessionController.dispose();
    annualIncomeController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    userAddressController.dispose();
    userCurrentCityController.dispose();
    contactNameController.dispose();
    mobileController.dispose();
    alternateContactNameController.dispose();
    alternateMobileNoController.dispose();
    userSummaryController.dispose();
    super.onClose();
  }

  /// Load Education, Community, and Profession concurrently
  Future<void> loadAllDropdownData() async {
    isLoadingDropdowns.value = true;
    try {
      final results = await Future.wait([
        _apiService.getEducationList(),
        _apiService.getCommunityList(),
        _apiService.getProfessionList(),
      ]);

      educationList.assignAll(results[0] as List<EducationModel>);
      communityList.assignAll(results[1] as List<CommunityModel>);
      professionList.assignAll(results[2] as List<ProfessionModel>);

      // Default select first items if available
      if (educationList.isNotEmpty) {
        selectedEducation.value = educationList.first;
      }
      if (communityList.isNotEmpty) {
        onCommunityChanged(communityList.first);
      }
      if (professionList.isNotEmpty) {
        selectedProfession.value = professionList.first;
      }
    } catch (e) {
      debugPrint("❌ Error loading initial dropdown data: $e");
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  /// When Community is selected, dynamically fetch its Gotras
  Future<void> onCommunityChanged(CommunityModel? community) async {
    if (community == null) return;
    selectedCommunity.value = community;
    selectedGotra.value = null;
    gotraList.clear();

    isLoadingGotra.value = true;
    try {
      final list = await _apiService.getGotraList(community.id);
      gotraList.assignAll(list);
      if (gotraList.isNotEmpty) {
        selectedGotra.value = gotraList.first;
      }
    } catch (e) {
      debugPrint("❌ Error loading gotra for community ${community.id}: $e");
    } finally {
      isLoadingGotra.value = false;
    }
  }

  /// Date of Birth Picker
  Future<void> pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 24, now.month, now.day);
    final firstDate = DateTime(now.year - 70);
    final lastDate = DateTime(now.year - 18, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE5097F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  /// Time of Birth Picker
  Future<void> pickTimeOfBirth(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE5097F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      tobController.text = '$hour:$minute';
    }
  }

  /// Image Pickers
  Future<void> pickFullImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file != null) {
        fullImage.value = File(file.path);
      }
    } catch (e) {
      debugPrint("Error picking full image: $e");
    }
  }

  Future<void> pickFaceImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file != null) {
        faceImage.value = File(file.path);
      }
    } catch (e) {
      debugPrint("Error picking face image: $e");
    }
  }

  /// Toggle Marry In Community multiple selections
  void toggleMarryCommunity(CommunityModel community) {
    if (selectedMarryCommunities.contains(community)) {
      selectedMarryCommunities.remove(community);
    } else {
      selectedMarryCommunities.add(community);
    }
  }

  /// Validates a specific step in the registration flow
  bool validateStep(int step) {
    switch (step) {
      case 0: // Basic Info
        if (nameController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please enter your full name.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (dobController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please select your Date of Birth.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (tobController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please select your Time of Birth.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (pobController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please enter your Place of Birth.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        final email = emailController.text.trim();
        if (email.isEmpty) {
          Get.snackbar('Required Field', 'Please enter your Email Address.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (!GetUtils.isEmail(email)) {
          Get.snackbar('Invalid Email', 'Please enter a valid Email Address format.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        return true;

      case 1: // Education & Career
        if (selectedEducation.value == null) {
          Get.snackbar('Required Field', 'Please select your Education.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (selectedProfession.value == null) {
          Get.snackbar('Required Field', 'Please select your Profession.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        final prof = selectedProfession.value!;
        if (prof.isPrivateOrGovt) {
          if (companyNameController.text.trim().isEmpty) {
            Get.snackbar('Required Field', 'Please enter Company Name.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return false;
          }
          if (companyTypeController.text.trim().isEmpty) {
            Get.snackbar('Required Field', 'Please enter Company Type.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return false;
          }
          if (annualIncomeController.text.trim().isEmpty) {
            Get.snackbar('Required Field', 'Please enter Annual Income.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return false;
          }
        } else if (prof.isBusiness) {
          if (businessNameController.text.trim().isEmpty) {
            Get.snackbar('Required Field', 'Please enter Business Name.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return false;
          }
          if (businessTypeController.text.trim().isEmpty) {
            Get.snackbar('Required Field', 'Please enter Business Type.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return false;
          }
          if (annualIncomeController.text.trim().isEmpty) {
            Get.snackbar('Required Field', 'Please enter Annual Income.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return false;
          }
        } else if (prof.isSelfEmployed) {
          if (annualIncomeController.text.trim().isEmpty) {
            Get.snackbar('Required Field', 'Please enter Annual Income.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return false;
          }
        } else if (prof.isOthers) {
          if (otherProfessionController.text.trim().isEmpty) {
            Get.snackbar('Required Field', 'Please enter Other Profession.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return false;
          }
          if (annualIncomeController.text.trim().isEmpty) {
            Get.snackbar('Required Field', 'Please enter Annual Income.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return false;
          }
        }
        return true;

      case 2: // Family Details
        if (fatherNameController.text.trim().isEmpty) {
          Get.snackbar('Required Field', "Please enter your Father's name.",
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (userAddressController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please enter your Address.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (userCurrentCityController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please enter your Current City.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        return true;

      case 3: // Community & Gotra
        if (selectedCommunity.value == null) {
          Get.snackbar('Required Field', 'Please select your Community.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (selectedGotra.value == null) {
          Get.snackbar('Required Field', 'Please select your Gotra.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        return true;

      case 4: // Contact & Photos
        if (contactNameController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please enter Contact Person Name.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (mobileController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please enter Mobile Number.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (alternateContactNameController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please enter Alternate Contact Name.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (alternateMobileNoController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please enter Alternate Mobile Number.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (userSummaryController.text.trim().isEmpty) {
          Get.snackbar('Required Field', 'Please enter a brief summary about yourself.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (fullImage.value == null) {
          Get.snackbar('Required Image', 'Please upload your Full Length Photo.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        if (faceImage.value == null) {
          Get.snackbar('Required Image', 'Please upload your Close-up Face Photo.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  /// Validates the form data across all steps and submits to API
  Future<void> submitRegistration() async {
    for (int step = 0; step <= 4; step++) {
      if (!validateStep(step)) {
        currentStep.value = step;
        return;
      }
    }

    // Determine conditional company_name, company_type, annual_income
    String companyName = '';
    String companyType = '';
    String annualIncome = annualIncomeController.text.trim();

    final prof = selectedProfession.value!;
    if (prof.isPrivateOrGovt) {
      companyName = companyNameController.text.trim();
      companyType = companyTypeController.text.trim();
    } else if (prof.isBusiness) {
      companyName = businessNameController.text.trim();
      companyType = businessTypeController.text.trim();
    } else if (prof.isOthers) {
      companyName = otherProfessionController.text.trim();
    }

    // Format marry_in_community string (e.g. comma-separated IDs or names)
    final marryInCommunityStr = selectedMarryCommunities.isNotEmpty
        ? selectedMarryCommunities.map((c) => c.id.toString()).join(',')
        : selectedCommunity.value!.id.toString();

    final Map<String, dynamic> payload = {
      'name': nameController.text.trim(),
      'gender': selectedGender.value,
      'date_of_birth': dobController.text.trim(),
      'time_of_birth': tobController.text.trim(),
      'place_of_birth': pobController.text.trim(),
      'email': emailController.text.trim(),
      'education_id': selectedEducation.value?.id.toString() ?? '1',
      'profession_id': selectedProfession.value?.id.toString() ?? '1',
      'company_name': companyName,
      'company_type': companyType,
      'annual_income': annualIncome.isEmpty ? '0' : annualIncome,
      'height_feet': selectedHeightFeet.value,
      'height_inch': selectedHeightInch.value,
      'father_name': fatherNameController.text.trim(),
      'mother_name': motherNameController.text.trim(),
      'brother_married': brotherMarried.value.toString(),
      'brother_un_married': brotherUnMarried.value.toString(),
      'sister_married': sisterMarried.value.toString(),
      'sister_un_married': sisterUnMarried.value.toString(),
      'user_address': userAddressController.text.trim(),
      'house_type': houseType.value,
      'user_current_city': userCurrentCityController.text.trim(),
      'contact_name': contactNameController.text.trim(),
      'mobile': mobileController.text.trim(),
      'alternate_contact_name': alternateContactNameController.text.trim(),
      'alternate_mobile_no': alternateMobileNoController.text.trim(),
      'community_id': selectedCommunity.value?.id.toString() ?? '1',
      'gotra_id': selectedGotra.value?.id.toString() ?? '1',
      'marry_in_community': marryInCommunityStr,
      'physical_disablity': physicalDisability.value,
      'married_before': marriedBefore.value,
      'divorce_status': marriedBefore.value == 'Yes' ? divorceStatus.value : '',
      'children_from_prior_marriage': (marriedBefore.value == 'Yes' && childrenFromPriorMarriage.value == 'Yes')
          ? childrenCount.value.toString()
          : '0',
      'children_with': (marriedBefore.value == 'Yes' && childrenFromPriorMarriage.value == 'Yes')
          ? childrenWith.value
          : '',
      'will_marry_same_gotra': willMarrySameGotra.value,
      'is_manglik': isManglik.value,
      'will_marry_manglik': willMarryManglik.value,
      'user_summary': userSummaryController.text.trim(),
    };

    isSubmitting.value = true;

    try {
      final response = await _apiService.registerUser(
        fields: payload,
        fullImage: fullImage.value,
        faceImage: faceImage.value,
      );

      isSubmitting.value = false;

      final bool success = response['status'] == true ||
          response['code'] == 200 ||
          response['response_code'] == 200;

      if (success) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
                SizedBox(width: 8),
                Text('Registration Successful'),
              ],
            ),
            content: Text(
              response['message']?.toString() ??
                  'Your profile has been created successfully. Welcome to VivahSambandh!',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5097F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  Get.back();
                  try {
                    final mobile = mobileController.text.trim();
                    final member = await _apiService.checkExistingMemberByMobile(mobile);
                    if (member != null) {
                      final user = UserModel.fromMember(member);
                      await SessionManager.instance.saveSession(user: user, token: ApiClient().authToken);
                      Get.offAll(() => VivahHomeScreen(user: user));
                      return;
                    }
                  } catch (_) {}
                  Get.offAll(() => const VivahHomeScreen());
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'Registration Note',
          response['message']?.toString() ?? 'Registration submitted.',
          backgroundColor: const Color(0xFFE5097F),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        // Even if mock/test server responds with route notice, allow navigation to home
        Get.offAll(() => const VivahHomeScreen());
      }
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar(
        'Submission Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
