import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:logger/logger.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final Logger _logger = Logger();

  final TextEditingController _emailController = TextEditingController();
  bool _otpSent = false; // Track if OTP has been sent

  Future<void> _sendOTP() async {
    String email = _emailController.text.trim();
    final url = Uri.parse('http://10.0.2.2:5500/api/send-otp');
    try {
      final response = await http.post(
        url,
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        setState(() {
          _otpSent = true;
        });
        _logger.i('OTP sent successfully');
        Navigator.pushReplacementNamed(context, AppRoute.verifyOtpRoute,
            arguments: email);
      } else {
        _logger.e('Failed to send OTP. Status code: ${response.statusCode}');
        _logger.e('Response body: ${response.body}');
      }
    } catch (error) {
      _logger.e('Error sending OTP: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoute.loginRoute);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Image.asset("assets/images/otp.png"),
            const Text(
              'Forgot Your Password??',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF3A3A3A),
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),

                fillColor:
                    const Color(0xFFE0F1FD), // TextField background color
                filled: true,
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            if (!_otpSent)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: SizedBox(
                    height: 37,
                    width: 164,
                    child: ElevatedButton(
                      onPressed: _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC6E0F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Send OTP',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
