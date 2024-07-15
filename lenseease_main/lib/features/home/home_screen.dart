import 'package:flutter/material.dart';
import 'package:lenseease_main/features/home/widgets/bottom_navbar.dart';
import 'package:lenseease_main/features/home/widgets/invite_banner.dart';
import 'package:lenseease_main/features/home/widgets/lense_card.dart';
import 'package:lenseease_main/features/home/widgets/lense_categories.dart';
import 'package:lenseease_main/features/home/widgets/sidebar.dart';
import 'package:lenseease_main/features/home/widgets/topbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const Sidebar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopBar(
              onMenuTap: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
            const SizedBox(height: 15),
            const LenseCategories(),
            const SizedBox(height: 15),
            const LenseCard(),
            const SizedBox(height: 15),
            const InviteBanner(),
            const SizedBox(height: 15),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
