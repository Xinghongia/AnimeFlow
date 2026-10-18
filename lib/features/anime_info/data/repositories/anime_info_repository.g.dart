// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_info_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(animeInfoRepository)
final animeInfoRepositoryProvider = AnimeInfoRepositoryProvider._();

final class AnimeInfoRepositoryProvider extends $FunctionalProvider<
    AnimeInfoRepository,
    AnimeInfoRepository,
    AnimeInfoRepository> with $Provider<AnimeInfoRepository> {
  AnimeInfoRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'animeInfoRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$animeInfoRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnimeInfoRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnimeInfoRepository create(Ref ref) {
    return animeInfoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimeInfoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimeInfoRepository>(value),
    );
  }
}

String _$animeInfoRepositoryHash() =>
    r'1c9a159906f833bde9136fec8d9d535be119c697';
