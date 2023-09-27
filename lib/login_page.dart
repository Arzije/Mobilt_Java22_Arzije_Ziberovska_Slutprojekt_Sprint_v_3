import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'task_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    try {
      QuerySnapshot result = await firestore.collection('users')
          .where('email', isEqualTo: emailController.text)
          .where('password', isEqualTo: passwordController.text)
          .get();

      if (result.docs.isNotEmpty) {
        print("Successfully logged in with email: ${emailController.text}");
        // Använd routerDelegate för navigering
        (Router.of(context).routerDelegate as AppRouterDelegate).setNewRoutePath(AppRoutes.tasks);
      } else {
        print("Login failed. Invalid email or password.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Login')),
    body: Padding(
    padding: EdgeInsets.all(16.0),
    child: SingleChildScrollView( // Lägg till denna rad
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loginUser,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Använd routerDelegate för att gå tillbaka till hemskärmen
                (Router.of(context).routerDelegate as AppRouterDelegate).setNewRoutePath(AppRoutes.home);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
      )
    );
  }
}
