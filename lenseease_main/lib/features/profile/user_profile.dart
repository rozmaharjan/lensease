import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:lenseease_main/config/service/user_service.dart';
import 'package:lenseease_main/core/storage/flutter_secure_storage.dart';
import 'package:lenseease_main/features/home/widgets/bottom_modal.dart';
import 'package:lenseease_main/features/home/widgets/bottom_navbar.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late UserService userService;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? userId;

  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    final secureStorage = SecureStorage();
    userService = UserService(
        baseUrl: 'http://10.0.2.2:5500/api/user/profile',
        secureStorage: secureStorage,
        deleteUrl: 'http://10.0.2.2:5500/api/user/delete',
        editUrl: 'http://10.0.2.2:5500/api/user/edit');
    fetchUserId();
  }

  Future<void> fetchUserId() async {
    try {
      final token = await SecureStorage().readToken();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final id = decodedToken['id'];

        if (id != null) {
          setState(() {
            userId = id;
          });
          fetchUserData(id);
        } else {
          throw Exception('User ID not found in token');
        }
      } else {
        throw Exception('Token not found');
      }
    } catch (e) {
      developer.log('Failed to load user ID: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserData(String userId) async {
    try {
      final data = await userService.fetchUserData(userId);
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      developer.log('Failed to load user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoute.homeRoute);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                'My Profile',
                style: GoogleFonts.libreBaskerville(
                  color: const Color(0xFF333434),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 70,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    backgroundImage: AssetImage('assets/images/user.png'),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC6E0F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userData?['email'] ?? 'Email',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF073767),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, AppRoute.editProfileRoute);
                    },
                    child: Text(
                      'Edit Your Profile',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0x80172B4D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ListTile(
                      title: Text('Phone Number',
                          style: GoogleFonts.libreBaskerville(
                              fontSize: 15,
                              color: const Color.fromARGB(128, 19, 36, 66),
                              fontWeight: FontWeight.bold)),
                      trailing: Text(userData?['phoneNumber'] ?? 'Phone Number',
                          style: GoogleFonts.libreBaskerville(
                            fontSize: 15,
                            color: const Color(0xE6172B4D),
                          )),
                    ),
                  ),
                  const Divider(
                    color: Color.fromARGB(255, 192, 192, 192),
                    thickness: 1,
                    indent: 30,
                    endIndent: 30,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: Color(0xFF111111),
                      size: 35,
                    ),
                    title: Text(
                      'Change Password',
                      style: GoogleFonts.libreBaskerville(
                          color: const Color(0xFF111111), fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, AppRoute.changePasswordRoute);
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: Image.asset(
                      color: const Color(0xFFF41D1D),
                      'assets/icons/delete.png',
                      width: 35,
                      height: 35,
                    ),
                    title: Text(
                      'Delete Account',
                      style: GoogleFonts.libreBaskerville(
                          color: const Color(0xFFF41D1D), fontSize: 16),
                    ),
                    onTap: () {
                      showCustomModalSheet(
                          context: context,
                          title: 'Logout',
                          message:
                              'Are you sure you want to delete your account?',
                          yesButtonLabel: 'Yes, Delete',
                          noButtonLabel: 'Cancel',
                          onYesPressed: () async {
                            await userService.deleteAccount(userId!);
                            Navigator.pushReplacementNamed(
                                context, AppRoute.loginRoute);
                          });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
