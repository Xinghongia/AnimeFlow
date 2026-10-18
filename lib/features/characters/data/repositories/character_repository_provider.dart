import 'package:anime_flow/features/characters/data/repositories/character_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final characterRepositoryProvider = Provider((ref) => CharacterRepository());
