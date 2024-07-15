import 'package:flutter/material.dart';
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:lenseease_main/features/home/widgets/bottom_modal.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const ListTile(
            title: Text(
              'LENSEASE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const Divider(thickness: 1),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Discover',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRoute.homeRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Appointment'),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, AppRoute.bookAppointmentRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRoute.aboutRoute);
            },
          ),
          const Spacer(),
          ListTile(
            leading: Image.asset(
              'assets/icons/out.png',
              color: Colors.red,
              height: 25,
              width: 25,
            ),
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              showCustomModalSheet(
                context: context,
                title: 'Logout',
                message: 'Are you sure you want to log out?',
                onYesPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoute.loginRoute);
                },
                yesButtonLabel: 'Yes, Logout',
                noButtonLabel: 'Cancel',
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
