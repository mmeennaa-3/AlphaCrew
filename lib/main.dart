import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tourguide/core/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'features/log_in_page.dart';
import 'features/map_page.dart';
import 'features/notifications_page.dart';
import 'features/profile_page.dart';
import 'features/sign_up_page.dart';
import 'features/search_page.dart';
import 'features/user_lists_page.dart';
import 'core/auth_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('profileBox');
  await Hive.openBox<Map>('placeMetadataCache');
  await Hive.openBox<Map>('favoritesCache');
  await Hive.openBox<Map>('visitsCache');
  await Hive.openBox('notificationsBox');

  await requestPermissions();

  await NotificationService.init();

  await Supabase.initialize(
    url: 'https://boigsncggxzxucrxtudz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJvaWdzbmNnZ3h6eHVjcnh0dWR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxNDU1ODgsImV4cCI6MjA3OTcyMTU4OH0.Qnsz7m4o4RH7Cde4_vLZdHdzpLVtiyRwnQvEptEAgds',
  );


  runApp(const MyApp());
}
Future<void> requestPermissions() async {
  await [
    Permission.location,
    Permission.locationAlways,
    Permission.notification,
  ].request();
}

final cloud = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tour Guide',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MainPage()),
        GetPage(name: '/notifications', page: () => const NotificationsPage()),

      ],
      theme: ThemeData(useMaterial3: true),
     // home: const MainPage(),
      home: LogInPage(),
      // MainPage()
      //AuthService().isLoggedIn() ? MainPage() : LogInPage(),

      //LogInPage(),
      //  const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final RxInt currentIndex = 0.obs;

  final pages = [
    // const HomePage(),
    const MapPage(),
    const SearchPage(),
    UserListsPage(),
    const NotificationsPage(),
    ProfilePage(),
  ];


  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: pages[currentIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex.value,
          onTap: (index) => currentIndex.value = index,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

