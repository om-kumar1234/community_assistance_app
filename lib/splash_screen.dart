import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ Delay to ensure splash screen is shown for at least 2 seconds
    Future.delayed(const Duration(seconds: 2), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!mounted) return;

          final role = userDoc.data()?['role'];

          if (role == 'Volunteer') {
            Navigator.pushReplacementNamed(context, '/volunteerHome');
          } else if (role == 'Help-Seeker') {
            Navigator.pushReplacementNamed(context, '/helpSeekerHome');
          } else {
            Navigator.pushReplacementNamed(context, '/roleSelection');
          }
        } catch (e) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/roleSelection');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/charity.png', height: 120),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.teal),
            const SizedBox(height: 20),
            const Text(
              "Connecting Helpers & Seekers...",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
