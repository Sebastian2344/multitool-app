import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multitool/features/flashlight/data/datasources/flashlight_datasource.dart';
import 'package:multitool/features/flashlight/domain/repositories/flashlight_repository.dart';


final flashlightDataSourceProvider = Provider<FlashlightDataSource>((ref) {
  return FlashlightDataSourceImpl();
});


class FlashlightRepositoryImpl implements FlashlightRepository {
  final FlashlightDataSource _dataSource;

  FlashlightRepositoryImpl(this._dataSource);

  @override
  Future<void> turnOn() => _dataSource.enableTorch();

  @override
  Future<void> turnOff() => _dataSource.disableTorch();
}

final flashlightRepositoryProvider = Provider<FlashlightRepository>((ref) {
  final dataSource = ref.watch(flashlightDataSourceProvider);
  return FlashlightRepositoryImpl(dataSource);
});