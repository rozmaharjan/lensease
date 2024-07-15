import 'package:flutter/material.dart';

class InviteBanner extends StatelessWidget {
  const InviteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.07),
      child: Container(
        width: screenWidth * 0.5, // Adjusted width of the container
        height: screenHeight * 0.15,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/invite.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          children: [
            Positioned(
              right: screenWidth *
                  0.05, // Adjusted position relative to screen width
              top: screenHeight *
                  0.66, // Adjusted position relative to screen height
              width: screenWidth * 0.2,
              height: screenHeight * 0.1,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text('Invite'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
