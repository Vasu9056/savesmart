import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/data/models/add_date.dart';
import 'package:savesmart/data/models/group.dart';
import 'package:savesmart/data/models/user.dart';
import 'package:savesmart/screens/bottom_navigation.dart';
import 'package:savesmart/screens/group/group_details_screen.dart';
import 'package:savesmart/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(AdddataAdapter());
  Hive.registerAdapter(GroupAdapter());
  Hive.registerAdapter(UserAdapter());
  
  // Open Hive Boxes
  await Hive.openBox<Add_data>('data');
  await Hive.openBox<Group>('groups');
  await Hive.openBox<User>('users');
  await Hive.openBox('settings');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xff368983),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xff368983),
          secondary: const Color(0xff368983),
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff368983),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff368983),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const Bottom(),
        '/group-details': (context) => const GroupDetailsScreen(),
      },
    );
  }
}