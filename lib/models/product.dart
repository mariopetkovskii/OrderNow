import 'dart:ffi';

class Product{
  final String brand;
  final String code;
  final String name;
  final double price;

  Product({
    required this.brand,
    required this.code,
    required this.name, 
    required this.price
  });

  factory Product.fromJson(Map<String, dynamic> json){
    return Product(brand: json['brand'], code: json['code'], name: json['name'], price: json['price']);
  }
}