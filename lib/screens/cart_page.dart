import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/cart_item.dart';
import 'package:shopping_app/viewmodels/cart_viewmodel.dart';
import 'package:shopping_app/widgets/slidable_litst_tile.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _checkoutSuccessful = false;

  void _setCheckoutSuccessful(bool value) {
    setState(() {
      _checkoutSuccessful = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: SafeArea(
        child: Consumer<CartViewModel>(
          builder: (context, cartViewModel, child) {
            if (cartViewModel.cart.isEmpty) {
              return _checkoutSuccessful ? _CheckoutSucceed() : _EmptyCart();
            } else {
              return _CartList(cartViewModel: cartViewModel);
            }
          },
        ),
      ),
      bottomNavigationBar: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          return cartViewModel.cart.isEmpty
              ? const SizedBox.shrink()
              : _CartSummary(
                  cartViewModel: cartViewModel,
                  onCheckoutSuccess: _setCheckoutSuccessful, // Pass callback
                );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Empty Cart",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.black),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Go to shopping',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSucceed extends StatelessWidget {
  const _CheckoutSucceed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Success!",
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Thank you for shopping with us!",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Colors.black),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Shop again',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  const _CartList({required this.cartViewModel});

  final CartViewModel cartViewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cartViewModel.cart.length,
      itemBuilder: (context, index) {
        final CartItem item = cartViewModel.cart[index];

        return CustomListTile(
          id: item.product.id.toString(),
          name: item.product.name,
          price: item.product.price.toString(),
          onPressedAddProduct: () {
            cartViewModel.addToCart(item.product, item.productType);
          },
          onPressedRemoveProduct: () {
            cartViewModel.removeFromCart(item.product, item.productType);
          },
          onPressedDelete: () {
            cartViewModel.deleteFromCart(item.product, item.productType);
          },
          productNumber: cartViewModel
                  .findProduct(item.product, item.productType)
                  ?.quantity ??
              0,
        );
      },
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary(
      {required this.cartViewModel, required this.onCheckoutSuccess});

  final CartViewModel cartViewModel;
  final Function(bool) onCheckoutSuccess;

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat("#,##0.00");
    final double discount = cartViewModel.calculateTotalDiscount();

    return BottomAppBar(
      height: 163,
      color: const Color(0xFFE8DEF8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Subtotal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  currencyFormat.format(
                    cartViewModel.calculateTotalWithoutDiscount(),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Text(
                    'Promotion discount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  (discount > 0)
                      ? Text(
                          "-${currencyFormat.format(
                            cartViewModel.calculateTotalDiscount(),
                          )}",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: const Color(0xFFB3261E)),
                        )
                      : Text(
                          currencyFormat.format(
                            cartViewModel.calculateTotalDiscount(),
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  Text(
                    currencyFormat.format(
                      cartViewModel.calculateFinalTotal(),
                    ),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final theme = Theme.of(context);
                      bool success = await cartViewModel.checkout(context);
                      if (success) {
                        onCheckoutSuccess(true);
                      } else {
                        onCheckoutSuccess(false);
                        messenger.showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFFB3261E),
                            behavior: SnackBarBehavior.floating,
                            showCloseIcon: true,
                            margin: EdgeInsets.only(bottom: 7),
                            content: Text(
                              'Something went wrong',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: const Color(0xFFF5EFF7),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 10.0,
                      ),
                      child: Text(
                        'Checkout',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
