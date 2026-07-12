/// Rate limiter para prevenir abusos en Edge Functions y endpoints.
///
/// Usa el algoritmo token bucket: permite [maxRequests] en [windowMs].
/// Las peticiones que exceden el límite retornan 429.
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Map<String, _Bucket> _buckets = {};

  RateLimiter({this.maxRequests = 10, this.window = const Duration(seconds: 60)});

  /// Verifica si [clientId] puede hacer una petición.
  /// Retorna `true` si está dentro del límite.
  bool tryAcquire(String clientId) {
    final now = DateTime.now();
    final bucket = _buckets.putIfAbsent(
      clientId,
      () => _Bucket(tokens: maxRequests, lastRefill: now),
    );

    _refill(bucket, now);

    if (bucket.tokens > 0) {
      bucket.tokens--;
      return true;
    }
    return false;
  }

  void _refill(_Bucket bucket, DateTime now) {
    final elapsed = now.difference(bucket.lastRefill);
    final tokensToAdd = (elapsed.inMilliseconds / window.inMilliseconds * maxRequests).floor();
    if (tokensToAdd > 0) {
      bucket.tokens = (bucket.tokens + tokensToAdd).clamp(0, maxRequests);
      bucket.lastRefill = now;
    }
  }

  /// Devuelve los segundos restantes hasta que [clientId] pueda hacer otra petición.
  int remainingSeconds(String clientId) {
    final bucket = _buckets[clientId];
    if (bucket == null || bucket.tokens > 0) return 0;
    final elapsed = DateTime.now().difference(bucket.lastRefill);
    final remaining = (window.inMilliseconds - elapsed.inMilliseconds) ~/ 1000;
    return remaining > 0 ? remaining : 0;
  }

  /// Limpia buckets inactivos para liberar memoria.
  void cleanup() {
    final cutoff = DateTime.now().subtract(window * 2);
    _buckets.removeWhere((_, b) => b.lastRefill.isBefore(cutoff));
  }
}

class _Bucket {
  int tokens;
  DateTime lastRefill;
  _Bucket({required this.tokens, required this.lastRefill});
}
