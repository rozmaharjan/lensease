import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:logger/logger.dart';

class NewPasswordPage extends StatefulWidget {
  final String? otp;
  const NewPasswordPage({super.key, this.otp});

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final Logger logger = Logger();

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  void _updatePassword() async {
    setState(() {
      _errorMessage = null;
    });

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Password do not match.';
      });
      return;
    }

    try {
      logger.d('Updating password...');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5500/api/update-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'newPassword': _newPasswordController.text,
          'otp': widget.otp ?? '',
        }),
      );

      if (response.statusCode == 200) {
        logger.d('Password updated successfully');
        showCustomModalSheet(
          context: context,
          onYesPressed: () {
            // Define additional actions if needed
          },
          message: 'Password updated Successfully!',
          yesButtonLabel: 'Continue to Login',
        );
      } else {
        final jsonResponse = jsonDecode(response.body);
        logger.e('Failed to update password: ${jsonResponse['message']}');
        setState(() {
          _errorMessage = jsonResponse['message'];
        });
      }
    } catch (error) {
      logger.e('Error updating password: $error');
      print('Error updating password: $error');
      setState(() {
        _errorMessage = 'Failed to update password. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoute.verifyOtpRoute);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Create New Password',
                    style: TextStyle(fontSize: 25),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "New Password",
                          style: GoogleFonts.amethysta(fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: 48,
                        width: 350,
                        child: TextField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.amethysta(fontSize: 16),
                            errorText: _errorMessage,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Confirm Password",
                              style: GoogleFonts.amethysta(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: 48,
                            width: 350,
                            child: TextField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.amethysta(fontSize: 16),
                                errorText: _errorMessage,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              obscureText: !_isConfirmPasswordVisible,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC6E0F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 80),
                      child: Text(
                        'Update Password',
                        style: GoogleFonts.amethysta(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showCustomModalSheet({
  required BuildContext context,
  required String message,
  required VoidCallback onYesPressed,
  required String yesButtonLabel,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Container(
        width: 430,
        height: 367,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 20),
            Center(
                child: Image.asset(
              "assets/icons/check.png",
              height: 80,
              width: 80,
            )),
            Text(
              message,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 90),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 48,
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () {
                      onYesPressed();
                      Navigator.pushReplacementNamed(
                          context, AppRoute.loginRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC6E0F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      yesButtonLabel,
                      style: GoogleFonts.amethysta(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}
