import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:multitool/features/battery/domain/entities/battery_info_entity.dart';
import 'package:multitool/features/battery/presentation/battery_card.dart';
import 'package:multitool/features/battery/presentation/battery_controller.dart';

void main() {
  testWidgets('BatteryCard powinien wyświetlać 85% i status ładowania', (tester) async {
    // 1. Definiujemy fałszywy stan baterii
    const mockBatteryInfo = BatteryInfoEntity(
      level: 85,
      status: BatteryChargingStatus.charging,
    );

    // 2. Renderujemy widżet w ProviderScope z nadpisanym strumieniem
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          batteryControllerProvider.overrideWith((ref) => Stream.value(mockBatteryInfo)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: BatteryCard(),
          ),
        ),
      ),
    );

    // 3. Czekamy na przetworzenie strumienia
    await tester.pump();

    // 4. Asercje: czy teksty są widoczne na ekranie?
    expect(find.text('Akumulator'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('Ładowanie w toku...'), findsOneWidget);
    expect(find.byIcon(Icons.battery_charging_full), findsOneWidget);
  });
}