import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource remoto que implementa la comunicación con Supabase
/// para el feature de chat en vivo.
class ChatRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChatRemoteDataSource(this.supabaseClient);

  // TODO (OpenCode): 
  // 1. Implementar consultas REST (getMessages)
  // 2. Implementar Realtime (.stream(primaryKey: ['id'])) para watchMessages
  // 3. Implementar insert para sendMessage
  // Asegurarse de manejar los canales para que no queden abiertos consumiendo memoria.
}
