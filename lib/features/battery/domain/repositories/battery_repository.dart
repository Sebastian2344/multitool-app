import '../entities/battery_info_entity.dart';

abstract class BatteryRepository {
  Stream<BatteryInfoEntity> getBatteryStream();
}