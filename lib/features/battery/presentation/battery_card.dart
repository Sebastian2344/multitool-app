import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multitool/features/battery/presentation/battery_controller.dart';


class BatteryCard extends ConsumerWidget {
  const BatteryCard({super.key});

  Color _getBatteryColor(int level, bool isCharging) {
    if (isCharging) return const Color(0xFF4ADE80); // Zielony
    if (level <= 20) return const Color(0xFFF87171); // Czerwony
    if (level <= 50) return const Color(0xFFFBBF24); // Żółty
    return const Color(0xFF38BDF8); // Niebieski
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryAsync = ref.watch(batteryControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: batteryAsync.when(
          loading: () => const Center(
            child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          ),
          error: (err, _) => Text('Błąd baterii: $err'),
          data: (info) {
            final color = _getBatteryColor(info.level, info.isCharging);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha:0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            info.isCharging ? Icons.battery_charging_full : Icons.battery_std,
                            size: 22,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Akumulator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                    Text(
                      '${info.level}%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pasek postępu poziomu naładowania
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: info.level / 100.0,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha:0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      info.isCharging ? 'Ładowanie w toku...' : 'Praca na baterii',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        info.status.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                    ),
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