import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:nubtk_cse/AdminScreen/Admin%20Home%20Screen.dart'; // Adjust this import based on your project structure

import '../AppColors/AppColors.dart'; // Import your AppColors

class AdminPasswordScreen extends StatefulWidget {
  @override
  _AdminPasswordScreenState createState() => _AdminPasswordScreenState();
}

class _AdminPasswordScreenState extends State<AdminPasswordScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _correctPassword; // Variable to store the fetched password from Firestore

  @override
  void initState() {
    super.initState();
    _fetchPasswordFromFirestore(); // Fetch the password when the widget is initialized
  }

  // Method to fetch the password from Firestore
  Future<void> _fetchPasswordFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('config')
          .doc('admin')
          .get();

      setState(() {
        _correctPassword = snapshot.get('password'); // Fetch the password field
      });
    } catch (e) {
      print("Error fetching password: $e");
    }
  }

  // Method to set a password in Firestore
  Future<void> _setPasswordInFirestore(String password) async {
    try {
      CollectionReference configCollection =
      FirebaseFirestore.instance.collection('config');

      await configCollection.doc('admin').set({
        'password': password,
      });

      print("Password set successfully!");
    } catch (e) {
      print("Error setting password: $e");
    }
  }

  void _checkPassword() {
    if (_controller.text == _correctPassword) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminHomeScreen()), // Navigate to AdminHomeScreen
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error", style: TextStyle(color: colorRed)),
          content: const Text("Incorrect password. Please try again."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.pColor,
        title: const Center(
          child: Text(
            "Admin ",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                fontFamily: 'kalpurush',
                color: colorWhite),
          ),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        color: AppColors.pColor.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Enter Your Password:"),
              const SizedBox(height: 30),
              TextField(
                controller: _controller,
                obscureText: true,
                keyboardType: TextInputType.text,
                maxLength: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter 8-character password',
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _checkPassword,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.pColor,
                  padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
