import 'package:veriattend_app/core/constants/api_constants.dart';

enum AssessmentType {
  quiz('quiz', 'Quiz', ApiConstants.quizMax),
  assignment('assignment', 'Assignment', ApiConstants.assignmentMax),
  internal('internal', 'Internal', ApiConstants.internalMax);

  final String value;
  final String label;
  final double maxMarks;

  const AssessmentType(this.value, this.label, this.maxMarks);
}
