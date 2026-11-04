import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/member_item_model.dart';
import '../../../controllers/user_home_controller.dart';
import 'candidate_feedback_dialog.dart';
import 'candidate_block_dialog.dart';

class CandidateDetailDialog extends StatefulWidget {
  final MemberItemModel initialMember;
  final UserHomeController controller;

  const CandidateDetailDialog({
    super.key,
    required this.initialMember,
    required this.controller,
  });

  static void show(BuildContext context, MemberItemModel member, UserHomeController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CandidateDetailDialog(initialMember: member, controller: controller),
    );
  }

  @override
  State<CandidateDetailDialog> createState() => _CandidateDetailDialogState();
}

class _CandidateDetailDialogState extends State<CandidateDetailDialog> {
  late MemberItemModel _member;
  bool _isLoadingFull = true;

  @override
  void initState() {
    super.initState();
    _member = widget.initialMember;
    _loadFreshDetails();
  }

  Future<void> _loadFreshDetails() async {
    final fresh = await widget.controller.fetchMemberDetail(_member.id);
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
    final imageBase = widget.controller.userImageBase.value;
    final fullImg = _member.getFullImageUrl(imageBase);
    final faceImg = _member.getImageUrl(imageBase);
    final displayImg = fullImg.isNotEmpty ? fullImg : faceImg;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Top drag pill
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Header Image & Basic Info
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: displayImg.isNotEmpty
                                ? Image.network(
                                    displayImg,
                                    width: double.infinity,
                                    height: 240,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                                  )
                                : _buildPlaceholderImage(),
                          ),
                          Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _member.userCurrentCity ?? 'City not specified',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name, Age & Verified badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _member.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (_member.ageDisplay.isNotEmpty) _member.ageDisplay,
                                  if (_member.gender.isNotEmpty) _member.gender,
                                  _member.heightDisplay,
                                ].join(' • '),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Color(0xFF2E7D32), size: 15),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_isLoadingFull) ...[
                      const SizedBox(height: 20),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(),

                    // Summary / About Me
                    if (_member.userSummary != null && _member.userSummary!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'About Me',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _member.userSummary!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(),
                    ],

                    // Section 1: Education & Profession
                    _buildSectionHeader(Icons.work_outline, 'Education & Career'),
                    _buildDetailRow('Education', _member.educationName ?? 'Not specified'),
                    _buildDetailRow('Profession', _member.professionName ?? 'Not specified'),
                    if (_member.companyName != null && _member.companyName!.isNotEmpty)
                      _buildDetailRow('Company Name', _member.companyName!),
                    if (_member.companyType != null && _member.companyType!.isNotEmpty)
                      _buildDetailRow('Company Type', _member.companyType!),
                    if (_member.annualIncome != null && _member.annualIncome!.isNotEmpty)
                      _buildDetailRow('Annual Income', '${_member.annualIncome} LPA'),

                    const SizedBox(height: 14),
                    const Divider(),

                    // Section 2: Community & Gotra
                    _buildSectionHeader(Icons.groups_outlined, 'Community & Gotra'),
                    _buildDetailRow('Community', _member.communityName ?? 'Not specified'),
                    _buildDetailRow('Gotra', _member.gotraName ?? 'Not specified'),
                    if (_member.marryMultiCommunity != null && _member.marryMultiCommunity!.isNotEmpty)
                      _buildDetailRow('Marry In Community', _member.marryMultiCommunity!),
                    _buildDetailRow('Will Marry Same Gotra', _member.willMarrySameGotra ?? 'No'),

                    const SizedBox(height: 14),
                    const Divider(),

                    // Section 3: Horoscope & Birth Details
                    _buildSectionHeader(Icons.auto_awesome_outlined, 'Horoscope & Birth Details'),
                    if (_member.dateOfBirth != null && _member.dateOfBirth!.isNotEmpty)
                      _buildDetailRow('Date of Birth', _member.dateOfBirth!),
                    if (_member.timeOfBirth != null && _member.timeOfBirth!.isNotEmpty)
                      _buildDetailRow('Time of Birth', _member.timeOfBirth!),
                    if (_member.placeOfBirth != null && _member.placeOfBirth!.isNotEmpty)
                      _buildDetailRow('Place of Birth', _member.placeOfBirth!),
                    _buildDetailRow('Manglik Status', _member.isManglik ?? 'No'),
                    _buildDetailRow('Will Marry Manglik', _member.willMarryManglik ?? 'Yes'),
                    _buildDetailRow('Physical Disability', _member.physicalDisability ?? 'No'),

                    const SizedBox(height: 14),
                    const Divider(),

                    // Section 4: Family Details
                    _buildSectionHeader(Icons.family_restroom_outlined, 'Family Details'),
                    if (_member.fatherName != null && _member.fatherName!.isNotEmpty)
                      _buildDetailRow("Father's Name", _member.fatherName!),
                    if (_member.motherName != null && _member.motherName!.isNotEmpty)
                      _buildDetailRow("Mother's Name", _member.motherName!),
                    _buildDetailRow(
                      'Brothers',
                      'Married: ${_member.brotherMarried ?? "0"}, Unmarried: ${_member.brotherUnMarried ?? "0"}',
                    ),
                    _buildDetailRow(
                      'Sisters',
                      'Married: ${_member.sisterMarried ?? "0"}, Unmarried: ${_member.sisterUnMarried ?? "0"}',
                    ),
                    if (_member.houseType != null && _member.houseType!.isNotEmpty)
                      _buildDetailRow('House Type', _member.houseType!),
                    if (_member.userAddress != null && _member.userAddress!.isNotEmpty)
                      _buildDetailRow('Family Address', _member.userAddress!),

                    const SizedBox(height: 14),
                    const Divider(),

                    // Section 5: Contact Information
                    _buildSectionHeader(Icons.contact_phone_outlined, 'Contact Details'),
                    if (_member.contactName != null && _member.contactName!.isNotEmpty)
                      _buildDetailRow('Contact Person', _member.contactName!),
                    if (_member.mobile != null && _member.mobile!.isNotEmpty)
                      _buildDetailRow('Mobile Number', _member.mobile!),
                    if (_member.alternateContactName != null && _member.alternateContactName!.isNotEmpty)
                      _buildDetailRow('Alt Contact Person', _member.alternateContactName!),
                    if (_member.alternateMobileNo != null && _member.alternateMobileNo!.isNotEmpty)
                      _buildDetailRow('Alt Mobile Number', _member.alternateMobileNo!),
                    if (_member.email != null && _member.email!.isNotEmpty)
                      _buildDetailRow('Email', _member.email!),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom Sticky Action Bar: Shortlist, Feedback, Block Profile
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Obx(() {
                    final isShortlisted = widget.controller.isShortlisted(_member.id);

                    return Row(
                      children: [
                        // 1. Shortlist button
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (isShortlisted) {
                                widget.controller.shortlistProfile(_member);
                              } else {
                                widget.controller.shortlistProfile(_member);
                              }
                            },
                            icon: Icon(
                              isShortlisted ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              isShortlisted ? 'Shortlisted' : 'Shortlist',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isShortlisted ? const Color(0xFFE91E63) : AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 2. Feedback button
                        Expanded(
                          flex: 3,
                          child: OutlinedButton.icon(
                            onPressed: () => CandidateFeedbackDialog.show(context, _member, widget.controller),
                            icon: const Icon(Icons.rate_review_outlined, color: AppColors.primary, size: 18),
                            label: const Text(
                              'Feedback',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 3. Block button
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            CandidateBlockDialog.show(context, _member, widget.controller);
                          },
                          icon: const Icon(Icons.block, color: Color(0xFFD32F2F)),
                          tooltip: 'Block Profile',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 240,
      color: Colors.pink.shade50,
      child: Center(
        child: Icon(
          _member.gender.toLowerCase() == 'female' ? Icons.face_3 : Icons.face,
          size: 80,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
