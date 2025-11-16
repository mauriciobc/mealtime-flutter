// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cats_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catsRepository)
const catsRepositoryProvider = CatsRepositoryProvider._();

final class CatsRepositoryProvider
    extends $FunctionalProvider<CatsRepository, CatsRepository, CatsRepository>
    with $Provider<CatsRepository> {
  const CatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CatsRepository create(Ref ref) {
    return catsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatsRepository>(value),
    );
  }
}

String _$catsRepositoryHash() => r'3f59cb7eef7bb09ec84b8d031a85885a41212394';
