import 'package:admin_dashboard/dashboard/admin_dashboard.dart';
import 'package:admin_dashboard/dashboard/admin_doctor.dart';
import 'package:admin_dashboard/dashboard/admin_login.dart';
import 'package:admin_dashboard/dashboard/products.dart';

class AppRoute {
  AppRoute._();

  static const String login = '/';
  static const String dashboard = 'dashboard';
  static const String notificationRoute = '/notification';
  static const String productsRoute = '/products';
  static const String adminDoctorRoute = '/adminDoctor';

  static getApplicationRoute() {
    return {
      login: (context) => const AdminLoginScreen(),
      dashboard: (context) => const AdminDashboard(),
      productsRoute: (context) => const AddProductsPage(),
      adminDoctorRoute: (context) => const AdminAddDoctorPage()
    };
  }
}
