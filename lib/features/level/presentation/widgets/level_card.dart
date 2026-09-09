import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/level_controller.dart';

class LevelCard extends ConsumerWidget {
  const LevelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelAsync = ref.watch(levelControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: levelAsync.when(
          loading: () => const Center(
            child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
          ),
          error: (err, _) => Center(child: Text('Błąd czujnika: $err')),
          data: (level) {
            final isLevel = level.isLevel;
            final primaryColor = isLevel ? const Color(0xFF4ADE80) : const Color(0xFF38BDF8);

            const maxRadius = 52.0;
            final offsetX = (level.roll / 15.0).clamp(-1.0, 1.0) * maxRadius;
            final offsetY = (-level.pitch / 15.0).clamp(-1.0, 1.0) * maxRadius;

            return Column(
              children: [
                // Nagłówek z badge'em statusu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha:0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.screen_rotation, size: 22, color: primaryColor),
                        ),
                        const SizedBox(width: 12),
                        const Text('Poziomica 2D', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isLevel ? primaryColor.withValues(alpha:0.15) : Colors.white.withValues(alpha:0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLevel ? primaryColor : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLevel ? Icons.check_circle : Icons.adjust,
                            size: 14,
                            color: isLevel ? primaryColor : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLevel ? 'POZIOM (0°)' : 'KALIBRACJA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isLevel ? primaryColor : Colors.grey,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tarcza przyrządu
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F141C),
                      border: Border.all(
                        color: isLevel ? primaryColor.withValues(alpha:0.8) : Colors.white.withValues(alpha:0.12),
                        width: 2,
                      ),
                      boxShadow: [
                        if (isLevel)
                          BoxShadow(
                            color: primaryColor.withValues(alpha:0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Linie siatki
                        Divider(color: Colors.white.withValues(alpha:0.07), thickness: 1),
                        VerticalDivider(color: Colors.white.withValues(alpha:0.07), thickness: 1),

                        // Pierścień zewnętrzny tolerancji
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha:0.08), width: 1),
                          ),
                        ),

                        // Środkowy celownik
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLevel ? primaryColor : Colors.white.withValues(alpha:0.3),
                              width: 1.5,
                            ),
                          ),
                        ),

                        // Pływający bąbelek
                        Transform.translate(
                          offset: Offset(offsetX, offsetY),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha:0.6),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Odczyty kątów
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AngleBadge(label: 'Roll (X)', value: '${level.roll.toStringAsFixed(1)}°'),
                    _AngleBadge(label: 'Pitch (Y)', value: '${level.pitch.toStringAsFixed(1)}°'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AngleBadge extends StatelessWidget {
  final String label;
  final String value;

  const _AngleBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}