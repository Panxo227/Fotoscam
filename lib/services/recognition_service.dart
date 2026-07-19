import 'dart:math';
import '../models/product.dart';

/// Servicio de reconocimiento. En modo "mock" elige un producto
/// aleatorio del catálogo. En modo "real" enchufarías aquí
/// Google ML Kit / Google Lens / tu modelo favorito.
class RecognitionService {
  static const bool useMock = true;

  final List<Product> _catalog = [
    Product(
      id: 'p_iphone15',
      name: 'iPhone 15 128GB',
      brand: 'Apple',
      imageUrl:
          'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-finish-select-202309-6-1inch?wid=5120&hei=2880',
      category: 'smartphone',
    ),
    Product(
      id: 'p_airpods',
      name: 'AirPods Pro 2',
      brand: 'Apple',
      imageUrl: 'https://example.com/airpods.jpg',
      category: 'audio',
    ),
    Product(
      id: 'p_ps5',
      name: 'PlayStation 5 Slim',
      brand: 'Sony',
      imageUrl: 'https://example.com/ps5.jpg',
      category: 'consola',
    ),
    Product(
      id: 'p_nespresso',
      name: 'Cafetera Nespresso Vertuo',
      brand: 'Nespresso',
      imageUrl: 'https://example.com/nespresso.jpg',
      category: 'hogar',
    ),
    Product(
      id: 'p_macbook',
      name: 'MacBook Air M2 13"',
      brand: 'Apple',
      imageUrl: 'https://example.com/macbook.jpg',
      category: 'laptop',
    ),
    Product(
      id: 'p_bose',
      name: 'Auriculares Bose QC Ultra',
      brand: 'Bose',
      imageUrl: 'https://example.com/bose.jpg',
      category: 'audio',
    ),
  ];

  Future<Product?> recognizeFromImage(String imagePath) async {
    // Simula latencia de la red/modelo
    await Future.delayed(const Duration(milliseconds: 1200));

    if (useMock) {
      final r = Random(imagePath.hashCode);
      return _catalog[r.nextInt(_catalog.length)];
    }
    // TODO: integrar Google ML Kit Object Detection o Google Vision
    return null;
  }

  List<Product> get catalog => List.unmodifiable(_catalog);
}
