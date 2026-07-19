import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/history_entry.dart';
import '../models/product.dart';

/// Servicio de historial + favoritos + alertas de bajada de precio.
/// Persistencia con SharedPreferences.
class HistoryService extends ChangeNotifier {
  static const _kKey = 'history_entries_v1';

  final List<HistoryEntry> _items = [];
  bool _loaded = false;

  List<HistoryEntry> get items => List.unmodifiable(_items);
  List<HistoryEntry> get favorites =>
      _items.where((e) => e.favorite).toList(growable: false);

  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    _items.clear();
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final j in list) {
        _items.add(HistoryEntry.fromJson(j as Map<String, dynamic>));
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, encoded);
    notifyListeners();
  }

  /// Registra (o actualiza) una búsqueda. Devuelve la entrada.
  Future<HistoryEntry> log({
    required Product product,
    required double bestPrice,
    required String bestStore,
    required String currency,
  }) async {
    final existing = _items.indexWhere((e) => e.productId == product.id);
    final now = DateTime.now();

    if (existing >= 0) {
      final prev = _items[existing];
      final trend = [...prev.priceTrend, prev.bestPrice];
      // limitar a los últimos 30 puntos
      if (trend.length > 30) {
        trend.removeRange(0, trend.length - 30);
      }
      final updated = prev.copyWith(
        bestPrice: bestPrice,
        bestStore: bestStore,
        searchedAt: now,
        priceTrend: trend,
      );
      _items[existing] = updated;
      await _persist();
      return updated;
    }

    final entry = HistoryEntry(
      id: const Uuid().v4(),
      productId: product.id,
      productName: product.name,
      brand: product.brand,
      imageUrl: product.imageUrl,
      category: product.category,
      bestPrice: bestPrice,
      currency: currency,
      bestStore: bestStore,
      searchedAt: now,
      priceTrend: [bestPrice],
    );
    _items.insert(0, entry);
    await _persist();
    return entry;
  }

  Future<void> toggleFavorite(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(favorite: !_items[i].favorite);
    await _persist();
  }

  Future<void> setTargetPrice(String id, double? price) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(targetPrice: price);
    await _persist();
  }

  /// Reemplaza una entrada por una versión más nueva (usado por workers).
  @visibleForTesting
  Future<void> replace(HistoryEntry entry) async {
    final i = _items.indexWhere((e) => e.id == entry.id);
    if (i < 0) return;
    _items[i] = entry;
    await _persist();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _persist();
  }

  Future<void> clear() async {
    _items.clear();
    await _persist();
  }

  /// Detecta entradas con alerta (precio <= objetivo).
  List<HistoryEntry> get triggeredAlerts => _items
      .where((e) =>
          e.favorite && e.targetPrice != null && e.bestPrice <= e.targetPrice!)
      .toList(growable: false);
}
