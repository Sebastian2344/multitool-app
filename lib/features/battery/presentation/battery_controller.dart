import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multitool/features/battery/data/repositories/battery_repository_impl.dart';
import 'package:multitool/features/battery/domain/entities/battery_info_entity.dart';

/// Strumień danych baterii z autoDispose
final batteryControllerProvider = StreamProvider.autoDispose<BatteryInfoEntity>((ref) {
  final repository = ref.watch(batteryRepositoryProvider);
  return repository.getBatteryStream();
});