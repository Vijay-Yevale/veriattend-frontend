import 'model/timetable_slot_model.dart';

abstract class TimetableRepository {
  Future<List<TimetableSlotModel>> getClassTimetable({
    String? classId,
    bool today = false,
    String? day,
  });

  Future<List<TimetableSlotModel>> getTeacherTimetable({
    String? teacherId,
    bool today = false,
    String? day,
  });

  Future<TimetableSlotModel?> getActiveTeacherSlot();

  Future<TimetableSlotModel?> getActiveClassSlot({String? classId});

  Future<TimetableSlotModel> createTimetableSlot({
    required String teacherId,
    required String subjectId,
    required String classId,
    required String room,
    required String weekDay,
    required String startTime,
    required String endTime,
  });

  Future<TimetableSlotModel> updateTimetableSlot({
    required String timetableId,
    required Map<String, dynamic> updates,
  });

  Future<void> deleteTimetableSlot({required String timetableId});
}
