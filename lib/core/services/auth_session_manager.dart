import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_roles.dart';
import '../routing/role_guard.dart';

/// Gestiona la sesión de autenticación: escucha cambios de estado
/// en Supabase Auth y notifica a la capa de presentación.
class AuthSessionManager {
  final SupabaseClient _client;
  StreamSubscription<AuthState>? _subscription;

  AuthSessionManager(this._client);

  /// Inicia la escucha de cambios de sesión. Debe llamarse en [main].
  void initialize() {
    _subscription = _client.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.userUpdated:
        case AuthChangeEvent.tokenRefreshed:
          _onUserChanged(data.session?.user);
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          _onUserLoggedOut();
        case AuthChangeEvent.passwordRecovery:
        case AuthChangeEvent.mfaChallengeVerified:
          break;
      }
    });
  }

  void _onUserChanged(User? user) async {
    if (user == null) {
      _onUserLoggedOut();
      return;
    }

    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        final role = UserRole.fromString(response['role'] as String);
        notifyAuthStateChanged(role);
      }
    } catch (_) {
      notifyAuthStateChanged(null);
    }
  }

  void _onUserLoggedOut() {
    notifyAuthStateChanged(null);
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final authSessionManagerProvider = Provider<AuthSessionManager>((ref) {
  throw UnimplementedError(
    'Registra AuthSessionManager en injection_container.dart',
  );
});
