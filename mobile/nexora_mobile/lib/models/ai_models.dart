class AIResponseModel {
  final String answer;
  final String provider;
  final bool isAvailable;

  AIResponseModel({
    required this.answer,
    required this.provider,
    required this.isAvailable,
  });

  factory AIResponseModel.fromJson(Map<String, dynamic> json) {
    return AIResponseModel(
      answer: json['answer'] as String,
      provider: json['provider'] as String,
      isAvailable: json['isAvailable'] as bool,
    );
  }
}

class CoachResponseModel {
  final String suggestion;
  final String toneFeedback;
  final String provider;
  final bool isAvailable;

  CoachResponseModel({
    required this.suggestion,
    required this.toneFeedback,
    required this.provider,
    required this.isAvailable,
  });

  factory CoachResponseModel.fromJson(Map<String, dynamic> json) {
    return CoachResponseModel(
      suggestion: json['suggestion'] as String,
      toneFeedback: json['toneFeedback'] as String,
      provider: json['provider'] as String,
      isAvailable: json['isAvailable'] as bool,
    );
  }
}
