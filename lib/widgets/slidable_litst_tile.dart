import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.productNumber,
    required this.name,
    required this.price,
    required this.onPressedAddProduct,
    required this.onPressedRemoveProduct,
    required this.id,
    this.onPressedDelete,
  });

  final String id;
  final String name;
  final String price;
  final VoidCallback onPressedAddProduct;
  final VoidCallback onPressedRemoveProduct;
  final int productNumber;
  final VoidCallback? onPressedDelete;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: key,
      endActionPane: onPressedDelete != null
          ? ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    onPressedDelete!();
                  },
                  backgroundColor: Color(0xFFB3261E),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                ),
              ],
            )
          : null,
      child: ListTile(
        minTileHeight: 76,
        leading: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(
                'assets/images/empty.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: RichText(
            text: TextSpan(
          children: [
            TextSpan(
              text: price,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextSpan(
              text: ' / unit',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        )),
        trailing: productNumber > 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filled(
                    onPressed: onPressedRemoveProduct,
                    iconSize: 24,
                    icon: Icon(
                      Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      productNumber.toString(),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: onPressedAddProduct,
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : FilledButton(
                onPressed: onPressedAddProduct,
                child: Text('Add to cart'),
              ),
      ),
    );
  }
}

class CustomListTileLoading extends StatelessWidget {
  const CustomListTileLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: key,
      child: ListTile(
        minTileHeight: 76,
        leading: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(
                'assets/images/empty.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Container(
          margin: EdgeInsets.only(bottom: 20),
          width: 152,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(
              0xFFE6E0E9,
            ),
          ),
        ),
        subtitle: Container(
          width: 96,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(
              0xFFE6E0E9,
            ),
          ),
        ),
      ),
    );
  }
}
