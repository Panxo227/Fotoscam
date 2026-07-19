import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../services/location_service.dart';

class NearbyMapScreen extends StatelessWidget {
  final List<PriceOffer> offers;
  final Product product;
  const NearbyMapScreen({
    super.key,
    required this.offers,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final userLat = context.read<LocationService>().lastLat ?? offers.first.latitude;
    final userLng = context.read<LocationService>().lastLng ?? offers.first.longitude;
    final userPoint = LatLng(userLat, userLng);
    final cheapest = offers.first;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tiendas cerca de ti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final maps = LocationService.mapsUrl(
                  cheapest.latitude, cheapest.longitude,
                  label: cheapest.storeName);
              await launchUrl(Uri.parse(maps),
                  mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: userPoint,
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.snapprice.app',
          ),
          MarkerLayer(
            markers: [
              // Usuario
              Marker(
                point: userPoint,
                width: 40,
                height: 40,
                child: const Icon(Icons.person_pin_circle,
                    color: Colors.blue, size: 40),
              ),
              // Tiendas
              for (final o in offers)
                Marker(
                  point: LatLng(o.latitude, o.longitude),
                  width: 50,
                  height: 50,
                  child: Tooltip(
                    message:
                        '${o.storeName} • ${o.price.toStringAsFixed(2)} ${o.currency}',
                    child: Icon(
                      Icons.local_offer,
                      color: o == cheapest ? Colors.red : Colors.orange,
                      size: 40,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.directions),
        label: const Text('Ir al más barato'),
        onPressed: () {
          final url = LocationService.mapsUrl(
              cheapest.latitude, cheapest.longitude,
              label: cheapest.storeName);
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        },
      ),
    );
  }
}
