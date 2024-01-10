abstract class Response<T> {
  Response({
    required this.data,
    required this.total,
    this.error,
  });

  final List<T> data;
  final int total;
  final ResponseError? error;
}

class ResponseError {
  ResponseError({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;
}