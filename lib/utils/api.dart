import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_helper.dart';

class API {
  final Dio _dio = Dio();

  API() {
    /// live url
    _dio.options.baseUrl = "https://vivahsambandh.com/crmapi/public/api/";
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String token = ApiHelper.apiHelper.authorizationToken;
          if (token.isEmpty) {
            try {
              final prefs = await SharedPreferences.getInstance();
              token = prefs.getString('vivah_auth_token') ?? '';
            } catch (_) {}
          }
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(PrettyDioLogger(
      request: false,
      responseBody: false,
    ));
  }

  Dio get dio => _dio;
}
