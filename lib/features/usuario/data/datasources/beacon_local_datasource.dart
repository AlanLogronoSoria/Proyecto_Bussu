import 'dart:async';

/// Datasource local de detección BLE de paradas cercanas (simulación para demo).
abstract class BeaconLocalDataSource {
  Stream<String> scanForStops({required String beaconUuid, Duration scanDuration = const Duration(seconds: 10)});
  Future<void> stopScanning();
  Future<bool> isBluetoothEnabled();
  Future<bool> requestBluetoothPermission();
}

class BeaconLocalDataSourceImpl implements BeaconLocalDataSource {
  StreamSubscription? _subscription;
  Timer? _simTimer;

  @override
  Stream<String> scanForStops({required String beaconUuid, Duration scanDuration = const Duration(seconds: 10)}) {
    final controller = StreamController<String>();
    int count = 0;
    final stopIds = ['s0000000-0000-0000-0000-000000000001', 's0000000-0000-0000-0000-000000000002'];
    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (count < 2) {
        controller.add('${stopIds[count]}:1:1');
        count++;
      } else {
        timer.cancel();
        controller.close();
      }
    });
    _subscription = controller.stream.listen((_) {});
    return controller.stream;
  }

  @override
  Future<void> stopScanning() async { _simTimer?.cancel(); await _subscription?.cancel(); }

  @override
  Future<bool> isBluetoothEnabled() async => true;

  @override
  Future<bool> requestBluetoothPermission() async => true;
}
