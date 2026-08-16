import 'subject_detail_model.dart';

class StudentSubjectDetailModel {
  final String studentId;
  final String userName;
  final String prn;

  final SubjectDetailModel subject;

  const StudentSubjectDetailModel({
    required this.studentId,
    required this.userName,
    required this.prn,
    required this.subject,
  });

  factory StudentSubjectDetailModel.fromJson(Map<String, dynamic> json) {
    return StudentSubjectDetailModel(
      studentId: json['studentId'] as String,
      userName: json['userName'] as String,
      prn: json['PRN'] as String,

      subject: SubjectDetailModel.fromJson(
        json['subject'] as Map<String, dynamic>,
      ),
    );
  }
}
