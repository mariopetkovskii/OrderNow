import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ordernow/constants/endpoint.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/productshoppingcart.dart';
import '../../models/shopping-cart-model.dart';
import '../products/products.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  List<ProductShoppingCart> productList = [];
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    fetchShoppingCart();
  }

  Future<void> fetchShoppingCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$apiEndpoint/rest/shopping-cart/get-shopping-cart');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final shoppingCart = ShoppingCart.fromJson(jsonData);

      setState(() {
        productList = shoppingCart.productList;
        total = shoppingCart.total;
      });
    } else {
      throw Exception('Failed to fetch shopping cart');
    }
  }

  Future<void> removeProductFromCart(String productCode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$apiEndpoint/rest/shopping-cart/delete-item');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'productCode': productCode}),
    );

    if (response.statusCode == 200) {
      await fetchShoppingCart();
    } else {
      throw Exception('Failed to remove product from cart');
    }
  }

  Future<void> placeOrder(String address) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse('$apiEndpoint/rest/order/placeOrder');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'deliveryAddress': address,
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Order Success'),
            content: Text('Thank you for your order. Check your email for more details.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductListScreen()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to place order');
      }
    } catch (e) {
      print('Error placing order: $e');
      // Handle order placement error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to place the order.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/order.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: productList.isEmpty
            ? Center(child: Text('Shopping cart is empty'))
            : ListView.builder(
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final product = productList[index];
                  return Container(
                    color: Colors.white.withOpacity(0.7),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text('Quantity: ${product.quantity.toString()}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${product.price.toStringAsFixed(2)}'),
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () {
                              removeProductFromCart(product.code);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: Container(
        color: Colors.orange,
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddressInputDialog(
                    onOrderPlaced: (address) {
                      placeOrder(address);
                    },
                  ),
                );
              },
              child: Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressInputDialog extends StatefulWidget {
  final Function(String) onOrderPlaced;

  AddressInputDialog({required this.onOrderPlaced});

  @override
  _AddressInputDialogState createState() => _AddressInputDialogState();
}

class _AddressInputDialogState extends State<AddressInputDialog> {
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Address'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: addressController,
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final address = addressController.text;
            widget.onOrderPlaced(address);
            Navigator.pop(context);
          },
          child: Text('Order'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}