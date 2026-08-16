// lib/features/face/presentation/providers/face_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/model/face_profile_model.dart';
import 'package:veriattend_app/core/providers/core_providers.dart';

import '../../data/face_remote_datasource.dart';
import '../../data/face_repository_impl.dart';
import '../../domain/face_repository.dart';

final faceRemoteDataSourceProvider = Provider<FaceRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return FaceRemoteDataSourceImpl(dioClient);
});

final faceRepositoryProvider = Provider<FaceRepository>((ref) {
  final remoteDataSource = ref.read(faceRemoteDataSourceProvider);
  return FaceRepositoryImpl(remoteDataSource);
});

final faceProfileProvider = FutureProvider<FaceProfileModel?>((ref) async {
  final repository = ref.read(faceRepositoryProvider);
  return repository.getFaceProfile();
});

final faceRegisteredProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(faceRepositoryProvider);
  return repository.checkFaceRegistration();
});
