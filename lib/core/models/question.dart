import 'package:surveys/core/constants/enums.dart';
import 'package:surveys/core/models/option.dart';

class Question {
  final String id;
  final String title;
  final String? description;
  final QuestionType type;
  final List<Option>? options;
  final double? min;
  final double? max;
  final int? divisions;
  final int? maxLength;
  final bool allowOtherText;

  Question({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.options,
    this.min,
    this.max,
    this.divisions,
    this.maxLength,
    this.allowOtherText = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      title: json['title'] as String,
      description: json['description'] as String?,
      type: QuestionTypeExtension.fromDb(json['type']),
      min: json['min']?.toDouble(),
      max: json['max']?.toDouble(),
      divisions: json['divisions'] as int?,
      maxLength: json['max_length'] as int?,
      allowOtherText: json['allow_other_text'] ?? false,
      options: json['options'] != null
          ? List<Option>.from(json['options'].map((x) => Option.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.dbValue,
    'min': min,
    'max': max,
    'divisions': divisions,
    'max_length': maxLength,
    'allow_other_text': allowOtherText,
    'options': options?.map((option) => option.toMap()).toList(),
  };
}
