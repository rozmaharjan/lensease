import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class AddProductsPage extends StatefulWidget {
  const AddProductsPage({super.key});

  @override
  _AddProductsPageState createState() => _AddProductsPageState();
}

class _AddProductsPageState extends State<AddProductsPage> {
  final Logger _logger = Logger();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();

  List<String> _validLensPowers = [];
  List<String> _selectedLensPowers = [];
  File? _imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchLensPowers();
  }

  Future<void> _fetchLensPowers() async {
    var url = Uri.parse('http://192.168.68.109:5500/api/lenspowers/get_lense');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)[
            'lensPowers']; // Assuming 'lensPowers' is the key in your response JSON
        setState(() {
          _validLensPowers = List<String>.from(data.map((item) => item['power']
              .toString())); // Adjust this line based on your data structure
        });
      } else {
        _logger.e(
            'Failed to fetch lens powers. Status Code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch lens powers')),
        );
      }
    } catch (e) {
      _logger.e('Error fetching lens powers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching lens powers')),
      );
    }
  }

  Future<void> _chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _addProduct() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    var url =
        Uri.parse('http://192.168.68.109:5500/api/products/create_product');
    var request = http.MultipartRequest('POST', url);
    request.fields['productName'] = _productNameController.text;
    request.fields['productPrice'] = _productPriceController.text;
    request.fields['productDescription'] = _productDescriptionController.text;

    // Flatten _selectedLensPowers list
    List<String> flattenedLensPowers =
        _selectedLensPowers.map((power) => power.toString()).toList();
    request.fields['lensPowers'] = flattenedLensPowers.join(',');

    request.files.add(
        await http.MultipartFile.fromPath('productImage', _imageFile!.path));

    // Debug prints
    print('Selected Lens Powers: $flattenedLensPowers');
    print('Request Fields: ${request.fields}');

    try {
      var response = await request.send();
      _logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        _productNameController.clear();
        _productPriceController.clear();
        _productDescriptionController.clear();
        setState(() {
          _selectedLensPowers = [];
          _imageFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add product. Please try again.')),
        );
        _logger.e('Failed to add product. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error adding product. Please try again later.')),
      );
      _logger.e('Error adding product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextFormField(
                controller: _productPriceController,
                decoration: const InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _productDescriptionController,
                decoration:
                    const InputDecoration(labelText: 'Product Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const Text('Select Lens Powers'),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: _validLensPowers.map((power) {
                  return ChoiceChip(
                    label: Text(power),
                    selected: _selectedLensPowers.contains(power),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedLensPowers.add(power);
                        } else {
                          _selectedLensPowers.remove(power);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Center(
                child: _imageFile == null
                    ? ElevatedButton(
                        onPressed: _chooseImage,
                        child: const Text('Choose Image'),
                      )
                    : SizedBox(
                        height: 200,
                        child: Image.file(_imageFile!),
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
