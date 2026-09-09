class LocationDataEntity {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double heading;
  final double accuracy;
  final String? address;
  final bool isLive;

  const LocationDataEntity({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.accuracy,
    this.address,
    this.isLive = false,
  });

  double get speedKmH => (speed * 3.6 < 0.5) ? 0.0 : speed * 3.6;
  String get mapsUrl => 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
}