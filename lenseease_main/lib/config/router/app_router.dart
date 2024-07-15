import 'package:lenseease_main/features/aboutus/about_us.dart';
import 'package:lenseease_main/features/cart/cart.dart';
import 'package:lenseease_main/features/details/checkout.dart';
import 'package:lenseease_main/features/details/details_screen.dart';
import 'package:lenseease_main/features/doctorbooking/book_doctor_appointment.dart';
import 'package:lenseease_main/features/forgotPassword/forgot_password.dart';
import 'package:lenseease_main/features/forgotPassword/new_password.dart';
import 'package:lenseease_main/features/forgotPassword/verify_otp.dart';
import 'package:lenseease_main/features/home/home_screen.dart';
import 'package:lenseease_main/features/login/login.dart';
import 'package:lenseease_main/features/notifications/notifications.dart';
import 'package:lenseease_main/features/profile/change_password.dart';
import 'package:lenseease_main/features/profile/edit_profile.dart';
import 'package:lenseease_main/features/profile/user_profile.dart';
import 'package:lenseease_main/features/signup/signup.dart';
import 'package:lenseease_main/features/splash/splash_screen.dart';

class AppRoute {
  AppRoute._();

  static const String splashRoute = '/';
  static const String locationRoute = '/location';
  static const String loginRoute = '/login';
  static const String signupRoute = '/register';
  static const String homeRoute = '/home';
  static const String detailsRoute = '/details';
  static const String checkoutRoute = '/checkout';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = '/editProfile';
  static const String cartRoute = '/Cart';
  static const String forgotPasswordRoute = '/forgotPassword';
  static const String verifyOtpRoute = '/verifyOtp';
  static const String createNewPasswordRoute = '/createNewPassword';
  static const String changePasswordRoute = '/changePassword';
  static const String bookAppointmentRoute = '/bookAppointment';
  static const String aboutRoute = '/about';
  static const String notificationRoute = '/notification';

  static getApplicationRoute() {
    return {
      splashRoute: (context) => const SplashScreen(),
      loginRoute: (context) => const LoginView(),
      homeRoute: (context) => const HomeScreen(),
      signupRoute: (context) => const SignupPage(),
      detailsRoute: (context) => const DetailsPage(),
      checkoutRoute: (context) => const CheckoutPage(
            cartItems: [],
          ),
      profileRoute: (context) => const UserProfile(),
      editProfileRoute: (context) => const EditProfilePage(),
      cartRoute: (context) => const CartPage(),
      forgotPasswordRoute: (context) => const ForgotPasswordPage(),
      verifyOtpRoute: (context) => const VerifyOtpPage(),
      createNewPasswordRoute: (context) => const NewPasswordPage(),
      bookAppointmentRoute: (context) => const BookingDoctorAppointmentPage(),
      aboutRoute: (context) => const AboutUsPage(),
      notificationRoute: (context) => const NotificationsPage(),
      changePasswordRoute: (context) => const ChangePasswordPage()
    };
  }
}
