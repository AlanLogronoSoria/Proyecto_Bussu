import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';

class SupabaseClientFactory {
  SupabaseClientFactory._();

  static SupabaseClient? _client;

  static Future<Either<Failure, SupabaseClient>> initialize() async {
    try {
      if (_client != null) return Right(_client!);

      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );

      _client = Supabase.instance.client;
      return Right(_client!);
    } on AuthFailureException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw StateError(
        'Supabase no ha sido inicializado. Llama initialize() primero.',
      );
    }
    return _client!;
  }

  static bool get isInitialized => _client != null;

  static void reset() {
    _client = null;
  }
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!SupabaseClientFactory.isInitialized) {
    throw StateError('Supabase no inicializado. Ejecuta initialize() en main().');
  }
  return SupabaseClientFactory.client;
});

typedef SupabaseInitializeFunc = Future<Either<Failure, SupabaseClient>>
    Function();
