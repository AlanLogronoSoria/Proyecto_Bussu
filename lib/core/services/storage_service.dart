/// Abstracción del almacenamiento local clave-valor.
///
/// Encapsula [SharedPreferences] y permite ser mockeada en tests.
/// Los métodos son síncronos en su interfaz porque SharedPreferences
/// ya mantiene una caché en memoria después de la inicialización.
abstract class StorageService {
  /// Inicializa el almacenamiento. Debe llamarse en [main] antes de usar
  /// cualquier otro método.
  Future<void> initialize();

  /// Almacena un valor de tipo [String] asociado a [key].
  Future<void> setString(String key, String value);

  /// Recupera un valor de tipo [String] asociado a [key], o `null`.
  String? getString(String key);

  /// Almacena un valor [bool] asociado a [key].
  Future<void> setBool(String key, bool value);

  /// Recupera un valor [bool] asociado a [key], o `null`.
  bool? getBool(String key);

  /// Almacena un valor [int] asociado a [key].
  Future<void> setInt(String key, int value);

  /// Recupera un valor [int] asociado a [key], o `null`.
  int? getInt(String key);

  /// Almacena un valor [double] asociado a [key].
  Future<void> setDouble(String key, double value);

  /// Recupera un valor [double] asociado a [key], o `null`.
  double? getDouble(String key);

  /// Almacena una lista de [String] asociada a [key].
  Future<void> setStringList(String key, List<String> value);

  /// Recupera una lista de [String] asociada a [key], o `null`.
  List<String>? getStringList(String key);

  /// Elimina el valor asociado a [key].
  Future<void> remove(String key);

  /// Verifica si existe un valor para [key].
  bool containsKey(String key);

  /// Elimina todos los valores almacenados.
  Future<void> clear();
}
