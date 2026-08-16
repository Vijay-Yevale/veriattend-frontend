import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/model/attendance_active_session_model.dart';
import 'attendance_provider.dart';

final studentActiveSessionProvider =
    FutureProvider.autoDispose<AttendanceActiveSessionModel?>((ref) async {
      final authState = ref.read(authProvider);

      if (authState is! AuthAuthenticated) {
        throw Exception('User not authenticated');
      }

      final classInfo = authState.user.classInfo;

      if (classInfo == null) {
        throw Exception('Student is not assigned to any class.');
      }

      return ref
          .read(attendanceRepositoryProvider)
          .getActiveSession(classId: classInfo.id);
    });
