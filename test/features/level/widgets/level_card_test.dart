import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:multitool/features/level/domain/entities/level_entity.dart';
import 'package:multitool/features/level/presentation/controllers/level_controller.dart';
import 'package:multitool/features/level/presentation/widgets/level_card.dart';

void main() {
  testWidgets('LevelCard wyświetla stan wypoziomowany [POZIOM (0°)] i zielony ptaszek', (tester) async {
    // Stan idealny (odchylenie < 1°)
    const levelData = LevelEntity(
      x: 0.0,
      y: 0.0,
      z: 9.81,
      roll: 0.3,
      pitch: -0.2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Zastępujemy żywy akcelerometr statycznym strumieniem testowym
          levelControllerProvider.overrideWith((ref) => Stream.value(levelData)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LevelCard(),
          ),
        ),
      ),
    );

    await tester.pump(); // Odczekanie na emisję strumienia

    // Asercje
    expect(find.text('Poziomica 2D'), findsOneWidget);
    expect(find.text('POZIOM (0°)'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('0.3°'), findsOneWidget);
    expect(find.text('-0.2°'), findsOneWidget);
  });

  testWidgets('LevelCard wyświetla stan braku poziomu [KALIBRACJA] przy przechyleniu', (tester) async {
    // Stan ze znacznym przechyleniem
    const tiltedData = LevelEntity(
      x: 3.2,
      y: -4.1,
      z: 7.5,
      roll: 6.4,
      pitch: -8.1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          levelControllerProvider.overrideWith((ref) => Stream.value(tiltedData)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LevelCard(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Asercje dla przechylenia
    expect(find.text('KALIBRACJA'), findsOneWidget);
    expect(find.byIcon(Icons.adjust), findsOneWidget);
    expect(find.text('6.4°'), findsOneWidget);
    expect(find.text('-8.1°'), findsOneWidget);
  });
}