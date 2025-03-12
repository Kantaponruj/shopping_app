import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/product.dart';
import 'package:shopping_app/viewmodels/cart_viewmodel.dart';
import 'package:shopping_app/widgets/slidable_litst_tile.dart';

class ProductList extends StatefulWidget {
  const ProductList({
    super.key,
    required this.products,
    this.scrollable = false,
    required this.productType,
    this.isLoading = false,
  });

  final List<Product> products;
  final String productType;
  final bool scrollable;
  final bool? isLoading;

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    return ListView.builder(
      physics: widget.scrollable ? null : const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        Product product = widget.products[index];
        final productType = widget.productType;
        return CustomListTile(
          id: product.id.toString(),
          name: product.name,
          price: product.price.toString(),
          onPressedAddProduct: () {
            cartViewModel.addToCart(product, productType);
            setState(() {});
          },
          onPressedRemoveProduct: () {
            cartViewModel.removeFromCart(product, productType);
            setState(() {});
          },
          productNumber:
              cartViewModel.findProduct(product, productType)?.quantity ?? 0,
        );
      },
    );
  }
}

class ProductListLoading extends StatefulWidget {
  const ProductListLoading({
    super.key,
  });

  @override
  State<ProductListLoading> createState() => _ProductListLoadingState();
}

class _ProductListLoadingState extends State<ProductListLoading> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder: (context, index) {
        return CustomListTileLoading();
      },
    );
  }
}
