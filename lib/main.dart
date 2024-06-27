import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'my_app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //Google FCM init
  await Firebase.initializeApp();

  runApp(const MyApp());
}