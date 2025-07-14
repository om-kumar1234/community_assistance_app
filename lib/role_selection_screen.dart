import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Save role to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'role': role},
        SetOptions(merge: true),
      );

      // Navigate based on role
      if (role == 'Volunteer') {
        Navigator.pushReplacementNamed(context, '/volunteerHome');
      } else if (role == 'Help-Seeker') {
        Navigator.pushReplacementNamed(context, '/helpSeekerHome');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid role selected.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found. Please log in again.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text("Choose Your Role"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Who are you?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.volunteer_activism),
                label: const Text("I'm a Volunteer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => _selectRole(context, "Volunteer"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text("I need Help"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => _selectRole(context, "Help-Seeker"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
