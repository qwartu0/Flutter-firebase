import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laba12/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await RemoteConfigService.initialize();
  await NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: Builder(
        builder: (context) {
          NotificationService.initialize(context);
          NotificationService.getToken().then((token) {
            print('FCM Token: ' + (token ?? 'No token'));
          });
          final appProvider = Provider.of<AppProvider>(context);
          final authProvider = Provider.of<AuthProvider>(context);
          return MaterialApp(
            title: 'Finance App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Color(0xFFF5F7FA),
              cardColor: Colors.white,
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.black),
                bodyMedium: TextStyle(color: Colors.black54),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color(0xFF121212),
              cardColor: Color(0xFF1E1E1E),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
              ),
            ),
            themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: authProvider.user == null ? LoginScreen() : HomeScreen(),
          );
        },
      ),
    );
  }
}