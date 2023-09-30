import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// En StatefulWidget som representerar registreringssidan.
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Instans av Firestore för att interagera med databasen.
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Kontroller för att hantera inmatning från användaren.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Funktion för att registrera användare i databasen.
  Future<void> registerUser() async {
    try {
      // Lägger till användare i 'users' samlingen i Firestore.
      DocumentReference userRef = await firestore.collection('users').add({
        'email': emailController.text,
        'password': passwordController.text,
      });
      print("Användare tillagd med ID: ${userRef.id}");
    } catch (e) {
      print("Fel: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrera')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Lösenord'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerUser,
              child: Text('Registrera'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Gå tillbaka'),
            ),
          ],
        ),
      ),
    );
  }
}
