import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/constants/api_constants.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  )) {
    // Interceptor for JWT
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired – clear and force logout (will be handled by router)
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          // Optionally navigate to login via global key, but we rely on router redirect.
        }
        return handler.next(e);
      },
    ));

    // Retry on network errors
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      retries: 2,
      retryDelays: const [Duration(seconds: 1), Duration(seconds: 2)],
    ));

    // Logging (optional)
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
}