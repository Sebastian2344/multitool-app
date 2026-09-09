import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location_data_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_datasource.dart';

final locationDataSourceProvider = Provider<LocationDataSource>((ref) {
  return LocationDataSourceImpl();
});

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource _dataSource;

  LocationRepositoryImpl(this._dataSource);

  LocationDataEntity _toEntity(Position pos, String? address, {bool isLive = false}) {
    return LocationDataEntity(
      latitude: pos.latitude,
      longitude: pos.longitude,
      altitude: pos.altitude,
      speed: pos.speed,
      heading: pos.heading,
      accuracy: pos.accuracy,
      address: address,
      isLive: isLive,
    );
  }

  @override
  Future<LocationDataEntity> getCurrentLocation() async {
    final pos = await _dataSource.getCurrentPosition();
    final address = await _dataSource.getAddressFromCoordinates(pos.latitude, pos.longitude);
    return _toEntity(pos, address, isLive: false);
  }

  @override
  Stream<LocationDataEntity> getLiveLocationStream() {
    return _dataSource.getPositionStream().asyncMap((pos) async {
      final address = await _dataSource.getAddressFromCoordinates(pos.latitude, pos.longitude);
      return _toEntity(pos, address, isLive: true);
    });
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final dataSource = ref.watch(locationDataSourceProvider);
  return LocationRepositoryImpl(dataSource);
});