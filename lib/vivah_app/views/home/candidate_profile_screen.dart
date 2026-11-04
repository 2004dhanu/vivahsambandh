import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/member_item_model.dart';
import '../../models/user_model.dart';
import '../../controllers/user_home_controller.dart';
import '../../core/services/session_manager.dart';
import 'widgets/candidate_feedback_dialog.dart';
import 'widgets/candidate_block_dialog.dart';

class CandidateProfileScreen extends StatefulWidget {
  final MemberItemModel initialMember;

  const CandidateProfileScreen({
    super.key,
    required this.initialMember,
  });

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> with SingleTickerProviderStateMixin {
  final UserHomeController _controller = Get.find<UserHomeController>();
  late MemberItemModel _member;
  bool _isLoadingFull = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserModel? u;
      try {
        if (Get.isRegistered<UserHomeController>()) {
          u = Get.find<UserHomeController>().currentUser.value;
        }
        u ??= await SessionManager.instance.getUser();
      } catch (_) {}
      if (u?.isSubscribed != true) {
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
    _member = widget.initialMember;
    _tabController = TabController(length: 4, vsync: this);
    _loadFreshDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFreshDetails() async {
    final fresh = await _controller.fetchMemberDetail(_member.id);
    if (mounted) {
      if (fresh != null) {
        setState(() {
          _member = fresh;
          _isLoadingFull = false;
        });
      } else {
        setState(() => _isLoadingFull = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBase = _controller.userImageBase.value;
    final faceImg = _member.getImageUrl(imageBase);
    final fullImg = _member.getFullImageUrl(imageBase);

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
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (val) {
              if (val == 'feedback') {
                CandidateFeedbackDialog.show(context, _member, _controller);
              } else if (val == 'block') {
                CandidateBlockDialog.show(context, _member, _controller);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'feedback',
                child: Row(
                  children: [
                    Icon(Icons.rate_review_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Text('Send Feedback'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text('Block Profile'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card (Image 2)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF8BBD0).withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with pink ring + online green indicator
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE91E63), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: faceImg.isNotEmpty
                            ? Image.network(
                                faceImg,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                              )
                            : _buildAvatarPlaceholder(),
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User ID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'User ID: ${_member.id}',
                          style: const TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Name
                      Text(
                        _member.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFFE91E63), size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _member.userCurrentCity ?? 'City not specified',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // DOB & Age
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFFE91E63), size: 13),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              [
                                if (_member.dateOfBirth != null) _member.dateOfBirth!,
                                if (_member.ageDisplay.isNotEmpty) '(${_member.ageDisplay})',
                              ].join(' '),
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Chips (Education, Profession)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (_member.educationName != null)
                            _buildInfoPill(_member.educationName!, const Color(0xFFEDE7F6), const Color(0xFF673AB7)),
                          if (_member.professionName != null)
                            _buildInfoPill(_member.professionName!, const Color(0xFFE8EAF6), const Color(0xFF3F51B5)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Top Right Heart (Shortlist Toggle)
                Obx(() {
                  final isShort = _controller.isShortlisted(_member.id);
                  return InkWell(
                    onTap: () => _controller.shortlistProfile(_member),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isShort ? const Color(0xFFFCE4EC) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isShort ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xFFE91E63),
                        size: 20,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Quick Action Circles Row (Gallery, WhatsApp, Shortlist, Report, Hide Profile - Image 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionCircle(
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFFE91E63),
                  label: 'Gallery',
                  onTap: () {
                    final imgToShow = fullImg.isNotEmpty ? fullImg : faceImg;
                    if (imgToShow.isNotEmpty) {
                      Get.dialog(
                        Dialog(
                          backgroundColor: Colors.transparent,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(imgToShow, fit: BoxFit.contain),
                          ),
                        ),
                      );
                    } else {
                      Get.snackbar('Notice', 'No photo available for this profile.', backgroundColor: Colors.blueGrey, colorText: Colors.white);
                    }
                  },
                ),
                _buildActionCircle(
                  icon: Icons.chat_outlined,
                  color: const Color(0xFF25D366),
                  label: 'WhatsApp',
                  onTap: () {
                    Get.snackbar(
                      'Contact',
                      'Contact Person: ${_member.contactName ?? _member.name} (${_member.mobile ?? "N/A"})',
                      backgroundColor: const Color(0xFF25D366),
                      colorText: Colors.white,
                    );
                  },
                ),
                Obx(() {
                  final isShort = _controller.isShortlisted(_member.id);
                  return _buildActionCircle(
                    icon: isShort ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFA000),
                    label: isShort ? 'Shortlisted' : 'Shortlist',
                    onTap: () => _controller.shortlistProfile(_member),
                  );
                }),
                _buildActionCircle(
                  icon: Icons.visibility_off_outlined,
                  color: const Color(0xFF8E24AA),
                  label: 'Hide Profile',
                  onTap: () => CandidateBlockDialog.show(context, _member, _controller),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // 4 Tabs Row (Image 2: Personal, Family, Kundali, Preferences)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 42,
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
            child: _isLoadingFull
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Personal
                      _buildPersonalTab(),

                      // Tab 2: Family
                      _buildFamilyTab(),

                      // Tab 3: Kundali
                      _buildKundaliTab(),

                      // Tab 4: Preferences
                      _buildPreferencesTab(),
                    ],
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
            _buildDetailRow(Icons.calendar_month_outlined, 'Date of Birth', _member.dateOfBirth ?? 'Not Mentioned'),
            _buildDetailRow(Icons.access_time_outlined, 'Time of Birth', _member.timeOfBirth ?? 'Not Mentioned'),
            _buildDetailRow(Icons.location_on_outlined, 'Place of Birth', _member.placeOfBirth ?? 'Not Mentioned'),
            _buildDetailRow(Icons.accessibility_new_outlined, 'Height', _member.heightDisplay),
            _buildDetailRow(Icons.favorite_outline, 'Physical Disability', _member.physicalDisability ?? 'Not Mentioned'),
          ],
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          title: 'Occupation Details',
          icon: Icons.work_outline,
          children: [
            _buildDetailRow(Icons.school_outlined, 'Qualification', _member.educationName ?? 'Not Mentioned'),
            _buildDetailRow(Icons.badge_outlined, 'Profession', _member.professionName ?? 'Not in any Profession'),
            _buildDetailRow(Icons.business_outlined, 'Organization', _member.companyName ?? '-'),
            _buildDetailRow(Icons.category_outlined, 'Organization Type', _member.companyType ?? '-'),
            _buildDetailRow(Icons.payments_outlined, 'Annual Income', _member.annualIncome != null ? '${_member.annualIncome} Lacs' : '-'),
          ],
        ),
        const SizedBox(height: 16),
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
            _buildDetailRow(Icons.person_outline, "Father's Name", _member.fatherName ?? '-'),
            _buildDetailRow(Icons.person_outline, "Mother's Name", _member.motherName ?? '-'),
            _buildDetailRow(Icons.phone_outlined, 'Mobile (Father)', _member.mobile ?? '-'),
            _buildDetailRow(Icons.phone_outlined, 'Mobile (Mother)', _member.alternateMobileNo ?? '-'),
            _buildDetailRow(Icons.people_outline, 'Brother', 'M - ${_member.brotherMarried ?? "0"}   Un M - ${_member.brotherUnMarried ?? "0"}'),
            _buildDetailRow(Icons.people_outline, 'Sister', 'M - ${_member.sisterMarried ?? "0"}   Un M - ${_member.sisterUnMarried ?? "0"}'),
            _buildDetailRow(Icons.home_outlined, 'Family Address', _member.userAddress ?? '-'),
          ],
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          title: 'Contact References',
          icon: Icons.contact_phone_outlined,
          children: [
            _buildDetailRow(Icons.person_pin_outlined, 'Contact Person', _member.contactName ?? '-'),
            _buildDetailRow(Icons.phone_android_outlined, 'Mobile Number', _member.mobile ?? '-'),
            _buildDetailRow(Icons.person_pin_outlined, 'Alt Contact', _member.alternateContactName ?? '-'),
            _buildDetailRow(Icons.phone_android_outlined, 'Alt Mobile', _member.alternateMobileNo ?? '-'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // TAB 3: Kundali
  Widget _buildKundaliTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildSectionCard(
          title: 'Kundali Details',
          icon: Icons.auto_awesome_outlined,
          children: [
            _buildDetailRow(Icons.brightness_low_outlined, 'Gotra', _member.gotraName ?? 'Not Mentioned'),
            _buildDetailRow(Icons.groups_outlined, 'Community', _member.communityName ?? 'Not Mentioned'),
            _buildDetailRow(Icons.compare_arrows_outlined, 'Marry in same gotra', _member.willMarrySameGotra ?? 'No'),
            _buildDetailRow(Icons.star_outline, 'Are you Manglik?', _member.isManglik ?? 'No'),
            _buildDetailRow(Icons.favorite_outline, 'Will you marry Manglik?', _member.willMarryManglik ?? 'Yes'),
          ],
        ),
        const SizedBox(height: 16),
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
            _buildDetailRow(Icons.groups_outlined, 'Marry in Community', _member.marryMultiCommunity ?? 'Any'),
            _buildDetailRow(Icons.favorite_outline, 'Married Before', _member.marriedBefore ?? 'No'),
            _buildDetailRow(Icons.location_city_outlined, 'Preferred Cities', _member.multipleCity ?? _member.userCurrentCity ?? 'Any'),
          ],
        ),
        if (_member.userSummary != null && _member.userSummary!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'About Candidate',
            icon: Icons.notes_outlined,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _member.userSummary!,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
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
            children: [
              Icon(icon, color: const Color(0xFFE91E63), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF880E4F),
                ),
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
            width: 110,
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
        mainAxisSize: MainAxisSize.min,
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String text, Color bg, Color textCol) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, color: textCol, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.pink.shade50,
      child: const Center(
        child: Icon(Icons.person, color: Color(0xFFE91E63), size: 40),
      ),
    );
  }
}
