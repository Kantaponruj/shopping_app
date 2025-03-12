import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/product.dart';
import 'package:shopping_app/screens/cart_page.dart';
import 'package:shopping_app/services/product_service.dart';
import 'package:shopping_app/viewmodels/cart_viewmodel.dart';
import 'package:shopping_app/widgets/product_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> _recommendedProductsFuture;
  int _currentPageIndex = 0;

  final ScrollController _scrollController = ScrollController();
  List<Product> _latestProducts = [];
  String _cursor = "";
  bool _isLoading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 0;
    _recommendedProductsFuture = ProductService.fetchRecommendedProducts();
    _loadInitialLatestProducts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLatestProducts() async {
    try {
      setState(() => _isLoading = true);
      final latestProduct =
          await ProductService.fetchProducts(limit: 20, cursor: "");
      setState(() {
        _latestProducts = latestProduct.items;
        _cursor = latestProduct.nextCursor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreLatestProducts() async {
    if (_isLoading || _cursor.isEmpty) return;

    try {
      setState(() => _isLoading = true);
      final latestProduct =
          await ProductService.fetchProducts(limit: 20, cursor: _cursor);

      setState(() {
        _latestProducts.addAll(latestProduct.items);
        _cursor = latestProduct.nextCursor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreLatestProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildRecommendedProductsSection(constraints),
                        _buildLatestProductsSection(constraints),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildRecommendedProductsSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Recommended Product",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
        SizedBox(
          height: constraints.maxHeight * 0.4,
          child: _buildRecommendedProductsList(),
        ),
      ],
    );
  }

  Widget _buildLatestProductsSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Text(
            "Latest Products",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (constraints.maxHeight * 0.5) - 36,
          ),
          child: _buildLatestProductsList(),
        ),
      ],
    );
  }

  Widget _buildRecommendedProductsList() {
    return FutureBuilder<List<Product>>(
      future: _recommendedProductsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ProductListLoading();
        } else if (snapshot.hasError) {
          return _buildErrorState(
            onRefresh: () {
              _recommendedProductsFuture =
                  ProductService.fetchRecommendedProducts();
            },
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        return ProductList(
          products: snapshot.data!,
          productType: ProductType.recommended,
          scrollable: true,
        );
      },
    );
  }

  Widget _buildLatestProductsList() {
    if (_error != null) {
      return _buildErrorState(
        onRefresh: () {
          setState(() => _error = null);
          _loadInitialLatestProducts();
        },
      );
    }

    if (_isLoading && _latestProducts.isEmpty) {
      return ProductListLoading();
    }

    if (_latestProducts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _latestProducts.length + (1),
      itemBuilder: (context, index) {
        if (index >= _latestProducts.length) {
          return _buildLoadingIndicator();
        }
        return ProductList(
          products: [_latestProducts[index]],
          productType: ProductType.latest,
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: const CircularProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "Loading..",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({required VoidCallback onRefresh}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: Icon(
              size: 65,
              Icons.cancel_outlined,
              color: Color(0xFFB3261E),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Something went wrong",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          FilledButton(
            onPressed: onRefresh,
            child: Text("Refresh"),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            child: Icon(
              Icons.cancel,
              color: Color(0xFFB3261E),
            ),
          ),
          Text(
            "No products available",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        String cartLabel = 'Cart';
        if (cartViewModel.cart.isNotEmpty) {
          cartLabel += ' (${cartViewModel.getTotalItemCount()})';
        }

        return NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _currentPageIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              ).then((_) {
                setState(() {
                  _currentPageIndex = 0;
                });
              });
            }
          },
          selectedIndex: _currentPageIndex,
          destinations: <Widget>[
            const NavigationDestination(
              selectedIcon: Icon(Icons.stars),
              icon: Icon(Icons.stars_outlined),
              label: 'Shopping',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.stars),
              icon: Icon(Icons.stars_outlined),
              label: cartLabel,
            ),
          ],
        );
      },
    );
  }
}
