import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/home_controller.dart';
import '../../models/profession_model.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import '../sign_up_screen/components/enums/signup_enums.dart';
import '../sign_up_screen/widget/type_selector.dart';
import 'my_profile_page.dart';

class Editprofilepage extends StatefulWidget {
  const Editprofilepage({super.key});

  @override
  State<Editprofilepage> createState() => _EditprofilepageState();
}

class _EditprofilepageState extends State<Editprofilepage> {
  HomeController homeController = Get.put(HomeController());

  List yesNoList = ["Yes", "No"];

  RxString selectedProfession = "".obs;
  RxString marriedBrotherCon = "".obs;
  RxString unMarriedBrotherCon = "".obs;
  RxString marriedSisterCon = "".obs;
  RxString unMarriedSisterCon = "".obs;
  RxString selectedHouseType = "".obs;

  RxString marriedBefore = "".obs;
  RxString areYouMarryAManglik = "".obs;
  RxString areYouManglik = "".obs;
  RxString willYouMatchingGanna = "".obs;
  RxString marrySameGotra = "".obs;
  RxString bridePermittedWork = "".obs;
  RxString budgetOfGroom = "".obs;
  RxString budgetOfBride = "".obs;
  RxString spouseYoungerBy = "".obs;
  RxString spouseOlderBy = "".obs;
  TextEditingController briefOfFatherProfession = TextEditingController();
  TextEditingController currantAddress = TextEditingController();

  //RxString selectedPhotoPath = ''.obs;
  //RxString photoPath = ''.obs;

  TextEditingController altContactNumber = TextEditingController();
  TextEditingController altContactName = TextEditingController();
  TextEditingController companyNameCon = TextEditingController();
  TextEditingController companyTypeCon = TextEditingController();
  TextEditingController annualIncomeCon = TextEditingController();
  TextEditingController placeOfResidenceAfterMarriage = TextEditingController();
  Rx<ProfessionModel> professionModel = ProfessionModel().obs;

  getData() async {
    /*  photoPath.value = homeController
                    .userData.value.profileFullFacePhotoFileName ==
                null ||
            homeController.userData.value.profileFullFacePhotoFileName!
                .trim()
                .isEmpty
        ? ConstHelper.profileImagePath
        : '${ConstHelper.userImagesPath}${homeController.userData.value.profileFullFacePhotoFileName!}';*/
    homeController.budgetCateModel.value =
        await ApiHelper.apiHelper.getBudgetCate();
    professionModel.value = await ApiHelper.apiHelper.getProfession();
    homeController.marriedBeforeModel.value =
        await ApiHelper.apiHelper.getMarriedBefore();

    altContactNumber.text =
        homeController.userData.value.profileAlternateContactNum ?? "";
    altContactName.text =
        homeController.userData.value.profileAlternateContactFullName ?? "";
    companyNameCon.text =
        homeController.userData.value.profileProfessionOrgName ?? "";
    companyTypeCon.text =
        homeController.userData.value.profileProfessionOrgType ?? "";
    annualIncomeCon.text = homeController
            .userData.value.profileProfessionAnnualNetIncome
            ?.toString() ??
        "";
    briefOfFatherProfession.text =
        homeController.userData.value.briefFatherProfession ?? "";
    selectedProfession.value =
        homeController.userData.value.profileProfession ?? "";
    if (!(professionModel.value.data!
        .any((element) => element.profession == selectedProfession.value))) {
      selectedProfession.value = "";
    }

    marriedBrotherCon.value =
        homeController.userData.value.profileMarriedBrother ?? "";
    unMarriedBrotherCon.value =
        homeController.userData.value.profileUnmarriedBrother ?? "";
    marriedSisterCon.value =
        homeController.userData.value.profileMarriedSister ?? "";
    unMarriedSisterCon.value =
        homeController.userData.value.profileUnmarriedSister ?? "";

    marriedBefore.value =
        homeController.userData.value.profileHaveMarriedBefore ?? "";
    spouseOlderBy.value =
        homeController.userData.value.profileSpouseCanBeOlderBy ?? "";
    spouseYoungerBy.value =
        homeController.userData.value.profileSpouseCanBeYoungerBy ?? "";
    budgetOfBride.value = homeController.budgetCateModel.value.data
            ?.firstWhereOrNull((element) =>
                element.id.toString() ==
                (homeController.userData.value.profileBudgetCategoryId
                    .toString()))
            ?.ranges ??
        "";
    budgetOfGroom.value = homeController.budgetCateModel.value.data
            ?.firstWhereOrNull(
              (element) =>
                  element.id.toString() ==
                  homeController.userData.value.profileGroomBudgetCategoryId
                      .toString(),
            )
            ?.ranges ??
        "";
    spouseYoungerBy.value =
        homeController.userData.value.profileSpouseCanBeYoungerBy ?? "";
    spouseOlderBy.value =
        homeController.userData.value.profileSpouseCanBeOlderBy ?? "";
    bridePermittedWork.value = homeController
            .userData.value.profileBridePermittedToWorkAfterMarriage ??
        "";
    print(homeController.userData.value.profileWillMarryInSameGotra);

    marrySameGotra.value =
        homeController.userData.value.profileWillMarryInSameGotra ?? "";
    print(homeController.userData.value.profileWillMatchGanna);
    print(homeController.userData.value.profileWillMatchGanna);
    willYouMatchingGanna.value =
        homeController.userData.value.profileWillMatchGanna ?? "";
    areYouManglik.value = homeController.userData.value.profileIsManglik ?? "";
    areYouMarryAManglik.value =
        homeController.userData.value.profileWillMarryManglink ?? "";
    annualIncomeCon.text = homeController
            .userData.value.profileProfessionAnnualNetIncome
            ?.toString() ??
        "";
    currantAddress.text =
        homeController.userData.value.profileCurrentResidAddress?.toString() ??
            "";
    placeOfResidenceAfterMarriage.text = homeController
            .userData.value.profileNumOfYearsAtThisAddress
            ?.toString() ??
        "";
    selectedHouseType.value =
        homeController.userData.value.profileHouseType?.toString() ?? "";
    /*for (var item in professionModel.value.data ?? []) {
      print(item.profession);
      print(selectedProfession.value);
      if (item.profession != selectedProfession.value) {
        selectedProfession.value = "";
        setState(() {});
      }
    }*/
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    /* /// PRINT ALL VALUES
    print("----------------------------");
    print("Alternate Contact Number: ${altContactNumber.text}");
    print("Alternate Contact Name: ${altContactName.text}");
    print("Company Name: ${companyNameCon.text}");
    print("Company Type: ${companyTypeCon.text}");
    print("Annual Income: ${annualIncomeCon.text}");
    print("Brief of Father's Profession: ${briefOfFatherProfession.text}");
    print("Selected Profession: ${selectedProfession.value}");
    print("Married Brothers: ${marriedBrotherCon.value}");
    print("Unmarried Brothers: ${unMarriedBrotherCon.value}");
    print("Married Sisters: ${marriedSisterCon.value}");
    print("Unmarried Sisters: ${unMarriedSisterCon.value}");
    print("Married Before: ${marriedBefore.value}");
    print("Spouse Older By: ${spouseOlderBy.value}");
    print("Spouse Younger By: ${spouseYoungerBy.value}");
    print("Budget of Bride: ${budgetOfBride.value}");
    print("Budget of Groom: ${budgetOfGroom.value}");
    print("Bride Permitted Work: ${bridePermittedWork.value}");
    print("Marry Same Gotra: ${marrySameGotra.value}");
    print("Will you match Ganna: ${willYouMatchingGanna.value}");
    print("Are you Manglik: ${areYouManglik.value}");
    print("Are you willing to marry Manglik: ${areYouMarryAManglik.value}");
    print("Current Address: ${currantAddress.text}");
    print(
        "Place of Residence after Marriage: ${placeOfResidenceAfterMarriage.text}");
    print("Selected House Type: ${selectedHouseType.value}");
    print("----------------------------");*/
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: Get.width * 0.06,
            color: ConstHelper.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            size: Get.width / 13,
          ),
        ),
        centerTitle: true,
        backgroundColor: ConstHelper.whiteColor,
        surfaceTintColor: ConstHelper.whiteColor,
        elevation: 10,
        shadowColor: ConstHelper.greyColor.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: () async {
              Get.back();
              Get.back();
              await Future.delayed(
                const Duration(
                  milliseconds: 300,
                ),
              );
              homeController.advancedDrawerController.hideDrawer();
            },
            icon: SvgPicture.asset(
              'assets/image/homeSVG.svg',
              height: Get.width / 18,
              width: Get.width / 18,
              color: ConstHelper.orangeColor,
            ),
          ),
        ],
        // elevation: 3,
        // shadowColor: Colors.grey.shade50.withOpacity(0.3),
      ),
      backgroundColor: ConstHelper.whiteColor,
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width / 20,
            ),
            child: Obx(
              () => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: Get.width / 30,
                    ),
                    Center(
                      child: Text(
                        homeController.userData.value.name == null ||
                                homeController.userData.value.name!
                                    .trim()
                                    .isEmpty
                            ? ConstHelper.nameNotAvailableMsg
                            : homeController.userData.value.name!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ConstHelper.blackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: Get.width * 0.05,
                        ),
                      ),
                    ),
                    Center(
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'User ID : ',
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                                fontWeight: FontWeight.w500,
                                fontSize: Get.width * 0.035,
                              ),
                            ),
                            TextSpan(
                              text: homeController.userData.value.id == null ||
                                      homeController.userData.value.id == 0
                                  ? ConstHelper.naMsg
                                  : homeController.userData.value.id!
                                      .toString(),
                              style: TextStyle(
                                color: ConstHelper.orangeColor,
                                fontWeight: FontWeight.w500,
                                fontSize: Get.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Get.width / 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CommonTextField(
                            label: "Gender",
                            subLabel:
                                homeController.userData.value.profileGender ??
                                    "",
                          ),
                        ),
                        Expanded(
                          child: CommonTextField(
                            label: "Date of Birth",
                            subLabel: DateFormat("dd-MM-yyyy").format(
                                homeController
                                        .userData.value.profileDateOfBirth ??
                                    DateTime.now()),
                          ),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 60,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CommonTextField(
                              label: "Time of Birth",
                              subLabel: normalizeTime(homeController
                                      .userData.value.profileTimeOfBirth ??
                                  "")),
                        ),
                        Expanded(
                          child: CommonTextField(
                              label: "Height",
                              subLabel: convertInchesToFeetInch(homeController
                                      .userData.value.profileHeight
                                      ?.toInt() ??
                                  0)),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 60,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CommonTextField(
                              label: "Place of Birth",
                              subLabel: homeController
                                      .userData.value.profilePlaceOfBirth ??
                                  ""),
                        ),
                        Expanded(
                          child: CommonTextField(
                            label: "Email",
                            subLabel: homeController.userData.value.email ?? "",
                          ),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 60,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CommonTextField(
                              label: "Education",
                              subLabel: homeController.userData.value
                                      .profileEducationQualification ??
                                  ""),
                        ),
                        Expanded(
                          child: CommonTextField(
                            label: "Physical Disability(if any)",
                            subLabel: homeController
                                    .userData.value.profilePhysicalDisablity ??
                                "",
                          ),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 60,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: Get.width * 0.005),
                            child: CommonTextField(
                                label: "Community Preferences",
                                subLabel: homeController.userData.value
                                        .profileMarryInComunity ??
                                    ""),
                          ),
                        ),
                        Expanded(
                          child: CommonTextField(
                            label: "My community",
                            subLabel: homeController
                                    .userData.value.profileComunityName ??
                                "",
                          ),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 60,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CommonTextField(
                              label: "Gotra",
                              subLabel:
                                  homeController.userData.value.profileGotra ??
                                      ""),
                        ),
                        Expanded(
                          child: CommonTextField(
                              label: "Father's Name",
                              subLabel: homeController
                                      .userData.value.profileFatherFullName ??
                                  ""),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 60,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CommonTextField(
                            label: "Mother's Name",
                            subLabel: homeController
                                    .userData.value.profileMotherFullName ??
                                '-',
                          ),
                        ),
                        Expanded(
                          child: CommonTextField(
                              label: "Main Contact Number",
                              subLabel: homeController
                                      .userData.value.profileMainContactNum ??
                                  '-'),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 60,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CommonTextField(
                              label: "Main Contact Name",
                              subLabel: homeController.userData.value
                                      .profileMainContactFullName ??
                                  '-'),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 40,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Obx(
                            () => CommonDropdown(
                              items: professionModel.value.data
                                      ?.map((item) =>
                                          (item.profession?.toString() ?? "")
                                              .trim())
                                      .toList() ??
                                  [],
                              value: selectedProfession.value.trim().isEmpty
                                  ? null
                                  : selectedProfession.value,
                              onChanged: (value) {
                                setState(() {
                                  selectedProfession.value = value.toString();
                                });
                              },
                              label: 'Profession',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Get.width / 30,
                        ),
                        Expanded(
                          child: CommonTextFormField(
                            controller: annualIncomeCon,
                            label: 'Annual Income(Lakh)',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.01,
                                horizontal: Get.width * 0.04),
                          ),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 60,
                    ),
                    if (selectedProfession.value.toLowerCase() !=
                        "not in any profession")
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CommonTextFormField(
                              controller: companyNameCon,
                              label: 'Company name',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: Get.height * 0.01,
                                  horizontal: Get.width * 0.04),
                            ),
                          ),
                          SizedBox(
                            width: Get.width / 30,
                          ),
                          Expanded(
                            child: CommonTextFormField(
                              controller: companyTypeCon,
                              label: 'Company Type',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: Get.height * 0.01,
                                  horizontal: Get.width * 0.04),
                            ),
                          ),
                        ],
                      ).paddingOnly(
                        bottom: Get.width / 60,
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CommonTextFormField(
                            controller: altContactNumber,
                            label: 'Alt Contact Number',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.01,
                                horizontal: Get.width * 0.04),
                          ),
                        ),
                        SizedBox(
                          width: Get.width / 30,
                        ),
                        Expanded(
                          child: CommonTextFormField(
                            controller: altContactName,
                            label: 'Alt Contact Name',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.01,
                                horizontal: Get.width * 0.04),
                          ),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 60,
                    ),
                    Text(
                      "Brother's",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: ConstHelper.orangeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: Get.width * 0.045,
                      ),
                    ).paddingOnly(
                        bottom: MediaQuery.of(context).size.height * 0.005),
                    Row(
                      children: [
                        Expanded(
                          child: CommonDropdown(
                            items: List.generate(5, (index) => index.toString())
                                .toList(),
                            value: marriedBrotherCon.value,
                            onChanged: (value) {
                              setState(() {
                                marriedBrotherCon.value = value.toString();
                              });
                            },
                            label: 'Married',
                          ),
                        ),
                        SizedBox(
                          width: Get.width / 30,
                        ),
                        Expanded(
                          child: CommonDropdown(
                            items: List.generate(5, (index) => index.toString())
                                .toList(),
                            value: unMarriedBrotherCon.value,
                            onChanged: (value) {
                              setState(() {
                                unMarriedBrotherCon.value = value.toString();
                              });
                            },
                            label: 'Un Married',
                          ),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 30,
                    ),
                    Text(
                      "Sister's",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: ConstHelper.orangeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: Get.width * 0.045,
                      ),
                    ).paddingOnly(
                        bottom: MediaQuery.of(context).size.height * 0.005),
                    Row(
                      children: [
                        Expanded(
                          child: CommonDropdown(
                            items: List.generate(5, (index) => index.toString())
                                .toList(),
                            value: marriedSisterCon.value,
                            onChanged: (value) {
                              setState(() {
                                marriedSisterCon.value = value.toString();
                              });
                            },
                            label: 'Married',
                          ),
                        ),
                        SizedBox(
                          width: Get.width / 30,
                        ),
                        Expanded(
                          child: CommonDropdown(
                            items: List.generate(5, (index) => index.toString())
                                .toList(),
                            value: unMarriedSisterCon.value,
                            onChanged: (value) {
                              setState(() {
                                unMarriedSisterCon.value = value.toString();
                              });
                            },
                            label: 'Un Married',
                          ),
                        ),
                      ],
                    ).paddingOnly(
                      bottom: Get.width / 30,
                    ),
                    CommonDropdown(
                      items: homeController.marriedBeforeModel.value.data
                              ?.map((e) => e.marriedbefore)
                              .toList() ??
                          [],
                      value: marriedBefore.value,
                      onChanged: (value) {
                        setState(() {
                          marriedBefore.value = value.toString();
                        });
                      },
                      label: 'Have you been married before?',
                    ).paddingOnly(
                      bottom: Get.width / 30,
                    ),
                    CommonTextFormField(
                      controller: currantAddress,
                      label: "Currant Residential Address(Candidate)",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: Get.height * 0.01,
                          horizontal: Get.width * 0.04),
                      maxLines: 3,
                    ),
                    HouseTypeSelector(
                      title: "House Type",
                      onChanged: (val) {
                        selectedHouseType.value = val;
                      },
                      allColor: Colors.black,
                      selectedValue: selectedHouseType.value,
                      firstTitle: "Own",
                      secondTitle: "Rent",
                    ),
                    Text(
                      'PARTNER PREFERENCES',
                      style: TextStyle(
                        color: ConstHelper.orangeColor,
                        fontSize: Get.width * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: Get.width / 65,
                    ),
                    HouseTypeSelector(
                      title: "Will you marry in same Gotra?",
                      onChanged: (val) {
                        print(val);
                        marrySameGotra.value = val;
                      },
                      allColor: Colors.black,
                      selectedValue: marrySameGotra.value,
                      firstTitle: "Yes",
                      secondTitle: "No",
                    ),
                    HouseTypeSelector(
                      title: "Will you be matching Ganna (Janampatri)?",
                      onChanged: (val) {
                        willYouMatchingGanna.value = val;
                      },
                      allColor: Colors.black,
                      selectedValue: willYouMatchingGanna.value,
                      firstTitle: "Yes",
                      secondTitle: "No",
                    ),
                    HouseTypeSelector(
                      title: "Are you Manglik?",
                      onChanged: (val) {
                        areYouManglik.value = val;
                      },
                      allColor: Colors.black,
                      selectedValue: areYouManglik.value,
                      firstTitle: "Yes",
                      secondTitle: "No",
                    ),
                    HouseTypeSelector(
                      title: "Will you marry a Manglik?",
                      onChanged: (val) {
                        areYouMarryAManglik.value = val;
                      },
                      allColor: Colors.black,
                      selectedValue: areYouMarryAManglik.value,
                      firstTitle: "Yes",
                      secondTitle: "No",
                    ),
                    SizedBox(
                      height: Get.width / 30,
                    ),
                    Text(
                      'Prospective Spouse can be (in years)?',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: ConstHelper.orangeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: Get.width * 0.045,
                      ),
                    ).paddingOnly(
                        bottom: MediaQuery.of(context).size.height * 0.005),
                    Row(
                      children: [
                        Expanded(
                          child: CommonDropdown(
                            items:
                                List.generate(10, (index) => index.toString())
                                    .toList(),
                            value: spouseOlderBy.value,
                            onChanged: (value) {
                              setState(() {
                                spouseOlderBy.value = value.toString();
                              });
                            },
                            label: 'Older By',
                          ),
                        ),
                        SizedBox(
                          width: Get.width / 30,
                        ),
                        Expanded(
                          child: CommonDropdown(
                            items:
                                List.generate(10, (index) => index.toString())
                                    .toList(),
                            value: spouseYoungerBy.value,
                            onChanged: (value) {
                              setState(() {
                                spouseYoungerBy.value = value.toString();
                              });
                            },
                            label: 'Younger By',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Get.width / 30,
                    ),
                    Text(
                      'Expected Budget(In Lakhs)',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: ConstHelper.orangeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: Get.width * 0.045,
                      ),
                    ).paddingOnly(
                        bottom: MediaQuery.of(context).size.height * 0.005),
                    Row(
                      children: [
                        Expanded(
                          child: CommonDropdown(
                            items: homeController.budgetCateModel.value.data
                                    ?.map((e) => e.ranges)
                                    .toList() ??
                                [],
                            value: budgetOfBride.value,
                            onChanged: (value) {
                              setState(() {
                                budgetOfBride.value = value.toString();
                              });
                            },
                            label: 'Bride',
                          ),
                        ),
                        if ((homeController.userData.value.profileGender ?? "")
                                .toLowerCase() ==
                            "male") ...[
                          SizedBox(
                            width: Get.width / 30,
                          ),
                          Expanded(
                            child: CommonDropdown(
                              items: homeController.budgetCateModel.value.data
                                      ?.map((e) => e.ranges)
                                      .toList() ??
                                  [],
                              value: budgetOfGroom.value,
                              onChanged: (value) {
                                setState(() {
                                  budgetOfGroom.value = value.toString();
                                });
                              },
                              label: 'Groom',
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(
                      height: Get.width / 20,
                    ),
                    if (homeController.userData.value.profileGender!
                            .toLowerCase() ==
                        "male")
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CommonDropdown(
                              items: PermittedAfterMarriageType.values
                                  .map((element) => element.displayValue)
                                  .toList(),
                              value: bridePermittedWork.value,
                              onChanged: (value) {
                                setState(() {
                                  bridePermittedWork.value = value.toString();
                                });
                              },
                              label: 'Bride permitted to work after marriage?',
                            ),
                          ),
                          SizedBox(
                            width: Get.width / 30,
                          ),
                          Expanded(
                            child: Expanded(
                              child: CommonTextFormField(
                                controller: placeOfResidenceAfterMarriage,
                                label: "Years at the address",
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      height: Get.width / 30,
                    ),
                    CommonTextFormField(
                      controller: briefOfFatherProfession,
                      label: "Brief Summary of Family History",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: Get.height * 0.01,
                          horizontal: Get.width * 0.04),
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    SizedBox(
                      height: Get.width / 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Get.width * 0.02,
                      ),
                      child: InkWell(
                        onTap: () async {
                          try {
                            EasyLoading.show(status: ConstHelper.pleaseWaitMsg);

                            await ApiHelper.apiHelper
                                .editProfile(
                                    profession: selectedProfession.value,
                                    compName: companyNameCon.value.text,
                                    compType: companyTypeCon.value.text,
                                    incomeLakh: annualIncomeCon.value.text,
                                    marriedBrother: marriedBrotherCon.value,
                                    unmarriedBrother: unMarriedBrotherCon.value,
                                    marriedSister: marriedSisterCon.value,
                                    unmarriedSister: unMarriedSisterCon.value,
                                    altContactName: altContactName.value.text,
                                    alterCnctNum: altContactNumber.value.text,
                                    fullPhoto: "",
                                    facePhoto: "",
                                    briefFatherProfession:
                                        briefOfFatherProfession.value.text,
                                    sameGothra: marrySameGotra.value,
                                    matchGanna: willYouMatchingGanna.value,
                                    isManglik: areYouManglik.value,
                                    marryManglik: areYouMarryAManglik.value,
                                    olderBy: spouseOlderBy.value,
                                    youngerBy: spouseYoungerBy.value,
                                    bridebudget: homeController
                                            .budgetCateModel.value.data
                                            ?.firstWhereOrNull((element) =>
                                                element.ranges ==
                                                budgetOfBride.value)
                                            ?.id
                                            ?.toString() ??
                                        "",
                                    groombudget: homeController
                                            .budgetCateModel.value.data
                                            ?.firstWhereOrNull((element) =>
                                                element.ranges ==
                                                budgetOfGroom.value)
                                            ?.id
                                            ?.toString() ??
                                        "",
                                    workAftrMarrige: bridePermittedWork.value,
                                    numYraddrs: placeOfResidenceAfterMarriage
                                        .value.text,
                                    ownrent: selectedHouseType.value,
                                    marriedBfor: marriedBefore.value,
                                    resAddress: currantAddress.value.text
                                    /* whatsapp: txtWhatsappNo.text,
                              working_city: txtWorkingCity.text,
                              ref_contact_name: txtReferenceName.text,
                              ref_contact_mobile: txtReferenceMobileNo.text,
                              photo: selectedPhotoPath.value,
                              education: txtQualification.text,
                              occupation: txtOccupation.text,
                              have_married_before: selectedPhysical,
                              physical_disablity: selectedPhysical,
                              note: txtImportantNote.text,
                              permanent_address: txtAddress.text,
                              village_city: "",
                              profession: ''*/
                                    )
                                .then(
                              (value) {
                                EasyLoading.dismiss();
                                Get.back();
                                ConstHelper.successDialog(
                                  text: 'Profile Updated Successfully',
                                  seconds: 10,
                                );
                              },
                            );
                            Get.back();
                            homeController.userData.value =
                                (await ApiHelper.apiHelper.fetchProfile())!;
                          } catch (e) {
                            EasyLoading.dismiss();
                            print(e);
                          }
                        },
                        child: Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: ConstHelper.orangeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: Get.width / 30,
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              color: ConstHelper.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: Get.width * 0.045,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Get.width / 20,
                    ),
                  ],
                ),
              ),
            )),
      ),
    ));
  }
}

class CommonTextField extends StatelessWidget {
  final String label;
  final String subLabel;
  final TextStyle? textStyle;

  const CommonTextField({
    super.key,
    required this.label,
    required this.subLabel,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black,
            fontSize: Get.width * 0.035,
          ),
        ),
        Text(
          subLabel,
          style: textStyle ??
              TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: Get.width * 0.04,
              ),
        ),
      ],
    );
  }
}

class CommonTextFormField extends StatelessWidget {
  final String label;
  final String? counterText;
  final TextEditingController controller;
  final bool readOnly;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;

  const CommonTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.textStyle,
    this.contentPadding,
    this.textInputAction,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
    this.counterText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: Get.width * 0.04,
          ),
        ).paddingOnly(bottom: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          validator: validator,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          style: textStyle ??
              TextStyle(
                fontSize: Get.width * 0.04,
                color: Colors.black,
              ),
          decoration: InputDecoration(
            counterText: counterText,
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.02,
                    vertical: 0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ConstHelper.blackColor, width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ConstHelper.blackColor, width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: ConstHelper.blackColor, width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    ).paddingOnly(bottom: MediaQuery.of(context).size.height * 0.01);
  }
}

class CommonDropdown extends StatelessWidget {
  final List<dynamic> items;
  final String label;

  final String? value;
  final Function(String?) onChanged;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final Icon? dropdownIcon;
  final TextStyle? itemTextStyle;
  final double itemHeight;
  final EdgeInsetsGeometry? itemPadding;

  const CommonDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.height = 48,
    this.width,
    this.padding,
    this.decoration,
    this.dropdownIcon,
    this.itemTextStyle,
    this.itemHeight = 70,
    this.itemPadding,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: Get.width * 0.04,
          ),
        ).paddingOnly(bottom: MediaQuery.of(context).size.height * 0.01),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: items
                .toSet()
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: itemTextStyle ??
                            TextStyle(
                              fontSize: Get.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            value: value == null || value!.trim().isEmpty ? null : value,
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              height: height,
              width: width ?? MediaQuery.of(context).size.width,
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 14),
              decoration: decoration ??
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black),
                  ),
              elevation: 0,
            ),
            iconStyleData: IconStyleData(
              icon: dropdownIcon ?? const Icon(Icons.keyboard_arrow_down),
              iconSize: 18,
              iconEnabledColor: Colors.black,
              iconDisabledColor: Colors.grey,
            ),
            dropdownStyleData: DropdownStyleData(
              width: width ?? MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
              offset: const Offset(-10, 0),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: itemHeight,
              padding: itemPadding ??
                  EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                      vertical: MediaQuery.of(context).size.height * 0.01),
            ),
          ),
        ),
      ],
    );
  }
}

/*import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../controllers/home_controller.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import '../../utils/photo_view_page.dart';

class Editprofilepage extends StatefulWidget {
  const Editprofilepage({super.key});

  @override
  State<Editprofilepage> createState() => _EditprofilepageState();
}

class _EditprofilepageState extends State<Editprofilepage> {
  HomeController homeController = Get.put(HomeController());

  List yesNoList = ["Yes", "No"];

  String selectedMarried = "No";
  String selectedPhysical = "No";
  RxString selectedPhotoPath = ''.obs;
  RxString photoPath = ''.obs;

  TextEditingController txtBirthDate = TextEditingController();
  TextEditingController txtBirthTime = TextEditingController();
  TextEditingController txtBirthPlace = TextEditingController();
  TextEditingController txtHeight = TextEditingController();
  TextEditingController txtGender = TextEditingController();
  TextEditingController txtMobileNo = TextEditingController();
  TextEditingController txtWhatsappNo = TextEditingController();
  TextEditingController txtMainContactNo = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtQualification = TextEditingController();
  TextEditingController txtOccupation = TextEditingController();
  TextEditingController txtFatherName = TextEditingController();
  TextEditingController txtReferenceName = TextEditingController();
  TextEditingController txtReferenceMobileNo = TextEditingController();
  TextEditingController txtWorkingCity = TextEditingController();
  TextEditingController txtPlaceOfBirth = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtImportantNote = TextEditingController();
  TextEditingController txtGotra = TextEditingController();
  TextEditingController txtCommunity = TextEditingController();

  /// Added new string
  TextEditingController altNumber = TextEditingController();
  TextEditingController altName = TextEditingController();

  getData() {
    photoPath.value = homeController
                    .userData.value.profileFullFacePhotoFileName ==
                null ||
            homeController.userData.value.profileFullFacePhotoFileName!
                .trim()
                .isEmpty
        ? ConstHelper.profileImagePath
        : '${ConstHelper.userImagesPath}${homeController.userData.value.profileFullFacePhotoFileName!}';
    txtBirthDate.text =
        homeController.userData.value.profileDateOfBirth == null ||
                homeController.userData.value.profileDateOfBirth!.year <= 0
            ? ConstHelper.naMsg
            : DateFormat('dd | MMM | yyyy')
                .format(homeController.userData.value.profileDateOfBirth!);
    txtBirthTime.text =
        homeController.userData.value.profileTimeOfBirth == null ||
                homeController.userData.value.profileTimeOfBirth!.trim().isEmpty
            ? ConstHelper.naMsg
            : homeController.userData.value.profileTimeOfBirth!;
    txtBirthPlace.text = homeController.userData.value.profilePlaceOfBirth ==
                null ||
            homeController.userData.value.profilePlaceOfBirth!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.profilePlaceOfBirth!;
    txtHeight.text = homeController.userData.value.profileHeight == null ||
            homeController.userData.value.profileHeight!
                .toString()
                .trim()
                .isEmpty
        ? ConstHelper.naMsg
        : '${homeController.userData.value.profileHeight!.toString()} ft ${homeController.userData.value.profileHeight!.toString().substring(1)} Inch';
    txtGender.text = homeController.userData.value.profileGender == null ||
            homeController.userData.value.profileGender!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.profileGender!;
    txtMobileNo.text = homeController.userData.value.profileMainContactNum ==
                null ||
            homeController.userData.value.profileMainContactNum!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.profileMainContactNum!;
    txtWhatsappNo.text = homeController.userData.value.profileMainContactNum ==
                null ||
            homeController.userData.value.profileMainContactNum!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.profileMainContactNum!;
    txtMainContactNo
        .text = homeController.userData.value.profileMainContactNum == null ||
            homeController.userData.value.profileMainContactNum!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.profileMainContactNum!;
    txtEmail.text = homeController.userData.value.email == null ||
            homeController.userData.value.email!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.email!;
    txtFatherName.text = homeController.userData.value.profileFatherFullName ==
                null ||
            homeController.userData.value.profileFatherFullName!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.profileFatherFullName!;
    txtReferenceMobileNo.text =
        homeController.userData.value.profileAlternateContactNum == null ||
                homeController.userData.value.profileAlternateContactNum!
                    .trim()
                    .isEmpty
            ? ConstHelper.naMsg
            : homeController.userData.value.profileAlternateContactNum!;
    selectedMarried =
        homeController.userData.value.profileHaveMarriedBefore == null ||
                homeController.userData.value.profileHaveMarriedBefore!
                    .trim()
                    .isEmpty
            ? ConstHelper.naMsg
            : homeController.userData.value.profileHaveMarriedBefore!;
    selectedPhysical =
        homeController.userData.value.profilePhysicalDisablity == null ||
                homeController.userData.value.profilePhysicalDisablity!
                    .trim()
                    .isEmpty
            ? ConstHelper.naMsg
            : homeController.userData.value.profilePhysicalDisablity!;
    txtQualification.text =
        homeController.userData.value.profileEducationCatogery == null ||
                homeController.userData.value.profileEducationCatogery!
                    .trim()
                    .isEmpty
            ? ConstHelper.naMsg
            : homeController.userData.value.profileEducationCatogery!;
    txtOccupation.text =
        homeController.userData.value.profileProfession == null ||
                homeController.userData.value.profileProfession!.trim().isEmpty
            ? ConstHelper.naMsg
            : homeController.userData.value.profileProfession!;
    txtReferenceName.text =
        homeController.userData.value.profileAlternateContactNum == null ||
                homeController.userData.value.profileAlternateContactNum!
                    .trim()
                    .isEmpty
            ? ConstHelper.naMsg
            : homeController.userData.value.profileAlternateContactNum!;
    txtWorkingCity.text =
        homeController.userData.value.profilePresentCity == null ||
                homeController.userData.value.profilePresentCity!.trim().isEmpty
            ? ConstHelper.naMsg
            : homeController.userData.value.profilePresentCity!;
    txtAddress.text =
        homeController.userData.value.profileCurrentResidAddress == null ||
                homeController.userData.value.profileCurrentResidAddress!
                    .trim()
                    .isEmpty
            ? ConstHelper.naMsg
            : homeController.userData.value.profileCurrentResidAddress!;
    txtImportantNote.text = homeController.userData.value.profileNote == null ||
            homeController.userData.value.profileNote!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.profileNote!;
    txtGotra.text = homeController.userData.value.profileGotra == null ||
            homeController.userData.value.profileGotra!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.profileGotra!;
    txtCommunity.text = homeController.userData.value.profileComunityName ==
                null ||
            homeController.userData.value.profileComunityName!.trim().isEmpty
        ? ConstHelper.naMsg
        : homeController.userData.value.profileComunityName!;
  }

  @override
  void initState() {
    super.initState();
    selectedMarried = yesNoList.first;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 20,
            color: ConstHelper.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            size: Get.width / 13,
          ),
        ),
        centerTitle: true,
        backgroundColor: ConstHelper.whiteColor,
        surfaceTintColor: ConstHelper.whiteColor,
        elevation: 10,
        shadowColor: ConstHelper.greyColor.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: () async {
              Get.back();
              Get.back();
              await Future.delayed(
                const Duration(
                  milliseconds: 300,
                ),
              );
              homeController.advancedDrawerController.hideDrawer();
            },
            icon: SvgPicture.asset(
              'assets/image/homeSVG.svg',
              height: Get.width / 18,
              width: Get.width / 18,
              color: ConstHelper.orangeColor,
            ),
          ),
        ],
        // elevation: 3,
        // shadowColor: Colors.grey.shade50.withOpacity(0.3),
      ),
      backgroundColor: ConstHelper.whiteColor,
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width / 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Get.width / 30,
                ),
                Obx(
                  () => Center(
                    child: Container(
                      height: Get.width / 2.3,
                      width: Get.width / 2.3,
                      child: Stack(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (selectedPhotoPath.trim().isNotEmpty) {
                                  Get.to(
                                    PhotoViewPage(
                                        imagePath: selectedPhotoPath.value),
                                  );
                                }
                              },
                              child: Container(
                                height: Get.width / 2.3,
                                width: Get.width / 2.3,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(
                                      color: ConstHelper.orangeColor,
                                    ),
                                    image: selectedPhotoPath.trim().isEmpty
                                        ? DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              photoPath.value,
                                            ),
                                          )
                                        : DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                              File(selectedPhotoPath.value),
                                            ),
                                          )),
                                child: selectedPhotoPath.trim().isNotEmpty ||
                                        photoPath.value.isNotEmpty
                                    ? null
                                    : Center(
                                        child: SvgPicture.asset(
                                        'assets/image/personWithRoundedSVG.svg',
                                        height: Get.width / 3.5,
                                        width: Get.width / 3.5,
                                        fit: BoxFit.contain,
                                        color: ConstHelper.cementColor,
                                      )),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: Get.width / 100,
                                bottom: Get.width / 100,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return IntrinsicHeight(
                                        child: Container(
                                          width: Get.width,
                                          decoration: BoxDecoration(
                                              color: ConstHelper.whiteColor,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                              )),
                                          padding: EdgeInsets.all(
                                            Get.width / 30,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Choose',
                                                style: TextStyle(
                                                  color: ConstHelper.blackColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              SizedBox(
                                                height: Get.width / 30,
                                              ),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      selectedPhotoPath.value =
                                                          await ConstHelper
                                                              .constHelper
                                                              .pickImage(
                                                        source:
                                                            ImageSource.camera,
                                                      );
                                                      if (selectedPhotoPath
                                                          .trim()
                                                          .isNotEmpty) {
                                                        Get.back();
                                                      }
                                                    },
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .camera_alt_rounded,
                                                          color: ConstHelper
                                                              .orangeColor,
                                                          size: Get.width / 18,
                                                        ),
                                                        Text(
                                                          'Camera',
                                                          style: TextStyle(
                                                            color: ConstHelper
                                                                .orangeColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: Get.width / 20,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      selectedPhotoPath.value =
                                                          await ConstHelper
                                                              .constHelper
                                                              .pickImage(
                                                        source:
                                                            ImageSource.gallery,
                                                      );
                                                      if (selectedPhotoPath
                                                          .trim()
                                                          .isNotEmpty) {
                                                        Get.back();
                                                      }
                                                    },
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons.photo_rounded,
                                                          color: ConstHelper
                                                              .orangeColor,
                                                          size: Get.width / 18,
                                                        ),
                                                        Text(
                                                          'Gallery',
                                                          style: TextStyle(
                                                            color: ConstHelper
                                                                .orangeColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ConstHelper.orangeColor,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(Get.width / 60),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    color: ConstHelper.whiteColor,
                                    size: Get.width / 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.width / 15,
                ),
                Center(
                  child: Text(
                    homeController.userData.value.name == null ||
                            homeController.userData.value.name!.trim().isEmpty
                        ? ConstHelper.nameNotAvailableMsg
                        : homeController.userData.value.name!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ConstHelper.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Center(
                  child: Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(children: [
                        TextSpan(
                          text: 'User ID : ',
                          style: TextStyle(
                            color: ConstHelper.blackColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: homeController.userData.value.id == null ||
                                  homeController.userData.value.id == 0
                              ? ConstHelper.naMsg
                              : homeController.userData.value.id!.toString(),
                          style: TextStyle(
                            color: ConstHelper.orangeColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ])),
                ),
                SizedBox(
                  height: Get.width / 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date of Birth",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtBirthDate,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.whiteColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //   borderSide: BorderSide(color: ConstHelper.whiteColor,),
                                //   borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width / 30,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date of Time",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtBirthTime,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //   borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //   borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Place of Birth",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtBirthPlace,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //   borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //   borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width / 30,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Height",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtHeight,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //   borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //   borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gender",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtGender,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //   borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //   borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width / 30,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mobile No.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtMobileNo,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //   borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //   borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Contact No.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtMainContactNo,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //   borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //   borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width / 30,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Father Name",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtFatherName,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Text(
                  "Email ID",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ConstHelper.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Container(
                  height: 40,
                  child: TextFormField(
                    style: TextStyle(
                      color: ConstHelper.blackColor,
                    ),
                    controller: txtEmail,
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter the full name";
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 5, left: 8),
                      // focusedBorder: OutlineInputBorder(
                      //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                      //     borderRadius: BorderRadius.circular(10)
                      // ),
                      // border: OutlineInputBorder(
                      //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                      //     borderRadius: BorderRadius.circular(10)
                      // )
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WhatsApp No.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtWhatsappNo,
                              maxLength: 10,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding:
                                      const EdgeInsets.only(bottom: 5, left: 8),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ConstHelper.blackColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ConstHelper.blackColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width / 30,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reference No.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtReferenceMobileNo,
                              maxLength: 10,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding:
                                      const EdgeInsets.only(bottom: 5, left: 8),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ConstHelper.blackColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ConstHelper.blackColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Text(
                  "Have you been married before?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ConstHelper.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                CommonDropdown(
                  items: yesNoList,
                  value: yesNoList.first,
                  onChanged: (value) {
                    setState(() {
                      selectedMarried = value.toString();
                    });
                  },
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    items: yesNoList
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    value: yesNoList.first,
                    // Default to the first item if null or invalid
                    onChanged: (String? value) {
                      setState(() {
                        selectedMarried = value!;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black),
                      ),
                      elevation: 0,
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconSize: 18,
                      iconEnabledColor: Colors.black,
                      iconDisabledColor: Colors.grey,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      offset: const Offset(-20, 0),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 14, right: 14),
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Text(
                  "Physical Disability (if any)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ConstHelper.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    items: yesNoList
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ConstHelper.blackColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    value: selectedPhysical,
                    onChanged: (String? value) {
                      setState(() {
                        selectedPhysical = value.toString();
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 40,
                      width: Get.width,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ConstHelper.blackColor),
                      ),
                      elevation: 0,
                    ),
                    iconStyleData: IconStyleData(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                      ),
                      iconSize: 18,
                      iconEnabledColor: ConstHelper.blackColor,
                      iconDisabledColor: Colors.grey,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: Get.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      offset: const Offset(-20, 0),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all<double>(6),
                        thumbVisibility: MaterialStateProperty.all<bool>(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 14, right: 14),
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Text(
                  "Qualification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ConstHelper.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Container(
                  height: 40,
                  child: TextFormField(
                    style: TextStyle(
                      color: ConstHelper.blackColor,
                    ),
                    controller: txtQualification,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter the full name";
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(bottom: 5, left: 8),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: ConstHelper.blackColor,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: ConstHelper.blackColor,
                            ),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Text(
                  "Occupation",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ConstHelper.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Container(
                  height: 40,
                  child: TextFormField(
                    style: TextStyle(
                      color: ConstHelper.blackColor,
                    ),
                    controller: txtOccupation,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter the full name";
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(bottom: 5, left: 8),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: ConstHelper.blackColor,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: ConstHelper.blackColor,
                            ),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reference Name",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtReferenceName,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(bottom: 5, left: 8),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ConstHelper.blackColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ConstHelper.blackColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width / 30,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Working City",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtWorkingCity,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(bottom: 5, left: 8),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ConstHelper.blackColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ConstHelper.blackColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Text(
                  "Permanent Address",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ConstHelper.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Container(
                  height: 40,
                  child: TextFormField(
                    style: TextStyle(
                      color: ConstHelper.blackColor,
                    ),
                    controller: txtAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter the full name";
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(bottom: 5, left: 8),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: ConstHelper.blackColor,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: ConstHelper.blackColor,
                            ),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Text(
                  "Important Note",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ConstHelper.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Container(
                  height: 40,
                  child: TextFormField(
                    style: TextStyle(
                      color: ConstHelper.blackColor,
                    ),
                    controller: txtImportantNote,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter the full name";
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(bottom: 5, left: 8),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: ConstHelper.blackColor,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: ConstHelper.blackColor,
                            ),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                SizedBox(
                  height: Get.width / 60,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gotra",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtGotra,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                counterText: "",
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width / 30,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Community",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstHelper.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(
                                color: ConstHelper.blackColor,
                              ),
                              controller: txtCommunity,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the full name";
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                counterText: "",
                                contentPadding:
                                    EdgeInsets.only(bottom: 5, left: 8),
                                // focusedBorder: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // ),
                                // border: OutlineInputBorder(
                                //     borderSide: BorderSide(color: ConstHelper.blackColor,),
                                //     borderRadius: BorderRadius.circular(10)
                                // )
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Get.width / 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width / 8,
                  ),
                  child: InkWell(
                    onTap: () async {
                      await ApiHelper.apiHelper
                          .editProfile(
                              whatsapp: txtWhatsappNo.text,
                              working_city: txtWorkingCity.text,
                              ref_contact_name: txtReferenceName.text,
                              ref_contact_mobile: txtReferenceMobileNo.text,
                              photo: selectedPhotoPath.value,
                              education: txtQualification.text,
                              occupation: txtOccupation.text,
                              have_married_before: selectedPhysical,
                              physical_disablity: selectedPhysical,
                              note: txtImportantNote.text,
                              permanent_address: txtAddress.text,
                              village_city: "")
                          .then(
                        (value) {
                          Get.back();
                          ConstHelper.successDialog(
                            text: 'Profile Updated Successfully',
                            seconds: 10,
                          );
                        },
                      );
                      homeController.userData.value =
                          (await ApiHelper.apiHelper.fetchProfile())!;
                    },
                    child: Container(
                      width: Get.width,
                      decoration: BoxDecoration(
                        color: ConstHelper.orangeColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        vertical: Get.width / 30,
                      ),
                      child: Text(
                        'Update',
                        style: TextStyle(
                          color: ConstHelper.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.width / 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommonDropdown extends StatelessWidget {
  final List<dynamic> items;
  final String? value;
  final Function(String?) onChanged;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final Icon? dropdownIcon;
  final TextStyle? itemTextStyle;
  final double itemHeight;
  final EdgeInsetsGeometry? itemPadding;

  const CommonDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.height = 40,
    this.width,
    this.padding,
    this.decoration,
    this.dropdownIcon,
    this.itemTextStyle,
    this.itemHeight = 40,
    this.itemPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: itemTextStyle ??
                        const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        value: value,
        onChanged: onChanged,
        buttonStyleData: ButtonStyleData(
          height: height,
          width: width ?? MediaQuery.of(context).size.width,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14),
          decoration: decoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black),
              ),
          elevation: 0,
        ),
        iconStyleData: IconStyleData(
          icon: dropdownIcon ?? const Icon(Icons.keyboard_arrow_down),
          iconSize: 18,
          iconEnabledColor: Colors.black,
          iconDisabledColor: Colors.grey,
        ),
        dropdownStyleData: DropdownStyleData(
          width: width ?? MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          offset: const Offset(-20, 0),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: itemHeight,
          padding: itemPadding ?? const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}
*/
String convertInchesToFeetInch(int inches) {
  if (inches <= 0) return "";
  int feet = inches ~/ 12;
  int remainingInches = inches % 12;
  return "$feet ft $remainingInches Inch";
}
