class TencentResponce {

  factory TencentResponce.fromJson(Map<String, dynamic> json) {
    return TencentResponce(
      message: json['message'] ?? 'Unknown status',
      modelPath: json['data'], 
      error: json['error'],
    );
  }

  TencentResponce({
    required this.message,
    this.modelPath,
    this.error,
  });
  final String message;
  final String? modelPath;
  final String? error;
}