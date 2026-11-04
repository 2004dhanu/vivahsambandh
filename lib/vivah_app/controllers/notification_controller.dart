import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/api_service.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class NotificationController extends GetxController {
  final UserModel? user;
  final ApiService _apiService = ApiService();

  NotificationController({this.user});

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// GET: Fetch notifications by user ID or notification ID
  Future<void> fetchNotifications({int? targetId}) async {
    final id = targetId ?? user?.id ?? 1;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final res = await _apiService.getNotificationById(id);
      if (res['success'] == true) {
        final list = res['notifications'] as List<NotificationModel>? ?? [];
        notifications.assignAll(list);
      } else {
        errorMessage.value = res['message']?.toString() ?? 'No notifications available.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// DELETE: Remove notification by notification ID
  Future<void> deleteNotification(int id) async {
    // Optimistic removal
    final existingIndex = notifications.indexWhere((n) => n.id == id);
    NotificationModel? removedItem;
    if (existingIndex != -1) {
      removedItem = notifications.removeAt(existingIndex);
    }

    try {
      final res = await _apiService.deleteNotification(id);
      if (res['success'] == true) {
        Get.snackbar(
          'Deleted',
          'Notification removed successfully.',
          backgroundColor: const Color(0xFF546E7A),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Rollback on failure
        if (removedItem != null && existingIndex != -1) {
          notifications.insert(existingIndex, removedItem);
        }
        Get.snackbar(
          'Notice',
          res['message']?.toString() ?? 'Unable to delete notification.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (removedItem != null && existingIndex != -1) {
        notifications.insert(existingIndex, removedItem);
      }
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
