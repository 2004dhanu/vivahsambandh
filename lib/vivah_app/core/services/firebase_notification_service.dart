import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';
import '../../models/member_item_model.dart';
import '../api/api_service.dart';
import '../../controllers/user_home_controller.dart';
import '../../views/home/candidate_profile_screen.dart';
import '../../views/notifications/notification_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  debugPrint("📩 FCM Background Message: ${message.messageId} - ${message.notification?.title}");
}

class FirebaseNotificationService {
  static final FirebaseNotificationService instance = FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;

  static const AndroidNotificationChannel _highImportanceChannel = AndroidNotificationChannel(
    'vivahsambandh_high_importance_channel',
    'VivahSambandh Notifications',
    description: 'High importance push notifications for alerts, match updates and approvals',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize Firebase Messaging, local notifications channel, permissions, and deep link listeners
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Request Notification Permissions (Android 13+ & iOS)
      try {
        final NotificationSettings settings = await _messaging
            .requestPermission(
              alert: true,
              announcement: false,
              badge: true,
              carPlay: false,
              criticalAlert: false,
              provisional: false,
              sound: true,
            )
            .timeout(const Duration(seconds: 4));
        debugPrint("🔔 Notification permission status: ${settings.authorizationStatus}");
      } catch (e) {
        debugPrint("Notice requesting notification permission: $e");
      }

      // 2. Initialize Local Notifications for Foreground System Heads-Up Banner
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint("🔔 System push notification tapped: ${response.payload}");
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data = jsonDecode(response.payload!);
              handleDeepLink(data);
            } catch (_) {
              handleDeepLink({'link': response.payload});
            }
          } else {
            Get.to(() => const NotificationScreen());
          }
        },
      );

      // 3. Create High Importance Android Notification Channel
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_highImportanceChannel);
      }

      // 4. Fetch and store FCM Token (non-blocking)
      _fetchAndPersistToken();

      // 5. Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        await _saveTokenToPrefs(newToken);
        debugPrint("🔥 FCM Token refreshed: $newToken");
      });

      // 6. Default topic subscriptions (background non-blocking)
      _messaging.subscribeToTopic('vivahsambandh_all').catchError((e) {
        debugPrint("Topic subscription notice: $e");
      });
      _messaging.subscribeToTopic('notifications').catchError((e) {
        debugPrint("Topic subscription notice: $e");
      });

      // 7. Handle Foreground Messages: Show REAL system push notification & in-app banner
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("📩 Foreground notification: ${message.notification?.title} - ${message.notification?.body}");
        _showSystemPushNotification(message);
        _showInAppNotification(message);
      });

      // 8. Handle notification tap when app is in BACKGROUND
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("📲 Background notification tapped: ${message.data}");
        handleDeepLink(message.data);
      });

      // 9. Handle notification tap when app is launched from TERMINATED state
      _messaging.getInitialMessage().timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      ).then((initialMessage) {
        if (initialMessage != null) {
          debugPrint("🚀 Terminated launch via notification: ${initialMessage.data}");
          Future.delayed(const Duration(milliseconds: 1000), () {
            handleDeepLink(initialMessage.data);
          });
        }
      }).catchError((_) {});

      _isInitialized = true;
    } catch (e) {
      debugPrint("❌ Error initializing FirebaseNotificationService: $e");
    }
  }

  /// Show native system push notification in Android notification bar/shade
  Future<void> _showSystemPushNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title']?.toString() ?? 'VivahSambandh';
      final body = notification?.body ??
          message.data['body']?.toString() ??
          message.data['message']?.toString() ??
          '';

      final androidDetails = AndroidNotificationDetails(
        _highImportanceChannel.id,
        _highImportanceChannel.name,
        channelDescription: _highImportanceChannel.description,
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: const BigTextStyleInformation(''),
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint("Notice displaying local push notification: $e");
    }
  }

  /// Deep Link Handler: Navigates to the exact screen or profile based on payload
  static Future<void> handleDeepLink(Map<String, dynamic> data) async {
    debugPrint("🔗 Processing Deep Link payload: $data");

    // 1. Extract Candidate / Member ID
    String? memberIdStr = data['member_id']?.toString() ??
        data['profile_id']?.toString() ??
        data['candidate_id']?.toString() ??
        data['to_id']?.toString() ??
        data['user_id']?.toString();

    // 2. Extract Link / URL / Route
    final rawLink = data['link']?.toString() ??
        data['deeplink']?.toString() ??
        data['url']?.toString() ??
        data['route']?.toString() ??
        data['click_action']?.toString() ??
        '';

    if (rawLink.isNotEmpty) {
      debugPrint("🔗 Raw link received: $rawLink");

      // Check for web URL
      if (rawLink.startsWith('http://') || rawLink.startsWith('https://')) {
        final uri = Uri.tryParse(rawLink);
        if (uri != null) {
          // If URL points to a member route on vivahsambandh website
          final segments = uri.pathSegments;
          if (segments.contains('member') || segments.contains('candidate') || segments.contains('profile')) {
            final idx = segments.contains('member')
                ? segments.indexOf('member')
                : (segments.contains('candidate')
                    ? segments.indexOf('candidate')
                    : segments.indexOf('profile'));
            if (idx + 1 < segments.length) {
              memberIdStr = segments[idx + 1];
            }
          } else if (uri.queryParameters.containsKey('id')) {
            memberIdStr = uri.queryParameters['id'];
          } else if (uri.queryParameters.containsKey('member_id')) {
            memberIdStr = uri.queryParameters['member_id'];
          } else {
            // External web link -> open with browser
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return;
              }
            } catch (_) {}
          }
        }
      } else {
        // App scheme URL (e.g., vivahsambandh://candidate/550 or /candidate/550)
        final uri = Uri.tryParse(rawLink);
        if (uri != null) {
          final segments = uri.pathSegments;
          if (segments.contains('member') || segments.contains('candidate') || segments.contains('profile')) {
            final idx = segments.contains('member')
                ? segments.indexOf('member')
                : (segments.contains('candidate')
                    ? segments.indexOf('candidate')
                    : segments.indexOf('profile'));
            if (idx + 1 < segments.length) {
              memberIdStr = segments[idx + 1];
            }
          }
        }
      }

      if (rawLink.toLowerCase().contains('wishlist') || rawLink.toLowerCase().contains('shortlist')) {
        if (Get.isRegistered<UserHomeController>()) {
          Get.find<UserHomeController>().selectedTab.value = 1;
        }
        return;
      }

      if (rawLink.toLowerCase().contains('notification')) {
        Get.to(() => const NotificationScreen());
        return;
      }
    }

    // 3. Open Candidate Profile if ID is found
    final targetId = int.tryParse(memberIdStr ?? '');
    if (targetId != null && targetId > 0) {
      try {
        final api = ApiService();
        final res = await api.getMemberById(targetId);
        if (res['success'] == true && res['member'] != null) {
          Get.to(() => CandidateProfileScreen(initialMember: res['member'] as MemberItemModel));
          return;
        }
      } catch (e) {
        debugPrint("Error fetching candidate for deep link: $e");
      }
    }

    // 4. Fallback based on 'screen' or 'type' parameter
    final screen = (data['screen'] ?? data['type'] ?? '').toString().toLowerCase();
    if (screen == 'wishlist' || screen == 'shortlist') {
      if (Get.isRegistered<UserHomeController>()) {
        Get.find<UserHomeController>().selectedTab.value = 1;
      }
    } else {
      Get.to(() => const NotificationScreen());
    }
  }

  /// Get real FCM Token from Firebase for backend device_id
  Future<String> getFcmToken() async {
    // 1. Return in-memory FCM token if already retrieved
    if (_fcmToken != null && _fcmToken!.trim().length > 30) {
      return _fcmToken!.trim();
    }

    // 2. Fetch directly from Firebase Messaging
    try {
      final token = await _messaging.getToken();
      if (token != null && token.trim().isNotEmpty) {
        _fcmToken = token.trim();
        await _saveTokenToPrefs(token.trim());
        debugPrint("🔥 Real FCM Token for device_id: $token");
        return token.trim();
      }
    } catch (e) {
      debugPrint("❌ Notice fetching FCM token from Firebase: $e");
    }

    // 3. Fallback: check cached real FCM token in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedToken = prefs.getString('fcm_device_token');
      if (cachedToken != null && cachedToken.trim().length > 30) {
        _fcmToken = cachedToken.trim();
        return cachedToken.trim();
      }
    } catch (_) {}

    return _fcmToken ?? '';
  }

  /// Subscribe user / admin to relevant FCM topics based on role
  Future<void> configureUserTopics(UserModel? user) async {
    if (user == null) return;

    try {
      await _messaging.subscribeToTopic('user_${user.id}');

      if (user.isSuperAdmin) {
        await _messaging.subscribeToTopic('super_admin');
        await _messaging.subscribeToTopic('admin');
        debugPrint("👑 Subscribed to super_admin and admin FCM topics");
      } else if (user.isAdmin) {
        await _messaging.subscribeToTopic('admin');
        debugPrint("🛡️ Subscribed to admin FCM topic");
      } else {
        await _messaging.subscribeToTopic('users');
        debugPrint("👤 Subscribed to users FCM topic");
      }
    } catch (e) {
      debugPrint("Notice configuring user FCM topics: $e");
    }
  }

  /// Unsubscribe user from FCM topics on logout
  Future<void> unsubscribeFromUserTopics(UserModel? user) async {
    if (user == null) return;
    try {
      await _messaging.unsubscribeFromTopic('user_${user.id}');
      if (user.isSuperAdmin) {
        await _messaging.unsubscribeFromTopic('super_admin');
        await _messaging.unsubscribeFromTopic('admin');
      } else if (user.isAdmin) {
        await _messaging.unsubscribeFromTopic('admin');
      } else {
        await _messaging.unsubscribeFromTopic('users');
      }
    } catch (_) {}
  }

  Future<void> _fetchAndPersistToken() async {
    try {
      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );
      if (token != null && token.isNotEmpty) {
        _fcmToken = token;
        await _saveTokenToPrefs(token);
        debugPrint("🔥 FCM Device Token: $token");
      }
    } catch (e) {
      debugPrint("Notice fetching initial FCM token: $e");
    }
  }

  Future<void> _saveTokenToPrefs(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_device_token', token);
    } catch (_) {}
  }

  void _showInAppNotification(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title']?.toString() ?? 'VivahSambandh Notification';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        'You have a new notification.';

    Get.snackbar(
      title,
      body,
      backgroundColor: const Color(0xFF880E4F),
      colorText: Colors.white,
      icon: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 14,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () => handleDeepLink(message.data),
        child: const Text(
          'VIEW',
          style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
