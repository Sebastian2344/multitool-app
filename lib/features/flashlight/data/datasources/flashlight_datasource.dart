import 'package:torch_light/torch_light.dart';

abstract class FlashlightDataSource {
  Future<void> enableTorch();
  Future<void> disableTorch();
}

class FlashlightDataSourceImpl implements FlashlightDataSource {
  @override
  Future<void> enableTorch() => TorchLight.enableTorch();

  @override
  Future<void> disableTorch() => TorchLight.disableTorch();
}