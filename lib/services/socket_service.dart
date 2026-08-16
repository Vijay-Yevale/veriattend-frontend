import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/storage/secure_storage.dart';

class SocketService {
  final SecureStorage _secureStorage;

  io.Socket? _socket;

  SocketService(this._secureStorage);

  io.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket?.connected ?? false) {
      return;
    }

    final token = await _secureStorage.getToken();

    if (token == null) {
      throw StateError('Authentication token not found.');
    }

    final socketUrl = ApiConstants.baseUrl.replaceAll('/api', '');

    final completer = Completer<void>();

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket!.onConnectError((error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });

    _socket!.onError((error) {});

    _socket!.onDisconnect((reason) {});

    _socket!.connect();

    return completer.future;
  }

  Future<void> joinSession(String sessionId) async {
    if (_socket == null || !_socket!.connected) {
      throw StateError('Socket is not connected.');
    }

    final completer = Completer<void>();

    _socket!.off('JOIN_SUCCESS');
    _socket!.off('JOIN_DENIED');

    _socket!.on('JOIN_SUCCESS', (data) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket!.on('JOIN_DENIED', (data) {
      if (!completer.isCompleted) {
        completer.completeError(
          data is Map && data['message'] != null
              ? data['message']
              : 'Unable to join session.',
        );
      }
    });

    _socket!.emit('join-session', sessionId);

    return completer.future;
  }

  void onQrUpdated(void Function(Map<String, dynamic>) listener) {
    _socket?.off('QR_UPDATED');

    _socket?.on('QR_UPDATED', (data) {
      listener(Map<String, dynamic>.from(data));
    });
  }

  void onStudentMarked(void Function(Map<String, dynamic>) listener) {
    _socket?.off('STUDENT_MARKED');

    _socket?.on('STUDENT_MARKED', (data) {
      listener(Map<String, dynamic>.from(data));
    });
  }

  void onAttendanceUpdated(void Function(Map<String, dynamic>) listener) {
    _socket?.off('ATTENDANCE_UPDATED');

    _socket?.on('ATTENDANCE_UPDATED', (data) {
      listener(Map<String, dynamic>.from(data));
    });
  }

  void onSessionEnded(void Function(Map<String, dynamic>) listener) {
    _socket?.off('SESSION_ENDED');

    _socket?.on('SESSION_ENDED', (data) {
      listener(Map<String, dynamic>.from(data));
    });
  }

  void clearSessionListeners() {
    _socket?.off('QR_UPDATED');
    _socket?.off('STUDENT_MARKED');
    _socket?.off('ATTENDANCE_UPDATED');
    _socket?.off('SESSION_ENDED');
  }

  void leaveSession(String sessionId) {
    if (_socket == null || !_socket!.connected) {
      return;
    }

    clearSessionListeners();

    _socket!.emit('leave-session', sessionId);
  }

  void disconnect() {
    clearSessionListeners();

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
  }
}
