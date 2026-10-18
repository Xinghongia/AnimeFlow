import 'package:anime_flow/features/anime_info/data/repositories/anime_info_repository.dart';
import 'package:anime_flow/features/user/application/collection_revision_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animeInfoRepositoryProvider = Provider<AnimeInfoRepository>((ref) {
  final repository = AnimeInfoRepository();
  ref.listen(
      collectionRevisionProvider, (_, __) => repository.invalidateCache());
  return repository;
});
