import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/profile/domain/usecases/get_profile.dart';
import 'package:mealtime_app/features/profile/domain/usecases/update_profile.dart';
import 'package:mealtime_app/features/profile/domain/usecases/upload_avatar.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:mealtime_app/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final UploadAvatar uploadAvatar;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.uploadAvatar,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadAvatarEvent>(_onUploadAvatar);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getProfile(GetProfileParams(idOrUsername: event.idOrUsername));

    result.fold(
      (failure) => emit(ProfileError(_mapFailureToMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    Profile? currentProfile;
    if (currentState is ProfileLoaded) {
      currentProfile = currentState.profile;
    } else if (currentState is ProfileOperationSuccess) {
      currentProfile = currentState.profile;
    }

    emit(ProfileOperationInProgress(currentProfile));

    final result = await updateProfile(UpdateProfileParams(
      idOrUsername: event.profile.id,
      profile: event.profile,
    ));

    result.fold(
      (failure) {
        if (currentProfile != null) {
          emit(ProfileError(_mapFailureToMessage(failure)));
        } else {
           emit(ProfileError(_mapFailureToMessage(failure)));
        }
      },
      (updatedProfile) => emit(
        ProfileOperationSuccess(updatedProfile, 'Perfil atualizado com sucesso!'),
      ),
    );
    
    // Após sucesso, volta para loaded? Ou mantem success e a UI reage?
    // Geralmente a UI consome o Success, mostra snackbar, e o Bloc volta para Loaded.
    // Mas vamos manter Success e se a UI precisar, ela dispara novo Load ou apenas exibe.
    // Se o user navegar, o state mantem.
    // Se quiser resetar msg, pode disparar evento.
  }

  Future<void> _onUploadAvatar(
    UploadAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    Profile? currentProfile;
    if (currentState is ProfileLoaded) {
      currentProfile = currentState.profile;
    } else if (currentState is ProfileOperationSuccess) {
      currentProfile = currentState.profile;
    }

    emit(ProfileOperationInProgress(currentProfile));

    final result = await uploadAvatar(UploadAvatarParams(
      idOrUsername: event.idOrUsername,
      filePath: event.filePath,
    ));

    result.fold(
      (failure) => emit(ProfileError(_mapFailureToMessage(failure))),
      (url) {
        if (currentProfile != null) {
          final updatedProfile = currentProfile.copyWith(avatarUrl: url);
          emit(ProfileOperationSuccess(
            updatedProfile, 
            'Avatar atualizado com sucesso!'
          ));
        } else {
          // Se nao tinha profile (estranho para upload), dispara load
          add(LoadProfile(event.idOrUsername));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Erro de cache ao acessar dados';
    } else if (failure is NetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    return 'Erro inesperado';
  }
}
