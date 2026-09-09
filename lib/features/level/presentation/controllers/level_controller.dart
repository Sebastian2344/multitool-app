import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multitool/features/level/data/reopsitories/level_repository_impl.dart';
import '../../domain/entities/level_entity.dart';

/// Strumień poziomicowy z automatycznym sprzątaniem (autoDispose)
final levelControllerProvider = StreamProvider.autoDispose<LevelEntity>((ref) {
  final repository = ref.watch(levelRepositoryProvider);
  return repository.getLevelStream();
});