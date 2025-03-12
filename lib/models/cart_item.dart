import 'package:shopping_app/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String productType;

  CartItem({
    required this.product,
    required this.quantity,
    required this.productType,
  });

  @override
  String toString() {
    return 'CartItem{product: $product, quantity: $quantity, productType: $productType}';
  }
}
