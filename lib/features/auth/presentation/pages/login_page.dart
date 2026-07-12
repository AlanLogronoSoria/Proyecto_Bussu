import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import 'recover_password_page.dart';
import 'register_page.dart';

/// Pantalla de inicio de sesión.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    });

    return Scaffold(
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
                      Icons.directions_bus,
                      size: 64,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BUSSU',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transporte público inteligente',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (v) => Validators.validatePassword(v),
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Iniciar Sesión'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => _navigateToRegister(),
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                    TextButton(
                      onPressed: () => _navigateToRecoverPassword(),
                      child: const Text('¿Olvidaste tu contraseña?'),
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

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<RegisterPage>(builder: (_) => const RegisterPage()),
    );
  }

  void _navigateToRecoverPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<RecoverPasswordPage>(
          builder: (_) => const RecoverPasswordPage()),
    );
  }
}
