import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/data/models/add_date.dart';
import 'package:savesmart/data/models/group.dart';
import 'package:savesmart/data/models/user.dart';
import 'package:savesmart/screens/bottom_navigation.dart';
import 'package:savesmart/screens/group/create_group_screen.dart';
import 'package:savesmart/screens/group/group_details_screen.dart';
import 'package:savesmart/screens/group/group_list_screen.dart';
import 'package:savesmart/screens/group/join_group_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AdddataAdapter());
  Hive.registerAdapter(GroupAdapter());
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<Add_data>('data');
  await Hive.openBox<Group>('groups');
  await Hive.openBox<User>('users');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() async {
    _appLinks = AppLinks();

    // Handle initial deep link (if app was opened via a link)
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('Initial deep link: $initialUri');
        _handleDeepLink(initialUri);
      } else {
        print('No initial deep link');
      }
    } catch (e) {
      print('Error handling initial deep link: $e');
    }

    // Listen for deep links while the app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('Received deep link: $uri');
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      print('Error listening to deep links: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'savesmart' && uri.host == 'join-group') {
      final groupId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      if (groupId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            final navigator = Navigator.of(context);
            if (navigator.mounted) {
              navigator.pushNamed(
                '/join-group',
                arguments: {'groupId': groupId},
              );
              print('Navigated to JoinGroupScreen with groupId: $groupId');
            } else {
              print('Navigator not mounted, cannot navigate to JoinGroupScreen');
            }
          } catch (e) {
            print('Error navigating to JoinGroupScreen: $e');
          }
        });
      } else {
        print('Invalid groupId in deep link: $uri');
      }
    } else {
      print('Invalid deep link scheme or host: $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SaveSmart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff368983),
          elevation: 0,
        ),
      ),
      initialRoute: '/bottom',
      routes: {
        '/bottom': (context) => const Bottom(),
        '/groups': (context) =>  GroupListScreen(),
        '/create-group': (context) => const CreateGroupScreen(),
        '/group-details': (context) =>  GroupDetailsScreen(),
        '/join-group': (context) => const JoinGroupScreen(),
      },
    );
  }
}