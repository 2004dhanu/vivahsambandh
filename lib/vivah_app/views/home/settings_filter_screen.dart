import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/app_colors.dart';
import '../../models/education_model.dart';
import '../../models/gotra_model.dart';
import '../../models/member_filter_model.dart';
import '../../controllers/user_home_controller.dart';
import '../../core/services/session_manager.dart';

class SettingsFilterScreen extends StatefulWidget {
  const SettingsFilterScreen({super.key});

  @override
  State<SettingsFilterScreen> createState() => _SettingsFilterScreenState();
}

class _SettingsFilterScreenState extends State<SettingsFilterScreen> {
  final ApiService _apiService = ApiService();
  final UserHomeController _homeController = Get.find<UserHomeController>();

  late MemberFilterModel _draftFilter;

  List<EducationModel> _educationList = [];
  List<GotraModel> _gotraList = [];
  bool _isLoadingDropdowns = true;

  // Sliders state
  RangeValues _incomeRange = const RangeValues(1, 300);
  RangeValues _ageRange = const RangeValues(18, 50);
  bool _isAdvanceExpanded = false;

  final List<String> _heightOptions = [
    '4.0', '4.1', '4.2', '4.3', '4.4', '4.5', '4.6', '4.7', '4.8', '4.9', '4.10', '4.11',
    '5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9', '5.10', '5.11',
    '6.0', '6.1', '6.2', '6.3', '6.4', '6.5', '6.6', '6.7', '6.8', '6.9', '6.10', '6.11',
    '7.0', '7.1', '7.2',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = _homeController.currentUser.value ?? await SessionManager.instance.getUser();
      if (user?.isSubscribed != true) {
        if (mounted) {
          Navigator.of(context).pop();
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
    _draftFilter = _homeController.activeFilter.value.copy();
    _draftFilter.heightFrom ??= '4.0';
    _draftFilter.heightTo ??= '7.0';
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final edus = await _apiService.getEducationList();
      final gotras = await _apiService.getGotraList(1);
      if (mounted) {
        setState(() {
          _educationList = edus;
          _gotraList = gotras;
          _isLoadingDropdowns = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingDropdowns = false);
    }
  }

  void _restore() {
    setState(() {
      _draftFilter.clear();
      _draftFilter.heightFrom = '4.0';
      _draftFilter.heightTo = '7.0';
      _incomeRange = const RangeValues(1, 300);
      _ageRange = const RangeValues(18, 50);
    });
    _homeController.resetFilter();
    Get.back();
  }

  void _save() {
    _homeController.applyFilter(_draftFilter);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: _buildGridIcon(),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Color(0xFFE91E63), size: 28),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // 1. Select Height (In feet / inches) (Image 5)
                      Row(
                        children: [
                          const Text(
                            'Select Height',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(In feet / inches)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Minimum Height',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                _buildPinkDropdown<String>(
                                  value: _draftFilter.heightFrom ?? '4.0',
                                  items: _heightOptions.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                                  onChanged: (val) => setState(() => _draftFilter.heightFrom = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Maximum Height',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                _buildPinkDropdown<String>(
                                  value: _draftFilter.heightTo ?? '7.0',
                                  items: _heightOptions.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                                  onChanged: (val) => setState(() => _draftFilter.heightTo = val),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 2. Select Yearly Income (in Lakh) (Image 5)
                      Row(
                        children: [
                          const Text(
                            'Select Yearly Income',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(in Lakh)',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Minimum ${_incomeRange.start.round()} Lakh',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Maximum ${_incomeRange.end.round()} Lakh',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _incomeRange,
                        min: 1,
                        max: 300,
                        activeColor: const Color(0xFFE91E63),
                        inactiveColor: const Color(0xFFF8BBD0),
                        onChanged: (values) => setState(() => _incomeRange = values),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1 Lakh', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          Text('300 Lakh', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 3. Select Age (in years) (Image 5)
                      Row(
                        children: [
                          const Text(
                            'Select Age',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(in years)',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Minimum ${_ageRange.start.round()} years',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Maximum ${_ageRange.end.round()} years',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _ageRange,
                        min: 18,
                        max: 60,
                        activeColor: const Color(0xFFE91E63),
                        inactiveColor: const Color(0xFFF8BBD0),
                        onChanged: (values) => setState(() => _ageRange = values),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('18 Year', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          Text('50 Year', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 4. Gotra (to exclude) (Image 5)
                      Row(
                        children: [
                          const Text(
                            'Gotra',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(to exclude)',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildPinkDropdown<int?>(
                        value: _draftFilter.gotraId,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('-- Select Gotra --'),
                          ),
                          ..._gotraList.map((g) => DropdownMenuItem<int?>(
                                value: g.id,
                                child: Text(g.gotraName),
                              )),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _draftFilter.gotraId = val;
                            if (val != null) {
                              final match = _gotraList.firstWhereOrNull((g) => g.id == val);
                              _draftFilter.gotraName = match?.gotraName;
                            } else {
                              _draftFilter.gotraName = null;
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // 5. Advance Setting Expandable Card (Image 5)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(() => _isAdvanceExpanded = !_isAdvanceExpanded),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Advance Setting',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _isAdvanceExpanded
                                                ? 'Tap to collapse advance settings'
                                                : 'Tap on plus icon to explore advance settings',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      _isAdvanceExpanded ? Icons.remove : Icons.add,
                                      color: const Color(0xFFE91E63),
                                      size: 26,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Expandable Filter Components
                            if (_isAdvanceExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Education
                                    const Text(
                                      'Education Qualification',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _educationList.map((edu) {
                                        final isSel = _draftFilter.educationIds.contains(edu.id);
                                        return FilterChip(
                                          label: Text(
                                            edu.educationName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isSel ? Colors.white : AppColors.textPrimary,
                                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          selected: isSel,
                                          selectedColor: const Color(0xFFE91E63),
                                          backgroundColor: Colors.white,
                                          checkmarkColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(color: isSel ? const Color(0xFFE91E63) : Colors.grey.shade300),
                                          ),
                                          onSelected: (selected) {
                                            setState(() {
                                              if (selected) {
                                                _draftFilter.educationIds.add(edu.id);
                                              } else {
                                                _draftFilter.educationIds.remove(edu.id);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),

                                    const SizedBox(height: 16),

                                    // Married Before
                                    const Text('Married Before', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    _buildChoiceRow(
                                      currentVal: _draftFilter.marriedBefore,
                                      options: const [
                                        {'label': 'Any', 'value': null},
                                        {'label': 'No', 'value': 'No'},
                                        {'label': 'Yes', 'value': 'Yes'},
                                      ],
                                      onChanged: (v) => setState(() => _draftFilter.marriedBefore = v),
                                    ),

                                    const SizedBox(height: 16),

                                    // Manglik
                                    const Text('Manglik Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    _buildChoiceRow(
                                      currentVal: _draftFilter.isManglik,
                                      options: const [
                                        {'label': 'Any', 'value': null},
                                        {'label': 'No', 'value': 'No'},
                                        {'label': 'Yes', 'value': 'Yes'},
                                      ],
                                      onChanged: (v) => setState(() => _draftFilter.isManglik = v),
                                    ),

                                    const SizedBox(height: 16),

                                    // Disability
                                    const Text('Physical Disability', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    _buildChoiceRow(
                                      currentVal: _draftFilter.physicalDisability,
                                      options: const [
                                        {'label': 'Any', 'value': null},
                                        {'label': 'No', 'value': 'No'},
                                        {'label': 'Yes', 'value': 'Yes'},
                                      ],
                                      onChanged: (v) => setState(() => _draftFilter.physicalDisability = v),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Bottom Buttons: Restore & Save (Image 5)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _restore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E99A2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Restore',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPinkDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE91E63), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFE91E63)),
          style: const TextStyle(
            color: Color(0xFFE91E63),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildChoiceRow({
    required String? currentVal,
    required List<Map<String, String?>> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = currentVal == opt['value'];
        return ChoiceChip(
          label: Text(
            opt['label']!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
          selected: isSelected,
          selectedColor: const Color(0xFFE91E63),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300),
          ),
          onSelected: (_) => onChanged(opt['value']),
        );
      }).toList(),
    );
  }

  Widget _buildGridIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(),
              const SizedBox(width: 3),
              _buildDot(),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(),
              const SizedBox(width: 3),
              _buildDot(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
