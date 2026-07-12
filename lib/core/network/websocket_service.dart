import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/env.dart';
import '../config/app_config.dart';
import '../error/failures.dart';

abstract class WebSocketService {
  Stream<WsMessage> get messageStream;
  WsConnectionState get connectionState;
  Future<Either<Failure, void>> connect();
  Future<Either<Failure, void>> disconnect();
  Future<Either<Failure, void>> send(String event, Map<String, dynamic> data);
  void dispose();
}

class WsMessage {
  final String event;
  final Map<String, dynamic> data;
  final DateTime receivedAt;

  const WsMessage({
    required this.event,
    required this.data,
    required this.receivedAt,
  });
}

enum WsConnectionState { disconnected, connecting, connected }

class WebSocketServiceImpl implements WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final _messageController = StreamController<WsMessage>.broadcast();
  final _stateController = StreamController<WsConnectionState>.broadcast();

  WsConnectionState _connectionState = WsConnectionState.disconnected;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;
  bool _intentionalDisconnect = false;

  @override
  WsConnectionState get connectionState => _connectionState;

  @override
  Stream<WsMessage> get messageStream => _messageController.stream;

  Stream<WsConnectionState> get stateStream => _stateController.stream;

  @override
  Future<Either<Failure, void>> connect() async {
    try {
      _intentionalDisconnect = false;

      if (_connectionState == WsConnectionState.connected) {
        return const Right(null);
      }

      _connectionState = WsConnectionState.connecting;
      _stateController.add(WsConnectionState.connecting);

      final uri = Uri.parse(Env.wsFallbackUrl);
      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready;

      _connectionState = WsConnectionState.connected;
      _stateController.add(WsConnectionState.connected);
      _reconnectAttempts = 0;

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _startPing();

      return const Right(null);
    } catch (e) {
      _connectionState = WsConnectionState.disconnected;
      _stateController.add(WsConnectionState.disconnected);
      _scheduleReconnect();
      return Left(WebSocketFailure(e.toString()));
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      _messageController.add(
        WsMessage(
          event: decoded['event'] as String? ?? 'message',
          data: Map<String, dynamic>.from(decoded),
          receivedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // ignorar mensajes mal formados
    }
  }

  void _onError(Object error) {
    _connectionState = WsConnectionState.disconnected;
    _stateController.add(WsConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _onDone() {
    _connectionState = WsConnectionState.disconnected;
    _stateController.add(WsConnectionState.disconnected);
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_channel != null && _connectionState == WsConnectionState.connected) {
        try {
          _channel!.sink.add(jsonEncode({'event': 'ping'}));
        } catch (_) {
          // conexión perdida, se detectará por onDone
        }
      }
    });
  }

  void _scheduleReconnect() {
    if (_isDisposed || _intentionalDisconnect) return;

    _reconnectTimer?.cancel();

    final delay = Duration(
      milliseconds: min(
        (AppConfig.wsReconnectMinDelay.inMilliseconds *
                pow(AppConfig.wsBackoffMultiplier, _reconnectAttempts))
            .round(),
        AppConfig.wsReconnectMaxDelay.inMilliseconds,
      ),
    );

    _reconnectAttempts++;

    _reconnectTimer = Timer(delay, () {
      if (!_isDisposed) {
        connect();
      }
    });
  }

  @override
  Future<Either<Failure, void>> send(
    String event,
    Map<String, dynamic> data,
  ) async {
    try {
      if (_channel == null ||
          _connectionState != WsConnectionState.connected) {
        return const Left(WebSocketFailure('Canal WebSocket no conectado'));
      }

      final payload = {'event': event, ...data};
      _channel!.sink.add(jsonEncode(payload));

      return const Right(null);
    } catch (e) {
      return Left(WebSocketFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    try {
      _intentionalDisconnect = true;
      _reconnectTimer?.cancel();
      _pingTimer?.cancel();
      _reconnectAttempts = 0;

      await _subscription?.cancel();
      final channel = _channel;
      if (channel != null) {
        await channel.sink.close();
      }

      _connectionState = WsConnectionState.disconnected;
      _stateController.add(WsConnectionState.disconnected);

      return const Right(null);
    } catch (e) {
      return Left(WebSocketFailure(e.toString()));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _messageController.close();
    _stateController.close();
  }
}

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  throw UnimplementedError(
    'Registra WebSocketService en injection_container.dart',
  );
});
