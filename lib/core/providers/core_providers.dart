import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:veriattend_app/services/device_id_service.dart';
import 'package:veriattend_app/services/location_service.dart';
import 'package:veriattend_app/services/socket_service.dart';
import '../storage/secure_storage.dart';
import '../network/dio_client.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.read(secureStorageProvider);

  return DioClient(
    secureStorage,
    onUnauthorized: () async {
      ref.read(authProvider.notifier).forceLogout();
    },
  );
});

final deviceIdServiceProvider = Provider<DeviceIdService>((ref) {
  return DeviceIdService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final socketServiceProvider = Provider<SocketService>((ref) {
  final secureStorage = ref.read(secureStorageProvider);

  return SocketService(secureStorage);
});
