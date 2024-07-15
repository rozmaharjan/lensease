import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/constants/api_endpoints.dart';
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:lenseease_main/core/snackbar/snackbar.dart';
import 'package:lenseease_main/core/storage/flutter_secure_storage.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _passwordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  Future<void> _login() async {
    final url = Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.login);
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'] ??
            ''; // Default to empty string if token is null
        if (token.isNotEmpty) {
          await secureStorage.writeToken(token);

          Navigator.pushNamed(context, AppRoute.homeRoute);

          showSnackBar(
            message: 'Login successful',
            context: context,
          );
        } else {
          showSnackBar(
            message: 'Login failed: token is missing',
            context: context,
          );
        }
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ??
            'Login failed'; // Default to a generic message if error message is null
        showSnackBar(
          message: errorMessage,
          context: context,
        );
      }
    } catch (e) {
      showSnackBar(
        message: 'Error: $e',
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 400,
                  height: 350,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to LensEase',
                    style: GoogleFonts.amethysta(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.waving_hand,
                      color: Color.fromARGB(255, 0, 0, 0)),
                ],
              ),
              const SizedBox(height: 30),
              _buildTextField(
                iconPath: 'assets/icons/user.png',
                hintText: 'email',
                controller: _emailController,
              ),
              const SizedBox(height: 40),
              _buildTextField(
                iconPath: 'assets/icons/password.png',
                hintText: 'Password',
                obscureText: !_passwordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
                controller: _passwordController,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 150),
                child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, AppRoute.forgotPasswordRoute);
                    },
                    child: Text("Forgot Password?",
                        style: GoogleFonts.amethysta(
                            fontSize: 17, color: Colors.black))),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 37,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC6E0F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.amethysta(
                        fontSize: 23, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't Have an Account? ",
                    style: GoogleFonts.amethysta(
                      fontSize: 17,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoute.signupRoute);
                    },
                    child: Text(
                      'Register',
                      style: GoogleFonts.amethysta(
                        color: const Color(0xFFF41D1D),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String iconPath,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    required TextEditingController controller,
  }) {
    return Container(
      width: 319,
      height: 45,
      decoration: BoxDecoration(
        color: const Color.fromARGB(132, 218, 237, 251),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }
}
