import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:logger/logger.dart';

class VerifyOtpPage extends StatefulWidget {
  final String? email;

  const VerifyOtpPage({super.key, this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final Logger _logger = Logger();

  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();

  void verifyOTP() async {
    String otp = otp1Controller.text +
        otp2Controller.text +
        otp3Controller.text +
        otp4Controller.text;
    try {
      const String apiUrl = 'http://10.0.2.2:5500/api/verify-otp';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'otp': otp,
        }),
      );

      _logger.d('Verify OTP Request: $apiUrl');
      _logger.d('Request Body: ${jsonEncode({'otp': otp})}');
      _logger.d('Response Status Code: ${response.statusCode}');
      _logger.d('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, AppRoute.createNewPasswordRoute);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to verify OTP. Please try again.'),
          ),
        );
        _logger.e('Failed to verify OTP. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _logger.e('Error verifying OTP: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error verifying OTP. Please try again later.'),
        ),
      );
    }
  }

  Future<void> resendCode() async {
    try {
      const String apiUrl = 'http://10.0.2.2:5500/api/resend-otp';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'email': widget.email,
        }),
      );

      _logger.d('Resend OTP Request: $apiUrl');
      _logger.d('Request Body: ${jsonEncode({'email': widget.email})}');
      _logger.d('Response Status Code: ${response.statusCode}');
      _logger.d('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your code has been sent.',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color(0xFFE0F1FD),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend OTP. Please try again.'),
          ),
        );
        _logger.e('Failed to resend OTP. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _logger.e('Error resending OTP: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error resending OTP. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, AppRoute.forgotPasswordRoute);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Enter 4 Digit Code',
              style: GoogleFonts.amethysta(fontSize: 32),
            ),
            const SizedBox(height: 20),
            Text(
              'Enter the 4-digit code sent to your email ${widget.email != null ? '(${widget.email})' : ''}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.amethysta(
                fontSize: 16,
                color: const Color(0xFF57545B),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildOtpTextField(otp1Controller),
                const SizedBox(width: 10),
                buildOtpTextField(otp2Controller),
                const SizedBox(width: 10),
                buildOtpTextField(otp3Controller),
                const SizedBox(width: 10),
                buildOtpTextField(otp4Controller),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Email not received?',
                  style: TextStyle(color: Colors.black),
                ),
                TextButton(
                  onPressed: resendCode,
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(
                      color: Color(0xFF323135),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC6E0F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text(
                  'Continue',
                  style: GoogleFonts.amethysta(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildOtpTextField(TextEditingController controller) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFC2C1C9)),
        ),
        child: TextFormField(
          controller: controller,
          textAlign: TextAlign.center,
          style: GoogleFonts.amethysta(fontSize: 24),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
        ),
      ),
    );
  }
}
