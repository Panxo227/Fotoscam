import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/history_service.dart';
import '../services/recognition_service.dart';
import '../services/location_service.dart';
import '../services/price_service.dart';
import 'results_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final _recognition = RecognitionService();
  final _location = LocationService();
  bool _busy = false;

  Future<void> _capture(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final x = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (x == null) return;

      // asegúrate de tener la ubicación antes de buscar
      await _location.getCurrent();
      if (mounted) {
        context.read<LocationService>().lastLat = _location.lastLat;
        context.read<LocationService>().lastLng = _location.lastLng;
      }

      final product = await _recognition.recognizeFromImage(x.path);
      if (!mounted) return;
      if (product != null) {
        // Pide las ofertas y registra la búsqueda en el historial
        final offers = await context.read<PriceService>().getOffers(product);
        if (offers.isNotEmpty && mounted) {
          await context.read<HistoryService>().log(
                product: product,
                bestPrice: offers.first.price,
                bestStore: offers.first.storeName,
                currency: offers.first.currency,
              );
        }
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResultsScreen(product: product),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo identificar el producto')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapPrice'),
        actions: [
          IconButton(
            tooltip: 'Historial',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Favoritos',
            icon: const Icon(Icons.star),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(Icons.search, size: 120, color: cs.primary),
            const SizedBox(height: 16),
            Text('¿Qué estás buscando?',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Sácale una foto al producto y te mostramos dónde está más barato cerca de ti.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Analizando imagen...'),
                  ],
                ),
              )
            else
              Column(
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar foto'),
                    onPressed: () => _capture(ImageSource.camera),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Elegir de la galería'),
                    onPressed: () => _capture(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
