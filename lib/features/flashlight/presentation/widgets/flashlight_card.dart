import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multitool/features/flashlight/presentation/controllers/flashlight_provider.dart';

class FlashlightCard extends ConsumerWidget {
  const FlashlightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOn = ref.watch(flashlightControllerProvider);
    final activeColor = const Color(0xFFFBBF24); // Ciepły żółty

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOn ? activeColor.withValues(alpha:0.15) : Colors.white.withValues(alpha:0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isOn ? Icons.flashlight_on : Icons.flashlight_off,
                    size: 28,
                    color: isOn ? activeColor : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latarka',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOn ? 'Aktywna (LED WŁ)' : 'Wyłączona',
                      style: TextStyle(
                        fontSize: 13,
                        color: isOn ? activeColor : Colors.grey.shade500,
                        fontWeight: isOn ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Duży przełącznik dotykowy
            GestureDetector(
              onTap: () => ref.read(flashlightControllerProvider.notifier).toggle(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOn ? activeColor : Colors.white.withValues(alpha:0.08),
                  boxShadow: isOn
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha:0.4),
                            blurRadius: 18,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  Icons.power_settings_new,
                  color: isOn ? Colors.black87 : Colors.white70,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}