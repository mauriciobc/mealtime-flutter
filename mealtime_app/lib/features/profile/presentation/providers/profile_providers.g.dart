// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
const profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  const ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'fa0c9d19afd8f78367bf6510b6da5f4118540029';

@ProviderFor(getProfile)
const getProfileProvider = GetProfileProvider._();

final class GetProfileProvider
    extends $FunctionalProvider<GetProfile, GetProfile, GetProfile>
    with $Provider<GetProfile> {
  const GetProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProfileHash();

  @$internal
  @override
  $ProviderElement<GetProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetProfile create(Ref ref) {
    return getProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProfile>(value),
    );
  }
}

String _$getProfileHash() => r'8eb5dd6c6b2b13ada8b2ef6c206f3b5ebc516284';

@ProviderFor(updateProfile)
const updateProfileProvider = UpdateProfileProvider._();

final class UpdateProfileProvider
    extends $FunctionalProvider<UpdateProfile, UpdateProfile, UpdateProfile>
    with $Provider<UpdateProfile> {
  const UpdateProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProfileHash();

  @$internal
  @override
  $ProviderElement<UpdateProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateProfile create(Ref ref) {
    return updateProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProfile>(value),
    );
  }
}

String _$updateProfileHash() => r'f433f7ea2d18112fdb3d66e3e78968c967ba775b';

@ProviderFor(uploadAvatar)
const uploadAvatarProvider = UploadAvatarProvider._();

final class UploadAvatarProvider
    extends $FunctionalProvider<UploadAvatar, UploadAvatar, UploadAvatar>
    with $Provider<UploadAvatar> {
  const UploadAvatarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadAvatarProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadAvatarHash();

  @$internal
  @override
  $ProviderElement<UploadAvatar> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UploadAvatar create(Ref ref) {
    return uploadAvatar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UploadAvatar value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UploadAvatar>(value),
    );
  }
}

String _$uploadAvatarHash() => r'9d326a52215845bd6e6fb41ed9f19c92b0331fca';

@ProviderFor(ProfileNotifier)
const profileProvider = ProfileNotifierFamily._();

final class ProfileNotifierProvider
    extends $AsyncNotifierProvider<ProfileNotifier, Profile?> {
  const ProfileNotifierProvider._({
    required ProfileNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileNotifierHash();

  @override
  String toString() {
    return r'profileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileNotifier create() => ProfileNotifier();

  @override
  bool operator ==(Object other) {
    return other is ProfileNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileNotifierHash() => r'afe7d8d844aa47178d8d8f396306c66fe13be044';

final class ProfileNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileNotifier,
          AsyncValue<Profile?>,
          Profile?,
          FutureOr<Profile?>,
          String
        > {
  const ProfileNotifierFamily._()
    : super(
        retry: null,
        name: r'profileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileNotifierProvider call(String idOrUsername) =>
      ProfileNotifierProvider._(argument: idOrUsername, from: this);

  @override
  String toString() => r'profileProvider';
}

abstract class _$ProfileNotifier extends $AsyncNotifier<Profile?> {
  late final _$args = ref.$arg as String;
  String get idOrUsername => _$args;

  FutureOr<Profile?> build(String idOrUsername);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<Profile?>, Profile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile?>, Profile?>,
              AsyncValue<Profile?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(currentUserProfile)
const currentUserProfileProvider = CurrentUserProfileProvider._();

final class CurrentUserProfileProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, FutureOr<Profile?>>
    with $FutureModifier<Profile?>, $FutureProvider<Profile?> {
  const CurrentUserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile?> create(Ref ref) {
    return currentUserProfile(ref);
  }
}

String _$currentUserProfileHash() =>
    r'c4557e036b85176cc1c9b3ff5f9616147d8b23f5';
