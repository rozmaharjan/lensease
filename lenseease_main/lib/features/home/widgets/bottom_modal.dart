import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lenseease_main/config/router/app_router.dart';

void showCustomModalSheet({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onYesPressed,
  required String yesButtonLabel,
  required String noButtonLabel,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Container(
        height: 430, // Adjusted height
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    fixedSize: const Size(141, 37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    noButtonLabel,
                    style: GoogleFonts.amethysta(
                        fontSize: 14, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    onYesPressed();
                    Navigator.pushReplacementNamed(
                        context, AppRoute.loginRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDE1135),
                    fixedSize: const Size(141, 37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    yesButtonLabel,
                    style: GoogleFonts.amethysta(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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
