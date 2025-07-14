import 'package:community_assistance/RoleScreen/Volunteer_home_screen.dart';
import 'package:community_assistance/RoleScreen/help_seeker_home_screen.dart';
import 'package:community_assistance/login_screen.dart';
import 'package:community_assistance/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> checkUserStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen(); // not logged in
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final role = doc.data()?['role'];

    if (role == 'Volunteer') {
      return const VolunteerHomeScreen();
    } else if (role == 'Help-Seeker') {
      return const HelpSeekerHomeScreen();
    } else {
      return const RoleSelectionScreen(); // no role yet
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkUserStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong!')),
          );
        } else {
          return snapshot.data as Widget;
        }
      },
    );
  }
}
