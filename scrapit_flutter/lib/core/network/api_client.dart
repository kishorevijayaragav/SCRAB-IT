import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../services/storage_service.dart';
import 'api_exceptions.dart';

class ApiClient {
  final Dio _dio;
  final StorageService _storageService;
  void Function()? onUnauthorized;

  ApiClient({
    required StorageService storageService,
    this.onUnauthorized,
  })  : _storageService = storageService,
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/json'},
        )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Resolve base URL dynamically
          final customUrl = _storageService.getCustomBaseUrl();
          options.baseUrl = (customUrl != null && customUrl.isNotEmpty)
              ? customUrl
              : ApiConstants.defaultBaseUrl;

          // Inject Bearer token if present
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            onUnauthorized?.call();
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: UnauthorizedException(
                  e.response?.data?['error']?.toString() ?? 'Session expired',
                ),
                response: e.response,
              ),
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  String get currentBaseUrl {
    final customUrl = _storageService.getCustomBaseUrl();
    return (customUrl != null && customUrl.isNotEmpty)
        ? customUrl
        : ApiConstants.defaultBaseUrl;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ApiException _handleError(DioException e) {
    if (e.error is ApiException) {
      return e.error as ApiException;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(
        'Cannot reach the ScrapIt server at $currentBaseUrl.\n'
        'Start the backend (npm start) and check the URL in '
        'Profile > Backend Server Connection. On a real phone use your '
        "PC's Wi-Fi IP, e.g. http://192.168.1.100:3000.",
      );
    }
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        return ApiException(data['error'].toString(), e.response?.statusCode);
      }
      return ApiException(
        'Server returned error: ${e.response?.statusCode}',
        e.response?.statusCode,
      );
    }
    return ApiException(e.message ?? 'An unexpected network error occurred.');
  }
}
