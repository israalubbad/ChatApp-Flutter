import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/users_list_screen.dart';

import '../widgets/custom_button.dart';

class SignUp extends StatefulWidget {
  static const String id = '/sign_up';
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _saveUser(String uid, String email) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
                const Text('Sign Up', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
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
              title: 'Create Account',
              onPress: () async {
                try {
                  final userCredential = await _auth.createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  final uid = userCredential.user?.uid;
                  if (uid != null) {
                    await _saveUser(uid, emailController.text.trim());
                    Navigator.pushReplacementNamed(context, UsersListScreen.id);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error creating account"), backgroundColor: Colors.red),
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
