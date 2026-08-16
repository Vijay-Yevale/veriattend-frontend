import 'model/teacher_class_summary_model.dart';

abstract class TeacherRepository {
  Future<List<TeacherClassSummaryModel>> getMyClasses();
}
