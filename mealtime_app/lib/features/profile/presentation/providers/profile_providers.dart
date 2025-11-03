import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mealtime_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:mealtime_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mealtime_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mealtime_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/domain/usecases/get_profile.dart';
import 'package:mealtime_app/features/profile/domain/usecases/update_profile.dart';
import 'package:mealtime_app/features/profile/domain/usecases/upload_avatar.dart';
import 'package:mealtime_app/services/api/profile_api_service.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';

part 'profile_providers.g.dart';

// Repository Provider
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  final remoteDataSource = ProfileRemoteDataSourceImpl(
    apiService: ProfileApiService(
      sl<Dio>(instanceName: 'dioV2'),
    ),
    dio: sl<Dio>(instanceName: 'dioV2'),
  );
  final localDataSource = ProfileLocalDataSourceImpl(
    database: sl(),
  );
  return ProfileRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
}

// Use Cases Providers
@riverpod
GetProfile getProfile(GetProfileRef ref) {
  return GetProfile(ref.watch(profileRepositoryProvider));
}

@riverpod
UpdateProfile updateProfile(UpdateProfileRef ref) {
  return UpdateProfile(ref.watch(profileRepositoryProvider));
}

@riverpod
UploadAvatar uploadAvatar(UploadAvatarRef ref) {
  return UploadAvatar(ref.watch(profileRepositoryProvider));
}

// Profile State Provider
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<Profile?> build(String idOrUsername) async {
    final useCase = ref.watch(getProfileProvider);
    final result = await useCase(GetProfileParams(idOrUsername: idOrUsername));
    return result.fold(
      (failure) => null,
      (profile) => profile,
    );
  }

  /// Recarrega o perfil
  Future<void> refresh() async {
    // Retorna antecipadamente se state.value for null para evitar chamada à API sem ID
    if (state.value == null) return;
    
    final useCase = ref.read(getProfileProvider);
    final result = await useCase(GetProfileParams(idOrUsername: state.value!.id));
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  /// Atualiza o perfil
  Future<bool> updateProfile(Profile profile) async {
    if (state.value == null) return false;
    
    final useCase = ref.read(updateProfileProvider);
    final result = await useCase(UpdateProfileParams(
      idOrUsername: state.value!.id,
      profile: profile,
    ));
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
      (updatedProfile) {
        state = AsyncValue.data(updatedProfile);
        return true;
      },
    );
  }

  /// Faz upload de avatar
  Future<String?> uploadAvatar(String filePath) async {
    final useCase = ref.read(uploadAvatarProvider);
    final result = await useCase(UploadAvatarParams(filePath: filePath));
    
    return result.fold(
      (failure) => null,
      (url) {
        if (state.value != null) {
          state = AsyncValue.data(state.value!.copyWith(avatarUrl: url));
        }
        return url;
      },
    );
  }
}

// Helper provider para obter perfil do usuário atual
@riverpod
Future<Profile?> currentUserProfile(CurrentUserProfileRef ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return null;
  
  return ref.watch(profileNotifierProvider(user.id).future);
}

