import 'dart:io';

import 'package:admin_dashboard/core/flutter_secure_storage/flutter_secure_Storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AdminAddDoctorPage extends StatefulWidget {
  const AdminAddDoctorPage({super.key});

  @override
  _AdminAddDoctorPageState createState() => _AdminAddDoctorPageState();
}

class _AdminAddDoctorPageState extends State<AdminAddDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  File? _imageFile;

  final SecureStorage storage = SecureStorage();

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
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
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? token = await storage.readToken();

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.68.109:5500/api/admin/create-doctor'),
        );
        request.headers['Authorization'] = 'Bearer $token';

        request.fields['doctorName'] = nameController.text;
        request.fields['doctorDescription'] = descriptionController.text;
        request.fields['availableDates'] =
            DateFormat('yyyy-MM-dd').format(selectedDate);
        request.fields['availableTimes'] = selectedTime.format(context);

        if (_imageFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'doctorImage', _imageFile!.path));
          debugPrint('Image added to request: ${_imageFile!.path}');
        } else {
          debugPrint('No image selected');
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          debugPrint('Doctor created successfully');
          Navigator.pop(context);
        } else {
          debugPrint('Failed to create doctor: ${response.statusCode}');
          debugPrint('Response body: $responseBody');
        }
      } catch (error) {
        debugPrint('Network error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Doctor'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                      'Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Select Time: ${selectedTime.format(context)}'),
                ),
                ElevatedButton(
                  onPressed: _selectImage,
                  child: const Text('Select Image'),
                ),
                _imageFile != null
                    ? Image.file(_imageFile!)
                    : const Text('No image selected'),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Create Doctor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
