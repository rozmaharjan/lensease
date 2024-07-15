import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageLensPowersPage extends StatefulWidget {
  const ManageLensPowersPage({super.key});

  @override
  _ManageLensPowersPageState createState() => _ManageLensPowersPageState();
}

class _ManageLensPowersPageState extends State<ManageLensPowersPage> {
  final TextEditingController _lensPowerController = TextEditingController();
  List<double> _lensPowers = [];

  @override
  void initState() {
    super.initState();
    _fetchLensPowers();
  }

  Future<void> _fetchLensPowers() async {
    final response = await http
        .get(Uri.parse('http://192.168.68.109:5500/api/lenspowers/all'));
    if (response.statusCode == 200) {
      setState(() {
        _lensPowers =
            (json.decode(response.body)['lensPowers'] as List<dynamic>)
                .map((data) => (data['power'] as num).toDouble())
                .toList();
      });
    }
  }

  Future<void> _addLensPower() async {
    final power = double.tryParse(_lensPowerController.text);
    if (power == null) return;

    final response = await http.post(
      Uri.parse('http://192.168.68.109:5500/api/lenspowers/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'power': power}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _lensPowers.add(power);
        _lensPowers.sort();
        _lensPowerController.clear();
      });
    }
  }

  Future<void> _deleteLensPower(double power) async {
    // Fetch the ID of the lens power to delete (assuming it is sent back in the fetch response)
    final response = await http
        .get(Uri.parse('http://192.168.68.109:5500/api/lenspowers/all'));
    if (response.statusCode == 200) {
      final lensPowers = json.decode(response.body)['lensPowers'];
      final lensPowerToDelete =
          lensPowers.firstWhere((lp) => lp['power'] == power);

      final deleteResponse = await http.delete(
        Uri.parse(
            'http://192.168.68.109:5500/api/lenspowers/delete/${lensPowerToDelete['_id']}'),
      );

      if (deleteResponse.statusCode == 200) {
        setState(() {
          _lensPowers.remove(power);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Lens Powers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _lensPowerController,
              decoration: const InputDecoration(labelText: 'Add Lens Power'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addLensPower,
              child: const Text('Add Lens Power'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _lensPowers.length,
                itemBuilder: (context, index) {
                  final power = _lensPowers[index];
                  return ListTile(
                    title: Text(power.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteLensPower(power),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
