import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'login_page.dart';
import 'registration_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //
  // final FirebaseFirestore storedb = FirebaseFirestore.instance;
  // final city = <String, String>{
  //   "name": "ALRIK",
  //   "age": "31",
  //   "country": "Sweden"
  // };
  // print(storedb);
  // storedb
  //     .collection("cities")
  //     .doc("LA")
  //     .set(city)
  //     .onError((e, _) => print("Error writing document: $e"));

//   runApp(const MyApp());
// }

  runApp( MyApp());
}

enum AppRoutes {
  home,
  register,
  login,
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}

class AppRouteInformationParser extends RouteInformationParser<AppRoutes> {
  @override
  Future<AppRoutes> parseRouteInformation(RouteInformation routeInformation) async {
    switch (routeInformation.location) {
      case '/register':
        return AppRoutes.register;
      case '/login':
        return AppRoutes.login;
      default:
        return AppRoutes.home;
    }
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutes route) {
    switch (route) {
      case AppRoutes.register:
        return RouteInformation(location: '/register');
      case AppRoutes.login:
        return RouteInformation(location: '/login');
      default:
        return RouteInformation(location: '/');
    }
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoutes> with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutes> {
  final GlobalKey<NavigatorState> navigatorKey;

  AppRoutes? _currentRoute;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoutes? get currentConfiguration => _currentRoute;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(child: HomePage()), // Default page
        if (_currentRoute == AppRoutes.register) MaterialPage(child: RegisterPage()),
        if (_currentRoute == AppRoutes.login) MaterialPage(child: LoginPage())
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        _currentRoute = null;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutes route) async {
    _currentRoute = route;
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/register');
              },
              child: Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}








// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   late Future<FirebaseApp> _initialization;
//
//   @override
//   void initState() {
//     super.initState();
//     _initialization = Firebase.initializeApp();
//   }
//
//   void addData() async {
//     CollectionReference collection = FirebaseFirestore.instance.collection('test');
//
//     collection.add({
//       'name': 'Flutter',
//       'description': 'Firestore test'
//     }).then((DocumentReference document) {
//       print("Document added with ID: ${document.id}");
//     }).catchError((error) {
//       print("Error adding document: $error");
//     });
//   }
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//     addData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initialization,
//       builder: (context, snapshot) {
//         // Check for errors
//         if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(child: Text('Error initializing Firebase')),
//           );
//         }
//
//         // Once complete, show your application
//         if (snapshot.connectionState == ConnectionState.done) {
//           return Scaffold(
//             appBar: AppBar(
//               backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//               title: Text(widget.title),
//             ),
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   const Text('You have pushed the button this many times:'),
//                   Text(
//                     '$_counter',
//                     style: Theme.of(context).textTheme.headlineMedium,
//                   ),
//                 ],
//               ),
//             ),
//             floatingActionButton: FloatingActionButton(
//               onPressed: _incrementCounter,
//               tooltip: 'Increment',
//               child: const Icon(Icons.add),
//             ),
//           );
//         }
//
//         // Otherwise, show something whilst waiting for initialization to complete
//         return Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       },
//     );
//   }
// }
