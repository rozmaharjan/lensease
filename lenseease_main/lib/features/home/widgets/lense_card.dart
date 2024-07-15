import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/router/app_router.dart';

class LenseCard extends StatefulWidget {
  const LenseCard({super.key});

  @override
  _LenseCardState createState() => _LenseCardState();
}

class _LenseCardState extends State<LenseCard> {
  List<dynamic> products = []; // List to store fetched products

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      var apiUrl = 'http://10.0.2.2:5500/api/products/get_products';
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body)['products'];
          // Ensure only 6 products are displayed
          if (products.length > 6) {
            products = products.sublist(0, 6);
          }
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            buildProductList(products),
            const SizedBox(height: 10),
            buildProductList(products),
          ],
        ),
      ),
    );
  }

  Widget buildProductList(List<dynamic> products) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var product in products) buildProductContainer(context, product),
        ],
      ),
    );
  }

  Widget buildProductContainer(
      BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoute.detailsRoute,
          arguments: {'productId': product['_id'], 'product': product},
        );
      },
      child: Container(
        width: 115,
        height: 104,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            product['productImageUrl'],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
