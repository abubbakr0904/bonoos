class PsychQuestion {
  final String question;
  final List<PsychOption> options;

  const PsychQuestion({
    required this.question,
    required this.options,
  });
}

class PsychOption {
  final String emoji;
  final String title;

  const PsychOption({
    required this.emoji,
    required this.title,
  });
}

