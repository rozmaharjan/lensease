import 'package:flutter/material.dart';

class LenseCategories extends StatelessWidget {
  const LenseCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16, 5, 16, 0), // Adjusted top padding to 10
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF8CC8B0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 5),
              SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF8CC8B0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 5),
              SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF8CC8B0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 5),
              SizedBox(
                width: 4,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF8CC8B0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 113,
                height: 31,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFC6E0F2),
                ),
                alignment: Alignment.center,
                child: const Text('Powered'),
              ),
              Container(
                width: 113,
                height: 31,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFC6E0F2),
                ),
                alignment: Alignment.center,
                child: const Text('Non-powered'),
              ),
              Container(
                width: 113,
                height: 31,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFC6E0F2),
                ),
                alignment: Alignment.center,
                child: const Text('Custom'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
