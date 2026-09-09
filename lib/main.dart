import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multitool/features/battery/presentation/battery_card.dart';
import 'features/flashlight/presentation/widgets/flashlight_card.dart';
import 'features/level/presentation/widgets/level_card.dart';
import 'features/location/presentation/widgets/location_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MultiToolApp()));
}

class MultiToolApp extends StatelessWidget {
  const MultiToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multitool Pro',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Domyślnie styl ciemny - idealny do narzędzi
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F141C),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF38BDF8), // Akcent błękitny
          secondary: const Color(0xFF4ADE80), // Akcent zielony (sukces/poziom)
          surface: const Color(0xFF192231),  // Tło kart
          onSurface: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF192231),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<bool> _confirmExit(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Zamknąć aplikację?'),
            content: const Text('Czy na pewno chcesz wyjść z narzędziownika?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Anuluj'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Wyjdź'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit(context)) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text(
              'Multitool Pro',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new),
              tooltip: 'Wyjdź',
              onPressed: () async {
                if (await _confirmExit(context)) await SystemNavigator.pop();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: const [
            FlashlightCard(),
            SizedBox(height: 14),
            LevelCard(),
            SizedBox(height: 14),
            BatteryCard(),
            SizedBox(height: 14),
            LocationCard(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}