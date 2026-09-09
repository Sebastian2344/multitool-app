import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/location_data_entity.dart';
import '../../domain/repositories/location_repository.dart';

class LocationController extends AutoDisposeAsyncNotifier<LocationDataEntity?> {
  late final LocationRepository _repository;
  StreamSubscription<LocationDataEntity>? _subscription;

  @override
  FutureOr<LocationDataEntity?> build() {
    _repository = ref.watch(locationRepositoryProvider);
    ref.onDispose(() => _subscription?.cancel());
    return null;
  }

  Future<void> fetchOnce() async {
  state = const AsyncValue.loading();
  _subscription?.cancel();
  _subscription = null;
  state = await AsyncValue.guard(() => _repository.getCurrentLocation());
}

  Future<void> toggleLiveTracking() async {
    if (state.value?.isLive == true) {
      await _subscription?.cancel();
      _subscription = null;
      state = AsyncValue.data(
        LocationDataEntity(
          latitude: state.value!.latitude,
          longitude: state.value!.longitude,
          altitude: state.value!.altitude,
          speed: state.value!.speed,
          heading: state.value!.heading,
          accuracy: state.value!.accuracy,
          address: state.value!.address,
          isLive: false,
        ),
      );
      return;
    }

    state = const AsyncValue.loading();
    _subscription = _repository.getLiveLocationStream().listen(
      (data) => state = AsyncValue.data(data),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  String get compassDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((state.value!.heading + 22.5) % 360 / 45).floor();
    return directions[index];
  }
}

final locationControllerProvider =
    AutoDisposeAsyncNotifierProvider<LocationController, LocationDataEntity?>(() {
  return LocationController();
});