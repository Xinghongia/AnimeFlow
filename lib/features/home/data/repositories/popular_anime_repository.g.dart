// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popular_anime_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(popularAnimeRepository)
final popularAnimeRepositoryProvider = PopularAnimeRepositoryProvider._();

final class PopularAnimeRepositoryProvider extends $FunctionalProvider<
    PopularAnimeRepository,
    PopularAnimeRepository,
    PopularAnimeRepository> with $Provider<PopularAnimeRepository> {
  PopularAnimeRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'popularAnimeRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$popularAnimeRepositoryHash();

  @$internal
  @override
  $ProviderElement<PopularAnimeRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PopularAnimeRepository create(Ref ref) {
    return popularAnimeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PopularAnimeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PopularAnimeRepository>(value),
    );
  }
}

String _$popularAnimeRepositoryHash() =>
    r'6f2bcb4816f1d98cbf1d2ba85a828236a4538156';
