enum ButtonType { primary, secondary, outlined, text }

enum QuestionType {
  shortText,
  longText,
  singleChoice,
  multiChoice,
  slider,
  number,
  decimal,
  email,
  phone,
}

extension QuestionTypeExtension on QuestionType {
  String get dbValue {
    switch (this) {
      case QuestionType.multiChoice:
        return 'multiple_choice';
      case QuestionType.singleChoice:
        return 'single_choice';
      case QuestionType.shortText:
        return 'short';
      case QuestionType.longText:
        return 'long';
      case QuestionType.slider:
        return 'slider';
      case QuestionType.decimal:
        return 'decimal';
      case QuestionType.number:
        return 'number';
      case QuestionType.email:
        return 'email';
      case QuestionType.phone:
        return 'phone';
    }
  }

  static QuestionType fromDb(String value) {
    switch (value) {
      case 'multiple_choice':
        return QuestionType.multiChoice;
      case 'single_choice':
        return QuestionType.singleChoice;
      case 'short':
        return QuestionType.shortText;
      case 'long':
        return QuestionType.longText;
      case 'slider':
        return QuestionType.slider;
      case 'decimal':
        return QuestionType.decimal;
      case 'number':
        return QuestionType.number;
      case 'email':
        return QuestionType.email;
      case 'phone':
        return QuestionType.phone;
      default:
        throw Exception('Unknown QuestionType: $value');
    }
  }

  static bool isText(QuestionType type) {
    return [
      QuestionType.shortText,
      QuestionType.longText,
      QuestionType.email,
      QuestionType.phone,
      QuestionType.number,
      QuestionType.decimal,
    ].contains(type);
  }
}

enum ShortTextInputType { text, number, decimal, email, phone }
