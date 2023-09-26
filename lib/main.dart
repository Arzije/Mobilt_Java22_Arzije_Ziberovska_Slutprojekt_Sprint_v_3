import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'login_page.dart';
import 'registration_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
                Navigator.of(context).pushNamed('/register');
              },
              child: Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

