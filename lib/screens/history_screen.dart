import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/history_entry.dart';
import '../models/product.dart';
import '../services/history_service.dart';
import 'results_screen.dart';
import 'favorites_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = context.watch<HistoryService>();
    final items = h.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            tooltip: 'Ver favoritos',
            icon: const Icon(Icons.star),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Vaciar',
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: items.isEmpty
          ? const _Empty()
          : RefreshIndicator(
              onRefresh: () => h.load(),
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (_, i) => _HistoryTile(entry: items[i]),
              ),
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final h = context.read<HistoryService>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Vaciar historial?'),
        content: const Text('Se eliminarán todas las búsquedas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (ok == true) await h.clear();
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final h = context.read<HistoryService>();
    final cs = Theme.of(context).colorScheme;
    final alerted = entry.favorite &&
        entry.targetPrice != null &&
        entry.bestPrice <= entry.targetPrice!;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.primaryContainer,
        child: Icon(_iconFor(entry.category), color: cs.onPrimaryContainer),
      ),
      title: Text(entry.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${entry.bestStore} • ${entry.bestPrice.toStringAsFixed(2)} ${entry.currency}'
        '${alerted ? "  🔔 BAJÓ" : ""}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: entry.favorite ? 'Quitar de favoritos' : 'Marcar favorito',
            icon: Icon(
              entry.favorite ? Icons.star : Icons.star_border,
              color: entry.favorite ? Colors.amber : null,
            ),
            onPressed: () => h.toggleFavorite(entry.id),
          ),
          IconButton(
            tooltip: 'Alerta de precio',
            icon: Icon(
              entry.targetPrice == null
                  ? Icons.notifications_none
                  : Icons.notifications_active,
              color: entry.targetPrice == null ? null : cs.primary,
            ),
            onPressed: () => _editTarget(context, entry),
          ),
        ],
      ),
      onTap: () => _openResults(context, entry),
      onLongPress: () => _confirmDelete(context, entry),
    );
  }

  Future<void> _editTarget(BuildContext context, HistoryEntry entry) async {
    final c = TextEditingController(
        text: entry.targetPrice?.toStringAsFixed(2) ?? '');
    final h = context.read<HistoryService>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Avísame cuando baje a...'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            suffixText: entry.currency,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final v = double.tryParse(c.text.replaceAll(',', '.'));
      await h.setTargetPrice(entry.id, v);
    }
  }

  Future<void> _confirmDelete(BuildContext context, HistoryEntry entry) async {
    final h = context.read<HistoryService>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: Text(entry.productName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) await h.remove(entry.id);
  }

  void _openResults(BuildContext context, HistoryEntry e) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResultsScreen(
        product: Product(
          id: e.productId,
          name: e.productName,
          brand: e.brand,
          imageUrl: e.imageUrl,
          category: e.category,
        ),
      ),
    ));
  }

  IconData _iconFor(String cat) {
    switch (cat) {
      case 'smartphone':
        return Icons.phone_iphone;
      case 'audio':
        return Icons.headphones;
      case 'laptop':
        return Icons.laptop_mac;
      case 'consola':
        return Icons.sports_esports;
      case 'hogar':
        return Icons.kitchen;
      default:
        return Icons.shopping_bag;
    }
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Theme.of(context).hintColor),
          const SizedBox(height: 12),
          const Text('Aún no has buscado nada'),
        ],
      ),
    );
  }
}
