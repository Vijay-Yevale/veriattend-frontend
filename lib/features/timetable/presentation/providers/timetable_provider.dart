import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/providers/core_providers.dart';
import 'package:veriattend_app/features/timetable/data/timetable_remote_datasource.dart';
import 'package:veriattend_app/features/timetable/data/timetable_repository_impl.dart';
import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';
import 'package:veriattend_app/features/timetable/domain/timetable_repository.dart';

class ClassTimetableParams {
  final String? classId;
  final bool today;
  final String? day;

  const ClassTimetableParams({this.classId, this.today = false, this.day});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassTimetableParams &&
          runtimeType == other.runtimeType &&
          classId == other.classId &&
          today == other.today &&
          day == other.day;

  @override
  int get hashCode => Object.hash(classId, today, day);
}

class TeacherTimetableParams {
  final String? teacherId;
  final bool today;
  final String? day;

  const TeacherTimetableParams({this.teacherId, this.today = false, this.day});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherTimetableParams &&
          runtimeType == other.runtimeType &&
          teacherId == other.teacherId &&
          today == other.today &&
          day == other.day;

  @override
  int get hashCode => Object.hash(teacherId, today, day);
}

final timetableRemoteDataSourceProvider = Provider<TimetableRemoteDataSource>((
  ref,
) {
  final dioClient = ref.read(dioClientProvider);

  return TimetableRemoteDataSourceImpl(dioClient);
});

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  final remoteDataSource = ref.read(timetableRemoteDataSourceProvider);

  return TimetableRepositoryImpl(remoteDataSource);
});

final classTimetableProvider = FutureProvider.autoDispose
    .family<List<TimetableSlotModel>, ClassTimetableParams>((
      ref,
      params,
    ) async {
      final repository = ref.read(timetableRepositoryProvider);

      return repository.getClassTimetable(
        classId: params.classId,
        today: params.today,
        day: params.day,
      );
    });

final teacherTimetableProvider = FutureProvider.autoDispose
    .family<List<TimetableSlotModel>, TeacherTimetableParams>((
      ref,
      params,
    ) async {
      final repository = ref.read(timetableRepositoryProvider);

      return repository.getTeacherTimetable(
        teacherId: params.teacherId,
        today: params.today,
        day: params.day,
      );
    });

final activeTeacherSlotProvider =
    FutureProvider.autoDispose<TimetableSlotModel?>((ref) async {
      final repository = ref.read(timetableRepositoryProvider);

      return repository.getActiveTeacherSlot();
    });

final activeClassSlotProvider = FutureProvider.autoDispose
    .family<TimetableSlotModel?, String?>((ref, classId) async {
      final repository = ref.read(timetableRepositoryProvider);

      return repository.getActiveClassSlot(classId: classId);
    });
