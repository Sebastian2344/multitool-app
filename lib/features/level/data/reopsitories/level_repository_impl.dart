import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/level_entity.dart';
import '../../domain/repositories/level_repository.dart';
import '../datasources/level_datasource.dart';

final levelDataSourceProvider = Provider<LevelDataSource>((ref) {
  return LevelDataSourceImpl();
});

class LevelRepositoryImpl implements LevelRepository {
  final LevelDataSource _dataSource;

  LevelRepositoryImpl(this._dataSource);

  @override
  Stream<LevelEntity> getLevelStream() {
    return _dataSource.getAccelerometerStream().map((event) {
      final roll = math.atan2(-event.x, math.sqrt(event.y * event.y + event.z * event.z)) * (180 / math.pi);
      final pitch = math.atan2(event.y, math.sqrt(event.x * event.x + event.z * event.z)) * (180 / math.pi);

      return LevelEntity(
        x: event.x,
        y: event.y,
        z: event.z,
        roll: roll,
        pitch: pitch,
      );
    });
  }
}

final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  final dataSource = ref.watch(levelDataSourceProvider);
  return LevelRepositoryImpl(dataSource);
});