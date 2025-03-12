class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }
}

class LatestProduct {
  final List<Product> items;
  final String nextCursor;

  LatestProduct({required this.items, required this.nextCursor});

  factory LatestProduct.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List;
    List<Product> itemsList =
        itemsJson.map((item) => Product.fromJson(item)).toList();

    return LatestProduct(
      items: itemsList,
      nextCursor: json['nextCursor'] as String,
    );
  }
}

class ProductType {
  static const recommended = "recommended";
  static const latest = "latest";
}
