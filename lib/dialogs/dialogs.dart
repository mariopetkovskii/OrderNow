import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api-service/products-api-service.dart';

class Dialogs{
  static Future<void> showQuantityDialog(String productCode, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    int quantity = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Quantity'),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            quantity = int.tryParse(value) ?? 0;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ProductsApiService.addToCart(productCode, quantity);
            },
            child: Text('Add to Cart'),
          ),
        ],
      ),
    );
  }

}