import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ordernow/constants/endpoint.dart';
import 'package:ordernow/main.dart';
import 'package:ordernow/models/product.dart';
import '../../dialogs/dialogs.dart';
import '../shopping-cart/shopping-cart.dart';

class ProductListScreen extends StatefulWidget {
  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  List<Product> productsList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('$apiEndpoint/rest/product/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final products = (jsonBody as List).map((e) => Product.fromJson(e)).toList();
      setState(() {
        productsList = products;
      });
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_sharp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage(title: 'HomePage')),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/order.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: productsList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: productsList.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final product = productsList[index];
                  return Container(
                    color: Colors.white.withOpacity(0.7),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(product.brand),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('\$${product.price.toString()}'),
                          ElevatedButton(
                            onPressed: () {
                              Dialogs.showQuantityDialog(product.code, context);
                            },
                            child: Text('Add'),
                            style: ElevatedButton.styleFrom(primary: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShoppingCartScreen()),
          );
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}