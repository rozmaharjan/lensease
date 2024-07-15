import 'package:admin_dashboard/config/router/app_routes.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final List<String> options = ['Products', 'Notifications', 'Add Doctors'];
  Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Admin Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ...options.map((option) => ListTile(
                title: Text(option),
                onTap: () {
                  switch (option) {
                    case 'Products':
                      Navigator.pushNamed(context, AppRoute.productsRoute);
                      break;

                    case 'Notifications':
                      Navigator.pushNamed(context, AppRoute.notificationRoute);
                      break;
                    case 'Add Doctors':
                      Navigator.pushNamed(context, AppRoute.adminDoctorRoute);
                      break;
                    default:
                      break;
                  }
                },
              )),
        ],
      ),
    );
  }
}
