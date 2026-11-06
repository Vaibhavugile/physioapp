import 'package:flutter/material.dart';

import 'theme.dart';
import '../features/splash/splash_screen.dart';

class PhysioAtHomeApp extends StatelessWidget {
  const PhysioAtHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PhysioHomey',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}