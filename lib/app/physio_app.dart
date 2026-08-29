import 'package:flutter/material.dart';

import '../features/physio_auth/physio_auth_gate.dart';

class PhysioApp extends StatelessWidget {
  const PhysioApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Physio at Home Partner',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(
          0xFFF5F7FC,
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(
            0xFF2457F5,
          ),

          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(
            0xFF111A3D,
          ),
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),

        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,

          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),

            borderSide: const BorderSide(
              color: Color(
                0xFFE1E6EF,
              ),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),

            borderSide: const BorderSide(
              color: Color(
                0xFFE1E6EF,
              ),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),

            borderSide: const BorderSide(
              color: Color(
                0xFF2457F5,
              ),
              width: 1.5,
            ),
          ),
        ),
      ),

      home: const PhysioAuthGate(),
    );
  }
}