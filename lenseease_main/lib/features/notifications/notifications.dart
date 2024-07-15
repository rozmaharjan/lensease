import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:lenseease_main/config/router/app_router.dart';
import 'package:lenseease_main/core/storage/flutter_secure_storage.dart';
import 'package:lenseease_main/features/home/widgets/bottom_navbar.dart';
import 'package:logger/logger.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final Logger _logger = Logger();
  List _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final token = await SecureStorage().readToken();
    _logger.d('Token retrieved: $token'); // Logging token retrieval

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5500/api/notifications/get-notifications'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _logger.d(
        'HTTP Request Status Code: ${response.statusCode}'); // Logging HTTP status code

    if (response.statusCode == 200) {
      setState(() {
        _notifications = json.decode(response.body);
      });
    } else {
      _logger.e(
          'Failed to load notifications: ${response.body}'); // Logging failure with response body
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load notifications')),
      );
    }
  }

  String _formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr); // Parse the date string
    return DateFormat('dd MMMM, yyyy').format(dateTime); // Format date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoute.homeRoute);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text('No notifications here'),
            )
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          _notifications[index]['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _notifications[index]['message'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications,
                              color: Color.fromARGB(255, 115, 237, 245),
                            ),
                            Text(
                              _formatDate(_notifications[index]['date']),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
