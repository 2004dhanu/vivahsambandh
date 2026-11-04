import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/member_item_model.dart';

class MemberDetailDialog extends StatefulWidget {
  final MemberItemModel member;
  final AdminController controller;

  const MemberDetailDialog({
    super.key,
    required this.member,
    required this.controller,
  });

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> {
  late String _currentSelectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentSelectedStatus = _normalizeStatus(widget.member.status);
  }

  String _normalizeStatus(String raw) {
    for (final opt in widget.controller.statusOptions) {
      if (opt.toLowerCase() == raw.trim().toLowerCase()) return opt;
    }
    return widget.controller.statusOptions.first;
  }

  void _callNumber(String? number) async {
    if (number == null || number.isEmpty) return;
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _handleSaveStatus() async {
    if (_currentSelectedStatus == widget.member.status) {
      Get.back();
      return;
    }
    setState(() => _isSaving = true);
    await widget.controller.updateStatus(widget.member, _currentSelectedStatus);
    if (mounted) {
      setState(() => _isSaving = false);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.member.getImageUrl(widget.controller.userImageBase.value);
    final isAdminMember = widget.member.userType == 2;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.85),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF880E4F),
                    Color(0xFFC2185B),
                    Color(0xFFE91E63),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.member.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdminMember) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF80CBC4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                color: Color(0xFF004D40),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image & Basic Info Card
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 140,
                          height: 160,
                          color: const Color(0xFFFCE4EC),
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF880E4F)),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.person,
                                    size: 64,
                                    color: Color(0xFF880E4F),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 64,
                                  color: Color(0xFF880E4F),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Status Dropdown Control
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0F4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF8BBD0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Status (Approval)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF880E4F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE0E0E0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: widget.controller.statusOptions.firstWhere(
                                        (opt) => opt.toLowerCase() == _currentSelectedStatus.toLowerCase(),
                                        orElse: () => widget.controller.statusOptions.first,
                                      ),
                                      isExpanded: true,
                                      items: widget.controller.statusOptions.map((s) {
                                        return DropdownMenuItem<String>(
                                          value: s,
                                          child: Text(
                                            s,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _currentSelectedStatus = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _isSaving ? null : _handleSaveStatus,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF880E4F),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Update'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (isAdminMember) ...[
                      // Admin Profile Attributes
                      _buildSectionHeader('Admin Account Details'),
                      _buildDetailTile('Role', 'Admin Member'),
                      _buildDetailTile('Gender', widget.member.gender),
                      _buildDetailTile('Email', widget.member.email ?? 'Not specified'),
                      _buildDetailTile('Current City', widget.member.userCurrentCity ?? 'Not specified'),
                      _buildDetailTile(
                        'Assigned Multiple Cities',
                        widget.member.multipleCity ?? widget.member.userCurrentCity ?? 'Not specified',
                      ),
                      _buildDetailTile('Address', widget.member.userAddress ?? 'Not specified'),
                      _buildDetailTile('Registration Date', widget.member.registerDate ?? 'N/A'),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Contact Information'),
                      _buildDetailTile(
                        'Mobile Number',
                        widget.member.mobile ?? 'N/A',
                        isActionable: true,
                        onTap: () => _callNumber(widget.member.mobile),
                      ),
                    ] else ...[
                      // Candidate Profile Attributes
                      _buildSectionHeader('Candidate Profile'),
                      _buildDetailTile('Gender', widget.member.gender),
                      _buildDetailTile('Date of Birth', widget.member.dateOfBirth ?? 'N/A'),
                      _buildDetailTile('Age', widget.member.ageDisplay.isNotEmpty ? widget.member.ageDisplay : 'N/A'),
                      _buildDetailTile('Height', widget.member.heightDisplay),
                      _buildDetailTile('Current City', widget.member.userCurrentCity ?? 'N/A'),
                      _buildDetailTile(
                        'Assigned City',
                        widget.member.multipleCity ?? widget.member.userCurrentCity ?? 'N/A',
                      ),
                      _buildDetailTile('Married Before', widget.member.marriedBefore ?? 'N/A'),
                      _buildDetailTile('Physical Disability', widget.member.physicalDisability ?? 'No'),
                      _buildDetailTile('Registration Date', widget.member.registerDate ?? 'N/A'),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Education & Career'),
                      _buildDetailTile('Education', widget.member.educationName ?? 'N/A'),
                      _buildDetailTile('Profession', widget.member.professionName ?? 'N/A'),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Community & Preferences'),
                      _buildDetailTile('Community', widget.member.communityName ?? 'N/A'),
                      _buildDetailTile('Gotra', widget.member.gotraName ?? 'N/A'),
                      _buildDetailTile('Preferred Communities', widget.member.marryMultiCommunity ?? 'Any'),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Contact Information'),
                      _buildDetailTile('Contact Person', widget.member.contactName ?? 'N/A'),
                      _buildDetailTile(
                        'Mobile Number',
                        widget.member.mobile ?? 'N/A',
                        isActionable: true,
                        onTap: () => _callNumber(widget.member.mobile),
                      ),
                      if (widget.member.email != null && widget.member.email!.isNotEmpty)
                        _buildDetailTile('Email', widget.member.email!),
                      if (widget.member.userAddress != null && widget.member.userAddress!.isNotEmpty)
                        _buildDetailTile('Address', widget.member.userAddress!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Container(width: 32, height: 2, color: const Color(0xFF880E4F)),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, {bool isActionable = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF757575))),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActionable ? const Color(0xFF880E4F) : const Color(0xFF212121),
                  decoration: isActionable ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
