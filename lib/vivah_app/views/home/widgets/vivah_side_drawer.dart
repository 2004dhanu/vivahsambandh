import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/session_manager.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../controllers/user_home_controller.dart';
import '../my_profile_screen.dart';
import '../settings_filter_screen.dart';
import '../../notifications/notification_screen.dart';
import '../../legal/legal_webview_screen.dart';
import '../../payment/payment_history_screen.dart';

class VivahSideDrawer extends StatelessWidget {
  final UserModel? user;
  final UserHomeController homeController;

  const VivahSideDrawer({
    super.key,
    required this.user,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    final imageBase = homeController.userImageBase.value;
    final faceImg = user?.faceImage != null && user!.faceImage!.isNotEmpty
        ? (imageBase.endsWith('/') ? '$imageBase${user!.faceImage}' : '$imageBase/${user!.faceImage}')
        : '';

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header with rich curved gradient & overlapping circles (Image 3)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 24, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF880E4F), Color(0xFFC2185B), Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Stack(
              children: [
                // Decorative circle 1
                Positioned(
                  right: -30,
                  top: -20,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                // Decorative circle 2
                Positioned(
                  right: 20,
                  bottom: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand row: 4 dots + vivahsambandh
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/image/vs_app_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'vivahsambandh',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Matrimony & Community',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Circular User Avatar with thick white border
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: faceImg.isNotEmpty
                            ? Image.network(
                                faceImg,
                                width: 84,
                                height: 84,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                              )
                            : _buildAvatarPlaceholder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // User ID
                    Text(
                      'User ID : ${user?.id ?? "523"}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // User Name
                    Text(
                      (user != null && user!.name.isNotEmpty)
                          ? user!.name.toUpperCase()
                          : 'RAGHAV GOEL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    // Contact
                    Text(
                      'Contact : ${user?.mobile ?? "9560265460"}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items List (Image 3)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Home',
                  isActive: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(() => MyProfileScreen(user: user));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.bookmark_border,
                  title: 'My Shortlisted',
                  onTap: () {
                    Navigator.of(context).pop();
                    homeController.selectedTab.value = 1;
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Payment History',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(() => PaymentHistoryScreen(user: user));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(() => NotificationScreen(user: user));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Messages',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'Messages',
                      'No new messages at this time.',
                      backgroundColor: Colors.blueGrey,
                      colorText: Colors.white,
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (user?.isSubscribed != true) {
                      Get.snackbar(
                        'Subscription Required',
                        'Not subscribed',
                        backgroundColor: const Color(0xFFD32F2F),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    Get.to(() => const SettingsFilterScreen());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.feedback_outlined,
                  title: 'Feedback',
                  onTap: () {
                    Navigator.of(context).pop();
                    homeController.selectedTab.value = 3;
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.defaultDialog(
                      title: 'About VivahSambandh',
                      middleText:
                          'VivahSambandh is a premier matrimonial platform connecting verified members across trusted communities.',
                      textConfirm: 'Close',
                      confirmTextColor: Colors.white,
                      buttonColor: AppColors.primary,
                      onConfirm: () => Get.back(),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(() => const LegalWebViewScreen(initialTabIndex: 0));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(() => const LegalWebViewScreen(initialTabIndex: 1));
                  },
                ),

                const SizedBox(height: 12),

                // Promotional Banner Card "Find Your Right Match"
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8BBD0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people_alt, color: Color(0xFFC2185B), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Your\nRight Match',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF880E4F),
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Connect with verified profiles',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFAD1457),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE91E63),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Logout Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.defaultDialog(
                      title: 'Logout',
                      middleText: 'Are you sure you want to logout?',
                      textConfirm: 'Logout',
                      textCancel: 'Cancel',
                      confirmTextColor: Colors.white,
                      buttonColor: const Color(0xFFE91E63),
                      onConfirm: () async {
                        Get.back();
                        await SessionManager.instance.destroySession();
                      },
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.blueGrey, size: 20),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Delete Account Button (Below Logout)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.defaultDialog(
                      title: 'Delete Account',
                      titleStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                      middleText:
                          'Are you sure you want to permanently delete your account? This action cannot be undone.',
                      textConfirm: 'Delete Account',
                      textCancel: 'Cancel',
                      confirmTextColor: Colors.white,
                      buttonColor: const Color(0xFFD32F2F),
                      onConfirm: () async {
                        Get.back();
                        try {
                          await ApiService().deleteProfile(userId: user?.id);
                        } catch (_) {}
                        await SessionManager.instance.destroySession();
                        Get.snackbar(
                          'Account Deleted',
                          'Your account has been deleted successfully.',
                          backgroundColor: const Color(0xFFD32F2F),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_forever_outlined, color: Color(0xFFD32F2F), size: 20),
                  label: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFDE8E9) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFFE91E63) : Colors.grey.shade700,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFFE91E63) : Colors.grey.shade800,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }


  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 84,
      height: 84,
      color: Colors.pink.shade100,
      child: const Center(
        child: Icon(Icons.person, color: Color(0xFFE91E63), size: 48),
      ),
    );
  }
}
