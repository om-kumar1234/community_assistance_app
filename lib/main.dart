import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'splash_screen.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';
import 'RoleScreen/Volunteer_home_screen.dart';
import 'RoleScreen/help_seeker_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Required for async init

  // ✅ Firebase Initialization
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCj3SbZaEwBme942AH_8J_RecXym0oXD74",
        authDomain: "community-assistance-b9e1e.firebaseapp.com",
        projectId: "community-assistance-b9e1e",
        storageBucket: "community-assistance-b9e1e.appspot.com", // 🔧 fixed `.app` typo
        messagingSenderId: "632471526230",
        appId: "1:632471526230:web:db7a43927efecae05fd4f7",
      ),
    );
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } else {
    await Firebase.initializeApp();
  }

  // ✅ Debug print to confirm session
  print("User on startup: ${FirebaseAuth.instance.currentUser}");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Assist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const SplashScreen(), // ✅ Start from splash screen
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/roleSelection': (context) => const RoleSelectionScreen(),
        '/volunteerHome': (context) => const VolunteerHomeScreen(),
        '/helpSeekerHome': (context) => const HelpSeekerHomeScreen(),
      },
    );
  }
}
