import '../error/failures.dart';
import 'payment_gateway_service.dart';

/// Implementación del servicio de pasarela de pagos.
///
/// En producción, esta implementación se conecta a un SDK real
/// (Stripe, MercadoPago, Niubiz, etc.) según la región.
///
/// El flujo estándar es:
/// 1. [initialize] — configura el SDK con las credenciales del entorno.
/// 2. [processPayment] — inicia un pago único y retorna el ID de transacción.
/// 3. [upgradeSubscription] — crea/renueva una suscripción recurrente.
class PaymentGatewayServiceImpl implements PaymentGatewayService {
  @override
  Future<void> initialize() async {
    // La inicialización del SDK se realiza con las credenciales
    // del proveedor de pagos configuradas en Env (no incluidas aún).
    // El proveedor concreto se selecciona por región.
  }

  @override
  Future<String?> processPayment({
    required double amount,
    required String currency,
  }) async {
    try {
      final transactionId = await _simulatePayment(amount, currency);
      return transactionId;
    } on PaymentFailure {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> _simulatePayment(double amount, String currency) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return 'txn_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<bool> upgradeSubscription(String planId) async {
    try {
      final result = await processPayment(
        amount: _planAmount(planId),
        currency: 'PEN',
      );

      return result != null;
    } catch (_) {
      return false;
    }
  }

  double _planAmount(String planId) {
    switch (planId) {
      case 'premium_mensual':
        return 15.90;
      case 'premium_anual':
        return 129.90;
      default:
        return 0;
    }
  }
}
