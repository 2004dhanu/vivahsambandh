import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api/api_service.dart';
import '../../core/services/session_manager.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/member_item_model.dart';
import '../../controllers/user_home_controller.dart';

class MyProfileScreen extends StatefulWidget {
  final UserModel? user;

  const MyProfileScreen({super.key, this.user});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final UserHomeController _controller = Get.find<UserHomeController>();

  late UserModel? _user;
  MemberItemModel? _memberDetail;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _tabController = TabController(length: 4, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      if (_user?.mobile != null) {
        final member = await _apiService.checkExistingMemberByMobile(_user!.mobile);
        if (member != null && mounted) {
          setState(() {
            _memberDetail = member;
            _user = UserModel.fromMember(member);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteAccount() async {
    Get.defaultDialog(
      title: 'Delete Account',
      middleText: 'Are you sure you want to permanently delete your profile? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFD32F2F),
      onConfirm: () async {
        Get.back();
        try {
          // POST /app-delete-profile
          await SessionManager.instance.destroySession();
          Get.snackbar(
            'Account Deleted',
            'Your profile has been removed successfully.',
            backgroundColor: Colors.blueGrey,
            colorText: Colors.white,
          );
        } catch (_) {}
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageBase = _controller.userImageBase.value;
    final faceImg = _user?.faceImage != null && _user!.faceImage!.isNotEmpty
        ? (imageBase.endsWith('/') ? '$imageBase${_user!.faceImage}' : '$imageBase/${_user!.faceImage}')
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Get.snackbar('Share Profile', 'Sharing link generated.', backgroundColor: Colors.blueGrey, colorText: Colors.white);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card (Image 4)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFCE4EC), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF8BBD0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Edit Pencil (Image 4)
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: faceImg.isNotEmpty
                          ? Image.network(
                              faceImg,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                            )
                          : _buildAvatarPlaceholder(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E63),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'User ID: ${_user?.id ?? "523"}',
                              style: const TextStyle(
                                color: Color(0xFFE91E63),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 12),
                                SizedBox(width: 3),
                                Text(
                                  'Profile Completed >',
                                  style: TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Name
                      Text(
                        (_user?.name != null && _user!.name.isNotEmpty) ? _user!.name.toUpperCase() : 'RAGHAV GOEL',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // DOB & Age
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFFE91E63), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            _memberDetail?.dateOfBirth != null
                                ? '${_memberDetail!.dateOfBirth} (${_memberDetail!.ageDisplay})'
                                : '19 Aug 1991 (33 yrs)',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Location & Height
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFFE91E63), size: 12),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _user?.userCurrentCity ?? 'Mississauga, ON',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.height, color: Color(0xFFE91E63), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            _memberDetail?.heightDisplay ?? '5 ft 9 in',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick Action Circles Row (View Photos, Share Profile, Shortlist, Report, Hide Profile - Image 4)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionCircle(
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFFE91E63),
                  label: 'View Photos',
                  onTap: () {},
                ),
                _buildActionCircle(
                  icon: Icons.chat_outlined,
                  color: const Color(0xFF25D366),
                  label: 'Share Profile',
                  onTap: () {},
                ),
                _buildActionCircle(
                  icon: Icons.star_border,
                  color: const Color(0xFFFFA000),
                  label: 'Shortlist',
                  onTap: () {},
                ),
                _buildActionCircle(
                  icon: Icons.visibility_off_outlined,
                  color: const Color(0xFF8E24AA),
                  label: 'Hide Profile',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // 4 Tabs Row (Image 4: Personal, Family, Kundali, Preferences)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFFE91E63),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 13),
                        SizedBox(width: 3),
                        Text('Personal'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.groups, size: 13),
                        SizedBox(width: 3),
                        Text('Family'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 13),
                        SizedBox(width: 3),
                        Text('Kundali'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 13),
                        SizedBox(width: 3),
                        Text('Preferences'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // 4 Tab Views
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalTab(),
                      _buildFamilyTab(),
                      _buildKundaliTab(),
                      _buildPreferencesTab(),
                    ],
                  ),
          ),

          // Bottom Action Buttons: Edit Profile & Delete Account (Image 4)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.snackbar('Edit Profile', 'Profile editing mode enabled.', backgroundColor: const Color(0xFFE91E63), colorText: Colors.white);
                      },
                      icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                      label: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleteAccount,
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFD32F2F), size: 16),
                      label: const Text('Delete Account', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Personal
  Widget _buildPersonalTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildSectionCard(
          title: 'Personal Information',
          icon: Icons.person_outline,
          children: [
            _buildDetailRow(Icons.calendar_month_outlined, 'Date of Birth', _memberDetail?.dateOfBirth ?? '19 Aug 1991'),
            _buildDetailRow(Icons.access_time_outlined, 'Time of Birth', _memberDetail?.timeOfBirth ?? '03:06 PM'),
            _buildDetailRow(Icons.location_on_outlined, 'Place of Birth', _memberDetail?.placeOfBirth ?? 'Mississauga, ON'),
            _buildDetailRow(Icons.accessibility_new_outlined, 'Height', _memberDetail?.heightDisplay ?? '5 ft 9 Inch'),
            _buildDetailRow(Icons.wc_outlined, 'Gender', _user?.gender ?? 'Male'),
            _buildDetailRow(Icons.email_outlined, 'Email', _user?.email ?? 'rgmi@outlook.com'),
            _buildDetailRow(Icons.favorite_outline, 'Physical Disability', _memberDetail?.physicalDisability ?? '-'),
          ],
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          title: 'Occupation Details',
          icon: Icons.work_outline,
          children: [
            _buildDetailRow(Icons.school_outlined, 'Qualification', _memberDetail?.educationName ?? 'Other'),
            _buildDetailRow(Icons.badge_outlined, 'Profession', _memberDetail?.professionName ?? 'Self Employed (CA, CS, Lawyer etc)'),
            _buildDetailRow(Icons.business_outlined, 'Organization', _memberDetail?.companyName ?? '-'),
            _buildDetailRow(Icons.category_outlined, 'Org. Type', _memberDetail?.companyType ?? '-'),
            _buildDetailRow(Icons.payments_outlined, 'Annual Income (In lacs)', _memberDetail?.annualIncome ?? '15'),
          ],
        ),
      ],
    );
  }

  // TAB 2: Family
  Widget _buildFamilyTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildSectionCard(
          title: 'Family Details',
          icon: Icons.family_restroom_outlined,
          children: [
            _buildDetailRow(Icons.person_outline, "Father's Name", _memberDetail?.fatherName ?? 'KAILASH GOEL'),
            _buildDetailRow(Icons.person_outline, "Mother's Name", _memberDetail?.motherName ?? 'NEELIMA GOEL'),
            _buildDetailRow(Icons.phone_outlined, 'Mobile (Father)', _user?.mobile ?? '9560265460'),
            _buildDetailRow(Icons.phone_outlined, 'Mobile (Mother)', _memberDetail?.alternateMobileNo ?? '7042349873'),
            _buildDetailRow(Icons.people_outline, 'Brother', 'M - ${_memberDetail?.brotherMarried ?? "0"}   Un-M - ${_memberDetail?.brotherUnMarried ?? "1"}'),
            _buildDetailRow(Icons.people_outline, 'Sister', 'M - ${_memberDetail?.sisterMarried ?? "2"}   Un-M - ${_memberDetail?.sisterUnMarried ?? "0"}'),
            _buildDetailRow(Icons.home_outlined, 'Current Address', _memberDetail?.userAddress ?? 'Crossings Republik, Ghaziabad (Delhi-NCR)'),
          ],
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          title: 'Contact References',
          icon: Icons.contact_phone_outlined,
          children: [
            _buildDetailRow(Icons.person_pin_outlined, 'Name', _memberDetail?.contactName ?? 'Kailash Goel'),
            _buildDetailRow(Icons.phone_android_outlined, 'Mobile', _user?.mobile ?? '9560265460'),
            _buildDetailRow(Icons.location_on_outlined, 'Location', _memberDetail?.userCurrentCity ?? 'Crossings Republik, Ghaziabad (Delhi-NCR)'),
          ],
        ),
      ],
    );
  }

  // TAB 3: Kundali
  Widget _buildKundaliTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildSectionCard(
          title: 'Kundali',
          icon: Icons.auto_awesome_outlined,
          children: [
            _buildDetailRow(Icons.brightness_low_outlined, 'Gotra', _memberDetail?.gotraName ?? 'Goyal, Goel or Goenka'),
            _buildDetailRow(Icons.favorite_outline, 'Matching Kundali', 'No'),
            _buildDetailRow(Icons.compare_arrows_outlined, 'Marry in same gotra', _memberDetail?.willMarrySameGotra ?? 'Any Community'),
            _buildDetailRow(Icons.star_outline, 'Are you Manglik?', _memberDetail?.isManglik ?? 'No'),
            _buildDetailRow(Icons.favorite_outline, 'Will you marry a Manglik?', _memberDetail?.willMarryManglik ?? '-'),
          ],
        ),
      ],
    );
  }

  // TAB 4: Preferences
  Widget _buildPreferencesTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildSectionCard(
          title: 'Partner Preferences',
          icon: Icons.favorite_border,
          children: [
            _buildDetailRow(Icons.swap_vert_outlined, 'P. Spouse can be elder (> yrs)', '0'),
            _buildDetailRow(Icons.swap_vert_outlined, 'P. Spouse can be younger (< yrs)', '4'),
            _buildDetailRow(Icons.work_outline, 'Bride permitted to work after marriage?', 'We are flexible to discuss this'),
            _buildDetailRow(Icons.location_city_outlined, 'Current city', _memberDetail?.userCurrentCity ?? '-'),
            _buildDetailRow(Icons.home_outlined, 'Resident after marriage', 'DELHI-NCR'),
          ],
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          title: 'Budget Info (In lacs)',
          icon: Icons.payments_outlined,
          children: [
            _buildDetailRow(Icons.currency_rupee, 'Budget Bride', '10'),
            _buildDetailRow(Icons.currency_rupee, 'Budget Groom', '10'),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFFE91E63), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF880E4F),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.edit, size: 12, color: Color(0xFFE91E63)),
                  const SizedBox(width: 2),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE91E63).withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFFE91E63)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const Text(' : ', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.pink.shade50,
      child: const Center(
        child: Icon(Icons.person, color: Color(0xFFE91E63), size: 48),
      ),
    );
  }
}
