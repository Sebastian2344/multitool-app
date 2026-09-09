import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:multitool/features/location/data/repositories/location_repository_impl.dart';
import 'package:multitool/features/location/domain/entities/location_data_entity.dart';
import 'package:multitool/features/location/domain/repositories/location_repository.dart';
import 'package:multitool/features/location/presentation/widgets/location_card.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockLocationRepository mockRepository;

  setUp(() {
    mockRepository = MockLocationRepository();
  });

  // Przykładowe dane telemetryczne do testu
  const fakeLocation = LocationDataEntity(
    latitude: 52.22970,
    longitude: 21.01220,
    altitude: 110.0,
    speed: 5.0, // 5.0 m/s = 18.0 km/h
    heading: 90.0,
    accuracy: 3.5,
    address: 'ul. Marszałkowska, Warszawa, Polska',
    isLive: false,
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        // Podmieniamy prawdziwy GPS na naszego mocka
        locationRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LocationCard(),
          ),
        ),
      ),
    );
  }

  testWidgets('LocationCard w stanie początkowym wyświetla zachętę do uruchomienia GPS', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Sprawdzamy nagłówek i pusty stan
    expect(find.text('Telemetria GPS'), findsOneWidget);
    expect(find.text('Uruchom GPS za pomocą [Odśwież] lub [Play].'), findsOneWidget);
    expect(find.byIcon(Icons.satellite_alt), findsOneWidget);
  });

  testWidgets('Kliknięcie przycisku Odśwież pobiera dane i renderuje kafelki telemetrii', (tester) async {
    when(() => mockRepository.getCurrentLocation()).thenAnswer((_) async => fakeLocation);

    await tester.pumpWidget(createWidgetUnderTest());

    // 1. Klikamy przycisk pojedynczego odświeżenia (ikona refresh)
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle(); // Czekamy na zakończenie operacji asynchronicznej

    // 2. Weryfikujemy, czy repozytorium zostało wywołane
    verify(() => mockRepository.getCurrentLocation()).called(1);

    // 3. Sprawdzamy wyrenderowany adres
    expect(find.text('ul. Marszałkowska, Warszawa, Polska'), findsOneWidget);

    // 4. Sprawdzamy kafelki telemetrii (wartości i etykiety)
    expect(find.text('PRĘDKOŚĆ'), findsOneWidget);
    expect(find.text('18.0 km/h'), findsOneWidget);

    expect(find.text('WYSOKOŚĆ'), findsOneWidget);
    expect(find.text('110 m n.p.m.'), findsOneWidget);

    expect(find.text('DOKŁADNOŚĆ'), findsOneWidget);
    expect(find.text('±3.5 m'), findsOneWidget);

    expect(find.text('KURS'), findsOneWidget);
    expect(find.text('90°'), findsOneWidget);

    // 5. Sprawdzamy współrzędne w formacie monospace
    expect(find.text('52.22970, 21.01220'), findsOneWidget);
  });

  testWidgets('Kliknięcie ikony kopiowania współrzędnych wyświetla SnackBar', (tester) async {
    when(() => mockRepository.getCurrentLocation()).thenAnswer((_) async => fakeLocation);

    await tester.pumpWidget(createWidgetUnderTest());

    // Pobieramy dane
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    // Klikamy ikonę kopiowania (Icons.copy)
    await tester.tap(find.byIcon(Icons.copy));
    await tester.pump(); // Start animacji SnackBara

    // Asercja: SnackBar z komunikatem o skopiowaniu musi być widoczny
    expect(find.text('Skopiowano współrzędne!'), findsOneWidget);
  });
}