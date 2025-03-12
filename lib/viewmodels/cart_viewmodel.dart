import 'package:flutter/material.dart';
import 'package:shopping_app/models/cart_item.dart';
import 'package:shopping_app/models/product.dart';
import 'package:shopping_app/services/product_service.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _cart = [];

  List<CartItem> get cart => _cart;

  void addToCart(Product product, String productType) {
    final existingItemIndex = _cart.indexWhere((item) =>
        item.product.id == product.id && item.productType == productType);

    if (existingItemIndex != -1) {
      _cart[existingItemIndex].quantity++;
    } else {
      _cart.add(
          CartItem(product: product, quantity: 1, productType: productType));
    }
    notifyListeners();
  }

  void removeFromCart(Product product, String productType) {
    final existingItemIndex = _cart.indexWhere((item) =>
        item.product.id == product.id && item.productType == productType);

    if (existingItemIndex != -1) {
      if (_cart[existingItemIndex].quantity > 1) {
        _cart[existingItemIndex].quantity--;
      } else {
        _cart.removeAt(existingItemIndex);
      }
      notifyListeners();
    }
  }

  void deleteFromCart(Product product, String productType) {
    _cart.removeWhere((item) =>
        item.product.id == product.id && item.productType == productType);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  int getTotalItemCount() {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  double calculateTotalWithoutDiscount() {
    double total = _cart.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
    return total;
  }

  double calculateTotalDiscount() {
    double discount = 0;
    for (var item in _cart) {
      int pairs = item.quantity ~/ 2; // Count number of pairs
      discount += (item.product.price * 0.05) * pairs; // 5% discount per pair
    }
    return discount;
  }

  double calculateFinalTotal() {
    final finalTotal =
        calculateTotalWithoutDiscount() - calculateTotalDiscount();

    return finalTotal;
  }

  CartItem? findProduct(Product product, String productType) {
    try {
      return _cart.firstWhere((item) =>
          item.product.id == product.id && item.productType == productType);
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkout(BuildContext context) async {
    try {
      final requestBody = {
        "products": _cart.map((item) => item.product.id).toList(),
      };

      int resCode = await ProductService.checkout(requestBody);

      if (resCode == 204) {
        clearCart();
        notifyListeners();
        return true;
      } else {
        debugPrint("Checkout failed with status code: $resCode");
        return false;
      }
    } catch (e) {
      debugPrint("Error during checkout: $e");
      return false;
    }
  }
}
