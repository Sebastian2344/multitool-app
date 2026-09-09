import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:multitool/features/flashlight/data/repositories/flashlight_repository_impl.dart';
import 'package:multitool/features/flashlight/domain/repositories/flashlight_repository.dart';
import 'package:multitool/features/flashlight/presentation/widgets/flashlight_card.dart';

class MockFlashlightRepository extends Mock implements FlashlightRepository {}

void main() {
  late MockFlashlightRepository mockRepository;

  setUp(() {
    mockRepository = MockFlashlightRepository();
  });

  testWidgets('Kliknięcie w przycisk latarki zmienia tekst z Wyłączona na Aktywna', (tester) async {
    when(() => mockRepository.turnOn()).thenAnswer((_) async {});
    when(() => mockRepository.turnOff()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashlightRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: FlashlightCard(),
          ),
        ),
      ),
    );

    // Stan początkowy
    expect(find.text('Wyłączona'), findsOneWidget);

    // Klikamy w przycisk włącznika (szukamy ikony zasilania)
    await tester.tap(find.byIcon(Icons.power_settings_new));
    await tester.pumpAndSettle(); // Czekamy na animację kontenera

    // Stan po kliknięciu
    expect(find.text('Aktywna (LED WŁ)'), findsOneWidget);
    verify(() => mockRepository.turnOn()).called(1);
  });
}