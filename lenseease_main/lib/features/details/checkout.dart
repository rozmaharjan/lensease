import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:lenseease_main/config/service/user_service.dart';
import 'package:lenseease_main/core/storage/flutter_secure_storage.dart';
import 'package:lenseease_main/features/home/widgets/bottom_navbar.dart';
import 'package:logger/logger.dart';

class CheckoutPage extends StatefulWidget {
  final List cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Future<Map<String, dynamic>>? userProfile;
  String? location;
  String? note = '';
  String paymentMethod = 'cash_on_delivery';
  double deliveryCost = 100.0;
  double totalAmount = 0.0;
  late UserService userService;
  bool isLoading = true;
  late Map<String, dynamic> userData;
  late String userId;

  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    userProfile = Future.value({});
    final secureStorage = SecureStorage();
    userService = UserService(
      baseUrl: 'http://10.0.2.2:5500/api/user/profile',
      secureStorage: secureStorage,
      deleteUrl: 'http://10.0.2.2:5500/api/user/delete',
      editUrl: 'http://10.0.2.2:5500/api/user/edit',
    );
    fetchUserId();

    double total = 0.0;
    for (var item in widget.cartItems) {
      total += item['totalPrice'];
    }
    setState(() {
      totalAmount = total;
    });
  }

  Future<void> fetchUserId() async {
    try {
      final token = await SecureStorage().readToken();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final id = decodedToken['id'];

        if (id != null) {
          setState(() {
            userId = id;
          });
          fetchUserData(id);
        } else {
          throw Exception('User ID not found in token');
        }
      } else {
        throw Exception('Token not found');
      }
    } catch (e) {
      _logger.e('Failed to load user ID: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> fetchProductDetails(String productId) async {
    try {
      final token = await SecureStorage().readToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5500/api/products/get_product/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final productData = json.decode(response.body);
        final productName = productData['productName'] as String;
        return productName;
      } else {
        throw Exception('Failed to fetch product details');
      }
    } catch (e) {
      throw Exception('Error fetching product details: $e');
    }
  }

  Future<void> fetchUserData(String userId) async {
    try {
      final data = await userService.fetchUserData(userId);
      setState(() {
        userData = data;
        isLoading = false;
        userProfile = Future.value(userData); // Assign userData to userProfile
      });

      // Fetch product names before submitting
      List<Map<String, dynamic>> updatedCartItems = [];
      for (var item in widget.cartItems) {
        String productName = await fetchProductDetails(item['productId']);
        updatedCartItems.add({
          ...item,
          'productName': productName,
        });
      }
      print('Updated cart items: $updatedCartItems');
    } catch (e) {
      _logger.e('Failed to load user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void onSuccess(PaymentSuccessModel success) {
    // payment successful, handle success scenario
    print('Payment successful');
  }

  void onFailure(PaymentFailureModel failure) {
    // payment failed, handle failure scenario
    print('Payment failed');
  }

  void onCancel() {
    // payment cancelled, handle cancel scenario
    print('Payment cancelled');
  }

  void submitCheckout() async {
    if (userId.isEmpty) {
      _logger.e('User ID is empty, cannot submit checkout');
      return;
    }

    final userProfileData = await userProfile;
    if (userProfileData == null || userProfileData.isEmpty) {
      _logger.e('User profile is empty, cannot submit checkout');
      return;
    }

    try {
      final token = await SecureStorage().readToken();
      final userProfileData = await userProfile;
      if (userProfileData == null) {
        throw Exception('User profile data is null');
      }
      const url = 'http://10.0.2.2:5500/api/checkout';

      _logger.d('Submitting checkout to $url');

      // Fetch product names before submitting
      List<Map<String, dynamic>> updatedCartItems = [];
      for (var item in widget.cartItems) {
        String productName = await fetchProductDetails(item['productId']);
        updatedCartItems.add({
          ...item,
          'productName': productName,
        });
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'contactName': {
            'firstName': userProfileData['firstName'].toString(),
            'lastName': userProfileData['lastName'].toString(),
          },
          'phoneNumber': userProfileData['phoneNumber'] ?? '',
          'location': location ?? '',
          'note': note ?? '',
          'orderSummary': {
            'items': updatedCartItems,
            'deliveryCost': deliveryCost,
            'totalAmount': totalAmount,
          },
          'paymentMethod': paymentMethod,
        }),
      );

      // Handle response
      if (response.statusCode == 201) {
        _logger.d('Checkout created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkout created successfully')),
        );
      } else {
        _logger.e('Failed to create checkout: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create checkout')),
        );
      }
    } catch (e) {
      _logger.e('Error submitting checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting checkout')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        leading: const BackButton(),
        title: Text(
          'Contact Details',
          style: GoogleFonts.amethysta(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 16,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('User profile data not available'));
          } else {
            final userProfileData = snapshot.data!;
            final user = userData;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Contact Name:',
                          style: GoogleFonts.amethysta(
                            color: const Color(0xFF172B4D).withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 100),
                        Text(
                          '${userProfileData['firstName'] ?? ''} ${userProfileData['lastName'] ?? ''}',
                          style: GoogleFonts.amethysta(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 233, 233, 233),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Phone Number:',
                          style: GoogleFonts.amethysta(
                            color: const Color(0xFF172B4D).withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 100),
                        Text(
                          '${userProfileData['phoneNumber'] ?? ''}',
                          style: GoogleFonts.amethysta(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 233, 233, 233),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Choose Location',
                      style: GoogleFonts.amethysta(
                        color: const Color(0xFF172B4D).withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 49,
                      padding: const EdgeInsets.symmetric(horizontal: 13.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFF),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/eventlocation.png',
                            width: 23,
                            height: 23,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Location',
                                hintStyle: TextStyle(fontSize: 12),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  location = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Note:',
                      style: GoogleFonts.amethysta(
                        color: const Color(0xFF172B4D).withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          note = value;
                        });
                      },
                      style: const TextStyle(
                          fontSize:
                              12), // Sets the font size for user typing text
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0x00e0f1fd).withOpacity(0.52),
                        hintText:
                            'Write description about your location, or nearest landmark...',
                        hintStyle: const TextStyle(
                            fontSize: 12), // Keeps hint text font size 12pt
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Order Summary',
                      style: GoogleFonts.amethysta(
                        color: const Color(0xFF172B4D).withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding:
                          const EdgeInsets.all(16.0), // Add padding if needed
                      color: const Color(0xFFF2EEEE), // Background color
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.cartItems.length,
                              itemBuilder: (BuildContext context, int index) {
                                final cartItem = widget.cartItems[index];
                                final productName = cartItem['productId']
                                        ['productName'] ??
                                    'Product Name';
                                final productQuantity = cartItem['quantity'];
                                final productPrice = cartItem['totalPrice'];
                                final totalPrice =
                                    productQuantity * productPrice;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${cartItem['productId']['productName'] ?? 'Product Name'} x ${cartItem['quantity']}',
                                          style: GoogleFonts.amethysta(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'Rs.${cartItem['totalPrice']}',
                                            style: GoogleFonts.amethysta(
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Delivery Cost',
                                style: GoogleFonts.amethysta(
                                  color:
                                      const Color(0xFF172B4D).withOpacity(0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rs.$deliveryCost',
                                style: GoogleFonts.amethysta(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: GoogleFonts.amethysta(
                                  color:
                                      const Color(0xFF172B4D).withOpacity(0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rs.${totalAmount + deliveryCost}',
                                style: GoogleFonts.amethysta(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Payment Method',
                      style: GoogleFonts.amethysta(
                        color: const Color(0xFF172B4D).withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                paymentMethod = 'cash_on_delivery';
                              });
                            },
                            child: Container(
                              height: 47,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 13.0),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'cash_on_delivery'
                                    ? const Color(0xFFC6E0F2)
                                    : const Color(0xFFFAFAFF),
                                border: Border.all(
                                    color: paymentMethod == 'cash_on_delivery'
                                        ? const Color(0xFFC6E0F2)
                                        : const Color(0xFFC6E0F2)
                                            .withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(13.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Cash on Delivery',
                                  style: GoogleFonts.amethysta(
                                    color: paymentMethod == 'cash_on_delivery'
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : const Color.fromARGB(255, 0, 0, 0)
                                            .withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                paymentMethod = 'khalti';
                              });
                            },
                            child: Container(
                              height: 47,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 13.0),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'khalti'
                                    ? const Color(0xFFC6E0F2)
                                    : const Color(0xFFFAFAFF),
                                border: Border.all(
                                    color: paymentMethod == 'khalti'
                                        ? const Color(0xFFC6E0F2)
                                        : const Color(0xFFC6E0F2)
                                            .withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(13.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Pay Via Khalti',
                                  style: GoogleFonts.amethysta(
                                    color: paymentMethod == 'khalti'
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : const Color.fromARGB(255, 0, 0, 0)
                                            .withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        if (paymentMethod == 'khalti') {
                          KhaltiScope.of(context).pay(
                            config: PaymentConfig(
                              amount: (totalAmount + deliveryCost).toInt() *
                                  100, // Convert rupees to paisa
                              productIdentity:
                                  json.encode(widget.cartItems[0]['productId']),
                              productName: 'Product',
                              mobileReadOnly: false,
                            ),
                            preferences: [PaymentPreference.khalti],
                            onSuccess: onSuccess,
                            onFailure: onFailure,
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Order Placed"),
                                content: const Text(
                                    "Your order has been placed successfully"),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: const Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC6E0F2),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
