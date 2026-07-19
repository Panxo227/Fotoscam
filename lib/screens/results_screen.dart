import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../services/price_service.dart';
import '../services/location_service.dart';
import 'nearby_map_screen.dart';

class ResultsScreen extends StatefulWidget {
  final Product product;
  const ResultsScreen({super.key, required this.product});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<List<PriceOffer>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<PriceService>().getOffers(widget.product);
  }

  Future<void> _shareOffer(PriceOffer o) async {
    final maps = LocationService.mapsUrl(o.latitude, o.longitude,
        label: o.storeName);
    final text = 'Encontré ${widget.product.name} en ${o.storeName} '
        'por ${o.price.toStringAsFixed(2)} ${o.currency}\n'
        'Tienda: $maps\n'
        'Producto: ${o.productUrl}';
    await Share.share(text, subject: 'SnapPrice: ${widget.product.name}');
  }

  Future<void> _openMaps(PriceOffer o) async {
    final uri = Uri.parse(
        LocationService.mapsUrl(o.latitude, o.longitude, label: o.storeName));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<List<PriceOffer>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final offers = snap.data!;
          if (offers.isEmpty) {
            return const Center(child: Text('Sin ofertas'));
          }
          final cheapest = offers.first;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Banner con el más barato
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mejor precio',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${cheapest.price.toStringAsFixed(2)} ${cheapest.currency}',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text('en ${cheapest.storeName} • '
                        '${cheapest.distanceKm.toStringAsFixed(2)} km'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.map),
                          label: const Text('Ver ruta'),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NearbyMapScreen(
                                offers: offers,
                                product: widget.product,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Compartir'),
                          onPressed: () => _shareOffer(cheapest),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Comparador de precios',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...offers.map((o) => _OfferTile(
                    offer: o,
                    onShare: () => _shareOffer(o),
                    onMap: () => _openMaps(o),
                    isCheapest: o == cheapest,
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final PriceOffer offer;
  final VoidCallback onShare;
  final VoidCallback onMap;
  final bool isCheapest;
  const _OfferTile({
    required this.offer,
    required this.onShare,
    required this.onMap,
    required this.isCheapest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isCheapest ? 4 : 1,
      color: isCheapest
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      child: ListTile(
        leading: CircleAvatar(child: Text(offer.storeName[0])),
        title: Text(offer.storeName,
            style: TextStyle(
                fontWeight:
                    isCheapest ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text(
            '${offer.distanceKm.toStringAsFixed(2)} km • ${offer.address}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${offer.price.toStringAsFixed(2)} ${offer.currency}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.directions, size: 20),
                  tooltip: 'Ir a Maps',
                  onPressed: onMap,
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  tooltip: 'Compartir',
                  onPressed: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
