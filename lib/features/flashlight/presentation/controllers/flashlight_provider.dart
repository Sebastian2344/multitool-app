import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multitool/features/flashlight/data/repositories/flashlight_repository_impl.dart';
import 'package:multitool/features/flashlight/domain/repositories/flashlight_repository.dart';

class FlashlightController extends Notifier<bool> {
  late final FlashlightRepository _repository;

  @override
  bool build() {
    _repository = ref.watch(flashlightRepositoryProvider);
    
    // Sprzątanie po zniszczeniu
    ref.onDispose(() async {
      if (state) {
        try {
          await _repository.turnOff();
        } catch (_) {}
      }
    });

    return false;
  }

  Future<void> toggle() async {
    try {
      if (state) {
        await _repository.turnOff();
        state = false;
      } else {
        await _repository.turnOn();
        state = true;
      }
    } catch (e) {
      state = false;
      rethrow;
    }
  }
}

final flashlightControllerProvider = NotifierProvider<FlashlightController, bool>(() {
  return FlashlightController();
});