import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/history_entry.dart';
import 'history_service.dart';

/// Worker que "simula" la monitorización de precios para favoritos.
/// En una app real, esto sería un cron en backend o un push (FCM).
class PriceAlertWorker {
  final HistoryService history;
  Timer? _timer;
  final _alertController = StreamController<HistoryEntry>.broadcast();

  PriceAlertWorker(this.history);

  Stream<HistoryEntry> get alerts => _alertController.stream;

  /// Arranca la revisión cada [interval]. Por defecto 6 h.
  void start({Duration interval = const Duration(hours: 6)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _tick());
    if (kDebugMode) {
      debugPrint('PriceAlertWorker started (every ${interval.inMinutes} min)');
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Revisa una vez (útil desde la UI para "actualizar ahora").
  Future<void> checkNow() => _tick();

  Future<void> _tick() async {
    if (!history.isLoaded) await history.load();
    for (final entry in history.favorites) {
      if (entry.targetPrice == null) continue;
      // Simula un nuevo precio +-5% del actual
      final r = Random(entry.id.hashCode + DateTime.now().day);
      final delta = (r.nextDouble() - 0.5) * 0.10; // ±5%
      final newPrice =
          (entry.bestPrice * (1 + delta)).clamp(1.0, double.infinity);
      final updated = entry.copyWith(bestPrice: newPrice.toDouble());

      // Sustituir en el historial
      await history.replace(updated);

      if (updated.bestPrice <= updated.targetPrice!) {
        _alertController.add(updated);
      }
    }
  }
}
