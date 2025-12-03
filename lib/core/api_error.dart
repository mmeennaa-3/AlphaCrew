class ApiError {
  // model ll status elly btrg3ly
  final String message;
  final int? statusCode;

  ApiError({required this.message, this.statusCode});

  @override
  String toString() {
    return message;
  }
}