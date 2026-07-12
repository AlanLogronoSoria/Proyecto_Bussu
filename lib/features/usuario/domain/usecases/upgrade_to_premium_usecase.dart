import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/payments/payment_gateway_service.dart';

/// Caso de uso que orquesta el flujo de Upgrade a Premium.
/// Aisla la lógica de negocio de la interfaz de usuario.
class UpgradeToPremiumUseCase {
  final PaymentGatewayService paymentGateway;

  UpgradeToPremiumUseCase(this.paymentGateway);

  /// Ejecuta el proceso de pago y actualiza el rol en backend si es exitoso.
  Future<Either<Failure, void>> execute(String planId) async {
    // TODO (OpenCode): 
    // 1. Invocar paymentGateway.upgradeSubscription
    // 2. Si el pago falla, retornar Left(PaymentFailure())
    // 3. Si el pago es exitoso, invocar repositorio de usuario para actualizar rol en BD
    // 4. Retornar Right(null)
    throw UnimplementedError();
  }
}
