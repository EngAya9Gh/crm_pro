import 'package:dio/dio.dart';

class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('================= API Request =================');
    print('URL: ${options.method} ${options.uri}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('Query Params: ${options.queryParameters}');
    }
    print('=============================================');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('================ API Response ================');
    print('URL: ${response.requestOptions.method} ${response.requestOptions.uri}');
    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
    print('=============================================');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('================= API Error ==================');
    print('URL: ${err.requestOptions.method} ${err.requestOptions.uri}');
    print('Status Code: ${err.response?.statusCode}');
    print('Error Message: ${err.message}');
    if (err.response?.data != null) {
      print('Response Data: ${err.response?.data}');
    }
    print('=============================================');
    super.onError(err, handler);
  }
}
