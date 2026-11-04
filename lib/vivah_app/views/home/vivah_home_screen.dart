import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_service.dart';
import '../../core/services/session_manager.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../controllers/user_home_controller.dart';
import 'widgets/user_candidate_card.dart';
import 'widgets/vivah_side_drawer.dart';
import 'candidate_profile_screen.dart';
import '../notifications/notification_screen.dart';

class VivahHomeScreen extends StatefulWidget {
  final UserModel? user;

  const VivahHomeScreen({super.key, this.user});

  @override
  State<VivahHomeScreen> createState() => _VivahHomeScreenState();
}

class _VivahHomeScreenState extends State<VivahHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  final UserHomeController _homeController = Get.put(UserHomeController());
  final TextEditingController _searchController = TextEditingController();

  late UserModel? _currentUser;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    if (_currentUser == null) {
      SessionManager.instance.getUser().then((u) {
        if (mounted && u != null) {
          setState(() {
            _currentUser = u;
          });
          _homeController.currentUser.value = u;
          _homeController.loadAllData(userId: _currentUser?.id, user: _currentUser);
        } else {
          _homeController.loadAllData(userId: null);
        }
      });
    } else {
      _homeController.currentUser.value = _currentUser;
      _homeController.loadAllData(userId: _currentUser?.id, user: _currentUser);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    try {
      if (_currentUser?.mobile != null) {
        final updatedMember = await _apiService.checkExistingMemberByMobile(_currentUser!.mobile);
        if (updatedMember != null && mounted) {
          setState(() {
            _currentUser = UserModel.fromMember(updatedMember);
          });
          _homeController.currentUser.value = _currentUser;
          await SessionManager.instance.saveSession(user: _currentUser!, token: ApiClient().authToken);
        }
      }
      await _homeController.loadAllData(userId: _currentUser?.id, user: _currentUser);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFBF4F6),
      drawer: VivahSideDrawer(
        user: _currentUser,
        homeController: _homeController,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          color: const Color(0xFFE91E63),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (4 dots, vivahsambandh, Search)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      // 4 dots menu icon
                      InkWell(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: _buildGridIcon(),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // vivahsambandh + Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'vivah',
                                    style: TextStyle(
                                      color: Color(0xFFE91E63),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'sambandh',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Verified Profiles • Trusted Community',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search Icon Button (Image 1)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isSearchVisible = !_isSearchVisible;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE4EC),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF8BBD0)),
                          ),
                          child: const Icon(Icons.search, color: Color(0xFFE91E63), size: 22),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Notification Bell Icon Button
                      InkWell(
                        onTap: () => Get.to(() => NotificationScreen(user: _currentUser)),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE4EC),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF8BBD0)),
                          ),
                          child: const Icon(Icons.notifications_none_rounded, color: Color(0xFFE91E63), size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar Input (Appears when Search Icon is Tapped)
                if (_isSearchVisible)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE91E63).withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (val) => _homeController.searchQuery.value = val,
                        decoration: InputDecoration(
                          hintText: 'Search by name, profession, gotra...',
                          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFFE91E63), size: 20),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _homeController.searchQuery.value = '';
                              setState(() => _isSearchVisible = false);
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ),

                // Active Filters Banner (If any filters applied)
                Obx(() {
                  final hasFilters = _homeController.activeFilter.value.hasActiveFilters;
                  if (!hasFilters) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text(
                            'Filters:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(width: 6),
                          if (_homeController.activeFilter.value.heightFrom != null)
                            _buildActiveTag(
                              'Height: ${_homeController.activeFilter.value.heightFrom} - ${_homeController.activeFilter.value.heightTo ?? "7.0"}',
                            ),
                          if (_homeController.activeFilter.value.gotraName != null)
                            _buildActiveTag('Gotra: ${_homeController.activeFilter.value.gotraName}'),
                          if (_homeController.activeFilter.value.educationIds.isNotEmpty)
                            _buildActiveTag('${_homeController.activeFilter.value.educationIds.length} Edu'),
                          InkWell(
                            onTap: () => _homeController.resetFilter(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Clear', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Secondary Tab Selector (Matches, Shortlisted, Blocked, Feedbacks)
                Obx(() {
                  final curTab = _homeController.selectedTab.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTabSelectorChip('Matches (${_homeController.filteredMatches.length})', curTab == 0, () {
                            _homeController.selectedTab.value = 0;
                          }),
                          const SizedBox(width: 8),
                          _buildTabSelectorChip('Shortlisted (${_homeController.shortlistedList.length})', curTab == 1, () {
                            _homeController.selectedTab.value = 1;
                          }),
                          const SizedBox(width: 8),
                          _buildTabSelectorChip('Blocked (${_homeController.blockedList.length})', curTab == 2, () {
                            _homeController.selectedTab.value = 2;
                          }),
                          const SizedBox(width: 8),
                          _buildTabSelectorChip('Feedbacks (${_homeController.feedbackList.length})', curTab == 3, () {
                            _homeController.selectedTab.value = 3;
                          }),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 4),

                // Main Content List (Recycler View of Candidate Cards)
                Obx(() {
                  if (_homeController.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFFE91E63)),
                      ),
                    );
                  }

                  switch (_homeController.selectedTab.value) {
                    case 0:
                      return _buildMatchesList();
                    case 1:
                      return _buildShortlistList();
                    case 2:
                      return _buildBlockedList();
                    case 3:
                      return _buildFeedbacksList();
                    default:
                      return _buildMatchesList();
                  }
                }),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Matches List (Image 1 Cards)
  Widget _buildMatchesList() {
    final matches = _homeController.filteredMatches;
    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                'No Profiles Found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try adjusting your search criteria or filter settings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final member = matches[index];
        return UserCandidateCard(
          member: member,
          controller: _homeController,
        );
      },
    );
  }

  // 2. Shortlisted List
  Widget _buildShortlistList() {
    final list = _homeController.shortlistedList;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.favorite_border, size: 54, color: Color(0xFFE91E63)),
              const SizedBox(height: 12),
              const Text(
                'No Shortlisted Profiles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap the heart icon on any card to shortlist profiles here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final imageBase = _homeController.userImageBase.value;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final imgUrl = item.getImageUrl(imageBase);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: imgUrl.isNotEmpty
                    ? Image.network(imgUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildThumbPlaceholder())
                    : _buildThumbPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.toUserName ?? 'Member #${item.toId}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Shortlisted: ${item.shortlistDate ?? "Recently"}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFE91E63)),
                onPressed: () async {
                  if (_currentUser?.isSubscribed != true) {
                    Get.snackbar(
                      'Subscription Required',
                      'Not subscribed',
                      backgroundColor: const Color(0xFFD32F2F),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  final member = await _homeController.fetchMemberDetail(item.toId);
                  if (member != null) {
                    Get.to(() => CandidateProfileScreen(initialMember: member));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                onPressed: () => _homeController.removeShortlist(item.toId),
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. Blocked List
  Widget _buildBlockedList() {
    final list = _homeController.blockedList;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.block, size: 54, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('No Blocked Profiles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Profiles you block will appear here.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final imageBase = _homeController.userImageBase.value;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final imgUrl = item.getImageUrl(imageBase);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: imgUrl.isNotEmpty
                    ? Image.network(imgUrl, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildThumbPlaceholder())
                    : _buildThumbPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.toUserName ?? 'Member #${item.toId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Reason: ${item.description ?? "Blocked"}', style: const TextStyle(fontSize: 11, color: Colors.red)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _homeController.unblockProfile(item.id, item.toId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Unblock', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
        );
      },
    );
  }

  // 4. Feedbacks List
  Widget _buildFeedbacksList() {
    final list = _homeController.feedbackList;
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined, size: 54, color: Colors.blueGrey),
              SizedBox(height: 12),
              Text('No Feedbacks Yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.feedbackDate ?? 'Recently', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                    onPressed: () => _homeController.deleteFeedback(item.id),
                  ),
                ],
              ),
              Text(item.feedbackDescription ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabSelectorChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCE4EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTag(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFF8BBD0)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10.5, color: Color(0xFFE91E63), fontWeight: FontWeight.bold),
      ),
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
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildThumbPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.pink.shade50,
      child: const Center(
        child: Icon(Icons.person, color: Color(0xFFE91E63), size: 26),
      ),
    );
  }
}
