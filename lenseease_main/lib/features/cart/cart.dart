import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:lenseease_main/core/storage/flutter_secure_storage.dart';
import 'package:lenseease_main/features/details/checkout.dart';
import 'package:lenseease_main/features/home/widgets/bottom_navbar.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchCartItems() async {
    try {
      final token = await SecureStorage().readToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5500/api/cart/getcart'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Response data: $jsonData');

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('cartItems')) {
          setState(() {
            cartItems = List<Map<String, dynamic>>.from(jsonData['cartItems']);
            isLoading = false;
          });
        } else if (jsonData is List<dynamic>) {
          setState(() {
            cartItems = jsonData.map((e) => e as Map<String, dynamic>).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          throw Exception('Unexpected data format');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load cart items: ${response.statusCode}');
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching cart items: $e');
    }
  }

  int get totalPrice {
    return cartItems.fold(0, (sum, item) {
      final product = item['productId'];
      final price = product != null ? product['productPrice'] as int? : null;
      final quantity = item['quantity'] as int?;
      if (price != null && quantity != null) {
        return sum + (price * quantity);
      }
      return sum;
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
        updateCartItem(index); // Update quantity on backend
      } else {
        // If quantity is 1, remove the item from the cart
        removeCartItem(index);
      }
    });
  }

  void incrementQuantity(int index) {
    setState(() {
      cartItems[index]['quantity']++;
      updateCartItem(index); // Update quantity on backend
    });
  }

  Future<void> removeCartItem(int index) async {
    final item = cartItems[index];
    final productId = item['productId']
        ['_id']; // Assuming productId is stored with _id in backend

    try {
      final token = await SecureStorage().readToken();
      final url =
          Uri.parse('http://10.0.2.2:5500/api/cart/removecart/$productId');

      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeAt(index); // Remove item from local list
        });
        print('Item successfully removed from cart');
      } else {
        print('Failed to remove item from cart: ${response.statusCode}');
        // Handle error if needed
      }
    } catch (e) {
      print('Error removing item from cart: $e');
      // Handle error
    }
  }

  Future<void> updateCartItem(int index) async {
    final item = cartItems[index];
    final cartItemId = item['_id']; // Correctly retrieve cartItemId
    final quantity = item['quantity'];

    try {
      final token = await SecureStorage().readToken();
      final url =
          Uri.parse('http://10.0.2.2:5500/api/cart/$cartItemId/updateQuantity');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        // Cart item updated successfully
        print('Cart item updated successfully');
      } else {
        print('Failed to update cart item: ${response.statusCode}');
        // Handle error if needed
      }
    } catch (e) {
      print('Error updating cart item: $e');
      // Handle error
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoute.homeRoute);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            return _buildCartItem(index);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: Rs $totalPrice'),
                            const SizedBox(height: 10),
                            const Text(
                                'Shipping: Cost will appear on checkout'),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 410,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CheckoutPage(cartItems: cartItems),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC6E0F2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size.fromHeight(40),
                                ),
                                child: Text(
                                  'CHECKOUT',
                                  style: GoogleFonts.amethysta(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Your Cart Is Empty!',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'When you add products, they’ll appear here.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildCartItem(int index) {
    final item = cartItems[index];
    final product = item['productId'];

    if (product == null) {
      return const ListTile(
        title: Text('Product not found'),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        height: 150,
        width: 384,
        decoration: const BoxDecoration(
          color: Color(0xFFE0F1FD),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: product['productImageUrl'] != null
                      ? Image.network(
                          product['productImageUrl'],
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),
                ),
              ),
              const SizedBox(width: 16), // Spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['productId']['productName'] ?? 'Product Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rs ${product['productPrice'] ?? item['productPrice'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildIconButton(Icons.remove, () {
                          decrementQuantity(index);
                        }),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item['quantity']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        _buildIconButton(Icons.add, () {
                          incrementQuantity(index);
                        }),
                        const SizedBox(width: 8.0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
