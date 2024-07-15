import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:lenseease_main/core/storage/flutter_secure_storage.dart';
import 'package:lenseease_main/features/home/widgets/bottom_navbar.dart';
import 'package:lenseease_main/features/home/widgets/sidebar.dart';
import 'package:lenseease_main/features/home/widgets/topbar.dart';
import 'package:logger/logger.dart';

class BookingDoctorAppointmentPage extends StatefulWidget {
  const BookingDoctorAppointmentPage({super.key});

  @override
  State<BookingDoctorAppointmentPage> createState() =>
      _BookingDoctorAppointmentPageState();
}

class _BookingDoctorAppointmentPageState
    extends State<BookingDoctorAppointmentPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final Logger logger = Logger();

  String selectedDoctor = "";
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  List<dynamic> doctors = [];
  Map<String, dynamic> selectedDoctorData = {};

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final token = await SecureStorage().readToken();
      if (token != null) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:5500/api/admin/get-doctors'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          List<dynamic> fetchedDoctors = jsonResponse['doctors'];

          // Ensure each doctor _id is unique before setting state
          Set<String> uniqueIds = {};
          for (var doctor in fetchedDoctors) {
            if (!uniqueIds.contains(doctor['_id'])) {
              uniqueIds.add(doctor['_id']);
            }
          }

          // Filter out doctors with non-unique _id
          List<dynamic> filteredDoctors = fetchedDoctors
              .where((doctor) => uniqueIds.contains(doctor['_id']))
              .toList();

          setState(() {
            doctors = filteredDoctors;
          });

          logger.d('Doctors fetched successfully: $doctors');
        } else {
          throw Exception('Failed to load doctors: ${response.statusCode}');
        }
      } else {
        logger.e('Token is null');
      }
    } catch (e) {
      logger.e('Exception occurred: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        String hour = picked.hour.toString().padLeft(2, '0');
        String minute = picked.minute.toString().padLeft(2, '0');
        String period = picked.hour < 12 ? 'AM' : 'PM';
        if (picked.hour > 12) {
          hour = (picked.hour - 12).toString().padLeft(2, '0');
        }
        _timeController.text = '$hour:$minute $period';
      });
    }
  }

  void _showDoctorSelectionOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(doctors[index]['doctorName']),
              onTap: () {
                setState(() {
                  selectedDoctor = doctors[index]['_id'];
                  selectedDoctorData = doctors[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _clearData() {
    setState(() {
      selectedDoctor = "";
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
      _dateController.clear();
      _timeController.clear();
      selectedDoctorData = {};
    });
  }

  Future<void> _createBooking() async {
    try {
      final token = await SecureStorage().readToken();
      if (token != null) {
        final bookingData = {
          'doctorId': selectedDoctor,
          'date': selectedDate.toIso8601String(),
          'time':
              '${selectedTime.hour}:${selectedTime.minute} ${selectedTime.hour < 12 ? 'AM' : 'PM'}',
        };

        logger.d('Booking data: $bookingData');

        final response = await http.post(
          Uri.parse('http://10.0.2.2:5500/api/user/create-booking'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bookingData),
        );

        logger.d('Response status: ${response.statusCode}');
        logger.d('Response body: ${response.body}');
        logger.d('Response headers: ${response.headers}');

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          logger.d('Booking created successfully: $jsonResponse');

          // Show success dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Appointment booked successfully!'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      _clearData();
                      Navigator.pushReplacementNamed(
                          context, AppRoute.homeRoute);
                      // Navigate back or perform other actions
                    },
                  ),
                ],
              );
            },
          );
        } else {
          throw Exception(
              'Failed to create booking: ${response.statusCode} - ${response.body}');
        }
      } else {
        logger.e('Token is null');
      }
    } catch (e) {
      logger.e('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const Sidebar(),
      body: SingleChildScrollView(
        child: Column(children: [
          TopBar(
            onMenuTap: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 39,
            width: 453,
            color: const Color(0xFFC6E0F2),
            child: const Center(
              child: Text(
                "Book your appointment now !!!",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            height: 200,
            width: 410,
            color: const Color(0xFFC6E0F2),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Container(
                  height: 163,
                  width: 152,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: NetworkImage(selectedDoctorData['image'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 30),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDoctorData['doctorName'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        child: Text(
                          selectedDoctorData.isNotEmpty
                              ? selectedDoctorData['doctorDescription'] ?? ''
                              : '',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          doctors.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: 165,
                              height: 70,
                              child: TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFE0F1FD).withOpacity(0.64),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              width: 165,
                              height: 70,
                              child: TextFormField(
                                controller: _timeController,
                                readOnly: true,
                                onTap: () => _selectTime(context),
                                decoration: InputDecoration(
                                  labelText: 'Time',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFE0F1FD).withOpacity(0.64),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Choose your prefered Doctor",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _showDoctorSelectionOptions,
                        child: Container(
                          height: 70,
                          width: 410,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: const Color(0xFFE0F1FD).withOpacity(0.64),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDoctor.isEmpty
                                      ? 'Select a doctor'
                                      : ' ${selectedDoctorData['doctorName']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _createBooking,
                          child: const Text("Book Appointment"),
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
