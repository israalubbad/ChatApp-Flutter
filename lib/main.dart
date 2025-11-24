import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/login.dart';
import 'screens/sign_up.dart';
import 'screens/users_list_screen.dart';
import 'screens/chat_screen.dart';
import 'welcom_screen.dart';
import 'firebase_options.dart';
import 'messaging/messaging_config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //   iOS Permission
  await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

  await MessagingConfig.init();

  //  FirebaseMessaging
  FirebaseMessaging.onBackgroundMessage(MessagingConfig.firebaseBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      navigatorKey: navigatorKey,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        Login.id: (context) => const Login(),
        SignUp.id: (context) => const SignUp(),
        UsersListScreen.id: (context) => UsersListScreen(),
        ChatScreen.id: (context) => const ChatScreen(),
      },
    );
  }
}
