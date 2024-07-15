// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/constants/api_endpoints.dart';
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:lenseease_main/core/snackbar/snackbar.dart';
import 'package:logger/logger.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );

  bool _passwordVisible = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final _phoneNumberFormatter = FilteringTextInputFormatter.digitsOnly;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _signup() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.register}');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'confirmPassword': _confirmPasswordController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
    });

    try {
      _logger.i(
          'Sending POST request to $url with body: $body and headers: $headers');
      final response = await http
          .post(
            url,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success']) {
          showSnackBar(
            message: 'Registration successful',
            context: context,
          );

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushNamed(context, AppRoute.loginRoute);
          });
        } else {
          showSnackBar(
            message: responseData['message'] ?? 'Signup failed',
            context: context,
          );
        }
      } else {
        showSnackBar(
          message: 'Server error',
          context: context,
        );
      }
    } on SocketException catch (e) {
      _logger.w('SocketException during signup: $e');
      showSnackBar(
        message: 'Connection timeout. Please try again later.',
        context: context,
      );
    } catch (e) {
      _logger.w('Error during signup: $e');
      showSnackBar(
        message: 'Error: $e',
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Image.asset(
              'assets/images/logo.png',
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Signup',
                style: GoogleFonts.amethysta(fontSize: 25),
              ),
            ),
            const SizedBox(height: 0),
            _buildTextField(
              iconPath: 'assets/icons/user.png',
              hintText: 'First Name',
              controller: _firstNameController,
            ),
            const SizedBox(height: 6),
            _buildTextField(
              iconPath: 'assets/icons/user.png',
              hintText: 'Last Name',
              controller: _lastNameController,
            ),
            const SizedBox(height: 6),
            _buildTextField(
              iconPath: 'assets/icons/email.png',
              hintText: 'Email',
              controller: _emailController,
            ),
            const SizedBox(height: 6),
            _buildTextField(
              iconPath: 'assets/icons/password.png',
              hintText: 'Password',
              controller: _passwordController,
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
            ),
            const SizedBox(height: 6),
            _buildTextField(
              iconPath: 'assets/icons/password.png',
              hintText: 'Confirm Password',
              controller: _confirmPasswordController,
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
            ),
            const SizedBox(height: 6),
            _buildTextField(
              iconPath: 'assets/icons/phone.png',
              hintText: 'Phone Number',
              controller: _phoneNumberController,
              inputFormatters: [_phoneNumberFormatter],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 149,
              height: 35,
              child: ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC6E0F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Signup',
                  style: GoogleFonts.amethysta(
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 21),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: GoogleFonts.amethysta(
                    fontSize: 17,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoute.loginRoute);
                  },
                  child: Text(
                    'Login',
                    style: GoogleFonts.amethysta(
                      color: const Color(0xFFF56B62),
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String iconPath,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return Container(
      width: 320,
      height: 37,
      decoration: BoxDecoration(
        color: const Color.fromARGB(132, 218, 237, 251),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 20),
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
              inputFormatters: inputFormatters,
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
