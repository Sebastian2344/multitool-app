import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/location_controller.dart';

class LocationCard extends ConsumerWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationControllerProvider);
    final notifier = ref.read(locationControllerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nagłówek i przyciski sterujące GPS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha:0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.satellite_alt, size: 22, color: Color(0xFF38BDF8)),
                    ),
                    const SizedBox(width: 12),
                    const Text('Telemetria GPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.refresh, size: 18),
                      tooltip: 'Pobierz raz',
                      onPressed: () => notifier.fetchOnce(),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: locationAsync.value?.isLive == true
                            ? Colors.redAccent
                            : const Color(0xFF4ADE80),
                      ),
                      icon: Icon(
                        locationAsync.value?.isLive == true ? Icons.stop : Icons.play_arrow,
                        size: 20,
                        color: Colors.black,
                      ),
                      tooltip: 'Tryb ciągły',
                      onPressed: () => notifier.toggleLiveTracking(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            locationAsync.when(
              loading: () => const Center(
                child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Błąd: $err', style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (data) {
                if (data == null) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.02),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Uruchom GPS za pomocą [Odśwież] lub [Play].',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Adres
                    if (data.address != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.04),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.place, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data.address!,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Kafelki telemetrii 2x2
                    Row(
                      children: [
                        Expanded(
                          child: _TelemetryCard(
                            label: 'PRĘDKOŚĆ',
                            value: '${data.speedKmH.toStringAsFixed(1)} km/h',
                            icon: Icons.speed,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TelemetryCard(
                            label: 'WYSOKOŚĆ',
                            value: '${data.altitude.toStringAsFixed(0)} m n.p.m.',
                            icon: Icons.terrain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _TelemetryCard(
                            label: 'DOKŁADNOŚĆ',
                            value: '±${data.accuracy.toStringAsFixed(1)} m',
                            icon: Icons.center_focus_strong,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TelemetryCard(
                            label: 'KURS',
                            value: '${data.heading.toStringAsFixed(0)}°',
                            icon: Icons.explore,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Współrzędne monospace
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${data.latitude.toStringAsFixed(5)}, ${data.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: '${data.latitude}, ${data.longitude}'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Skopiowano współrzędne!')),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.copy, size: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TelemetryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TelemetryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}