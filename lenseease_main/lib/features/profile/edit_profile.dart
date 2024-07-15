import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:lenseease_main/config/service/user_service.dart';
import 'package:lenseease_main/core/storage/flutter_secure_storage.dart';
import 'package:lenseease_main/features/home/widgets/bottom_navbar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
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
      editUrl: 'http://10.0.2.2:5500/api/user/edit',
    );
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
      print('Failed to load user ID: $e');
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
      print('Failed to load user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveProfileChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await userService.updateUserData(userId!, {
          'firstName': userData?['firstName'],
          'lastName': userData?['lastName'],
          'email': userData?['email'],
          'phoneNumber': userData?['phoneNumber'],
          'gender': userData?['gender'],
          'location': userData?['location'],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        print('Failed to save profile changes: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 255, 255, 253),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoute.profileRoute);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                'Edit Profile',
                style: GoogleFonts.libreBaskerville(
                  color: const Color(0xFF333434),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage('assets/images/user.png'),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(height: 20),
                      _buildTextFieldWithIcon(
                        iconPath: 'assets/icons/user.png',
                        initialValue: userData?['firstName'] ?? '',
                        hintText: 'First Name',
                        onChanged: (value) {
                          setState(() {
                            userData?['firstName'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      _buildTextFieldWithIcon(
                        iconPath: 'assets/icons/user.png',
                        initialValue: userData?['lastName'] ?? '',
                        hintText: 'Last Name',
                        onChanged: (value) {
                          setState(() {
                            userData?['lastName'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      _buildTextFieldWithIcon(
                        iconPath: 'assets/icons/email.png',
                        initialValue: userData?['email'] ?? '',
                        hintText: 'Email',
                        onChanged: (value) {
                          setState(() {
                            userData?['email'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      _buildTextFieldWithIcon(
                        iconPath: 'assets/icons/phone.png',
                        initialValue: userData?['phoneNumber'] ?? '',
                        hintText: 'Phone Number',
                        onChanged: (value) {
                          setState(() {
                            userData?['phoneNumber'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      _buildTextFieldWithIcon(
                        iconPath: 'assets/icons/gender.png',
                        hintText: 'Gender',
                        initialValue: userData?['gender'] ?? '',
                        onChanged: (value) {
                          setState(() {
                            userData?['gender'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      _buildTextFieldWithIcon(
                        iconPath: 'assets/icons/direction.png',
                        hintText: 'Location',
                        initialValue: userData?['location'] ?? '',
                        onChanged: (value) {
                          setState(() {
                            userData?['location'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC6E0F2),
                          minimumSize: const Size(140, 50),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: saveProfileChanges,
                        child: Text(
                          'Save',
                          style: GoogleFonts.libreBaskerville(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildTextFieldWithIcon({
    required String iconPath,
    String? initialValue,
    required String hintText,
    Function(String)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFFAFAFF),
        border: Border.all(
          color: Colors.black.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 25,
            height: 25,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
              ),
              initialValue: initialValue,
              onChanged: onChanged,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
