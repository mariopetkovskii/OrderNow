import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ordernow/constants/endpoint.dart';
import 'package:ordernow/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsApiService {
  static Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('$apiEndpoint/rest/product/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final products = (response as List).map((e) => Product.fromJson(e)).toList();
      return products;
    } else {
      throw Exception('Failed to fetch products');
    }
  }


  static Future<void> addToCart(String productCode, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final url = Uri.parse('$apiEndpoint/rest/shopping-cart/add-product');
    final body = jsonEncode({
      'productCode': productCode,
      'quantity': quantity,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // Product added to the cart successfully
      // Handle the success scenario
    } else {
      // Failed to add the product to the cart
      // Handle the failure scenario
    }
  }
}
