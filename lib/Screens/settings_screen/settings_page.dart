import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/home_controller.dart';
import '../../models/members_data_model.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import '../home_screen/home_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!homeController.userDataWithToken.value.isSubscribed) {
        if (mounted) {
          Get.back();
          Get.snackbar(
            'Subscription Required',
            'Not subscribed',
            backgroundColor: const Color(0xFFD32F2F),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    });
  }

  // Top Tab Index: 0 = Preferences, 1 = Notifications, 2 = Privacy
  final RxInt selectedSettingTab = 0.obs;

  // Accordion Expand/Collapse States
  final RxBool isBasicOpen = true.obs;
  final RxBool isCommunityOpen = true.obs;
  final RxBool isLocationOpen = true.obs;
  final RxBool isAdvancedOpen = true.obs;

  // Location Preference States
  final RxString selectedCurrentCity = "Any".obs;
  final RxString selectedResidentLocation = "Chennai - Tamil Nadu".obs;

  final List<String> cityList = [
    'Any',
    'Bangalore',
    'Chennai',
    'Mumbai',
    'Delhi',
    'Hyderabad',
    'Pune',
    'Kolkata',
    'Ahmedabad',
    'Coimbatore',
    'Madurai',
  ];

  final List<String> residentLocationList = [
    'Any',
    'Chennai - Tamil Nadu',
    'Bangalore - Karnataka',
    'Mumbai - Maharashtra',
    'Delhi - NCR',
    'Hyderabad - Telangana',
    'Pune - Maharashtra',
    'Kolkata - West Bengal',
  ];

  final RxList<String> minHeightList = [
    '4.0',
    '4.1',
    '4.2',
    '4.3',
    '4.4',
    '4.5',
    '4.6',
    '4.7',
    '4.8',
    '4.9',
    '4.10',
    '4.11',
    '5.0',
    '5.1',
    '5.2',
    '5.3',
    '5.4',
    '5.5',
    '5.6',
    '5.7',
    '5.8',
    '5.9',
    '5.10',
    '5.11',
  ].obs;

  final RxList<String> maxHeightList = [
    '6.0',
    '6.1',
    '6.2',
    '6.3',
    '6.4',
    '6.5',
    '6.6',
    '6.7',
    '6.8',
    '6.9',
    '6.10',
    '6.11',
    '7.0',
  ].obs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E2448),
              size: 20,
            ),
          ),
          centerTitle: true,
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1E2448),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Find your right match",
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF7A8299),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: InkWell(
                onTap: _onReset,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.replay_rounded,
                        color: Color(0xFFE5097F),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Reset",
                        style: TextStyle(
                          color: Color(0xFFE5097F),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: const Color(0xFFF0F0F5),
              height: 1,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildTopCategoryTabs(),
              const SizedBox(height: 12),
              Obx(() {
                switch (selectedSettingTab.value) {
                  case 0:
                    return _buildPreferencesView();
                  case 1:
                    return _buildNotificationsView();
                  case 2:
                    return _buildPrivacyView();
                  default:
                    return _buildPreferencesView();
                }
              }),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  // Top Segmented Tabs: Preferences | Notifications | Privacy
  Widget _buildTopCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _buildTabItem(
              index: 0,
              icon: Icons.tune_rounded,
              label: "Preferences",
            ),
            _buildTabItem(
              index: 1,
              icon: Icons.notifications_none_rounded,
              label: "Notifications",
            ),
            _buildTabItem(
              index: 2,
              icon: Icons.shield_outlined,
              label: "Privacy",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = selectedSettingTab.value == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          selectedSettingTab.value = index;
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE5097F) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFE5097F).withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFFE5097F),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4A4A68),
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab 0: Preferences View
  Widget _buildPreferencesView() {
    return Column(
      children: [
        // 1. Basic Preferences
        _buildSectionCard(
          number: 1,
          sectionIcon: Icons.tune_rounded,
          title: "Basic Preferences",
          isOpen: isBasicOpen,
          child: _buildBasicPreferencesContent(),
        ),

        // 2. Community Preferences
        _buildSectionCard(
          number: 2,
          sectionIcon: Icons.storefront_rounded,
          title: "Community Preferences",
          isOpen: isCommunityOpen,
          child: _buildCommunityPreferencesContent(),
        ),

        // 3. Location Preferences
        _buildSectionCard(
          number: 3,
          sectionIcon: Icons.wb_sunny_outlined,
          title: "Location Preferences",
          isOpen: isLocationOpen,
          child: _buildLocationPreferencesContent(),
        ),

        // 4. Advanced Preferences
        _buildSectionCard(
          number: 4,
          sectionIcon: Icons.tune_rounded,
          title: "Advanced Preferences",
          isOpen: isAdvancedOpen,
          child: _buildAdvancedPreferencesContent(),
        ),

        const SizedBox(height: 16),

        // Bottom Save Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: _onSave,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1493), Color(0xFFE5097F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE5097F).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Save Preferences",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Section 1: Basic Preferences
  Widget _buildBasicPreferencesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Height (in feet / inches)
        _buildFieldTitle(
          icon: Icons.height_rounded,
          title: "Height",
          subtitle: "(in feet / inches)",
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Minimum Height',
                    style: TextStyle(
                      color: Color(0xFF4A4A68),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => _buildDropdown<String>(
                      value: homeController.selectedMinHeightValue.value,
                      items: minHeightList
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                "$item ft",
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E2448),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          homeController.selectedMinHeightValue.value = val;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maximum Height',
                    style: TextStyle(
                      color: Color(0xFF4A4A68),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => _buildDropdown<String>(
                      value: homeController.selectedMaxHeightValue.value,
                      items: maxHeightList
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                "$item ft",
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E2448),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          homeController.selectedMaxHeightValue.value = val;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Age (in years)
        _buildFieldTitle(
          icon: Icons.star_rounded,
          title: "Age",
          subtitle: "(in years)",
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum ${homeController.selectedAgeStart.value.toStringAsFixed(0)} years',
                style: const TextStyle(
                  color: Color(0xFF4A4A68),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Maximum ${homeController.selectedAgeEnd.value.toStringAsFixed(0)} years',
                style: const TextStyle(
                  color: Color(0xFF4A4A68),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: const Color(0xFFE5097F),
              inactiveTrackColor: const Color(0xFFFDE8EF),
              thumbColor: const Color(0xFFE5097F),
              overlayColor: const Color(0xFFE5097F).withValues(alpha: 0.15),
              rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            ),
            child: RangeSlider(
              divisions: 32,
              values: RangeValues(
                homeController.selectedAgeStart.value,
                homeController.selectedAgeEnd.value,
              ),
              onChanged: (value) {
                homeController.selectedAgeStart.value = value.start;
                homeController.selectedAgeEnd.value = value.end;
              },
              min: 18.0,
              max: 50.0,
            ),
          ),
        ),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                homeController.selectedAgeStart.value.toStringAsFixed(0),
                style: const TextStyle(
                  color: Color(0xFF1E2448),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                homeController.selectedAgeEnd.value.toStringAsFixed(0),
                style: const TextStyle(
                  color: Color(0xFF1E2448),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Yearly Income (in Lakh)
        _buildFieldTitle(
          icon: Icons.favorite_rounded,
          title: "Yearly Income",
          subtitle: "(in Lakh)",
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum ${homeController.yearlyIncomeStart.value.toStringAsFixed(0)} Lakh',
                style: const TextStyle(
                  color: Color(0xFF4A4A68),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Maximum ${homeController.yearlyIncomeEnd.value.toStringAsFixed(0)} Lakh',
                style: const TextStyle(
                  color: Color(0xFF4A4A68),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: const Color(0xFFE5097F),
              inactiveTrackColor: const Color(0xFFFDE8EF),
              thumbColor: const Color(0xFFE5097F),
              overlayColor: const Color(0xFFE5097F).withValues(alpha: 0.15),
              rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            ),
            child: RangeSlider(
              divisions: 300,
              values: RangeValues(
                homeController.yearlyIncomeStart.value,
                homeController.yearlyIncomeEnd.value,
              ),
              onChanged: (value) {
                homeController.yearlyIncomeStart.value = value.start;
                homeController.yearlyIncomeEnd.value = value.end;
              },
              min: 1.0,
              max: 300.0,
            ),
          ),
        ),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${homeController.yearlyIncomeStart.value.toStringAsFixed(0)} Lakh",
                style: const TextStyle(
                  color: Color(0xFF1E2448),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${homeController.yearlyIncomeEnd.value.toStringAsFixed(0)} Lakh",
                style: const TextStyle(
                  color: Color(0xFF1E2448),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Section 2: Community Preferences
  Widget _buildCommunityPreferencesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(
          icon: Icons.group_work_outlined,
          title: "Gotra",
          subtitle: "(to exclude)",
        ),
        const SizedBox(height: 10),
        Obx(
          () => _buildDropdown<String>(
            value: homeController.selectedGotra.value,
            items: homeController.gotraDataList
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: item == "-- Select Gotra --"
                            ? FontWeight.w600
                            : FontWeight.bold,
                        color: item == "-- Select Gotra --"
                            ? const Color(0xFFE5097F)
                            : const Color(0xFF1E2448),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                homeController.selectedGotra.value = val;
              }
            },
          ),
        ),
      ],
    );
  }

  // Section 3: Location Preferences
  Widget _buildLocationPreferencesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(
          icon: Icons.place_outlined,
          title: "Current City",
          subtitle: "(Preferred)",
        ),
        const SizedBox(height: 10),
        Obx(
          () => _buildDropdown<String>(
            value: selectedCurrentCity.value,
            items: cityList
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2448),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                selectedCurrentCity.value = val;
              }
            },
          ),
        ),

        const SizedBox(height: 18),

        _buildFieldTitle(
          icon: Icons.location_city_rounded,
          title: "Resident After Marriage",
        ),
        const SizedBox(height: 10),
        Obx(
          () => _buildDropdown<String>(
            value: selectedResidentLocation.value,
            items: residentLocationList
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2448),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                selectedResidentLocation.value = val;
              }
            },
          ),
        ),
      ],
    );
  }

  // Section 4: Advanced Preferences
  Widget _buildAdvancedPreferencesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Education Selection
        _buildEducationSection(),

        const SizedBox(height: 18),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF6F6FA)),
        const SizedBox(height: 14),

        // Manglik Preference
        _buildFieldTitle(
          icon: Icons.warning_amber_rounded,
          title: "Manglik",
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            children: [
              _buildSegmentPill(
                label: "Yes",
                isSelected: homeController.maglikStatus.value.toLowerCase() == "yes",
                onTap: () {
                  homeController.maglikStatus.value = "Yes";
                },
              ),
              const SizedBox(width: 10),
              _buildSegmentPill(
                label: "No",
                isSelected: homeController.maglikStatus.value.toLowerCase() == "no",
                onTap: () {
                  homeController.maglikStatus.value = "No";
                },
              ),
              const SizedBox(width: 10),
              _buildSegmentPill(
                label: "All",
                isSelected: homeController.maglikStatus.value.toLowerCase() == "all",
                onTap: () {
                  homeController.maglikStatus.value = "All";
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF6F6FA)),
        const SizedBox(height: 14),

        // Married Before Preference
        _buildFieldTitle(
          icon: Icons.favorite_border_rounded,
          title: "Married Before",
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            children: [
              _buildSegmentPill(
                label: "Yes",
                isSelected: homeController.marriedBeforeStatus.value.toLowerCase() == "yes",
                onTap: () {
                  homeController.marriedBeforeStatus.value = "Yes";
                },
              ),
              const SizedBox(width: 10),
              _buildSegmentPill(
                label: "No",
                isSelected: homeController.marriedBeforeStatus.value.toLowerCase() == "no",
                onTap: () {
                  homeController.marriedBeforeStatus.value = "No";
                },
              ),
              const SizedBox(width: 10),
              _buildSegmentPill(
                label: "All",
                isSelected: homeController.marriedBeforeStatus.value.toLowerCase() == "all",
                onTap: () {
                  homeController.marriedBeforeStatus.value = "All";
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Education Section with Select All & Chips
  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldTitle(
              icon: Icons.school_outlined,
              title: "Select Education",
            ),
            Obx(
              () => InkWell(
                onTap: () {
                  homeController.selectAll.value = !homeController.selectAll.value;
                  for (int i = 0; i < homeController.educationDataList.length; i++) {
                    homeController.educationDataList[i]['selected'] =
                        homeController.selectAll.value;
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: homeController.selectAll.value
                              ? const Color(0xFFE5097F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: homeController.selectAll.value
                                ? const Color(0xFFE5097F)
                                : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: homeController.selectAll.value
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 13,
                              )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Select All",
                        style: TextStyle(
                          color: homeController.selectAll.value
                              ? const Color(0xFFE5097F)
                              : const Color(0xFF4A4A68),
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(homeController.educationDataList.length, (index) {
              final item = homeController.educationDataList[index];
              final isSelected = item['selected'] == true;
              final title = item['education_name']?.toString() ?? '-';

              return InkWell(
                onTap: () {
                  homeController.educationDataList[index]['selected'] = !isSelected;
                  homeController.educationDataList[index] =
                      homeController.educationDataList[index];
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFDE8EF) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE5097F)
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          Icons.check_rounded,
                          color: Color(0xFFE5097F),
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFE5097F)
                              : const Color(0xFF4A4A68),
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // Generic Accordion Section Card
  Widget _buildSectionCard({
    required int number,
    required IconData sectionIcon,
    required String title,
    required RxBool isOpen,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF0F0F5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          InkWell(
            onTap: () {
              isOpen.value = !isOpen.value;
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5097F),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      number.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    sectionIcon,
                    color: const Color(0xFFE5097F),
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1E2448),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  Obx(
                    () => Icon(
                      isOpen.value
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF6B7280),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Collapsible Body
          Obx(
            () => isOpen.value
                ? Column(
                    children: [
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF6F6FA),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: child,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Field Title with Pink Circular Badge
  Widget _buildFieldTitle({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFFDE8EF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 12,
            color: const Color(0xFFE5097F),
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(
                  color: Color(0xFF1E2448),
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                TextSpan(
                  text: " $subtitle",
                  style: const TextStyle(
                    color: Color(0xFF8C93A3),
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Dropdown Builder
  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    double height = 48,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFE5097F),
              size: 20,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 42,
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  // Segment Pill for Yes / No / All
  Widget _buildSegmentPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE5097F) : const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFFE5097F) : const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFE5097F).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4A4A68),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // Tab 1: Notifications View
  Widget _buildNotificationsView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldTitle(
            icon: Icons.notifications_active_outlined,
            title: "Notification Settings",
          ),
          const SizedBox(height: 14),
          _buildNotificationSwitch(
            title: "Daily Match Alerts",
            subtitle: "Receive matches suited to your preferences",
            value: true,
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF6F6FA)),
          _buildNotificationSwitch(
            title: "Shortlist Notifications",
            subtitle: "Get notified when someone shortlists your profile",
            value: true,
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF6F6FA)),
          _buildNotificationSwitch(
            title: "WhatsApp Alerts",
            subtitle: "Receive verified match alerts directly on WhatsApp",
            value: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
  }) {
    final RxBool isSwitched = value.obs;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E2448),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF7A8299),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Switch(
            value: isSwitched.value,
            onChanged: (val) {
              isSwitched.value = val;
            },
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFE5097F),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ),
      ],
    );
  }

  // Tab 2: Privacy View
  Widget _buildPrivacyView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldTitle(
            icon: Icons.shield_outlined,
            title: "Privacy Controls",
          ),
          const SizedBox(height: 14),
          _buildNotificationSwitch(
            title: "Profile Visibility",
            subtitle: "Allow all verified members to view your details",
            value: true,
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF6F6FA)),
          _buildNotificationSwitch(
            title: "Contact Number Visibility",
            subtitle: "Show contact number only to shortlisted profiles",
            value: true,
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF6F6FA)),
          _buildNotificationSwitch(
            title: "Hide Date of Birth",
            subtitle: "Show only calculated age instead of complete birth date",
            value: false,
          ),
        ],
      ),
    );
  }

  // Save Preferences Action
  Future<void> _onSave() async {
    List<String> eductionSelected = [];
    for (var data in homeController.educationDataList) {
      eductionSelected.add(data["selected"].toString());
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("gotra", homeController.selectedGotra.value.toString());
    prefs.setString(
        "yearlyIncomeStart", homeController.yearlyIncomeStart.value.toString());
    prefs.setString(
        "yearlyIncomeEnd", homeController.yearlyIncomeEnd.value.toString());
    prefs.setString(
        "selectedAgeStart", homeController.selectedAgeStart.value.toString());
    prefs.setString(
        "selectedAgeEnd", homeController.selectedAgeEnd.value.toString());
    prefs.setString("selectedMaxHeightValue",
        homeController.selectedMaxHeightValue.value.toString());
    prefs.setString("selectedMinHeightValue",
        homeController.selectedMinHeightValue.value.toString());
    prefs.setString("marriedBeforeStatus",
        homeController.marriedBeforeStatus.value.toString());
    prefs.setString(
        "maglikStatus", homeController.maglikStatus.value.toString());
    prefs.setString("selectAll", homeController.selectAll.value.toString());
    log(eductionSelected.toString());
    prefs.setStringList("eductionSelected", eductionSelected);
    homeController.restore.value = false;
    await getAllMembersData();
  }

  // Reset / Restore Preferences Action
  Future<void> _onReset() async {
    setState(() {
      homeController.selectedGotra.value = "-- Select Gotra --";
      homeController.yearlyIncomeStart.value = 1.0;
      homeController.yearlyIncomeEnd.value = 300.0;
      homeController.selectedAgeStart.value = 18.0;
      homeController.selectedAgeEnd.value = 50.0;
      homeController.selectedMaxHeightValue.value = "7.0";
      homeController.selectedMinHeightValue.value = "4.0";
      homeController.marriedBeforeStatus.value = 'All';
      homeController.maglikStatus.value = 'All';
      homeController.selectAll.value = true;
      for (int i = 0; i < homeController.educationDataList.length; i++) {
        homeController.educationDataList[i]['selected'] = true;
      }
    });
    List<String> eductionSelected = [];
    for (var data in homeController.educationDataList) {
      eductionSelected.add(data["selected"].toString());
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("gotra", "");
    prefs.setString(
        "yearlyIncomeStart", homeController.yearlyIncomeStart.value.toString());
    prefs.setString(
        "yearlyIncomeEnd", homeController.yearlyIncomeEnd.value.toString());
    prefs.setString(
        "selectedAgeStart", homeController.selectedAgeStart.value.toString());
    prefs.setString(
        "selectedAgeEnd", homeController.selectedAgeEnd.value.toString());
    prefs.setString("selectedMaxHeightValue",
        homeController.selectedMaxHeightValue.value.toString());
    prefs.setString("selectedMinHeightValue",
        homeController.selectedMinHeightValue.value.toString());
    prefs.setString("marriedBeforeStatus",
        homeController.marriedBeforeStatus.value.toString());
    prefs.setString(
        "maglikStatus", homeController.maglikStatus.value.toString());
    prefs.setString("selectAll", homeController.selectAll.value.toString());
    prefs.setStringList("eductionSelected", eductionSelected);
    homeController.restore.value = true;
    await getAllMembersData();
    ConstHelper.successDialog(
      text: 'Setting Restore Successfully',
      seconds: 10,
    );
  }

  // Existing Query & Member Filtering Logic (Preserved 100%)
  Future<void> getAllMembersData() async {
    List<String> educationCategory = [];
    for (int i = 0; i < homeController.educationDataList.length; i++) {
      if (homeController.educationDataList[i]['selected'] == true) {
        educationCategory
            .add(homeController.educationDataList[i]['education_name'] ?? '-');
      }
    }
    try {
      var minHeight = int.parse(homeController.selectedMinHeightValue.value
              .toString()
              .split(".")[0]) *
          12;
      var maxHeight = int.parse(homeController.selectedMaxHeightValue.value
              .toString()
              .split(".")[0]) *
          12;
      debugPrint(
          homeController.selectedMinHeightValue.value.toString().split(".")[0]);
      debugPrint(
          homeController.selectedMaxHeightValue.value.toString().split(".")[0]);
      debugPrint('$minHeight');
      debugPrint('$maxHeight');
      List<MembersDataModel> allMembersDataList =
          await ApiHelper.apiHelper.getAllMembersDataList(
        heightFrom: minHeight.toString(),
        heightTo: maxHeight.toString(),
        educationCategory: educationCategory,
        haveMarriedBefore:
            homeController.marriedBeforeStatus.value.toLowerCase(),
        ageFrom: homeController.selectedAgeStart.value.toStringAsFixed(0),
        ageTo: homeController.selectedAgeEnd.value.toStringAsFixed(0),
        incomeFrom: homeController.yearlyIncomeStart.value.toStringAsFixed(0),
        incomeTo: homeController.yearlyIncomeEnd.value.toStringAsFixed(0),
        isManglik: homeController.maglikStatus.value,
        excludeGotra: homeController.restore.value == true ||
                homeController.selectedGotra.value == "-- Select Gotra --"
            ? "No Exclude"
            : homeController.selectedGotra.value,
      );
      debugPrint('allMembersDataList: ${allMembersDataList.length}');
      if (homeController.userData.value.profileType?.toString() == "1") {
        homeController.allMembersDataListGenderWise.value = allMembersDataList
            .where(
              (element) =>
                  element.profileGender.toString().trim().toLowerCase() ==
                  (homeController.userData.value.profileGender
                              ?.toString()
                              .trim()
                              .toLowerCase() ==
                          "Female".toLowerCase()
                      ? 'Male'.trim().toLowerCase()
                      : 'Female'.trim().toLowerCase()),
            )
            .toList();
      } else {
        homeController.allMembersDataListGenderWise.value = allMembersDataList
            .where(
              (element) =>
                  element.profileGender.toString().trim().toLowerCase() ==
                  (maleFemale.value
                      ? 'Male'.trim().toLowerCase()
                      : 'Female'.trim().toLowerCase()),
            )
            .toList();
        totalMaleMembers.value = allMembersDataList
            .where(
              (element) =>
                  element.profileGender.toString().trim().toLowerCase() ==
                  'Male'.trim().toLowerCase(),
            )
            .toList()
            .length;
        totalFemaleMembers.value = allMembersDataList
            .where(
              (element) =>
                  element.profileGender.toString().trim().toLowerCase() ==
                  'Female'.trim().toLowerCase(),
            )
            .toList()
            .length;
      }
      homeController.advancedDrawerController.hideDrawer();
      Get.back();
    } catch (error) {
      homeController.allMembersDataListGenderWise.value = [];
    }
  }
}
