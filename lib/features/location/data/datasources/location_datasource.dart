import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationDataSource {
  Future<Position> getCurrentPosition();
  Stream<Position> getPositionStream();
  Future<String?> getAddressFromCoordinates(double lat, double lng);
}

class LocationDataSourceImpl implements LocationDataSource {
  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('GPS jest wyłączony.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('Brak uprawnień do GPS.');
    }
  }

  @override
  Future<Position> getCurrentPosition() async {
    await _checkPermission();
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  @override
  Stream<Position> getPositionStream() async* {
    await _checkPermission();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
    );
  }

  @override
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    final Geocoding geocoding = Geocoding();
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return [p.street, p.locality, p.country].where((s) => s != null && s.isNotEmpty).join(', ');
      }
    } catch (_) {}
    return null;
  }
}