import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/history_entry.dart';
import '../services/history_service.dart';
import '../services/price_alert_worker.dart';
import 'results_screen.dart';
import '../models/product.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Escucha alertas y muestra un SnackBar cuando se dispare alguna
    final worker = context.read<PriceAlertWorker>();
    worker.alerts.listen((entry) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text('🔔 ¡${entry.productName} bajó a '
            '${entry.bestPrice.toStringAsFixed(2)} ${entry.currency}!'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<HistoryService>().favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar precios',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PriceAlertWorker>().checkNow(),
          ),
        ],
      ),
      body: favs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.star_border, size: 80, color: Colors.amber),
                  SizedBox(height: 12),
                  Text('No tienes favoritos aún'),
                  SizedBox(height: 4),
                  Text('Marca con la estrella en el historial',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: favs.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final e = favs[i];
                final alerted = e.targetPrice != null &&
                    e.bestPrice <= e.targetPrice!;
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(e.productName),
                  subtitle: Text(
                    '${e.bestStore} • '
                    '${e.bestPrice.toStringAsFixed(2)} ${e.currency}'
                    '${e.targetPrice != null ? "  (objetivo ${e.targetPrice!.toStringAsFixed(2)})" : ""}'
                    '${alerted ? "  🔔" : ""}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResultsScreen(
                        product: Product(
                          id: e.productId,
                          name: e.productName,
                          brand: e.brand,
                          imageUrl: e.imageUrl,
                          category: e.category,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
