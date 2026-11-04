import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/member_item_model.dart';
import '../../../controllers/user_home_controller.dart';
import '../candidate_profile_screen.dart';

class UserCandidateCard extends StatelessWidget {
  final MemberItemModel member;
  final UserHomeController controller;

  const UserCandidateCard({
    super.key,
    required this.member,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final imageBase = controller.userImageBase.value;
    final faceImg = member.getImageUrl(imageBase);

    void openProfile() {
      if (!controller.isSubscribed) {
        Get.snackbar(
          'Subscription Required',
          'Not subscribed',
          backgroundColor: const Color(0xFFD32F2F),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      Get.to(() => CandidateProfileScreen(initialMember: member));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: openProfile,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Left Circular Avatar with Double Ring
                Container(
                  width: 82,
                  height: 82,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE91E63),
                      width: 2.2,
                    ),
                  ),
                  child: ClipOval(
                    child: faceImg.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: faceImg,
                            width: 77,
                            height: 77,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFFFCE4EC),
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE91E63),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => _buildAvatarPlaceholder(),
                          )
                        : _buildAvatarPlaceholder(),
                  ),
                ),

                const SizedBox(width: 10),

                // 2. Vertical Gradient Accent Bar (Pink to Purple)
                Container(
                  width: 4.5,
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE91E63), // Pink
                        Color(0xFF9C27B0), // Purple
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                const SizedBox(width: 10),

                // 3. Middle Section: Name, DOB, Education, Profession, Chips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Candidate Name
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),

                      // Calendar + DOB (Age)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFFE91E63),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              [
                                if (member.dateOfBirth != null && member.dateOfBirth!.isNotEmpty)
                                  member.dateOfBirth!,
                                if (member.ageDisplay.isNotEmpty) '(${member.ageDisplay})',
                              ].join('  '),
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF616161),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.5),

                      // Education
                      Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 13,
                            color: Color(0xFFE91E63),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              member.educationName ?? 'Not specified',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF616161),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.5),

                      // Profession
                      Row(
                        children: [
                          const Icon(
                            Icons.business_center_outlined,
                            size: 13,
                            color: Color(0xFFE91E63),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              member.professionName ?? 'Not in any Profession',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF616161),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.5),

                      // Bottom Chip: City
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 11,
                              color: Color(0xFFE91E63),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              member.userCurrentCity ?? 'Bangalore',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 4. Right Side: Top ID Badge + Wishlist Heart & Bottom "View Profile ->"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Member ID Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${member.id}',
                        style: const TextStyle(
                          color: Color(0xFFE91E63),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Wishlist Heart Symbol (Toggles Wishlist API)
                    Obx(() {
                      final isWishlisted = controller.isWishlisted(member.id);
                      return InkWell(
                        onTap: () => controller.toggleWishlist(member),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: const Color(0xFFE91E63),
                            size: 23,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // "View Profile ->" Pill Button
                    InkWell(
                      onTap: openProfile,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE91E63).withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 12),
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
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 77,
      height: 77,
      color: const Color(0xFFFCE4EC),
      child: Center(
        child: Icon(
          member.gender.toLowerCase() == 'female' ? Icons.face_3 : Icons.face,
          size: 46,
          color: const Color(0xFFE91E63),
        ),
      ),
    );
  }
}
