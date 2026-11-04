import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/api_service.dart';
import '../core/services/session_manager.dart';
import '../models/user_model.dart';
import '../models/member_item_model.dart';
import '../models/shortlist_model.dart';
import '../models/feedback_model.dart';
import '../models/block_profile_model.dart';
import '../models/member_filter_model.dart';

class UserHomeController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs; // 0: Matches, 1: Shortlisted, 2: Blocked, 3: Feedbacks

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  bool get isSubscribed => currentUser.value?.isSubscribed ?? false;

  // Active Partner Filter Settings
  final Rx<MemberFilterModel> activeFilter = MemberFilterModel().obs;

  // Data lists
  final RxList<MemberItemModel> allCandidateMembers = <MemberItemModel>[].obs;
  final RxList<ShortlistItemModel> shortlistedList = <ShortlistItemModel>[].obs;
  final RxList<BlockProfileItemModel> blockedList = <BlockProfileItemModel>[].obs;
  final RxList<FeedbackItemModel> feedbackList = <FeedbackItemModel>[].obs;

  // Lookup structures for fast state check
  final RxSet<int> shortlistedMemberIds = <int>{}.obs;
  final RxMap<int, int> shortlistRowIdByMemberId = <int, int>{}.obs;
  final RxSet<int> blockedMemberIds = <int>{}.obs;

  final RxString userImageBase = 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/'.obs;
  final RxString searchQuery = ''.obs;

  int? currentUserId;

  /// Filtered candidate matches (excluding current user & blocked profiles)
  List<MemberItemModel> get filteredMatches {
    return allCandidateMembers.where((m) {
      if (currentUserId != null && m.id == currentUserId) return false;
      if (blockedMemberIds.contains(m.id)) return false;

      final query = searchQuery.value.trim().toLowerCase();
      if (query.isNotEmpty) {
        final nameMatch = m.name.toLowerCase().contains(query);
        final cityMatch = (m.userCurrentCity ?? '').toLowerCase().contains(query);
        final commMatch = (m.communityName ?? '').toLowerCase().contains(query);
        final gotraMatch = (m.gotraName ?? '').toLowerCase().contains(query);
        final profMatch = (m.professionName ?? '').toLowerCase().contains(query);
        return nameMatch || cityMatch || commMatch || gotraMatch || profMatch;
      }
      return true;
    }).toList();
  }

  bool isWishlisted(int memberId) => shortlistedMemberIds.contains(memberId);
  bool isShortlisted(int memberId) => isWishlisted(memberId);
  bool isBlocked(int memberId) => blockedMemberIds.contains(memberId);

  /// Load all data: matches, shortlist, blocked, feedbacks
  Future<void> loadAllData({int? userId, UserModel? user}) async {
    if (userId != null) currentUserId = userId;
    if (user != null) currentUser.value = user;
    if (currentUser.value == null) {
      try {
        currentUser.value = await SessionManager.instance.getUser();
      } catch (_) {}
    }
    isLoading.value = true;
    try {
      // 1. Fetch blocked first to filter matching cards
      await _fetchBlockedList();

      // 2. Fetch shortlist
      await _fetchShortlist();

      // 3. Fetch feedbacks
      await _fetchFeedbacks();

      // 4. Fetch all active members
      await _fetchAllMembers();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAllMembers({Map<String, dynamic>? queryParams}) async {
    try {
      final params = queryParams ?? (activeFilter.value.hasActiveFilters ? activeFilter.value.toQueryParams() : null);
      final res = await _apiService.getAllMembers(queryParams: params);
      if (res['success'] == true) {
        if (res['user_image_base'] != null) {
          userImageBase.value = res['user_image_base'].toString();
        }
        final list = res['members'] as List<MemberItemModel>? ?? [];
        allCandidateMembers.assignAll(list);
      }
    } catch (e) {
      debugPrint("Error fetching all members: $e");
    }
  }

  /// Apply partner preferences filter from Settings screen
  Future<void> applyFilter(MemberFilterModel filter) async {
    activeFilter.value = filter.copy();
    activeFilter.refresh();
    isLoading.value = true;
    try {
      await _fetchAllMembers();
      Get.snackbar(
        'Filters Applied',
        'Showing ${filteredMatches.length} matching profiles according to your criteria.',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset / Clear partner preferences filter
  Future<void> resetFilter() async {
    activeFilter.value.clear();
    activeFilter.refresh();
    isLoading.value = true;
    try {
      await _fetchAllMembers(queryParams: null);
      Get.snackbar(
        'Filters Cleared',
        'Showing all available profiles.',
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchShortlist() async {
    try {
      final res = await _apiService.getShortlist();
      if (res['success'] == true) {
        if (res['user_image_base'] != null) {
          userImageBase.value = res['user_image_base'].toString();
        }
        final list = res['shortlists'] as List<ShortlistItemModel>? ?? [];
        shortlistedList.assignAll(list);

        final Set<int> ids = {};
        final Map<int, int> map = {};
        for (var s in list) {
          ids.add(s.toId);
          map[s.toId] = s.id;
        }
        shortlistedMemberIds.assignAll(ids);
        shortlistRowIdByMemberId.assignAll(map);
      }
    } catch (e) {
      debugPrint("Error fetching shortlist: $e");
    }
  }

  Future<void> _fetchBlockedList() async {
    try {
      final res = await _apiService.getBlockedProfiles();
      if (res['success'] == true) {
        if (res['user_image_base'] != null) {
          userImageBase.value = res['user_image_base'].toString();
        }
        final list = res['blockedProfiles'] as List<BlockProfileItemModel>? ?? [];
        blockedList.assignAll(list);

        final Set<int> ids = {};
        for (var b in list) {
          ids.add(b.toId);
        }
        blockedMemberIds.assignAll(ids);
      }
    } catch (e) {
      debugPrint("Error fetching blocked list: $e");
    }
  }

  Future<void> _fetchFeedbacks() async {
    try {
      final res = await _apiService.getFeedbackList();
      if (res['success'] == true) {
        final list = res['feedbacks'] as List<FeedbackItemModel>? ?? [];
        feedbackList.assignAll(list);
      }
    } catch (e) {
      debugPrint("Error fetching feedbacks: $e");
    }
  }

  /// Toggle wishlist status (heart icon action)
  Future<void> toggleWishlist(MemberItemModel member) async {
    if (isWishlisted(member.id)) {
      await removeWishlist(member.id);
    } else {
      await addWishlist(member);
    }
  }

  /// POST: Add candidate to wishlist (to_id: member.id)
  Future<void> addWishlist(MemberItemModel member) async {
    // Optimistic UI state update
    shortlistedMemberIds.add(member.id);

    try {
      final res = await _apiService.addToWishlist(member.id);
      if (res['success'] == true) {
        if (res['data'] is Map && res['data']['data'] is Map && res['data']['data']['id'] != null) {
          final rowId = int.tryParse(res['data']['data']['id'].toString());
          if (rowId != null) {
            shortlistRowIdByMemberId[member.id] = rowId;
          }
        }
        Get.snackbar(
          'Added to Wishlist',
          '${member.name} has been added to your wishlist.',
          backgroundColor: const Color(0xFFE91E63),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        await _fetchShortlist();
      } else {
        // Rollback optimistic update on failure
        shortlistedMemberIds.remove(member.id);
        Get.snackbar(
          'Notice',
          res['message']?.toString() ?? 'Unable to add to wishlist.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      shortlistedMemberIds.remove(member.id);
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// DELETE: Remove candidate from wishlist (/wishlist/{id})
  Future<void> removeWishlist(int memberId) async {
    final rowId = shortlistRowIdByMemberId[memberId];
    // Optimistic UI state update
    shortlistedMemberIds.remove(memberId);

    try {
      final deleteId = rowId ?? memberId;
      final res = await _apiService.removeFromWishlist(deleteId);
      if (res['success'] == true) {
        if (rowId != null) {
          shortlistRowIdByMemberId.remove(memberId);
          shortlistedList.removeWhere((item) => item.id == rowId || item.toId == memberId);
        } else {
          shortlistedList.removeWhere((item) => item.toId == memberId);
        }
        Get.snackbar(
          'Removed from Wishlist',
          'Profile removed from your wishlist.',
          backgroundColor: const Color(0xFF546E7A),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        await _fetchShortlist();
      } else {
        // Rollback on failure
        shortlistedMemberIds.add(memberId);
        Get.snackbar(
          'Notice',
          res['message']?.toString() ?? 'Failed to remove from wishlist',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      shortlistedMemberIds.add(memberId);
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// Backward-compatible aliases
  Future<void> shortlistProfile(MemberItemModel member) => toggleWishlist(member);
  Future<void> removeShortlist(int memberId) => removeWishlist(memberId);

  /// Submit feedback for candidate profile
  Future<void> submitFeedback({required int toProfileId, required String description}) async {
    if (description.trim().isEmpty) {
      Get.snackbar('Empty Feedback', 'Please type your feedback description.', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      final res = await _apiService.submitFeedback(
        toProfileId: toProfileId,
        description: description.trim(),
      );
      if (res['success'] == true) {
        Get.snackbar(
          'Feedback Sent',
          'Your feedback has been submitted successfully.',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        await _fetchFeedbacks();
      } else {
        Get.snackbar('Notice', res['message']?.toString() ?? 'Failed to send feedback', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// Delete feedback by ID
  Future<void> deleteFeedback(int feedbackId) async {
    try {
      final res = await _apiService.deleteFeedback(feedbackId);
      if (res['success'] == true) {
        feedbackList.removeWhere((f) => f.id == feedbackId);
        Get.snackbar(
          'Deleted',
          'Feedback removed successfully.',
          backgroundColor: Colors.blueGrey,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Notice', res['message']?.toString() ?? 'Failed to delete feedback', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// Block candidate profile
  Future<void> blockProfile({
    required int toId,
    required String candidateName,
    required String reason,
    int? reasonValue,
    String? reasonTitle,
  }) async {
    try {
      final res = await _apiService.blockProfile(
        toId: toId,
        description: reason.trim().isEmpty ? 'Blocked by user' : reason.trim(),
        reasonValue: reasonValue,
        reasonTitle: reasonTitle,
      );
      if (res['success'] == true) {
        blockedMemberIds.add(toId);
        // Also remove from shortlist if was shortlisted
        shortlistedMemberIds.remove(toId);
        Get.snackbar(
          'Profile Blocked',
          '$candidateName has been blocked.',
          backgroundColor: const Color(0xFFD32F2F),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        await _fetchBlockedList();
      } else {
        Get.snackbar('Notice', res['message']?.toString() ?? 'Failed to block profile', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// Unblock candidate profile
  Future<void> unblockProfile(int blockRowId, int memberId) async {
    try {
      final res = await _apiService.unblockProfile(blockRowId);
      if (res['success'] == true) {
        blockedMemberIds.remove(memberId);
        blockedList.removeWhere((b) => b.id == blockRowId || b.toId == memberId);
        Get.snackbar(
          'Unblocked',
          'Profile unblocked successfully.',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Notice', res['message']?.toString() ?? 'Failed to unblock', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  /// Fetch full candidate details via GET /member/{id}
  Future<MemberItemModel?> fetchMemberDetail(int memberId) async {
    try {
      final res = await _apiService.getMemberById(memberId);
      if (res['success'] == true && res['member'] is MemberItemModel) {
        return res['member'] as MemberItemModel;
      }
    } catch (e) {
      debugPrint("Error fetching member detail for $memberId: $e");
    }
    return null;
  }
}
