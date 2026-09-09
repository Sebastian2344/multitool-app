import '../entities/location_data_entity.dart';

abstract class LocationRepository {
  Future<LocationDataEntity> getCurrentLocation();
  Stream<LocationDataEntity> getLiveLocationStream();
}