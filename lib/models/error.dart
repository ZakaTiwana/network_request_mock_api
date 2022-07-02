class Error implements Exception {
  final int statusCode;
  final String message;
  const Error(this.statusCode, this.message);

  @override
  String toString() {
    return '$statusCode : $message';
  }

  Map<String, dynamic> toMap() {
    return {
      'statusCode': statusCode,
      'message': message,
    };
  }
}
