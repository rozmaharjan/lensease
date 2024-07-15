import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  static const Color activeColor = Colors.blue;
  static const Color inactiveColor = Colors.grey;

  void _onItemTapped(int index) {
    if (Provider.of<BottomNavBarProvider>(context, listen: false)
            .selectedIndex !=
        index) {
      Provider.of<BottomNavBarProvider>(context, listen: false)
          .selectItem(index);
      switch (index) {
        case 0:
          Navigator.pushNamed(context, AppRoute.homeRoute);
          break;
        case 1:
          Navigator.pushNamed(context, AppRoute.cartRoute);
          break;
        case 2:
          Navigator.pushNamed(context, AppRoute.profileRoute);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavBarProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavigationBarItem(
                  icon: 'assets/icons/homepage.png',
                  label: 'Home',
                  index: 0,
                  isSelected: provider.selectedIndex == 0,
                ),
                _buildBottomNavigationBarItem(
                  icon: 'assets/icons/shopping-cart.png',
                  label: 'Cart',
                  index: 1,
                  isSelected: provider.selectedIndex == 1,
                ),
                _buildBottomNavigationBarItem(
                  icon: 'assets/icons/account.png',
                  label: 'Account',
                  index: 2,
                  isSelected: provider.selectedIndex == 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBarItem({
    required String icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    Color iconColor = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 24,
            height: 24,
            color: iconColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.libreBaskerville(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBarProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void selectItem(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
