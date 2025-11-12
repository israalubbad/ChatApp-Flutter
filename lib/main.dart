import 'package:flutter_chat_app/firebase_options.dart';
import 'package:flutter_chat_app/screens/chat_screen.dart';
import 'package:flutter_chat_app/screens/login.dart';
import 'package:flutter_chat_app/screens/sign_up.dart';
import 'package:flutter_chat_app/screens/users_list_screen.dart';
import 'package:flutter_chat_app/welcom_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/welcome_screen',
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        Login.id: (context) => const Login(),
        SignUp.id: (context) => const SignUp(),
        ChatScreen.id: (context) => const ChatScreen(),
        UsersListScreen.id: (context) => UsersListScreen(),
      },
    );
  }
}
