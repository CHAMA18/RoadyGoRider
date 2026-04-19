import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: \$e');
  }

  // Load saved preferences
  String initialLanguage = 'English';
  ThemeMode initialThemeMode = ThemeMode.light;
  try {
    final prefs = await SharedPreferences.getInstance();
    initialLanguage = prefs.getString('selected_language') ?? 'English';
    final savedTheme = prefs.getString('theme_mode');
    if (savedTheme == 'dark') {
      initialThemeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      initialThemeMode = ThemeMode.light;
    } else if (savedTheme == 'system') {
      initialThemeMode = ThemeMode.system;
    }
  } catch (e) {
    debugPrint('Failed to load preferences: \$e');
  }

  runApp(RoadyGoRiderApp(
    initialLanguage: initialLanguage,
    initialThemeMode: initialThemeMode,
  ));
}
