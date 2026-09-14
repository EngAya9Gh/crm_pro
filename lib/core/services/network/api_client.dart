import 'dart:async'; // for Completer
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:typed_data'; // for Uint8List
import '../../error/api_exception.dart';
import '../storage/token_storage.dart';
import 'api_response.dart';
import '../download/download_service.dart';
import '../../utils/end_points.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  ApiClient({required Dio dio, required TokenStorage tokenStorage})
    : _dio = dio,
      _tokenStorage = tokenStorage {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null && !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Check if the request that failed was the refresh request itself
            if (e.requestOptions.path.contains(EndPoints.refresh)) {
              await _tokenStorage.clearTokens();
              return handler.next(e);
            }

            final refreshToken = await _tokenStorage.getRefreshToken();
            if (refreshToken == null) {
              return handler.next(e);
            }

            if (_isRefreshing) {
              // Wait for the current refresh to finish
              try {
                await _refreshCompleter?.future;
                // Retry with new token
                final newToken = await _tokenStorage.getAccessToken();
                if (newToken != null) {
                  // Update header with new token
                  e.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';
                  // Retry request
                  final response = await _dio.fetch(e.requestOptions);
                  return handler.resolve(response);
                }
              } catch (_) {
                // If refresh failed, just continue with error
                return handler.next(e);
              }
            }

            _isRefreshing = true;
            _refreshCompleter = Completer<void>();

            try {
              // Call refresh endpoint
              final refreshResponse = await _dio.post(
                EndPoints.refresh,
                options: Options(
                  headers: {'Authorization': 'Bearer $refreshToken'},
                ),
              );

              if (refreshResponse.statusCode == 200 &&
                  refreshResponse.data['success'] == true) {
                final newAccessToken =
                    refreshResponse.data['data']['access_token'];
                await _tokenStorage.saveAccessToken(newAccessToken);

                _isRefreshing = false;
                _refreshCompleter?.complete();

                // Retry original request
                e.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final response = await _dio.fetch(e.requestOptions);
                return handler.resolve(response);
              } else {
                _isRefreshing = false;
                _refreshCompleter?.completeError('Refresh failed');
                await _tokenStorage.clearTokens();
                return handler.next(e);
              }
            } catch (refreshError) {
              _isRefreshing = false;
              _refreshCompleter?.completeError(refreshError);
              await _tokenStorage.clearTokens();
              return handler.next(e);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw UnknownException(message: "استجابة الخادم غير صالحة");
      }
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data is Uint8List
          ? response.data
          : Uint8List.fromList(List<int>.from(response.data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
    bool isFormData = false,
  }) async {
    try {
      if (isFormData && data is Map) {
        print('====== FORM DATA FIELDS ======');
        data.forEach((k, v) {
          print('$k: ${v.runtimeType}');
          if (v is! MultipartFile) {
            print('Value: $v');
          }
        });
        print('==============================');
      }
      final response = await _dio.post(
        path,
        data: isFormData
            ? FormData.fromMap(data as Map<String, dynamic>)
            : data,
        queryParameters: queryParameters,
        options: isFormData
            ? Options(contentType: 'multipart/form-data')
            : null,
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        if (isFormData) {
          // FormData endpoints (like media send) may return non-standard responses
          return ApiResponse<T>(data: null, message: 'success', success: true);
        }
        throw UnknownException(message: "استجابة الخادم غير صالحة");
      }
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw UnknownException(message: "استجابة الخادم غير صالحة");
      }
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw UnknownException(message: "استجابة الخادم غير صالحة");
      }
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw UnknownException(message: "استجابة الخادم غير صالحة");
      }
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  Future<void> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (kIsWeb) {
        // Web: Fetch bytes and trigger browser download
        final response = await _dio.get(
          path,
          queryParameters: queryParameters,
          options: Options(responseType: ResponseType.bytes),
        );

        final fileName = savePath.split('/').last.isNotEmpty
            ? savePath.split('/').last
            : path
                  .split('/')
                  .lastWhere(
                    (element) => element.isNotEmpty,
                    orElse: () => 'download.pdf',
                  );

        DownloadService.download(
          bytes: response.data is Uint8List
              ? response.data
              : Uint8List.fromList(List<int>.from(response.data)),
          fileName: fileName,
          savePath: null, // Web doesn't use savePath
        );
      } else {
        // Mobile: Download to file directly (Efficient streaming)
        await _dio.download(path, savePath, queryParameters: queryParameters);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    final response = error.response;
    if (response != null) {
      switch (response.statusCode) {
        case 401:
          String? msg;
          if (response.data is Map<String, dynamic>) {
            msg = response.data['message'];
          }
          return UnauthorizedException(message: msg);
        case 404:
          return NotFoundException();
        case 422:
          final errors =
              (response.data['errors'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(
                  key,
                  (value as List).map((e) => e.toString()).toList(),
                ),
              ) ??
              {};

          String message = response.data['message'] ?? 'بيانات غير صالحة';

          // If we have specific field errors, summarize them to be useful to the user
          if (errors.isNotEmpty) {
            final allErrors = errors.values.expand((e) => e).toList();
            if (allErrors.isNotEmpty) {
              message = allErrors.join('\n');
            }
          }

          return ValidationException(errors: errors, message: message);
        case 500:
          return ServerException(
            message: response.data['message'] ?? 'حدث خطأ في الخادم',
          );
        default:
          return UnknownException(
            message: response.data['message'] ?? 'حدث خطأ غير متوقع',
            statusCode: response.statusCode,
          );
      }
    }

    return UnknownException(message: error.message ?? 'حدث خطأ غير معروف');
  }
}
