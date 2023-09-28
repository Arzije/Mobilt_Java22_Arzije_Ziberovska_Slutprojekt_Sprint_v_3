import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

// En StatefulWidget som representerar inloggningssidan.
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Instans av Firestore för att interagera med databasen.
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Kontroller för att hantera inmatning från användaren.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Funktion för att logga in användaren.
  Future<void> loginUser() async {
    try {
      // Söker i 'users' samlingen efter en matchande e-post och lösenord.
      QuerySnapshot result = await firestore.collection('users')
          .where('email', isEqualTo: emailController.text)
          .where('password', isEqualTo: passwordController.text)
          .get();

      if (result.docs.isNotEmpty) {
        print("Lyckades logga in med email: ${emailController.text}");
        // Om lyckad inloggning, navigera till uppgiftssidan.
        (Router.of(context).routerDelegate as AppRouterDelegate).setNewRoutePath(AppRoutes.tasks);
      } else {
        print("Inloggning misslyckades. Ogiltig e-post eller lösenord.");
      }
    } catch (e) {
      print("Fel: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Logga in')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Textfält för e-postinmatning.
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                // Textfält för lösenordsinmatning med dolt lösenord.
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Lösenord'),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                // Knapp för att påbörja inloggningsprocessen.
                ElevatedButton(
                  onPressed: loginUser,
                  child: Text('Logga in'),
                ),
                SizedBox(height: 20),
                // Knapp för att gå tillbaka till startsidan.
                ElevatedButton(
                  onPressed: () {
                    (Router.of(context).routerDelegate as AppRouterDelegate).setNewRoutePath(AppRoutes.home);
                  },
                  child: Text('Gå tillbaka'),
                ),
              ],
            ),
          ),
        )
    );
  }
}
