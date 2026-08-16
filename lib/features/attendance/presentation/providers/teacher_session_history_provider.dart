import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/teacher_session_history_model.dart';
import 'attendance_provider.dart';

final teacherSessionHistoryProvider = FutureProvider.autoDispose
    .family<List<TeacherSessionHistoryModel>, bool>((ref, todayOnly) async {
      return ref
          .read(attendanceRepositoryProvider)
          .getTeacherSessions(todayOnly: todayOnly);
    });
