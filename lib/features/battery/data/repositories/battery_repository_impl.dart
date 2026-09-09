import 'package:battery_plus/battery_plus.dart' as bp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/battery_info_entity.dart';
import '../../domain/repositories/battery_repository.dart';
import '../datasources/battery_datasource.dart';

final batteryDataSourceProvider = Provider<BatteryDataSource>((ref) {
  return BatteryDataSourceImpl();
});

class BatteryRepositoryImpl implements BatteryRepository {
  final BatteryDataSource _dataSource;

  BatteryRepositoryImpl(this._dataSource);

  BatteryChargingStatus _mapBatteryState(bp.BatteryState state) {
    switch (state) {
      case bp.BatteryState.charging:
        return BatteryChargingStatus.charging;
      case bp.BatteryState.discharging:
        return BatteryChargingStatus.discharging;
      case bp.BatteryState.full:
        return BatteryChargingStatus.full;
      case bp.BatteryState.unknown:
      default:
        return BatteryChargingStatus.unknown;
    }
  }

  @override
  Stream<BatteryInfoEntity> getBatteryStream() async* {
    // 1. Początkowa emisja aktualnego stanu
    final initialLevel = await _dataSource.getBatteryLevel();
    yield BatteryInfoEntity(
      level: initialLevel,
      status: BatteryChargingStatus.unknown,
    );

    // 2. Emisja kolejnych zmian stanu i ponowny odczyt poziomu
    await for (final state in _dataSource.getBatteryStateStream()) {
      final level = await _dataSource.getBatteryLevel();
      yield BatteryInfoEntity(
        level: level,
        status: _mapBatteryState(state),
      );
    }
  }
}

final batteryRepositoryProvider = Provider<BatteryRepository>((ref) {
  final dataSource = ref.watch(batteryDataSourceProvider);
  return BatteryRepositoryImpl(dataSource);
});