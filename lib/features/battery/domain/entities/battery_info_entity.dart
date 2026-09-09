enum BatteryChargingStatus {
  charging,
  discharging,
  full,
  unknown;
}

class BatteryInfoEntity {
  final int level;
  final BatteryChargingStatus status;

  const BatteryInfoEntity({
    required this.level,
    required this.status,
  });

  bool get isCharging => status == BatteryChargingStatus.charging;
}