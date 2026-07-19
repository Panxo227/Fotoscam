class HistoryEntry {
  final String id;
  final String productId;
  final String productName;
  final String brand;
  final String imageUrl;
  final String category;
  final double bestPrice;
  final String currency;
  final String bestStore;
  final DateTime searchedAt;
  final bool favorite;
  final double? targetPrice; // para alertas
  final List<double> priceTrend; // histórico de precios

  HistoryEntry({
    required this.id,
    required this.productId,
    required this.productName,
    required this.brand,
    required this.imageUrl,
    required this.category,
    required this.bestPrice,
    required this.currency,
    required this.bestStore,
    required this.searchedAt,
    this.favorite = false,
    this.targetPrice,
    List<double>? priceTrend,
  }) : priceTrend = priceTrend ?? <double>[];

  HistoryEntry copyWith({
    bool? favorite,
    double? targetPrice,
    double? bestPrice,
    String? bestStore,
    DateTime? searchedAt,
    List<double>? priceTrend,
  }) =>
      HistoryEntry(
        id: id,
        productId: productId,
        productName: productName,
        brand: brand,
        imageUrl: imageUrl,
        category: category,
        bestPrice: bestPrice ?? this.bestPrice,
        currency: currency,
        bestStore: bestStore ?? this.bestStore,
        searchedAt: searchedAt ?? this.searchedAt,
        favorite: favorite ?? this.favorite,
        targetPrice: targetPrice ?? this.targetPrice,
        priceTrend: priceTrend ?? this.priceTrend,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'brand': brand,
        'imageUrl': imageUrl,
        'category': category,
        'bestPrice': bestPrice,
        'currency': currency,
        'bestStore': bestStore,
        'searchedAt': searchedAt.toIso8601String(),
        'favorite': favorite,
        'targetPrice': targetPrice,
        'priceTrend': priceTrend,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        id: j['id'],
        productId: j['productId'],
        productName: j['productName'],
        brand: j['brand'],
        imageUrl: j['imageUrl'],
        category: j['category'],
        bestPrice: (j['bestPrice'] as num).toDouble(),
        currency: j['currency'],
        bestStore: j['bestStore'],
        searchedAt: DateTime.parse(j['searchedAt']),
        favorite: j['favorite'] ?? false,
        targetPrice: (j['targetPrice'] as num?)?.toDouble(),
        priceTrend: (j['priceTrend'] as List?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            <double>[],
      );
}
