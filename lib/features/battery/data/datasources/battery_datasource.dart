import 'package:battery_plus/battery_plus.dart';

abstract class BatteryDataSource {
  Future<int> getBatteryLevel();
  Stream<BatteryState> getBatteryStateStream();
}

class BatteryDataSourceImpl implements BatteryDataSource {
  final Battery _battery;

  BatteryDataSourceImpl([Battery? battery]) : _battery = battery ?? Battery();

  @override
  Future<int> getBatteryLevel() => _battery.batteryLevel;

  @override
  Stream<BatteryState> getBatteryStateStream() => _battery.onBatteryStateChanged;
}