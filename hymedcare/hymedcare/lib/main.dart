import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/chat/provider/chat_room_provider.dart';
import 'firebase_options.dart';
import 'provider/auth_provider.dart';
import 'features/articles/provider/article_provider.dart';
import 'appointments/provider/appointment_provider.dart';
import 'features/home/home_page.dart';
import 'splash_screen.dart';
import 'theme/theme_provider.dart';
import 'services/notification_service.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final savedEmail = prefs.getString('email');
  final savedPassword = prefs.getString('password');
  final savedUserId = prefs.getString('userId');

  final authProvider = HymedCareAuthProvider();
  await authProvider.initializeUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => ChatRoomProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
      ],
      child: MyApp(
        initialPage:  savedUserId != null ? (savedEmail != null && savedPassword != null)
            // ? const HomePage()
            // : const TelemedLoginPage() : const SplashScreen(),
             ? const HomePage()
            : const HomePage() : const SplashScreen(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CupertinoApp(
          theme: themeProvider.theme,
          home: initialPage,
          localizationsDelegates: const [
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          title: "HymedCare",
        );
      },
    );
  }
}
