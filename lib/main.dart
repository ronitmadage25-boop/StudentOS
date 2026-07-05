import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/core.dart';
import 'widgets/main_navigation.dart';

/// Entry point for the StudentOS application.
///
/// Initializes Firebase and configures the [MaterialApp] with the centralized [AppTheme]
/// and routes to the [MainNavigation] shell.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const StudentOSApp());
}

/// Root widget for StudentOS.
class StudentOSApp extends StatelessWidget {
  const StudentOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ── Branding ────────────────────────────────────────────────────
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────────────────
      theme: AppTheme.light,

      // ── Entry Screen ────────────────────────────────────────────────
      home: const MainNavigation(),
    );
  }
}
