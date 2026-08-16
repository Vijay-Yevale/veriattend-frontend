import 'package:veriattend_app/core/model/class_model.dart';

abstract class InformationRepository {
  Future<ClassModel> getClassDetail(String classId);
}
