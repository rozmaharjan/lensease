import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:lenseease_main/core/storage/flutter_secure_storage.dart';
import 'package:lenseease_main/features/home/widgets/bottom_navbar.dart';
import 'package:logger/logger.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int _selectedIndex = 0;
  int _quantity = 1;
  double? _selectedPower;
  Map<String, dynamic>? _arguments;
  bool _isLoading = false;

  final Logger _logger = Logger();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeArguments();
  }

  void _initializeArguments() {
    // Retrieve arguments when the state initializes
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments == null) {
      // Handle the case where arguments are null, perhaps show a loading indicator or an error message
      _logger.e('Arguments are null');
      setState(() {
        _arguments = null;
      });
    } else {
      _logger.i('Arguments received: $arguments');
      setState(() {
        _arguments = arguments;
      });
    }
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addToCart() async {
    // Check if _arguments is null or not
    if (_arguments == null) {
      _logger.e('Arguments are null. Cannot add to cart.');
      return;
    }

    final String? productId = _arguments!['productId'];
    final Map<String, dynamic>? product = _arguments!['product'];

    if (productId == null || product == null) {
      _logger.e('Product ID or product is null');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'http://10.0.2.2:5500/api/cart/addcart';

    final Map<String, dynamic> requestData = {
      'productId': productId,
      'quantity': _quantity,
      'selectedPower': _selectedPower,
    };

    final String? token = await SecureStorage().readToken();

    _logger.i('Request Data: $requestData');
    _logger.i('Token: $token');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestData),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      _logger.i('Product added to cart successfully: $responseData');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Product added successfully!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  _clearData();
                  Navigator.pushReplacementNamed(context, AppRoute.cartRoute);
                },
              ),
            ],
          );
        },
      );
    } else {
      _logger.e('Failed to add product to cart: ${response.body}');
    }
  }

  void _clearData() {
    setState(() {
      _quantity = 1;
      _selectedPower = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if _arguments is null or not
    if (_arguments == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final String? productId = _arguments!['productId'];
    final Map<String, dynamic>? product = _arguments!['product'];

    if (productId == null || product == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: Product ID or product is null'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        product['productImageUrl'],
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['productName'],
                            style: GoogleFonts.amethysta(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: product['lensPowers']
                                .map<Widget>((power) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedPower = power.toDouble();
                                        });
                                      },
                                      child: Container(
                                        height: 20,
                                        width: 33,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color:
                                              _selectedPower == power.toDouble()
                                                  ? const Color(0xFFF7F7F7)
                                                  : const Color(0xFFC6E0F2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: _selectedPower ==
                                                    power.toDouble()
                                                ? const Color(0xFFC6E0F2)
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          power.toString(),
                                          style: GoogleFonts.amethysta(
                                            fontSize: 12,
                                            color: _selectedPower ==
                                                    power.toDouble()
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rs ${product['productPrice']}',
                            style: GoogleFonts.amethysta(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                  });
                                },
                              ),
                              Container(
                                height: 24,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC6E0F2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    '$_quantity',
                                    style: GoogleFonts.amethysta(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 32,
                                  color: Colors.black,
                                ),
                                onPressed: _quantity > 1
                                    ? () {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC6E0F2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextButton(
                              onPressed: _isLoading ? null : _addToCart,
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      'Add to Cart',
                                      style: GoogleFonts.amethysta(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 39,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC6E0F2),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Description',
                        style: GoogleFonts.amethysta(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 500,
                  height: 340,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 232, 231, 231),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Text(
                        product['productDescription'],
                        style: GoogleFonts.amethysta(
                          fontSize: 17,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
