import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/api_helper.dart';
import 'api_endpoints.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  String? _authToken;

  String? get authToken => _authToken;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept up to 500 to handle custom server error response messages properly
          return status != null && status < 500;
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }

    // Interceptor to add auth token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_authToken == null || _authToken!.isEmpty) {
            try {
              final prefs = await SharedPreferences.getInstance();
              _authToken = prefs.getString('vivah_auth_token');
            } catch (_) {}
          }
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          debugPrint("❌ ApiClient Error: [${error.response?.statusCode}] ${error.message}");
          return handler.next(error);
        },
      ),
    );

    _initTokenFromStorage();
  }

  Future<void> _initTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('vivah_auth_token');
      if (token != null && token.isNotEmpty) {
        _authToken = token;
        dio.options.headers['Authorization'] = 'Bearer $token';
        try {
          ApiHelper.apiHelper.authorizationToken = token;
          ApiHelper.apiHelper.api.dio.options.headers['Authorization'] = 'Bearer $token';
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> setToken(String token) async {
    _authToken = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vivah_auth_token', token);
    } catch (_) {}
    try {
      ApiHelper.apiHelper.authorizationToken = token;
      ApiHelper.apiHelper.api.dio.options.headers['Authorization'] = 'Bearer $token';
    } catch (_) {}
  }

  Future<void> clearToken() async {
    _authToken = null;
    dio.options.headers.remove('Authorization');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('vivah_auth_token');
    } catch (_) {}
    try {
      ApiHelper.apiHelper.authorizationToken = '';
      ApiHelper.apiHelper.api.dio.options.headers.remove('Authorization');
    } catch (_) {}
  }
}
