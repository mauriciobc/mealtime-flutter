// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryHash() => r'6a2df5c752bf47a7fc6b17c670a250985a701773';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider = Provider<ProfileRepository>.internal(
  profileRepository,
  name: r'profileRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProfileRepositoryRef = ProviderRef<ProfileRepository>;
String _$getProfileHash() => r'fb5cf4d016cbf544cbd339137f966035f3557c7c';

/// See also [getProfile].
@ProviderFor(getProfile)
final getProfileProvider = AutoDisposeProvider<GetProfile>.internal(
  getProfile,
  name: r'getProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetProfileRef = AutoDisposeProviderRef<GetProfile>;
String _$updateProfileHash() => r'50ce24b959928e53841d46d0605357b9c92368ec';

/// See also [updateProfile].
@ProviderFor(updateProfile)
final updateProfileProvider = AutoDisposeProvider<UpdateProfile>.internal(
  updateProfile,
  name: r'updateProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpdateProfileRef = AutoDisposeProviderRef<UpdateProfile>;
String _$uploadAvatarHash() => r'e5a7db0f41573bc7cbe8ef28770570629c92eaf5';

/// See also [uploadAvatar].
@ProviderFor(uploadAvatar)
final uploadAvatarProvider = AutoDisposeProvider<UploadAvatar>.internal(
  uploadAvatar,
  name: r'uploadAvatarProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$uploadAvatarHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UploadAvatarRef = AutoDisposeProviderRef<UploadAvatar>;
String _$currentUserProfileHash() =>
    r'2d12ac319afe5e71312ed7fb44a939e5b258c4a6';

/// See also [currentUserProfile].
@ProviderFor(currentUserProfile)
final currentUserProfileProvider = AutoDisposeFutureProvider<Profile?>.internal(
  currentUserProfile,
  name: r'currentUserProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserProfileRef = AutoDisposeFutureProviderRef<Profile?>;
String _$profileNotifierHash() => r'6b46a6ac1c0d6789b5965c673da449b3c63fde24';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ProfileNotifier
    extends BuildlessAutoDisposeAsyncNotifier<Profile?> {
  late final String idOrUsername;

  FutureOr<Profile?> build(
    String idOrUsername,
  );
}

/// See also [ProfileNotifier].
@ProviderFor(ProfileNotifier)
const profileNotifierProvider = ProfileNotifierFamily();

/// See also [ProfileNotifier].
class ProfileNotifierFamily extends Family<AsyncValue<Profile?>> {
  /// See also [ProfileNotifier].
  const ProfileNotifierFamily();

  /// See also [ProfileNotifier].
  ProfileNotifierProvider call(
    String idOrUsername,
  ) {
    return ProfileNotifierProvider(
      idOrUsername,
    );
  }

  @override
  ProfileNotifierProvider getProviderOverride(
    covariant ProfileNotifierProvider provider,
  ) {
    return call(
      provider.idOrUsername,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileNotifierProvider';
}

/// See also [ProfileNotifier].
class ProfileNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ProfileNotifier, Profile?> {
  /// See also [ProfileNotifier].
  ProfileNotifierProvider(
    String idOrUsername,
  ) : this._internal(
          () => ProfileNotifier()..idOrUsername = idOrUsername,
          from: profileNotifierProvider,
          name: r'profileNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileNotifierHash,
          dependencies: ProfileNotifierFamily._dependencies,
          allTransitiveDependencies:
              ProfileNotifierFamily._allTransitiveDependencies,
          idOrUsername: idOrUsername,
        );

  ProfileNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.idOrUsername,
  }) : super.internal();

  final String idOrUsername;

  @override
  FutureOr<Profile?> runNotifierBuild(
    covariant ProfileNotifier notifier,
  ) {
    return notifier.build(
      idOrUsername,
    );
  }

  @override
  Override overrideWith(ProfileNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProfileNotifierProvider._internal(
        () => create()..idOrUsername = idOrUsername,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        idOrUsername: idOrUsername,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProfileNotifier, Profile?>
      createElement() {
    return _ProfileNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileNotifierProvider &&
        other.idOrUsername == idOrUsername;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, idOrUsername.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProfileNotifierRef on AutoDisposeAsyncNotifierProviderRef<Profile?> {
  /// The parameter `idOrUsername` of this provider.
  String get idOrUsername;
}

class _ProfileNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProfileNotifier, Profile?>
    with ProfileNotifierRef {
  _ProfileNotifierProviderElement(super.provider);

  @override
  String get idOrUsername => (origin as ProfileNotifierProvider).idOrUsername;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
