import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/member_item_model.dart';
import 'member_detail_dialog.dart';
import 'edit_city_dialog.dart';
import 'edit_admin_member_dialog.dart';

class MemberCard extends StatelessWidget {
  final MemberItemModel member;
  final AdminController controller;

  const MemberCard({
    super.key,
    required this.member,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = member.getImageUrl(controller.userImageBase.value);
    final isAdminMember = member.userType == 2;
    final isPending = member.status.trim().toLowerCase() == 'pending';
    final isFemale = member.gender.trim().toLowerCase() == 'female';

    return Obx(() {
      final isUpdating = controller.updatingMemberStatusMap[member.id] == true;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending ? const Color(0xFFFFB74D) : const Color(0xFFE8EAF0),
            width: isPending ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPending
                  ? const Color(0xFFFF9800).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.dialog(MemberDetailDialog(member: member, controller: controller));
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar + Main Info + Status Chip & ID
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with Gender Ring
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isFemale ? const Color(0xFFF48FB1) : const Color(0xFF90CAF9),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: const Color(0xFFFCE4EC),
                                child: imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF880E4F),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Icon(
                                          isFemale ? Icons.female_rounded : Icons.male_rounded,
                                          size: 32,
                                          color: isFemale ? Colors.pink : Colors.blue,
                                        ),
                                      )
                                    : Icon(
                                        isFemale ? Icons.female_rounded : Icons.male_rounded,
                                        size: 32,
                                        color: isFemale ? Colors.pink : Colors.blue,
                                      ),
                              ),
                            ),
                          ),
                          // ID Badge overlaid at bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                '#${member.id}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Candidate Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name & Status Pill
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    member.name.isNotEmpty ? member.name : 'Candidate #${member.id}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: member.statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: member.statusColor.withValues(alpha: 0.45),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: member.statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        member.status,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: member.statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),

                            // Subtitle 1: Demographic Details
                            if (isAdminMember) ...[
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'ADMINISTRATOR',
                                      style: TextStyle(
                                        color: Color(0xFF004D40),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      member.userCurrentCity ?? 'City not set',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                member.mobile ?? member.email ?? 'No contact',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ] else ...[
                              // Member Demographic Row
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    member.gender,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isFemale ? const Color(0xFFD81B60) : const Color(0xFF1976D2),
                                    ),
                                  ),
                                  if (member.ageDisplay.isNotEmpty) ...[
                                    const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                                    Text(
                                      member.ageDisplay,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                    ),
                                  ],
                                  if (member.heightDisplay.isNotEmpty) ...[
                                    const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                                    Text(
                                      member.heightDisplay,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                    ),
                                  ],
                                  if (member.userCurrentCity != null && member.userCurrentCity!.isNotEmpty) ...[
                                    const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF880E4F)),
                                        const SizedBox(width: 1),
                                        Text(
                                          member.userCurrentCity!,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),

                              // Community & Gotra
                              Text(
                                [
                                  if (member.communityName != null && member.communityName!.isNotEmpty)
                                    member.communityName,
                                  if (member.gotraName != null && member.gotraName!.isNotEmpty)
                                    'Gotra: ${member.gotraName}',
                                  if (member.professionName != null && member.professionName!.isNotEmpty)
                                    member.professionName,
                                ].join(' • '),
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),

                  // Bottom Action Bar: Quick Approve + Status Dropdown + Admin Actions + Details
                  Row(
                    children: [
                      // Quick Approve Button if Pending
                      if (isPending) ...[
                        InkWell(
                          onTap: isUpdating ? null : () => controller.quickApprove(member),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF43A047).withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isUpdating)
                                  const SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  const Icon(Icons.check_circle_rounded, size: 15, color: Colors.white),
                                const SizedBox(width: 4),
                                const Text(
                                  'Approve',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Status Dropdown
                      Expanded(
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.statusOptions.firstWhere(
                                (opt) => opt.toLowerCase() == member.status.trim().toLowerCase(),
                                orElse: () => controller.statusOptions.first,
                              ),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF880E4F), size: 18),
                              isExpanded: true,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                              items: controller.statusOptions.map((String status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _getStatusDotColor(status),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: status.toLowerCase() == member.status.toLowerCase()
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: isUpdating
                                  ? null
                                  : (newStatus) {
                                      if (newStatus != null &&
                                          newStatus.toLowerCase() != member.status.toLowerCase()) {
                                        controller.updateStatus(member, newStatus);
                                      }
                                    },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Super Admin Actions on Admin Member
                      if (isAdminMember && controller.isSuperAdmin) ...[
                        InkWell(
                          onTap: () {
                            Get.dialog(EditCityDialog(member: member, controller: controller));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF8BBD0)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.location_city_rounded, size: 14, color: Color(0xFF880E4F)),
                                SizedBox(width: 3),
                                Text(
                                  'Cities',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF880E4F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            Get.dialog(EditAdminMemberDialog(member: member, controller: controller));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF80CBC4)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 14, color: Colors.teal),
                                SizedBox(width: 3),
                                Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // View Details Button
                      InkWell(
                        onTap: () {
                          Get.dialog(MemberDetailDialog(member: member, controller: controller));
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF880E4F).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF880E4F).withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Details',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF880E4F),
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF880E4F)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Color _getStatusDotColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'hold':
        return const Color(0xFF2196F3);
      case 'married':
        return const Color(0xFF9C27B0);
      case 'cancel':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }
}
