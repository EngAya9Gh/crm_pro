class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends ApiException {
  ServerException({
    super.message = 'حدث خطأ في الخادم',
    super.statusCode = 500,
  });
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    String? message,
  }) : super(
          message: message ?? 'تم انتهاء الجلسة، يرجى تسجيل الدخول مجدداً',
          statusCode: 401,
        );
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;

  ValidationException({
    required this.errors,
    super.message = 'بيانات غير صالحة',
    super.statusCode = 422,
  });
}

class NotFoundException extends ApiException {
  NotFoundException({
    super.message = 'المورد غير موجود',
    super.statusCode = 404,
  });
}

class NetworkException extends ApiException {
  NetworkException({
    super.message = 'لا يوجد اتصال بالإنترنت',
    super.statusCode,
  });
}

class UnknownException extends ApiException {
  UnknownException({super.message = 'حدث خطأ غير متوقع', super.statusCode});
}
