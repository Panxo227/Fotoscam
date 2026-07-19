class Product {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        brand: json['brand'],
        imageUrl: json['imageUrl'],
        category: json['category'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'imageUrl': imageUrl,
        'category': category,
      };
}

class PriceOffer {
  final String productId;
  final String storeName;
  final String storeLogo;
  final double price;
  final String currency;
  final String productUrl;
  final double latitude;
  final double longitude;
  final String address;
  final double distanceKm;

  PriceOffer({
    required this.productId,
    required this.storeName,
    required this.storeLogo,
    required this.price,
    required this.currency,
    required this.productUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.distanceKm,
  });

  factory PriceOffer.fromJson(Map<String, dynamic> json) => PriceOffer(
        productId: json['productId'],
        storeName: json['storeName'],
        storeLogo: json['storeLogo'],
        price: (json['price'] as num).toDouble(),
        currency: json['currency'],
        productUrl: json['productUrl'],
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'],
        distanceKm: (json['distanceKm'] as num).toDouble(),
      );
}
