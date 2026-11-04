import 'package:bsvt/screens/sign_up_screen/widget/photo_section.dart';
import 'package:bsvt/screens/sign_up_screen/widget/type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../controllers/home_controller.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import 'components/enums/signup_enums.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  RxString gender = ''.obs;
  RxString dob = ''.obs;
  RxString dobTime = ''.obs;
  HomeController homeController = Get.put(HomeController());
  RxMap selectedCommunityData = {}.obs;
  RxMap selectedGotraData = {}.obs;
  RxMap selectedEducationData = {}.obs;
  RxList heightFeetList = [
    '4',
    '5',
    '6',
    '7',
  ].obs;
  RxList heightInchList = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
  ].obs;
  RxList marriedUnMarriedList = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
  ].obs;

  RxString heightFeet = ''.obs;
  RxString heightInch = ''.obs;
  RxString brotherMarried = ''.obs;
  RxString brotherUnMarried = ''.obs;
  RxString sisterMarried = ''.obs;
  RxString sisterUnMarried = ''.obs;

  /// SELECTION OF RADIO BUTTON
  RxString selectedHouseType = ''.obs; // Default selection
  PartnerPreferences partnerPreferences = PartnerPreferences();

  RxList physicalAbilityList = [
    'Yes',
    'No',
  ].obs;
  RxList marriedBeforeList = [
    'No',
    'Yes And Divorced',
    'Yes And Spouse Dead',
  ].obs;
  RxString selectedPhysicalAbility = ''.obs;
  RxString selectedMarriedBefore = ''.obs;

  RxString selectedPhotoPath = ''.obs;
  RxString selectedFullFacePath = ''.obs;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtFullName = TextEditingController();
  RxString txtOccupation = "".obs;
  TextEditingController txtEmail = TextEditingController();

  //TextEditingController txtMobileNo = TextEditingController();
  //TextEditingController txtWhatsappNo = TextEditingController();
  TextEditingController txtMainContactNo = TextEditingController();
  TextEditingController txtFatherName = TextEditingController();
  TextEditingController txtMotherName = TextEditingController();
  TextEditingController txtReferenceName = TextEditingController();
  TextEditingController txtReferenceMobileNo = TextEditingController();

  //TextEditingController txtWorkingCity = TextEditingController();
  TextEditingController txtPlaceOfBirth = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController briefSummaryOfParents = TextEditingController();

  /// New field added from like panel which is optional
  TextEditingController companyNameCon = TextEditingController();
  TextEditingController companyTypeCon = TextEditingController();
  TextEditingController annualIncomeCon = TextEditingController();
  TextEditingController mainConNameCon = TextEditingController();
  TextEditingController altConNameCon = TextEditingController();
  TextEditingController altConNoCon = TextEditingController();
  TextEditingController noOfYearADCon = TextEditingController();

  FocusNode fullNameFocusNode = FocusNode();
  FocusNode occupationFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode whatsappNoFocusNode = FocusNode();
  FocusNode mainContactNoFocusNode = FocusNode();
  FocusNode fatherNameFocusNode = FocusNode();
  FocusNode motherNameFocusNode = FocusNode();
  FocusNode referenceNameFocusNode = FocusNode();
  FocusNode referenceMobileNoFocusNode = FocusNode();
  FocusNode workingCityFocusNode = FocusNode();
  FocusNode placeOfBirthFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode briefSummaryFocusNode = FocusNode();
  FocusNode reAfterMrgFocusNode = FocusNode();

  /// New field added
  FocusNode companyNameFocusNode = FocusNode();
  FocusNode companyTypeFocusNode = FocusNode();
  FocusNode mcNameFocusNode = FocusNode();
  FocusNode mcNoTypeFocusNode = FocusNode();
  FocusNode acNameFocusNode = FocusNode();
  FocusNode acNoFocusNode = FocusNode();
  FocusNode noOfYearADFocusNode = FocusNode();
  FocusNode childrenFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    debugPrint('Gender: ${gender.value}');
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: formKey,
          child: Stack(
            children: [
              // Background Image with Premium Dark Pink Gradient Overlay
              Container(
                width: Get.width,
                height: Get.height,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/image/loginPage.jpg',
                      width: Get.width,
                      height: Get.height,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: Get.width,
                      height: Get.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ConstHelper.darkRedColor.withOpacity(0.85),
                            ConstHelper.orangeDarkColor.withOpacity(0.9),
                            ConstHelper.orangeColor.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Obx(
                  () => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Get.width * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: Get.height * 0.05,
                        ),
                        Center(
                          child: Container(
                            height: Get.width / 3.2,
                            width: Get.width / 3.2,
                            decoration: BoxDecoration(
                              color: ConstHelper.whiteColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/image/vs_app_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Get.width / 25,
                        ),
                        Text(
                          'AGRAWAL SAMAJ VIKAS TRUST',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            color: ConstHelper.whiteColor,
                            fontSize: Get.width * 0.06,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(
                          height: Get.width / 20,
                        ),
                        Text(
                          'Register Now!',
                          style: GoogleFonts.inter(
                            color: ConstHelper.whiteColor,
                            fontSize: Get.width * 0.052,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            TextFormField(
                              style: TextStyle(
                                fontSize: Get.width * 0.04,
                                letterSpacing: 1,
                                color: ConstHelper.whiteColor,
                              ),
                              textInputAction: TextInputAction.next,
                              // Shows "Done" on the keyboard
                              controller: txtFullName,
                              maxLength: 50,
                              focusNode: fullNameFocusNode,
                              validator: (value) {
                                if (value == null || value
                                    .trim()
                                    .isEmpty) {
                                  return "Please enter full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: textFiledInputDecoration(
                                labelText: 'Full Name',
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Gender',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Select Gender',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: 'Male',
                                            child: Text(
                                              'Male',
                                              style: TextStyle(
                                                  color: ConstHelper.whiteColor,
                                                  fontSize: Get.width * 0.04,
                                                  letterSpacing: 1),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Female',
                                            child: Text(
                                              'Female',
                                              style: TextStyle(
                                                color: ConstHelper.whiteColor,
                                                fontSize: Get.width * 0.04,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          gender.value = value ?? '';
                                        },
                                        value: gender
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : gender.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (gender.value.isEmpty) {
                                        Get.snackbar(
                                          "Gender",
                                          "Please select gender",
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                        return;
                                      }
                                      EasyLoading.show(
                                          status: ConstHelper.pleaseWaitMsg);
                                      await Future.delayed(
                                          const Duration(milliseconds: 200));

                                      DateTime nowDateTime =
                                      await ConstHelper.getCurrentDateTime();
                                      EasyLoading.dismiss();

                                      // Determine minimum age based on gender
                                      int minAge =
                                      gender.value.toLowerCase() == 'female'
                                          ? 18
                                          : 21;

                                      // Set lastDate as the latest allowed DOB (i.e., today - minAge)
                                      DateTime lastAllowedDOB = DateTime(
                                        nowDateTime.year - minAge,
                                        nowDateTime.month,
                                        nowDateTime.day,
                                      );

                                      // Set firstDate to 100 years before today
                                      DateTime firstAllowedDOB = DateTime(
                                        nowDateTime.year - 60,
                                        nowDateTime.month,
                                        nowDateTime.day,
                                      );
                                      debugPrint('Last Allowed DOB: $lastAllowedDOB');
                                      debugPrint('First Allowed DOB: $firstAllowedDOB');
                                      if (!mounted) return;
                                      DateTime? picked = await showDatePicker(
                                        context: this.context,
                                        firstDate: firstAllowedDOB,
                                        lastDate: lastAllowedDOB,
                                        initialDate: dob
                                            .trim()
                                            .isEmpty
                                            ? lastAllowedDOB
                                            : DateTime.parse(dob.value),
                                      );

                                      if (picked != null) {
                                        dob.value = picked.toString();
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: textFiledInputDecoration(
                                        labelText: 'Date of Birth',
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dob
                                                .trim()
                                                .isEmpty
                                                ? 'dd/mm/yyyy'
                                                : DateFormat('dd/MM/yyyy')
                                                .format(
                                                DateTime.parse(dob.value)),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: ConstHelper.whiteColor,
                                              fontWeight: dob
                                                  .trim()
                                                  .isEmpty
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              fontSize: dob
                                                  .trim()
                                                  .isEmpty
                                                  ? Get.width * 0.035
                                                  : null,
                                            ),
                                          ),
                                          Icon(
                                            Icons.calendar_month,
                                            color: ConstHelper.whiteColor,
                                            size: Get.width / 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      EasyLoading.show(
                                          status: ConstHelper.pleaseWaitMsg);
                                      await Future.delayed(
                                          const Duration(milliseconds: 200));

                                      TimeOfDay initialTime;
                                      if (dobTime
                                          .trim()
                                          .isEmpty) {
                                        EasyLoading.dismiss();
                                        final now = DateTime.now();
                                        initialTime = TimeOfDay(
                                            hour: now.hour, minute: now.minute);
                                      } else {
                                        EasyLoading.dismiss();
                                        // Use local context to parse formatted time
                                        initialTime = TimeOfDay.fromDateTime(
                                          DateFormat('hh:mm a')
                                              .parse(dobTime.value),
                                        );
                                      }

                                      EasyLoading.dismiss();

                                      final pickedTime = await showTimePicker(
                                        context: ConstHelper
                                            .navigatorKey.currentContext!,
                                        initialTime: initialTime,
                                      );

                                      if (pickedTime != null) {
                                        EasyLoading.dismiss();
                                        if (!mounted) return;
                                        dobTime.value = pickedTime.format(
                                            this.context); // will give "10:41 AM"

                                        /*   dobTime.value = pickedTime.format(
                                        ConstHelper
                                            .navigatorKey.currentContext!);*/
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: textFiledInputDecoration(
                                        labelText: 'Time of Birth',
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dobTime
                                                .trim()
                                                .isEmpty
                                                ? '--:-- --'
                                                : DateFormat("hh : mm a")
                                                .format(
                                                DateFormat('HH:mm')
                                                    .parse(dobTime.value)),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: ConstHelper.whiteColor,
                                              fontWeight: dobTime
                                                  .trim()
                                                  .isEmpty
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              fontSize: dobTime
                                                  .trim()
                                                  .isEmpty
                                                  ? Get.width * 0.035
                                                  : null,
                                            ),
                                          ),
                                          Icon(
                                            Icons.access_time_rounded,
                                            color: ConstHelper.whiteColor,
                                            size: Get.width / 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'My Community',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        focusColor: Colors.red,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Select Community',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: homeController.communityDataList
                                            .map((element) =>
                                            DropdownMenuItem(
                                              value: element['id'],
                                              // Use a unique identifier
                                              child: Text(
                                                (element['community_name'] ??
                                                    '')
                                                    .toString(),
                                                style: TextStyle(
                                                  color: ConstHelper.whiteColor,
                                                  fontSize: Get.width * 0.04,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ))
                                            .toList(),
                                        onChanged: (value) async {
                                          EasyLoading.show(
                                              status: ConstHelper
                                                  .pleaseWaitMsg);
                                          await Future.delayed(
                                              const Duration(
                                                  milliseconds: 100));
                                          if (await ConstHelper
                                              .checkInternet()) {
                                            selectedCommunityData.value =
                                                homeController.communityDataList
                                                    .firstWhere(
                                                      (element) =>
                                                  element['id'] == value,
                                                  orElse: () => {},
                                                );
                                            selectedGotraData.value = {};
                                            try {
                                              homeController
                                                  .gotraDataListCommunityIdWise
                                                  .value =
                                              await ApiHelper.apiHelper
                                                  .getGotraDataListCommunityWise(
                                                comunityId:
                                                (selectedCommunityData['id'] ??
                                                    '0')
                                                    .toString(),
                                              );
                                            } catch (error) {
                                              homeController
                                                  .gotraDataListCommunityIdWise
                                                  .value = [];
                                              EasyLoading.dismiss();
                                              ConstHelper.errorDialog(
                                                text: ConstHelper
                                                    .somethingErrorMsg,
                                                seconds: 10,
                                              );
                                            }
                                          } else {
                                            EasyLoading.dismiss();
                                            ConstHelper.errorDialog(
                                              text: ConstHelper.internetMsg,
                                              seconds: 10,
                                            );
                                          }
                                          EasyLoading.dismiss();
                                        },
                                        value: selectedCommunityData['id'],
                                        // Match the unique value
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Gotra',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<
                                          Map<dynamic, dynamic>>(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        focusColor: Colors.red,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Select Gotra',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: homeController
                                            .gotraDataListCommunityIdWise
                                            .map((element) {
                                          return DropdownMenuItem<
                                              Map<dynamic, dynamic>>(
                                            value: element,
                                            // Pass the full element as value
                                            child: Text(
                                              (element['gotra_name'] ?? '')
                                                  .toString(),
                                              style: TextStyle(
                                                color: ConstHelper.whiteColor,
                                                fontSize: Get.width * 0.04,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          if (value != null) {
                                            selectedGotraData.value =
                                                value; // Explicitly handle the value as a Map
                                          }
                                        },
                                        value: homeController
                                            .gotraDataListCommunityIdWise
                                            .firstWhere(
                                              (element) =>
                                          element['gotra_name'] ==
                                              selectedGotraData['gotra_name'],
                                          orElse: () => null,
                                        ) as Map<dynamic, dynamic>?,
                                        // Explicitly cast to Map
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                        labelText: 'Education'),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Select Education',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: homeController.educationDataList
                                            .map((element) {
                                          return DropdownMenuItem(
                                            value: element['education_name'],
                                            // Use a unique identifier like 'id'
                                            child: Text(
                                              (element['education_name'] ?? '')
                                                  .toString(),
                                              style: TextStyle(
                                                color: ConstHelper.whiteColor,
                                                fontSize: Get.width * 0.04,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          // Find the full map by ID and update selectedEducationData
                                          selectedEducationData.value =
                                              homeController.educationDataList
                                                  .firstWhere((element) =>
                                              element['education_name'] ==
                                                  value);
                                        },
                                        value:
                                        selectedEducationData['education_name'],
                                        // Use the unique identifier for value
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            if (txtOccupation.value.trim().toLowerCase() !=
                                "not in any profession") ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: companyNameCon,
                                      style: TextStyle(
                                        fontSize: Get.width * 0.04,
                                        letterSpacing: 1,
                                        color: ConstHelper.whiteColor,
                                      ),
                                      textInputAction: TextInputAction.next,
                                      // Shows "Done" on the keyboard

                                      focusNode: companyNameFocusNode,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          if (value
                                              .trim()
                                              .isEmpty) {
                                            return "Please enter the Company Name";
                                          }
                                        }
                                        return null;
                                      },
                                      textCapitalization: TextCapitalization
                                          .words,
                                      decoration: textFiledInputDecoration(
                                        labelText: 'Company Name',
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                  SizedBox(
                                    width: Get.width / 30,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: companyTypeCon,
                                      style: TextStyle(
                                        fontSize: Get.width * 0.04,
                                        letterSpacing: 1,
                                        color: ConstHelper.whiteColor,
                                      ),
                                      textInputAction: TextInputAction.next,
                                      // Shows "Done" on the keyboard

                                      focusNode: companyTypeFocusNode,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          if (value
                                              .trim()
                                              .isEmpty) {
                                            return "Please enter the Company Type";
                                          }
                                        }
                                        return null;
                                      },
                                      textCapitalization: TextCapitalization
                                          .words,
                                      decoration: textFiledInputDecoration(
                                        labelText: 'Company Type',
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: Get.width / 65,
                              ),
                            ],
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: Get.width / 65),
                              child: HouseTypeSelector(
                                title: "House Type",
                                onChanged: (val) {
                                  selectedHouseType.value = val;
                                },
                                selectedValue: selectedHouseType.value,
                                firstTitle: "Own",
                                secondTitle: "Rent",
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 65,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Community Preferences',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        focusColor: Colors.red,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Please select',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: homeController
                                            .communityDataList.isNotEmpty
                                            ? [
                                          ...homeController.communityDataList
                                              .map((element) =>
                                          element['community_name'])
                                              .toSet()
                                              .map(
                                                (communityName) =>
                                                DropdownMenuItem<String>(
                                                  value: communityName,
                                                  child: Text(
                                                    communityName.toString(),
                                                    style: TextStyle(
                                                        fontSize:
                                                        Get.width * 0.04,
                                                        letterSpacing: 1,
                                                        color: ConstHelper
                                                            .whiteColor),
                                                  ),
                                                ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'Any of above',
                                            // Unique value
                                            child: Text(
                                              'Any of above',
                                              style: TextStyle(
                                                  fontSize: Get.width * 0.04,
                                                  letterSpacing: 1,
                                                  color:
                                                  ConstHelper.whiteColor),
                                            ),
                                          ),
                                        ]
                                            : [],
                                        onChanged: (value) async {
                                          partnerPreferences.comPref.value =
                                              value.toString();
                                        },
                                        value: partnerPreferences.comPref.value
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : partnerPreferences.comPref.value,
                                        // Match the unique value
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: Get.width * 0.04,
                                      letterSpacing: 1,
                                      color: ConstHelper.whiteColor,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    // Shows "Done" on the keyboard
                                    maxLength: 2,
                                    controller:
                                    partnerPreferences.yearAtTheAdd.value,
                                    focusNode: noOfYearADFocusNode,
                                    validator: (value) {
                                      if (value == null || value
                                          .trim()
                                          .isEmpty) {
                                        return "Please enter years at the address";
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    textCapitalization: TextCapitalization
                                        .words,
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Years at address?',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                      () =>
                                      Expanded(
                                        child: InputDecorator(
                                          decoration: textFiledInputDecoration(
                                            labelText: 'Profession',
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              dropdownColor:
                                              ConstHelper.lightBlackColor,
                                              hint: Text(
                                                'Profession',
                                                style: TextStyle(
                                                  color: ConstHelper.whiteColor,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: Get.width * 0.035,
                                                ),
                                              ),
                                              icon: Icon(
                                                Icons.arrow_drop_down_outlined,
                                                color: ConstHelper.whiteColor,
                                              ),
                                              items: (homeController
                                                  .professionModel.value.data
                                                  ?.map(
                                                    (element) =>
                                                    DropdownMenuItem<String>(
                                                      value: element.profession,
                                                      child: Text(
                                                        element.profession!,
                                                        style: TextStyle(
                                                          fontSize:
                                                          Get.width * 0.04,
                                                          letterSpacing: 1,
                                                          color: ConstHelper
                                                              .whiteColor,
                                                        ),
                                                      ),
                                                    ),
                                              )
                                                  .toList() ??
                                                  []),
                                              onChanged: (value) {
                                                txtOccupation.value =
                                                    value.toString();
                                              },
                                              value: txtOccupation.value
                                                  .trim()
                                                  .isEmpty
                                                  ? null
                                                  : txtOccupation.value,
                                              isExpanded: true,
                                              style: TextStyle(
                                                color: ConstHelper.whiteColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: Get.width * 0.04,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: Get.width * 0.04,
                                      letterSpacing: 1,
                                      color: ConstHelper.whiteColor,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    // Shows "Done" on the keyboard

                                    controller: txtPlaceOfBirth,
                                    focusNode: placeOfBirthFocusNode,
                                    validator: (value) {
                                      if (value == null || value
                                          .trim()
                                          .isEmpty) {
                                        return "Please enter the place of birth";
                                      }
                                      return null;
                                    },
                                    textCapitalization: TextCapitalization
                                        .words,
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Place of Birth',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            TextFormField(
                              controller: txtEmail,
                              style: TextStyle(
                                fontSize: Get.width * 0.04,
                                letterSpacing: 1,
                                color: ConstHelper.whiteColor,
                              ),
                              maxLength: 50,
                              textInputAction: TextInputAction.next,
                              // Shows "Done" on the keyboard

                              focusNode: emailFocusNode,
                              validator: (value) {
                                if (value == null || value
                                    .trim()
                                    .isEmpty) {
                                  return "Please enter the email";
                                } else if (!(ConstHelper.constHelper
                                    .validateEmail(email: value))) {
                                  return "Please enter the valid email";
                                }
                                return null;
                              },
                              decoration: textFiledInputDecoration(
                                labelText: 'Email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: Get.width * 0.04,
                                      letterSpacing: 1,
                                      color: ConstHelper.whiteColor,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    // Shows "Done" on the keyboard

                                    controller: txtMainContactNo,
                                    focusNode: mainContactNoFocusNode,
                                    validator: (value) {
                                      if (value == null || value
                                          .trim()
                                          .isEmpty) {
                                        return "Please enter the main contact no.";
                                      } else if (value.length != 10) {
                                        return "Please enter the valid main contact no.";
                                      }
                                      return null;
                                    },
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Main Contact No.',
                                    ),
                                    maxLength: 10,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: Get.width * 0.04,
                                      letterSpacing: 1,
                                      color: ConstHelper.whiteColor,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    // Shows "Done" on the keyboard
                                    maxLength: 50,
                                    controller: mainConNameCon,
                                    focusNode: mcNameFocusNode,
                                    validator: (value) {
                                      if (value == null || value
                                          .trim()
                                          .isEmpty) {
                                        return "Please enter the main contact name";
                                      }
                                      return null;
                                    },
                                    textCapitalization: TextCapitalization
                                        .words,
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Main Contact Name',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: Get.width * 0.04,
                                      letterSpacing: 1,
                                      color: ConstHelper.whiteColor,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    // Shows "Done" on the keyboard

                                    controller: altConNoCon,
                                    focusNode: acNoFocusNode,
                                    validator: (value) {
                                      if (value == null || value
                                          .trim()
                                          .isEmpty) {
                                        return "Please enter the alt contact no.";
                                      } else if (value.length != 10) {
                                        return "Please enter the valid alt contact no.";
                                      }
                                      return null;
                                    },
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Alt Contact No.',
                                    ),
                                    maxLength: 10,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: Get.width * 0.04,
                                      letterSpacing: 1,
                                      color: ConstHelper.whiteColor,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    // Shows "Done" on the keyboard
                                    maxLength: 50,
                                    controller: altConNameCon,
                                    focusNode: acNameFocusNode,
                                    validator: (value) {
                                      if (value == null || value
                                          .trim()
                                          .isEmpty) {
                                        return "Please enter the alt contact name";
                                      }
                                      return null;
                                    },
                                    textCapitalization: TextCapitalization
                                        .words,
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Alt Contact Name',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: Get.width * 0.04,
                                      letterSpacing: 1,
                                      color: ConstHelper.whiteColor,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    // Shows "Done" on the keyboard

                                    controller: txtFatherName,
                                    focusNode: fatherNameFocusNode,
                                    validator: (value) {
                                      if (value == null || value
                                          .trim()
                                          .isEmpty) {
                                        return "Please enter the father name";
                                      }
                                      return null;
                                    },
                                    maxLength: 50,
                                    textCapitalization: TextCapitalization
                                        .words,
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Father Name',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: Get.width * 0.04,
                                      letterSpacing: 1,
                                      color: ConstHelper.whiteColor,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    // Shows "Done" on the keyboard
                                    maxLength: 50,
                                    controller: txtMotherName,
                                    focusNode: motherNameFocusNode,
                                    validator: (value) {
                                      if (value == null || value
                                          .trim()
                                          .isEmpty) {
                                        return "Please enter the mother name";
                                      }
                                      return null;
                                    },
                                    textCapitalization: TextCapitalization
                                        .words,
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Mother Name',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Text(
                              'Height',
                              style: TextStyle(
                                color: ConstHelper.whiteColor,
                                fontWeight: FontWeight.w400,
                                fontSize: Get.width * 0.04,
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Feet',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Feet',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: heightFeetList
                                            .map(
                                              (element) =>
                                              DropdownMenuItem(
                                                value: '$element',
                                                child: Text(
                                                  '$element',
                                                  style: TextStyle(
                                                    color: ConstHelper
                                                        .whiteColor,
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                        )
                                            .toList(),
                                        onChanged: (value) {
                                          heightFeet.value = value ?? '';
                                        },
                                        value: heightFeet
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : heightFeet.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Inch',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Inch',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: heightInchList
                                            .map(
                                              (element) =>
                                              DropdownMenuItem(
                                                value: '$element',
                                                child: Text(
                                                  '$element',
                                                  style: TextStyle(
                                                    color: ConstHelper
                                                        .whiteColor,
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                        )
                                            .toList(),
                                        onChanged: (value) {
                                          heightInch.value = value ?? '';
                                        },
                                        value: heightInch
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : heightInch.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Text(
                              "Brother's",
                              style: TextStyle(
                                color: ConstHelper.whiteColor,
                                fontWeight: FontWeight.w400,
                                fontSize: Get.width * 0.04,
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Married',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Married',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: marriedUnMarriedList
                                            .map(
                                              (element) =>
                                              DropdownMenuItem(
                                                value: '$element',
                                                child: Text(
                                                  '$element',
                                                  style: TextStyle(
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                    color: ConstHelper
                                                        .whiteColor,
                                                  ),
                                                ),
                                              ),
                                        )
                                            .toList(),
                                        onChanged: (value) {
                                          brotherMarried.value = value ?? '';
                                        },
                                        value: brotherMarried
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : brotherMarried.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Un - M',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Un - M',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: marriedUnMarriedList
                                            .map(
                                              (element) =>
                                              DropdownMenuItem(
                                                value: '$element',
                                                child: Text(
                                                  '$element',
                                                  style: TextStyle(
                                                    color: ConstHelper
                                                        .whiteColor,
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                        )
                                            .toList(),
                                        onChanged: (value) {
                                          brotherUnMarried.value = value ?? '';
                                        },
                                        value: brotherUnMarried
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : brotherUnMarried.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Text(
                              "Sister's",
                              style: TextStyle(
                                color: ConstHelper.whiteColor,
                                fontWeight: FontWeight.w400,
                                fontSize: Get.width * 0.04,
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Married',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Married',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: marriedUnMarriedList
                                            .map(
                                              (element) =>
                                              DropdownMenuItem(
                                                value: '$element',
                                                child: Text(
                                                  '$element',
                                                  style: TextStyle(
                                                    color: ConstHelper
                                                        .whiteColor,
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                        )
                                            .toList(),
                                        onChanged: (value) {
                                          sisterMarried.value = value ?? '';
                                        },
                                        value: sisterMarried
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : sisterMarried.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Un - M',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Un - M',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: marriedUnMarriedList
                                            .map(
                                              (element) =>
                                              DropdownMenuItem(
                                                value: '$element',
                                                child: Text(
                                                  '$element',
                                                  style: TextStyle(
                                                    color: ConstHelper
                                                        .whiteColor,
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                        )
                                            .toList(),
                                        onChanged: (value) {
                                          sisterUnMarried.value = value ?? '';
                                        },
                                        value: sisterUnMarried
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : sisterUnMarried.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            /* SizedBox(
                          height: Get.width / 25,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(
                                  color: ConstHelper.whiteColor,
                                ),
                                controller: txtReferenceName,
                                focusNode: referenceNameFocusNode,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter the reference name";
                                  }
                                  return null;
                                },
                                textCapitalization: TextCapitalization.words,
                                decoration: textFiledInputDecoration(
                                  labelText: 'Reference Name',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Get.width / 30,
                            ),
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(
                                  color: ConstHelper.whiteColor,
                                ),
                                controller: txtReferenceMobileNo,
                                focusNode: referenceMobileNoFocusNode,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter the reference mobile no.";
                                  } else if (value.length != 10) {
                                    return "Please enter the valid reference mobile no.";
                                  }
                                  return null;
                                },
                                decoration: textFiledInputDecoration(
                                  labelText: 'Reference Mobile No.',
                                ),
                                maxLength: 10,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),*/
                            SizedBox(
                              height: Get.width / 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Physical Disability (if any)',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Select one',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: physicalAbilityList
                                            .map(
                                              (element) =>
                                              DropdownMenuItem(
                                                value: '$element',
                                                child: Text(
                                                  '$element',
                                                  style: TextStyle(
                                                    color: ConstHelper
                                                        .whiteColor,
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                        )
                                            .toList(),
                                        onChanged: (value) {
                                          selectedPhysicalAbility.value =
                                              value ?? '';
                                        },
                                        value:
                                        selectedPhysicalAbility
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : selectedPhysicalAbility.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Married before ?',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Select one',
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: (homeController
                                            .marriedBeforeModel.value.data
                                            ?.map(
                                              (element) =>
                                              DropdownMenuItem<String>(
                                                value: element.marriedbefore,
                                                child: Text(
                                                  element.marriedbefore!,
                                                  style: TextStyle(
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                    color:
                                                    ConstHelper.whiteColor,
                                                  ),
                                                ),
                                              ),
                                        )
                                            .toList() ??
                                            []),
                                        onChanged: (value) {
                                          selectedMarriedBefore.value =
                                              value?.toString() ?? '';
                                        },
                                        value: selectedMarriedBefore
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : selectedMarriedBefore.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 20,
                            ),
                            if (selectedMarriedBefore.value.trim()
                                .toLowerCase() !=
                                "no") ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: InputDecorator(
                                      decoration: textFiledInputDecoration(
                                        labelText: 'Divorce Status',
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          dropdownColor:
                                          ConstHelper.lightBlackColor,
                                          icon: Icon(
                                            Icons.arrow_drop_down_outlined,
                                            color: ConstHelper.whiteColor,
                                          ),
                                          hint: Text(
                                            'Select one',
                                            style: TextStyle(
                                              color: ConstHelper.whiteColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: Get.width * 0.035,
                                            ),
                                          ),
                                          items: (homeController
                                              .divorceStatusModel.value.data
                                              ?.map(
                                                (element) =>
                                                DropdownMenuItem<String>(
                                                  value: element.divorceStatus,
                                                  child: Text(
                                                    element.divorceStatus!,
                                                    style: TextStyle(
                                                      fontSize:
                                                      Get.width * 0.04,
                                                      letterSpacing: 1,
                                                      color: ConstHelper
                                                          .whiteColor,
                                                    ),
                                                  ),
                                                ),
                                          )
                                              .toList() ??
                                              []),
                                          onChanged: (value) {
                                            partnerPreferences.divorceStatus
                                                .value =
                                                value?.toString() ?? '';
                                          },
                                          value: partnerPreferences
                                              .divorceStatus.value
                                              .trim()
                                              .isEmpty
                                              ? null
                                              : partnerPreferences
                                              .divorceStatus.value,
                                          isExpanded: true,
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: Get.width * 0.04,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: Get.width / 30,
                                  ),
                                  Expanded(
                                    child: InputDecorator(
                                      decoration: textFiledInputDecoration(
                                        labelText: 'Children With',
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          dropdownColor:
                                          ConstHelper.lightBlackColor,
                                          icon: Icon(
                                            Icons.arrow_drop_down_outlined,
                                            color: ConstHelper.whiteColor,
                                          ),
                                          hint: Text(
                                            'Select one',
                                            style: TextStyle(
                                              color: ConstHelper.whiteColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: Get.width * 0.035,
                                            ),
                                          ),
                                          items: (homeController
                                              .childrenWithModel.value.data
                                              ?.map(
                                                (element) =>
                                                DropdownMenuItem<String>(
                                                  value: element.childrenWith,
                                                  child: Text(
                                                    element.childrenWith!,
                                                    style: TextStyle(
                                                      fontSize:
                                                      Get.width * 0.04,
                                                      letterSpacing: 1,
                                                      color: ConstHelper
                                                          .whiteColor,
                                                    ),
                                                  ),
                                                ),
                                          )
                                              .toList() ??
                                              []),
                                          onChanged: (value) {
                                            partnerPreferences.childrenWith
                                                .value =
                                                value?.toString() ?? '';
                                          },
                                          value: partnerPreferences
                                              .childrenWith.value
                                              .trim()
                                              .isEmpty
                                              ? null
                                              : partnerPreferences
                                              .childrenWith.value,
                                          isExpanded: true,
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontSize: Get.width * 0.04,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: Get.width / 25,
                              ),
                              TextFormField(
                                style: TextStyle(
                                  color: ConstHelper.whiteColor,
                                  fontSize: Get.width * 0.04,
                                  letterSpacing: 1,
                                  height: 1.5,
                                ),
                                textInputAction: TextInputAction.next,
                                // Shows "Done" on the keyboard

                                controller: partnerPreferences.childrenCon
                                    .value,
                                focusNode: childrenFocusNode,
                                validator: (value) {
                                  if (value == null || value
                                      .trim()
                                      .isEmpty) {
                                    return "Please enter children";
                                  }
                                  return null;
                                },
                                decoration: textFiledInputDecoration(
                                  labelText: 'Children',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              SizedBox(
                                height: Get.width / 25,
                              ),
                            ],
                            /*Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(
                                  color: ConstHelper.whiteColor,
                                ),
                                controller: txtWorkingCity,
                                focusNode: workingCityFocusNode,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter the working city";
                                  }
                                  return null;
                                },
                                textCapitalization: TextCapitalization.words,
                                decoration: textFiledInputDecoration(
                                  labelText: 'Working City',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Get.width / 30,
                            ),
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(
                                  color: ConstHelper.whiteColor,
                                ),
                                controller: txtPlaceOfBirth,
                                focusNode: placeOfBirthFocusNode,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter the place of birth";
                                  }
                                  return null;
                                },
                                textCapitalization: TextCapitalization.words,
                                decoration: textFiledInputDecoration(
                                  labelText: 'Place of Birth',
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Get.width / 25,
                        ),*/
                            TextFormField(
                              controller: txtAddress,
                              style: TextStyle(
                                color: ConstHelper.whiteColor,
                                fontSize: Get.width * 0.04,
                                letterSpacing: 1,
                                height: 1.5,
                              ),
                              focusNode: addressFocusNode,
                              validator: (value) {
                                if (value == null || value
                                    .trim()
                                    .isEmpty) {
                                  return "Please enter the permanent address";
                                }
                                return null;
                              },

                              textInputAction: TextInputAction.next,
                              // Shows "Done" on the keyboard
                              maxLength: 250,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .always,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: ConstHelper.whiteColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: ConstHelper.whiteColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: ConstHelper.whiteColor,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: Get.width / 30,
                                    vertical: Get.width / 65),
                                labelStyle: TextStyle(
                                  color: ConstHelper.cementColor,
                                ),
                                label: Text(
                                  'Permanent Address',
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: ConstHelper.whiteColor,
                                    fontSize: Get.width * 0.035,
                                    letterSpacing: 1,
                                  ),
                                ),
                                errorMaxLines: 5,
                                counterStyle: TextStyle(
                                  color: ConstHelper.whiteColor,
                                  fontSize: Get.width * 0.035,
                                  letterSpacing: 1,
                                ),
                                //counterText: '',
                              ),
                              maxLines: 4,
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                            Text(
                              'PARTNER PREFERENCES',
                              style: TextStyle(
                                color: ConstHelper.whiteColor,
                                fontSize: Get.width * 0.05,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 65,
                            ),
                            HouseTypeSelector(
                              title: "Will you marry in same Gotra?",
                              onChanged: (val) {
                                partnerPreferences.marrySameGotra.value = val;
                              },
                              selectedValue:
                              partnerPreferences.marrySameGotra.value,
                              firstTitle: "Yes",
                              secondTitle: "No",
                            ),
                            HouseTypeSelector(
                              title: "Will you be matching Ganna (Janampatri)?",
                              onChanged: (val) {
                                partnerPreferences.willYouMatchingGanna.value =
                                    val;
                              },
                              selectedValue:
                              partnerPreferences.willYouMatchingGanna.value,
                              firstTitle: "Yes",
                              secondTitle: "No",
                            ),
                            HouseTypeSelector(
                              title: "Are you Manglik?",
                              onChanged: (val) {
                                partnerPreferences.areYouManglik.value = val;
                              },
                              selectedValue: partnerPreferences.areYouManglik
                                  .value,
                              firstTitle: "Yes",
                              secondTitle: "No",
                            ),
                            HouseTypeSelector(
                              title: "Will you marry a Manglik?",
                              onChanged: (val) {
                                partnerPreferences.areYouMarryAManglik.value =
                                    val;
                              },
                              selectedValue:
                              partnerPreferences.areYouMarryAManglik.value,
                              firstTitle: "Yes",
                              secondTitle: "No",
                            ),
                            SizedBox(
                              height: Get.width / 65,
                            ),
                            Text(
                              'Prospective Spouse can be (in years)?'
                                  .toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: ConstHelper.whiteColor,
                                fontSize: Get.width * 0.04,
                                // letterSpacing: 1,
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Older By',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Older By',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: ConstHelper.whiteColor,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: List.generate(
                                          10,
                                              (index) =>
                                              DropdownMenuItem(
                                                value: '$index',
                                                child: Text(
                                                  '$index',
                                                  style: TextStyle(
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                    color: ConstHelper
                                                        .whiteColor,
                                                  ),
                                                ),
                                              ),
                                        ).toList(),
                                        onChanged: (value) {
                                          partnerPreferences.spouseOlderBy
                                              .value =
                                              value.toString();
                                        },
                                        value: partnerPreferences
                                            .spouseOlderBy.value
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : partnerPreferences
                                            .spouseOlderBy.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width / 30,
                                ),
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Younger By',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Younger By',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: ConstHelper.whiteColor,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: List.generate(
                                          10,
                                              (index) =>
                                              DropdownMenuItem(
                                                value: '$index',
                                                child: Text(
                                                  '$index',
                                                  style: TextStyle(
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                    color: ConstHelper
                                                        .whiteColor,
                                                  ),
                                                ),
                                              ),
                                        ).toList(),
                                        onChanged: (value) {
                                          partnerPreferences.spouseYoungerBy
                                              .value =
                                              value.toString();
                                        },
                                        value: partnerPreferences
                                            .spouseYoungerBy.value
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : partnerPreferences
                                            .spouseYoungerBy.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Text(
                              'Expected Budget(In Lakhs)'.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: ConstHelper.whiteColor,
                                fontSize: Get.width * 0.04,
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: InputDecorator(
                                    decoration: textFiledInputDecoration(
                                      labelText: 'Bride',
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        dropdownColor: ConstHelper
                                            .lightBlackColor,
                                        icon: Icon(
                                          Icons.arrow_drop_down_outlined,
                                          color: ConstHelper.whiteColor,
                                        ),
                                        hint: Text(
                                          'Bride',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: ConstHelper.whiteColor,
                                            fontSize: Get.width * 0.035,
                                          ),
                                        ),
                                        items: (homeController
                                            .budgetCateModel.value.data
                                            ?.map(
                                              (element) =>
                                              DropdownMenuItem<String>(
                                                value: element.ranges,
                                                child: Text(
                                                  element.ranges!,
                                                  style: TextStyle(
                                                    fontSize: Get.width * 0.04,
                                                    letterSpacing: 1,
                                                    color:
                                                    ConstHelper.whiteColor,
                                                  ),
                                                ),
                                              ),
                                        )
                                            .toList() ??
                                            []),
                                        onChanged: (String? value) {
                                          partnerPreferences.budgetOfBride
                                              .value =
                                              value ??
                                                  ''; // Assign the value directly
                                        },
                                        value: partnerPreferences
                                            .budgetOfBride.value
                                            .trim()
                                            .isEmpty
                                            ? null
                                            : partnerPreferences
                                            .budgetOfBride.value,
                                        isExpanded: true,
                                        style: TextStyle(
                                          color: ConstHelper.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Get.width * 0.04,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (gender.value.toLowerCase() != "female") ...[
                                  SizedBox(
                                    width: Get.width / 30,
                                  ),
                                  Expanded(
                                    child: InputDecorator(
                                      decoration: textFiledInputDecoration(
                                        labelText: 'Groom',
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          dropdownColor:
                                          ConstHelper.lightBlackColor,
                                          icon: Icon(
                                            Icons.arrow_drop_down_outlined,
                                            color: ConstHelper.whiteColor,
                                          ),
                                          hint: Text(
                                            'Groom',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: ConstHelper.whiteColor,
                                              fontSize: Get.width * 0.035,
                                            ),
                                          ),
                                          items: homeController
                                              .budgetCateModel.value.data
                                              ?.map((element) => element.ranges)
                                              .toSet() // Remove duplicates
                                              .map((range) =>
                                              DropdownMenuItem<String>(
                                                value: range,
                                                child: Text(
                                                  range!,
                                                  style: TextStyle(
                                                    fontSize:
                                                    Get.width * 0.04,
                                                    letterSpacing: 1,
                                                    color: ConstHelper
                                                        .whiteColor,
                                                  ),
                                                ),
                                              ))
                                              .toList() ??
                                              [],
                                          onChanged: (value) {
                                            // Set the selected value to the partnerPreferences object
                                            partnerPreferences.budgetOfGroom
                                                .value =
                                                value ?? '';
                                          },
                                          // Ensure the value exists in the dropdown items
                                          value: homeController
                                              .budgetCateModel.value.data
                                              ?.map((element) =>
                                          element.ranges)
                                              .toSet()
                                              .contains(partnerPreferences
                                              .budgetOfGroom.value) ??
                                              false
                                              ? partnerPreferences
                                              .budgetOfGroom.value
                                              : null,
                                          // If value exists, use it; otherwise, show null (default)
                                          isExpanded: true,
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: Get.width * 0.04,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ]
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 12,
                            ),
                            if (gender.value.toLowerCase() != "female")
                              Row(
                                children: [
                                  Expanded(
                                    child: InputDecorator(
                                      decoration: textFiledInputDecoration(
                                        labelText:
                                        'Bride permitted to work after marriage',
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          dropdownColor:
                                          ConstHelper.lightBlackColor,
                                          icon: Icon(
                                            Icons.arrow_drop_down_outlined,
                                            color: ConstHelper.whiteColor,
                                          ),
                                          items: PermittedAfterMarriageType
                                              .values
                                              .map(
                                                (element) =>
                                                DropdownMenuItem(
                                                  value: element.displayValue,
                                                  child: Text(
                                                    element.displayValue,
                                                    style: TextStyle(
                                                      color: ConstHelper
                                                          .whiteColor,
                                                      fontSize: Get.width *
                                                          0.04,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ),
                                          )
                                              .toList(),
                                          onChanged: (value) {
                                            partnerPreferences
                                                .bridePermittedWork
                                                .value = value ?? '';
                                          },
                                          value: partnerPreferences
                                              .bridePermittedWork.value
                                              .trim()
                                              .isEmpty
                                              ? null
                                              : partnerPreferences
                                              .bridePermittedWork.value,
                                          isExpanded: true,
                                          style: TextStyle(
                                            color: ConstHelper.whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: Get.width * 0.04,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: Get.width / 30,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      style: TextStyle(
                                        color: ConstHelper.whiteColor,
                                        fontSize: Get.width * 0.04,
                                        letterSpacing: 1,
                                      ),
                                      textInputAction: TextInputAction.next,
                                      // Shows "Done" on the keyboard

                                      controller: partnerPreferences
                                          .placeOfResidenceAfterMarriage.value,
                                      focusNode: reAfterMrgFocusNode,
                                      validator: (value) {
                                        if (value == null || value
                                            .trim()
                                            .isEmpty) {
                                          return "Please enter the Place of residence after marriage";
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.text,
                                      textCapitalization: TextCapitalization
                                          .words,
                                      decoration: textFiledInputDecoration(
                                        labelText: 'Residence place after marriage',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: Get.width / 20,
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'ADDITIONAL INFORMATION ',
                                style: TextStyle(
                                  color: ConstHelper.whiteColor,
                                  fontSize: Get.width * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                    '(Your details will help find the right match. Please provide brief and specific information.)',
                                    style: TextStyle(
                                      color: ConstHelper.whiteColor,
                                      fontSize: Get.width * 0.03,
                                      //letterSpacing: 1,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: Get.height / 65,
                            ),
                            TextFormField(
                              controller: briefSummaryOfParents,
                              style: TextStyle(
                                color: ConstHelper.whiteColor,
                                fontSize: Get.width * 0.04,
                                letterSpacing: 1,
                              ),
                              maxLength: 500,
                              focusNode: briefSummaryFocusNode,
                              validator: (value) {
                                if (value == null || value
                                    .trim()
                                    .isEmpty) {
                                  return "Summary of Parent’s Occupation / Family History";
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              // Shows "Done" on the keyboard
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .always,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: ConstHelper.whiteColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: ConstHelper.whiteColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: ConstHelper.whiteColor,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: Get.width / 30,
                                    vertical: Get.width / 65),
                                labelStyle: TextStyle(
                                  color: ConstHelper.cementColor,
                                ),
                                label: Text(
                                  "Parent's occupation & family background (brief)",
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: Get.width * 0.035,
                                    color: ConstHelper.whiteColor,
                                  ),
                                ),
                                errorMaxLines: 5,
                                counterStyle: TextStyle(
                                  fontSize: Get.width * 0.035,
                                  color: ConstHelper.whiteColor,
                                ),
                                //counterText: '',
                              ),
                              maxLines: 4,
                            ),
                            SizedBox(
                              height: Get.width / 30,
                            ),
                            Text(
                              "Photograph".toUpperCase(),
                              style: TextStyle(
                                color: ConstHelper.whiteColor,
                                fontSize: Get.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: Get.height * 0.01,
                            ),
                            Row(
                              children: [
                                PhotoSection(
                                  title: 'Full Length',
                                  selectedPhotoPath: selectedPhotoPath,
                                  context: context,
                                ),
                                PhotoSection(
                                  title: 'Full Face',
                                  selectedPhotoPath: selectedFullFacePath,
                                  context: context,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 15,
                            ),
                            GestureDetector(
                              onTap: () async {
                                EasyLoading.show(
                                    status: ConstHelper.pleaseWaitMsg);
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                _unfocusAllFields();
                                debugPrint((selectedCommunityData["id"] ?? ""));
                                if (!await ConstHelper.checkInternet()) {
                                  _showError(ConstHelper.internetMsg);
                                  return;
                                }
                                if (!_validateForm()) return;

                                try {
                                  // Get all the necessary fields from your form or other sources
                                  //  final membersDataModel = _buildMembersDataModel();

                                  // Call newSignup with the fields
                                  final response =
                                  await ApiHelper.apiHelper.newSignup(
                                    fname: txtFullName.value.text,
                                    gender: gender.value,
                                    //dob: DateFormat('yyyy-MM-dd').format(membersDataModel.profileDateOfBirth ?? DateTime.now()),
                                    birthtime: dobTime.value,
                                    placeofBirth: txtPlaceOfBirth.value.text,
                                    heightFeet: /*membersDataModel.profileHeightFeet ??*/
                                    heightFeet.value,
                                    heightInch: heightInch.value,
                                    email: txtEmail.value.text,
                                    eduQualification:
                                    (selectedEducationData["education_name"] ??
                                        "")
                                        .toString(),
                                    //eduqualificationOther: '',
                                    profession: txtOccupation.value,
                                    otherProfession: '',
                                    businessName: "",
                                    businessType: '',
                                    compName: companyNameCon.value.text,
                                    compType: companyTypeCon.value.text,
                                    incomeLakh: annualIncomeCon.value.text,
                                    //profilePhysicalDisability: membersDataModel.profilePhysicalDisablity ?? '',
                                    fatherName: txtFatherName.value.text,
                                    motherName: /*membersDataModel.profileMotherFullName*/
                                    txtMotherName.value.text,
                                    community: (selectedCommunityData["id"] ??
                                        "")
                                        .toString(),
                                    gotra: (selectedGotraData['gotra_name'] ??
                                        '')
                                        .toString(),
                                    //profileMarryInCommunity: '',
                                    //marriedBrother: '',
                                    //unmarriedBrother: '',
                                    //marriedSister: '',
                                    //unmarriedSister: '',
                                    sameGothra:
                                    partnerPreferences.marrySameGotra.value,
                                    matchGanna: partnerPreferences
                                        .willYouMatchingGanna.value,
                                    isManglik:
                                    partnerPreferences.areYouManglik.value,
                                    marryManglik: partnerPreferences
                                        .areYouMarryAManglik.value,
                                    mainContactName: mainConNameCon.value.text,
                                    mainContactNum: txtMainContactNo.value.text,
                                    altContactName: altConNameCon.value.text,
                                    //alterContactNum: membersDataModel.profileRefContactMobile ?? '',
                                    resAddress: txtAddress.value.text,
                                    numYraddrs:
                                    partnerPreferences.yearAtTheAdd.value.text,
                                    //ownRent: '',

                                    divorceStatus:
                                    partnerPreferences.divorceStatus.value,
                                    children:
                                    partnerPreferences.childrenCon.value.text,
                                    childrenWith:
                                    partnerPreferences.childrenWith.value,
                                    olderBy: partnerPreferences.spouseOlderBy
                                        .value,
                                    youngerBy:
                                    partnerPreferences.spouseYoungerBy.value,
                                    //resAfterMarriage: '',
                                    //brideBudget: '',
                                    //groomBudget: '',
                                    //workAfterMarriage: '',
                                    //briefFatherProfession: '',
                                    fullPhoto: selectedPhotoPath.value,
                                    // You can add the photo path if available
                                    facePhoto: selectedFullFacePath.value,
                                    dobs: dob.value.split(" ")[0],
                                    eduQualificationOther: '',
                                    profilePhysicalDisablity:
                                    selectedPhysicalAbility.value,
                                    profileMarryInCommunity: partnerPreferences.comPref.value,
                                    marriedBrother: brotherMarried.value,
                                    unmarriedBrother: brotherUnMarried.value,
                                    marriedSister: sisterMarried.value,
                                    unmarriedSister: sisterUnMarried.value,
                                    alterCnctNum: altConNoCon.value.text,
                                    ownrent: selectedHouseType.value,
                                    marriedBfor: selectedMarriedBefore.value,
                                    resaftrMarrige: partnerPreferences
                                        .placeOfResidenceAfterMarriage.value
                                        .text,
                                    bridebudget:
                                    homeController.budgetCateModel.value.data
                                        ?.firstWhereOrNull(
                                          (element) =>
                                      element.ranges ==
                                          partnerPreferences
                                              .budgetOfBride.value,
                                    )
                                        ?.id
                                        ?.toString() ??
                                        "",
                                    groombudget:
                                    homeController.budgetCateModel.value.data
                                        ?.firstWhereOrNull(
                                          (element) =>
                                      element.ranges ==
                                          partnerPreferences
                                              .budgetOfGroom.value,
                                    )
                                        ?.id
                                        ?.toString() ??
                                        "",
                                    workAftrMarrige:
                                    partnerPreferences.bridePermittedWork.value,
                                    briefFatherProfession: briefSummaryOfParents
                                        .value
                                        .text, // You can add the photo path if available
                                  );

                                  if (response.isNotEmpty &&
                                      response['code'] == 200) {
                                    Get.back();
                                    _showSuccess(response['msg'] ??
                                        'Your profile is created successfully.');
                                  } else {
                                    _showError(response['msg'] ??
                                        ConstHelper.somethingErrorMsg);
                                  }
                                } catch (error) {
                                  _showError(ConstHelper.somethingErrorMsg);
                                }
                              },
                              child: Container(
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: ConstHelper.orangeColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                padding:
                                EdgeInsets.symmetric(vertical: Get.width / 30),
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: ConstHelper.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Get.width * 0.045,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 25,
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration textFiledInputDecoration({
    required String labelText,
    Color? borderColor,
  }) {
    borderColor = borderColor ?? ConstHelper.cementColor;
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: ConstHelper.whiteColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: ConstHelper.whiteColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: ConstHelper.whiteColor,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: Get.width / 30,
      ),
      labelStyle: TextStyle(
        color: ConstHelper.whiteColor,
        fontSize: Get.width * 0.04,
        letterSpacing: 1,
      ),
      label: Text(
        labelText,
        maxLines: 2,
        style: TextStyle(
          color: ConstHelper.whiteColor,
          fontSize: Get.width * 0.035,
          // letterSpacing: 1,
        ),
      ),
      errorMaxLines: 5,
      counterText: '',
    );
  }

  void _unfocusAllFields() {
    for (var focusNode in [
      fullNameFocusNode,
      occupationFocusNode,
      emailFocusNode,
      mobileNoFocusNode,
      whatsappNoFocusNode,
      mainContactNoFocusNode,
      fatherNameFocusNode,
      motherNameFocusNode,
      referenceNameFocusNode,
      referenceMobileNoFocusNode,
      workingCityFocusNode,
      placeOfBirthFocusNode,
      addressFocusNode,
      briefSummaryFocusNode,
      reAfterMrgFocusNode,
      companyNameFocusNode,
      companyTypeFocusNode,
      mcNameFocusNode,
      mcNoTypeFocusNode,
      acNameFocusNode,
      acNoFocusNode,
      noOfYearADFocusNode,
      noOfYearADFocusNode,
      childrenFocusNode
    ]) {
      focusNode.unfocus();
    }
  }

  bool _validateForm() {
    debugPrint("Validation started");

    if (txtFullName.value.text
        .trim()
        .isEmpty) {
      fullNameFocusNode.requestFocus();
      _showError('Full name is required');
      return false;
    } else if (gender.value
        .trim()
        .isEmpty) {
      _showError('Please select gender');
      return false;
    } else if (dob.value
        .trim()
        .isEmpty) {
      _showError('Please select date of birth');
      return false;
    } else if (dobTime.value
        .trim()
        .isEmpty) {
      _showError('Please select time of birth');
      return false;
    } else if ((selectedCommunityData['community_name']
        ?.trim()
        .isEmpty ??
        true)) {
      _showError('Please select community');
      return false;
    } else if ((selectedGotraData['gotra_name']
        ?.trim()
        .isEmpty ?? true)) {
      _showError('Please select gotra');
      return false;
    } else if ((selectedEducationData['education_name']
        ?.trim()
        .isEmpty ??
        true)) {
      _showError('Please select education');
      return false;
    } else if (selectedHouseType.value
        .trim()
        .isEmpty) {
      _showError('Please select house type');
      return false;
    } else if (partnerPreferences.comPref.value
        .trim()
        .isEmpty) {
      _showError('Please enter community pref.');
      return false;
    } else if (partnerPreferences.yearAtTheAdd.value.text
        .trim()
        .isEmpty) {
      noOfYearADFocusNode.requestFocus();
      _showError('Please enter Number of years at the address');
      return false;
    } else if (txtOccupation.value
        .trim()
        .isEmpty) {
      occupationFocusNode.requestFocus();
      _showError('Occupation is required');
      return false;
    } else if (txtPlaceOfBirth.value.text
        .trim()
        .isEmpty) {
      placeOfBirthFocusNode.requestFocus();
      _showError('Place of birth is required');
      return false;
    } else if (!_isValidEmail(txtEmail.value.text)) {
      emailFocusNode.requestFocus();
      _showError('Invalid email format');
      return false;
    } else if (altConNameCon.value.text
        .trim()
        .isEmpty) {
      acNameFocusNode.requestFocus();
      _showError('Alt name is required');
      return false;
    } else if (mainConNameCon.value.text
        .trim()
        .isEmpty) {
      referenceMobileNoFocusNode.requestFocus();
      _showError('Main name is required');
      return false;
    } else if (!_isValidPhone(altConNoCon.value.text)) {
      acNoFocusNode.requestFocus();
      _showError('Invalid alternate contact number');
      return false;
    } else if (!_isValidPhone(txtMainContactNo.value.text)) {
      mainContactNoFocusNode.requestFocus();
      _showError('Invalid main contact number');
      return false;
    } else if (txtFatherName.value.text
        .trim()
        .isEmpty) {
      fatherNameFocusNode.requestFocus();
      _showError('Father’s name is required');
      return false;
    } else if (txtMotherName.value.text
        .trim()
        .isEmpty) {
      motherNameFocusNode.requestFocus();
      _showError('Mother’s name is required');
      return false;
    } else if (heightFeet.value
        .trim()
        .isEmpty ||
        heightInch.value
            .trim()
            .isEmpty) {
      _showError('Please provide height in feet and inches');
      return false;
    } else if (brotherMarried.value
        .trim()
        .isEmpty ||
        brotherUnMarried.value
            .trim()
            .isEmpty) {
      _showError('Please provide brother married or unmarried');
      return false;
    } else if (sisterMarried.value
        .trim()
        .isEmpty ||
        sisterUnMarried.value
            .trim()
            .isEmpty) {
      _showError('Please provide sister married or unmarried');
      return false;
    } else if (selectedPhysicalAbility.value
        .trim()
        .isEmpty) {
      _showError('Please select physical disability status');
      return false;
    } else if (selectedMarriedBefore.value
        .trim()
        .isEmpty) {
      _showError('Please select marital status');
      return false;
    } else if (txtAddress.value.text
        .trim()
        .isEmpty) {
      addressFocusNode.requestFocus();
      _showError('Address is required');
      return false;
    } else if (partnerPreferences.marrySameGotra.value
        .trim()
        .isEmpty) {
      _showError('Please select same gotra or not');
      return false;
    } else if (partnerPreferences.willYouMatchingGanna.value
        .trim()
        .isEmpty) {
      _showError('Please select matching ganna or not');
      return false;
    } else if (partnerPreferences.areYouManglik.value
        .trim()
        .isEmpty) {
      _showError('Please select are you manglik or not');
      return false;
    } else if (partnerPreferences.areYouMarryAManglik.value
        .trim()
        .isEmpty) {
      _showError('Please select are you marry manglik or not');
      return false;
    } else if (partnerPreferences.spouseOlderBy.value
        .trim()
        .isEmpty ||
        partnerPreferences.spouseYoungerBy.value
            .trim()
            .isEmpty) {
      _showError('Please provide spouse older by and younger by');
      return false;
    } else if (gender.value
        .trim()
        .isNotEmpty) {
      if (gender.value.toLowerCase() != "female") {
        if (partnerPreferences.budgetOfGroom.value
            .trim()
            .isEmpty) {
          _showError('Please provide groom budget');
          return false;
        } else if (partnerPreferences.bridePermittedWork.value
            .trim()
            .isEmpty) {
          _showError('Please provide bride permitted to work after marriage');
          return false;
        } else if (partnerPreferences.placeOfResidenceAfterMarriage.value.text
            .trim()
            .isEmpty) {
          _showError('Please select place of residence after marriage');
          return false;
        }
      }
    } else if (partnerPreferences.budgetOfBride.value
        .trim()
        .isEmpty) {
      _showError('Please provide bride');
      return false;
    } else if (partnerPreferences.bridePermittedWork.value
        .trim()
        .isEmpty) {
      _showError('Please provide bride permitted to work after marriage');
      return false;
    } else if (partnerPreferences.placeOfResidenceAfterMarriage.value.text
        .trim()
        .isEmpty) {
      _showError('Please select place of residence after marriage');
      return false;
    } else if (briefSummaryOfParents.value.text
        .trim()
        .isEmpty) {
      briefSummaryFocusNode.requestFocus();
      _showError('Brief summary of parents is required');
      return false;
    } else if (selectedPhotoPath.value
        .trim()
        .isEmpty) {
      _showError('Please upload a full photo');
      return false;
    } else if (selectedFullFacePath.value
        .trim()
        .isEmpty) {
      _showError('Please upload a full-face photo');
      return false;
    } else if (partnerPreferences.childrenWith.value
        .trim()
        .isEmpty) {
      _showError('Please select children with');
      return false;
    } else if (partnerPreferences.childrenCon.value.text
        .trim()
        .isEmpty) {
      childrenFocusNode.requestFocus();
      _showError('Please enter children');
      return false;
    } else if (partnerPreferences.divorceStatus.value
        .trim()
        .isEmpty) {
      _showError('Please select divorce type');
      return false;
    }

    debugPrint("Validation successful");
    return true;
  }

  void _showError(String message) {
    EasyLoading.dismiss();
    ConstHelper.errorDialog(text: message, seconds: 10);
  }

  void _showSuccess(String message) {
    EasyLoading.dismiss();
    ConstHelper.successDialog(text: message, seconds: 10);
  }

  bool _isValidEmail(String email) {
    return ConstHelper.constHelper.validateEmail(email: email.trim());
  }

  bool _isValidPhone(String phone) {
    return phone
        .trim()
        .length == 10;
  }

/*  MembersDataModel _buildMembersDataModel() {
    return MembersDataModel(
      name: txtFullName.text,
      profileGender: gender.value,
      profileDateOfBirth: DateTime.parse(dob.value),
      profileTimeOfBirth: DateFormat('hh:mm')
          .format(DateFormat('hh:mm a').parse(dobTime.value)),
      profileComunityName: (selectedCommunityData['id'] ?? '0').toString(),
      profileGotra: (selectedGotraData['gotra_name'] ?? '').toString(),
      profileEducation:
          (selectedEducationData['education_name'] ?? '').toString(),
      profileOccupation: txtOccupation.value,
      email: txtEmail.text,
      profileMobile: txtMainContactNo.text,
      profileWhatsapp: altConNoCon.text,
      profileMainContactNum: txtMainContactNo.text,
      profileHeight: heightFeet.value,
      profileHeightInch: heightInch.value,
      profileFatherFullName: txtFatherName.text,
      profileRefContactName: txtReferenceName.text,
      profileRefContactMobile: txtReferenceMobileNo.text,
      profilePhysicalDisablity: selectedPhysicalAbility.value,
      profileHaveMarriedBefore: selectedMarriedBefore.value,
      profilePlaceOfBirth: txtPlaceOfBirth.text,
      profilePermanentAddress: txtAddress.text,
      profileNote: briefSummaryOfParents.text,
      profilePhoto: selectedPhotoPath.value,
    );
  }*/
}
