import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/victim_store.dart';
// import 'screens/resource_allocation_details_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await VictimStore.loadVictims();
  await NotificationService.initialize();

  final bool loggedIn = await AuthService.isLoggedIn();

  runApp(
    ResQNovaApp(
      loggedIn: loggedIn,
    ),
  );
}

class ResQNovaApp extends StatelessWidget {
  final bool loggedIn;

  const ResQNovaApp({
    super.key,
    required this.loggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ResQNova',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: loggedIn
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}