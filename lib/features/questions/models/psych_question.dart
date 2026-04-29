class PsychQuestion {
  final int id;
  final int type;
  final bool isActive;
  final String question;
  final List<PsychOption> options;

  const PsychQuestion({
    required this.id,
    required this.type,
    required this.isActive,
    required this.question,
    required this.options,
  });

  factory PsychQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = <PsychOption>[];
    if (rawOptions is List) {
      options.addAll(
        rawOptions.whereType<Map>().map(
              (e) => PsychOption.fromJson(Map<String, dynamic>.from(e)),
            ),
      );
    }
    return PsychQuestion(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true,
      question: json['question']?.toString() ?? '',
      options: options,
    );
  }
}

class PsychOption {
  final int id;
  final int questionId;
  final int score;
  final String emoji;
  final String title;

  const PsychOption({
    required this.id,
    required this.questionId,
    required this.score,
    required this.emoji,
    required this.title,
  });

  factory PsychOption.fromJson(Map<String, dynamic> json) {
    return PsychOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      questionId: (json['question_id'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      emoji: '',
      title: json['option']?.toString() ?? '',
    );
  }
}

