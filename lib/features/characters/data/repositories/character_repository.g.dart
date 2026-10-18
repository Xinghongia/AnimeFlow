// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(characterRepository)
final characterRepositoryProvider = CharacterRepositoryProvider._();

final class CharacterRepositoryProvider extends $FunctionalProvider<
    CharacterRepository,
    CharacterRepository,
    CharacterRepository> with $Provider<CharacterRepository> {
  CharacterRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'characterRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$characterRepositoryHash();

  @$internal
  @override
  $ProviderElement<CharacterRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CharacterRepository create(Ref ref) {
    return characterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CharacterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CharacterRepository>(value),
    );
  }
}

String _$characterRepositoryHash() =>
    r'6b1ecfb8ee732f89dad5601322862134b3a6c5bd';
