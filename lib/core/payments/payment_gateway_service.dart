abstract class PaymentGatewayService {
  /// Inicializa el SDK de la pasarela de pagos
  Future<void> initialize();

  /// Procesa un pago por un monto específico.
  /// Retorna un ID de transacción si es exitoso, null si falla o se cancela.
  Future<String?> processPayment({
    required double amount,
    required String currency,
  });

  /// Ejecuta la suscripción a un plan específico (Premium).
  Future<bool> upgradeSubscription(String planId);
}
