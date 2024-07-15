import 'package:flutter/material.dart';
import 'package:lenseease_main/config/router/app_router.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoute.homeRoute);
          },
        ),
        title: const Text('About Lensease'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Welcome to Lensease!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lensease is your go-to app for seamless vision care and eyewear solutions. '
              'Our app integrates cutting-edge technology with personalized service to '
              'ensure your eye health and vision needs are met with convenience and quality.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildFeatureSection(
              title: 'Doctor Appointments Made Easy',
              description:
                  'Easily schedule appointments with leading eye care professionals '
                  'through our app. Whether it\'s for routine check-ups or specialized '
                  'consultations, managing your eye health has never been simpler.',
            ),
            const SizedBox(height: 24),
            _buildFeatureSection(
              title: 'Customized Power Lens Selection',
              description:
                  'Explore a wide range of power lenses tailored to your vision requirements. '
                  'Our app helps you choose the perfect lenses, ensuring comfort and clarity '
                  'for your daily activities.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(
      {required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
