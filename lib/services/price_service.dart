import 'dart:async';
import 'dart:math';
import '../models/product.dart';
import 'location_service.dart';

class PriceService {
  final LocationService _location;

  PriceService(this._location);

  /// Simula una API de comparación de precios.
  /// Devuelve ofertas cercanas ordenadas por precio ascendente.
  Future<List<PriceOffer>> getOffers(Product product) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final userLat = _location.lastLat ?? 40.4168; // Madrid fallback
    final userLng = _location.lastLng ?? -3.7038;

    final r = Random(product.id.hashCode);
    final stores = [
      _mkStore('Amazon', 0.95 + r.nextDouble() * 0.4, userLat, userLng,
          'https://amazon.es/dp/${product.id}'),
      _mkStore('MediaMarkt', 0.92 + r.nextDouble() * 0.5, userLat, userLng,
          'https://mediamarkt.es/p/${product.id}'),
      _mkStore('El Corte Inglés', 0.99 + r.nextDouble() * 0.3, userLat,
          userLng, 'https://elcorteingles.es/${product.id}'),
      _mkStore('PCComponentes', 0.90 + r.nextDouble() * 0.6, userLat, userLng,
          'https://pccomponentes.com/${product.id}'),
      _mkStore('Fnac', 0.97 + r.nextDouble() * 0.4, userLat, userLng,
          'https://fnac.es/${product.id}'),
    ];

    stores.sort((a, b) => a.price.compareTo(b.price));
    return stores;
  }

  PriceOffer _mkStore(String name, double priceFactor, double userLat,
      double userLng, String url) {
    final r = Random(name.hashCode);
    // tiendas dentro de ~3 km
    final lat = userLat + (r.nextDouble() - 0.5) * 0.04;
    final lng = userLng + (r.nextDouble() - 0.5) * 0.04;
    final basePrice = 100.0; // precio base ficticio
    final price = double.parse((basePrice * priceFactor).toStringAsFixed(2));
    return PriceOffer(
      productId: '',
      storeName: name,
      storeLogo: 'https://logo.clearbit.com/${name.toLowerCase().replaceAll(' ', '')}.com',
      price: price,
      currency: 'EUR',
      productUrl: url,
      latitude: lat,
      longitude: lng,
      address: 'Calle $name ${1 + r.nextInt(150)}, Madrid',
      distanceKm: LocationService.haversine(userLat, userLng, lat, lng),
    );
  }
}
