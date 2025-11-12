import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/screens/login.dart';
import 'package:flutter_chat_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SignUp extends StatefulWidget {
  static const String id = '/sign_up';
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _auth = FirebaseAuth.instance; //1
  final _firebaseStore = FirebaseFirestore.instance;
  String collectionName = 'users';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(height: 100, child: Image.asset('images/logo.jpg')),

                Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 30),

                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue[800]!,
                        width: 1,
                      ),
                    ),
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  controller: passwordController,

                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue[800]!,
                        width: 1,
                      ),
                    ),
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),

            CustomButton(
              color: Colors.blue[800]!,
              title: 'Sign Up',
              onPress: () async {
                //
                try {
                  final newUser = await _auth.createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (newUser.user != null) {
                    await _firebaseStore.collection(collectionName).doc(newUser.user!.uid).set({
                      'email': newUser.user!.email,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    Navigator.pushNamed(context, Login.id);
                  }
                } catch (e) {
                  print(' Error: $e');
                }

              },
            ),
          ],
        ),
      ),
    );
  }
}
