import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'login_page.dart';
import 'registration_page.dart';
import 'task_page.dart';
import 'completed_task_page.dart';

// Huvudfunktionen som kör appen
void main() async {
  // Initialisera Flutter widgets
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisera Firebase med de angivna alternativen
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

// Enum för att hantera appens rutter
enum AppRoutes {
  home,
  register,
  login,
  tasks,
  completedTasks,
}

class MyApp extends StatelessWidget {
  final _routerDelegate = AppRouterDelegate();
  final _routeInformationParser = AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

// Parser klass för att omvandla ruttinformation till en AppRoutes enum
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
      case AppRoutes.tasks:
        return RouteInformation(location: '/tasks');
      case AppRoutes.completedTasks:
        return RouteInformation(location: '/completedTasks');
      default:
        return RouteInformation(location: '/');
    }
  }
}

// Delegera klass för att hantera ruttbyten i appen
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
        MaterialPage(child: HomePage()),
        if (_currentRoute == AppRoutes.register) MaterialPage(child: RegisterPage()),
        if (_currentRoute == AppRoutes.login) MaterialPage(child: LoginPage()),
        if (_currentRoute == AppRoutes.tasks) MaterialPage(child: TaskPage()),
        if (_currentRoute == AppRoutes.completedTasks) MaterialPage(child: CompletedTasksPage()),
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
    notifyListeners();
  }
}

// Startsida med knappar för att navigera till registrering och inloggning
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
                (Router.of(context).routerDelegate as AppRouterDelegate).setNewRoutePath(AppRoutes.register);
              },
              child: Text('Registrera'),
            ),
            ElevatedButton(
              onPressed: () {
                (Router.of(context).routerDelegate as AppRouterDelegate).setNewRoutePath(AppRoutes.login);
              },
              child: Text('Logga in'),
            ),
          ],
        ),
      ),
    );
  }
}
