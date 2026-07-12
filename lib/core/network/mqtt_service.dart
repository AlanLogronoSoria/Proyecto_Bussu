import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

import '../config/app_config.dart';
import '../config/env.dart';
import '../error/failures.dart';

abstract class MqttService {
  Stream<MqttServiceMessage> get messageStream;
  mqtt.MqttConnectionState get connectionState;
  Future<Either<Failure, void>> connect();
  Future<Either<Failure, void>> disconnect();
  Future<Either<Failure, void>> subscribe(String topic);
  Future<Either<Failure, void>> unsubscribe(String topic);
  Future<Either<Failure, void>> publish(String topic, String payload);
  void dispose();
}

class MqttServiceMessage {
  final String topic;
  final String payload;
  final DateTime receivedAt;

  const MqttServiceMessage({
    required this.topic,
    required this.payload,
    required this.receivedAt,
  });
}

class MqttServiceImpl implements MqttService {
  MqttServerClient? _client;
  Timer? _reconnectTimer;
  late StreamSubscription<List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>>>
      _updatesSubscription;

  final StreamController<MqttServiceMessage> _messageController =
      StreamController<MqttServiceMessage>.broadcast();
  final StreamController<mqtt.MqttConnectionState> _stateController =
      StreamController<mqtt.MqttConnectionState>.broadcast();

  final Set<String> _pendingSubscriptions = {};
  int _reconnectAttempts = 0;
  bool _isDisposed = false;
  bool _intentionalDisconnect = false;

  mqtt.MqttConnectionState _connectionState =
      mqtt.MqttConnectionState.disconnected;

  @override
  mqtt.MqttConnectionState get connectionState => _connectionState;

  @override
  Stream<MqttServiceMessage> get messageStream => _messageController.stream;

  Stream<mqtt.MqttConnectionState> get stateStream => _stateController.stream;

  @override
  Future<Either<Failure, void>> connect() async {
    try {
      _intentionalDisconnect = false;

      if (_client != null &&
          _connectionState == mqtt.MqttConnectionState.connected) {
        return const Right(null);
      }

      final clientId = 'bussu_${_generateClientId()}';

      _client = MqttServerClient.withPort(
        Env.mqttBrokerHost,
        clientId,
        Env.mqttBrokerPort,
      );

      _client!.logging(on: false);
      _client!.keepAlivePeriod = AppConfig.mqttKeepAlive.inSeconds;
      _client!.autoReconnect = false;
      _client!.resubscribeOnAutoReconnect = false;

      final connMessage = mqtt.MqttConnectMessage()
          .authenticateAs(
            Env.mqttBrokerUsername,
            Env.mqttBrokerPassword,
          )
          .withClientIdentifier(clientId)
          .withWillTopic('bussu/$clientId/status')
          .withWillMessage('offline')
          .startClean()
          .withWillQos(mqtt.MqttQos.atLeastOnce);

      _client!.connectionMessage = connMessage;

      await _client!.connect();

      if (_client!.connectionStatus?.state ==
          mqtt.MqttConnectionState.connected) {
        _connectionState = mqtt.MqttConnectionState.connected;
        _stateController.add(mqtt.MqttConnectionState.connected);
        _reconnectAttempts = 0;

        _startListening();

        await _resubscribeAll();

        return const Right(null);
      }

      return const Left(MqttFailure('No se pudo conectar al broker MQTT'));
    } catch (e) {
      _scheduleReconnect();
      return Left(MqttFailure(e.toString()));
    }
  }

  void _startListening() {
    try {
      _updatesSubscription.cancel();
    } catch (_) {
      // subscription not yet initialized
    }

    _updatesSubscription = _client!.updates!.listen(
      _onMessageReceived,
      onDone: _onDone,
      cancelOnError: false,
    );
  }

  void _onMessageReceived(
    List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> messages,
  ) {
    for (final receivedMessage in messages) {
      final topic = receivedMessage.topic;
      if (topic.isEmpty) continue;

      final publishMsg =
          receivedMessage.payload as mqtt.MqttPublishMessage;
      final payload = mqtt.MqttPublishPayload.bytesToStringAsString(
        publishMsg.payload.message,
      );

      _messageController.add(
        MqttServiceMessage(
          topic: topic,
          payload: payload,
          receivedAt: DateTime.now(),
        ),
      );
    }
  }

  void _onDone() {
    _connectionState = mqtt.MqttConnectionState.disconnected;
    _stateController.add(mqtt.MqttConnectionState.disconnected);
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isDisposed || _intentionalDisconnect) return;

    _reconnectTimer?.cancel();

    final delay = Duration(
      milliseconds: min(
        (AppConfig.mqttReconnectMinDelay.inMilliseconds *
                pow(AppConfig.mqttBackoffMultiplier, _reconnectAttempts))
            .round(),
        AppConfig.mqttReconnectMaxDelay.inMilliseconds,
      ),
    );

    _reconnectAttempts++;

    _reconnectTimer = Timer(delay, () {
      if (!_isDisposed) {
        connect();
      }
    });
  }

  Future<void> _resubscribeAll() async {
    for (final topic in _pendingSubscriptions) {
      if (_client != null) {
        _client!.subscribe(
          topic,
          mqtt.MqttQos.values[AppConfig.mqttQos],
        );
      }
    }
  }

  @override
  Future<Either<Failure, void>> subscribe(String topic) async {
    try {
      if (_client == null ||
          _connectionState != mqtt.MqttConnectionState.connected) {
        _pendingSubscriptions.add(topic);
        return const Right(null);
      }

      _client!.subscribe(
        topic,
        mqtt.MqttQos.values[AppConfig.mqttQos],
      );
      _pendingSubscriptions.add(topic);
      return const Right(null);
    } catch (e) {
      return Left(MqttFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribe(String topic) async {
    try {
      _pendingSubscriptions.remove(topic);
      if (_client != null) {
        _client!.unsubscribe(topic);
      }
      return const Right(null);
    } catch (e) {
      return Left(MqttFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> publish(String topic, String payload) async {
    try {
      if (_client == null ||
          _connectionState != mqtt.MqttConnectionState.connected) {
        return const Left(MqttFailure('Cliente MQTT no conectado'));
      }

      final builder = mqtt.MqttClientPayloadBuilder();
      builder.addString(payload);

      _client!.publishMessage(
        topic,
        mqtt.MqttQos.values[AppConfig.mqttQos],
        builder.payload!,
        retain: false,
      );

      return const Right(null);
    } catch (e) {
      return Left(MqttFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    try {
      _intentionalDisconnect = true;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _reconnectAttempts = 0;

      _client?.disconnect();
      _connectionState = mqtt.MqttConnectionState.disconnected;
      _stateController.add(mqtt.MqttConnectionState.disconnected);

      return const Right(null);
    } catch (e) {
      return Left(MqttFailure(e.toString()));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    try {
      _updatesSubscription.cancel();
    } catch (_) {
      // not initialized
    }
    _client?.disconnect();
    _messageController.close();
    _stateController.close();
  }

  String _generateClientId() {
    final rng = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = rng.nextInt(9999);
    return '${timestamp}_$random';
  }
}

final mqttServiceProvider = Provider<MqttService>((ref) {
  throw UnimplementedError(
    'Registra MqttService en injection_container.dart',
  );
});
