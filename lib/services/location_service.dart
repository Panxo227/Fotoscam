import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class LocationService {
  double? lastLat;
  double? lastLng;

  Future<bool> ensurePermission() async {
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  Future<void> getCurrent() async {
    final ok = await ensurePermission();
    if (!ok) return;
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    lastLat = pos.latitude;
    lastLng = pos.longitude;
  }

  /// Distancia en km entre dos puntos (fórmula de Haversine).
  static double haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _rad(double deg) => deg * (math.pi / 180.0);

  /// Link universal de Google Maps para una coordenada.
  static String mapsUrl(double lat, double lng, {String? label}) {
    final q = label == null
        ? '$lat,$lng'
        : '$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(label)})';
    return 'https://www.google.com/maps/search/?api=1&query=$q';
  }
}
