import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_roles.dart';

final currentUserRoleProvider = StateProvider<UserRole?>((ref) => null);

final _authStateStreamController =
    StreamController<UserRole?>.broadcast();

final authStateChangesProvider = StreamProvider<UserRole?>((ref) {
  return _authStateStreamController.stream;
});

void notifyAuthStateChanged(UserRole? role) {
  if (!_authStateStreamController.isClosed) {
    _authStateStreamController.add(role);
  }
}

void disposeAuthStream() {
  if (!_authStateStreamController.isClosed) {
    _authStateStreamController.close();
  }
}

final userRoleProvider = Provider<UserRole>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  if (role == null) {
    throw StateError('Usuario no autenticado');
  }
  return role;
});

final isPremiumProvider = StateProvider<bool>((ref) => false);
