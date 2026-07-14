import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class TileCacheService {
  static const int _maxMemoryTiles = 200;
  static const int _maxDiskTiles = 5000;

  final Map<String, _TileEntry> _memory = {};
  String? _cacheDir;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _cacheDir = '${dir.path}/osm_tiles';
    final d = Directory(_cacheDir!);
    if (!await d.exists()) await d.create(recursive: true);
    _pruneDisk();
  }

  Future<Uint8List?> get(String url) async {
    final key = _urlToKey(url);
    final mem = _memory[key];
    if (mem != null) {
      mem.lastAccess = DateTime.now();
      return mem.data;
    }
    if (_cacheDir == null) return null;
    final file = File('$_cacheDir/$key');
    if (await file.exists()) {
      final data = await file.readAsBytes();
      _memory[key] = _TileEntry(data, DateTime.now());
      _evictMemory();
      return data;
    }
    return null;
  }

  Future<void> put(String url, Uint8List data) async {
    final key = _urlToKey(url);
    _memory[key] = _TileEntry(data, DateTime.now());
    _evictMemory();
    if (_cacheDir != null) {
      try {
        await File('$_cacheDir/$key').writeAsBytes(data);
        _pruneDisk();
      } catch (_) {}
    }
  }

  void _evictMemory() {
    if (_memory.length <= _maxMemoryTiles) return;
    final sorted = _memory.entries.toList()
      ..sort((a, b) => a.value.lastAccess.compareTo(b.value.lastAccess));
    final toRemove = sorted.take(_memory.length - _maxMemoryTiles);
    for (final e in toRemove) _memory.remove(e.key);
  }

  Future<void> _pruneDisk() async {
    if (_cacheDir == null) return;
    try {
      final dir = Directory(_cacheDir!);
      final files = await dir.list().toList();
      if (files.length > _maxDiskTiles) {
        final sorted = files
          .map((f) => (f as File))
          .toList()
        ..sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
        final toDelete = sorted.take(files.length - _maxDiskTiles);
        for (final f in toDelete) {
          try { await f.delete(); } catch (_) {}
        }
      }
    } catch (_) {}
  }

  String _urlToKey(String url) => url.replaceAll(RegExp('[/:?=&]'), '_');

  void clear() {
    _memory.clear();
    if (_cacheDir != null) {
      try { Directory(_cacheDir!).deleteSync(recursive: true); } catch (_) {}
    }
  }
}

class _TileEntry { final Uint8List data; DateTime lastAccess; _TileEntry(this.data, this.lastAccess); }
