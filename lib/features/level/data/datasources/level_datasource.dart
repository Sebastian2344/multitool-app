import 'package:sensors_plus/sensors_plus.dart';

abstract class LevelDataSource {
  Stream<AccelerometerEvent> getAccelerometerStream();
}

class LevelDataSourceImpl implements LevelDataSource {
  @override
  Stream<AccelerometerEvent> getAccelerometerStream() {
    return accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval);
  }
}