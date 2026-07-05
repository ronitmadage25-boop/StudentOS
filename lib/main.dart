import 'package:flutter/material.dart';
import 'core/core.dart';
import 'widgets/main_navigation.dart';

/// Entry point for the StudentOS application.
///
/// Configures the [MaterialApp] with the centralized [AppTheme]
/// and routes to the [MainNavigation] shell.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
