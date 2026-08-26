/// What `submit_survey()` hands back: the response it created, the reward it
/// credited, and the balance after crediting it.
///
/// The balance comes from the database rather than being computed on the client,
/// so the outro screen can show the real number instead of a promise.
class SurveySubmission {
  final String responseId;
  final int reward;
  final int pointsBalance;

  const SurveySubmission({
    required this.responseId,
    required this.reward,
    required this.pointsBalance,
  });

  factory SurveySubmission.fromJson(Map<String, dynamic> json) {
    return SurveySubmission(
      responseId: json['response_id'].toString(),
      reward: (json['reward'] as num?)?.toInt() ?? 0,
      pointsBalance: (json['points_balance'] as num?)?.toInt() ?? 0,
    );
  }
}
