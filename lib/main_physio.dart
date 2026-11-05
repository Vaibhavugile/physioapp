import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/physio_app.dart';
import 'firebase_options_physio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const PhysioApp(),
  );
}