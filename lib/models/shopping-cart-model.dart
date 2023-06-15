import 'package:ordernow/models/productshoppingcart.dart';

class ShoppingCart {
  final String shoppingCartId;
  final List<ProductShoppingCart> productList;
  final double total;

  ShoppingCart({
    required this.shoppingCartId,
    required this.productList,
    required this.total,
  });

  factory ShoppingCart.fromJson(Map<String, dynamic> json) {
    final productList = (json['productList'] as List)
        .map((productJson) => ProductShoppingCart(
              code: productJson['code'],
              price: productJson['price'].toDouble(),
              name: productJson['name'],
              quantity: productJson['quantity'],
            ))
        .toList();

    return ShoppingCart(
      shoppingCartId: json['shoppingCartId'],
      productList: productList,
      total: json['total'].toDouble(),
    );
  }
}