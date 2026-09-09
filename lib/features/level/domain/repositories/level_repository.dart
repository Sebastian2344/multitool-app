import '../entities/level_entity.dart';

abstract class LevelRepository {
  Stream<LevelEntity> getLevelStream();
}