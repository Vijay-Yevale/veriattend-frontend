class MarkEntryModel {
  final String studentId;
  final num mark;

  const MarkEntryModel({required this.studentId, required this.mark});

  Map<String, dynamic> toJson() => {'studentId': studentId, 'mark': mark};
}
