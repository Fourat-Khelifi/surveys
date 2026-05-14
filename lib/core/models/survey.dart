import 'package:surveys/core/models/question.dart';

class Survey {
  final String id;
  final String title;
  final String description;
  final int length;
  final List<Question>? questions;
  final int duration;
  final int reward;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.length,
    this.questions = const [],
    required this.duration,
    required this.reward,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      length: json['length'] as int,
      duration: json['duration'] as int,
      reward: json['reward'] as int,
      questions: json['questions'] != null
          ? List<Question>.from(
              json['questions'].map((x) => Question.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'length': length,
      'duration': duration,
      'reward': reward,
      'questions': questions?.map((q) => q.toMap()).toList(),
    };
  }
}
