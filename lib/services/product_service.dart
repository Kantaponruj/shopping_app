import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_app/models/product.dart';

class ProductService {
  static const String baseUrl = "http://10.0.2.2:8081";

  static Future<String> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/healthcheck"),
      );

      if (response.statusCode == 200) {
        return "OK";
      } else {
        return "";
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  static Future<LatestProduct> fetchProducts(
      {required int limit, required String cursor}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products?limit=$limit&cursor=$cursor"),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return LatestProduct.fromJson(data);
      } else {
        throw Exception("Failed to load  products");
      }
    } catch (e) {
      debugPrint("error: $e");
      throw Exception("Error fetching products: $e");
    }
  }

  static Future<List<Product>> fetchRecommendedProducts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/recommended-products"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load latest products");
      }
    } catch (e) {
      debugPrint("error: $e");
      throw Exception("Error fetching products: $e");
    }
  }

  static Future<int> checkout(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/orders/checkout"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      return response.statusCode;
    } catch (e) {
      return 500;
    }
  }
}
