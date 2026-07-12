import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

abstract class ConnectivityService {
  Stream<bool> get isConnected;
  Future<bool> get isCurrentlyConnected;
  void dispose();
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl(Connectivity connectivity)
      : _connectivity = connectivity,
        _subject = StreamController<bool>.broadcast() {
    _init();
  }

  final Connectivity _connectivity;
  final StreamController<bool> _subject;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  DateTime _lastEmit = DateTime(2000);

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    _subject.add(_isConnected(results));

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final now = DateTime.now();
      if (now.difference(_lastEmit) < AppConfig.connectivityThrottle) {
        return;
      }
      _lastEmit = now;
      _subject.add(_isConnected(results));
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return !results.contains(ConnectivityResult.none);
  }

  @override
  Stream<bool> get isConnected => _subject.stream;

  @override
  Future<bool> get isCurrentlyConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subject.close();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  throw UnimplementedError(
    'Registra ConnectivityService en injection_container.dart',
  );
});

final isConnectedProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.isConnected;
});
