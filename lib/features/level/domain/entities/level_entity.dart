class LevelEntity {
  final double x;
  final double y;
  final double z;
  final double roll;  // Przechylenie lewo/prawo w stopniach
  final double pitch; // Przechylenie góra/dół w stopniach

  const LevelEntity({
    required this.x,
    required this.y,
    required this.z,
    required this.roll,
    required this.pitch,
  });

  /// Reguła biznesowa: wypoziomowano przy odchyleniu mniejszym niż 1 stopień
  bool get isLevel => roll.abs() < 1.0 && pitch.abs() < 1.0;
}