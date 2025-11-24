
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/screens/users_list_screen.dart';

import '../widgets/custom_button.dart';

class Login extends StatefulWidget {
  static const String id = '/login';
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _saveTokenToFirestore(String uid, String email) async {
    final token = await FirebaseMessaging.instance.getToken();
    print(token);
    print('================================================================================================================');
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print(' Saved token for $email: $token');
    } else {
      print('Could not get FCM token');
    }
  }

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(height: 100, child: Image.asset('assets/logo.jpg')),
                const SizedBox(height: 12),
                const Text('Log In', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 1)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue[800]!, width: 1)),
                    hintText: 'Enter your email',
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 1)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue[800]!, width: 1)),
                    hintText: 'Enter your password',
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
            CustomButton(
              color: Colors.yellow[800]!,
              title: 'Log In',
              onPress: () async {
                try {
                  final userCredential = await _auth.signInWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  final uid = userCredential.user?.uid;
                  if (uid != null) {
                    await _saveTokenToFirestore(uid, emailController.text.trim());
                    Navigator.pushReplacementNamed(context, UsersListScreen.id);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid Credentials"), backgroundColor: Colors.red),
                  );
                  print(e);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
