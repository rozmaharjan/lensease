import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class TopBar extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const TopBar({super.key, this.onMenuTap});

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();
  final List<Product> _products = [];
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchProducts);
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:5500/api/products/get_products'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> productJson = responseBody['products'];
        _products.clear();
        _products
            .addAll(productJson.map((json) => Product.fromJson(json)).toList());

        if (mounted) {
          setState(() {});
        }

        logger.i('Products fetched successfully');
      } else {
        logger.e('Failed to load products: ${response.statusCode}');
        logger.e('Response body: ${response.body}');
        throw Exception('Failed to load products');
      }
    } catch (e) {
      logger.e('Error: $e');
    }
  }

  void _searchProducts() {
    final searchQuery = _searchController.text.toLowerCase();
    _searchResults = _products.where((product) {
      return product.productName.toLowerCase().contains(searchQuery);
    }).toList();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 132,
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 80,
            child: GestureDetector(
              onTap: widget.onMenuTap ?? () {},
              child:
                  Image.asset('assets/icons/menu.png', width: 25, height: 25),
            ),
          ),
          Positioned(
            left: 62,
            top: 80,
            child: Container(
              width: 280,
              height: 31,
              decoration: BoxDecoration(
                color: const Color(0xA3E0F1FD),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.asset('assets/icons/search.png',
                        width: 18, height: 18),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 350,
            top: 80,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, AppRoute.notificationRoute);
              },
              child: Image.asset('assets/icons/notification.png',
                  width: 25, height: 25),
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String productName;

  Product({required this.productName});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(productName: json['productName']);
  }
}
