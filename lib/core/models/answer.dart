class Answer {
  final String questionId;

  // Different possible values
  String? textAnswer;
  List<String>? selectedOptionIds;
  double? sliderValue;
  bool? yesNoAnswer;

  // Optional explanation
  String? extraText;

  Answer({
    required this.questionId,
    this.textAnswer,
    this.selectedOptionIds,
    this.sliderValue,
    this.yesNoAnswer,
    this.extraText,
  });
}
