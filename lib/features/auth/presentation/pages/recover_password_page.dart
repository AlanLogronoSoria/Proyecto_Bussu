import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Pantalla de recuperación de contraseña.
class RecoverPasswordPage extends ConsumerStatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  ConsumerState<RecoverPasswordPage> createState() =>
      _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends ConsumerState<RecoverPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        final isSuccess = next.errorMessage!.contains('enviado');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor:
                isSuccess ? Colors.green.shade700 : AppTheme.error,
          ),
        );

        if (isSuccess) {
          setState(() => _emailSent = true);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_reset,
                      size: 64,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _emailSent
                          ? '¡Correo enviado!'
                          : 'Recupera tu acceso',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _emailSent
                          ? 'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.'
                          : 'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (!_emailSent) ...[
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: Validators.validateEmail,
                        onFieldSubmitted: (_) => _handleRecover(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRecover,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Enviar enlace'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Volver al inicio de sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleRecover() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).recoverPassword(
            _emailController.text.trim(),
          );
    }
  }
}
