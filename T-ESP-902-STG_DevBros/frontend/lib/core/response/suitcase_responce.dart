import 'package:inspiria/core/model/suitcase_model.dart';

class SuitcaseResponce {

  factory SuitcaseResponce.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return SuitcaseResponce(
      statusCode: json['statusCode'] ?? 200,
      errorMessage: json['errorMessage'],

      suitcase: data['suitcase'] != null
          ? SuitcaseModel.fromJson(data['suitcase'])
          : null,

      warnings: data['warnings'],
      weather: data['weather'],
    );
  }

  SuitcaseResponce({
    required this.statusCode,
    this.suitcase,
    this.errorMessage,
    this.warnings,
    this.weather,
  });
  final int statusCode;
  final String? errorMessage;
  final SuitcaseModel? suitcase;
  final Map<String, dynamic>? warnings;
  final Map<String, dynamic>? weather;

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'errorMessage': errorMessage,
      'suitcase': suitcase?.toJson(),
      'warnings': warnings ?? {},
      'weather': weather ?? {},
    };
  }
}

class SuitcaseResponces {
  SuitcaseResponces({required this.statusCode, this.suitcaseList, this.errorMessage});

  final List<SuitcaseModel>? suitcaseList;
  final int statusCode;
  final String? errorMessage;
}