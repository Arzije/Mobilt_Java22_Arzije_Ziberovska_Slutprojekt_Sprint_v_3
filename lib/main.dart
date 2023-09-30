import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'login_page.dart';
import 'registration_page.dart';
import 'task_page.dart';
import 'completed_task_page.dart';

// Huvudfunktionen som kör appen
void main() async {
  // Säkerställer att Flutter widgets är initialiserade
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiserar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

// Definierar rutter i appen
enum AppRoutes {
  home,
  register,
  login,
  tasks,
  completedTasks,
}

class MyApp extends StatelessWidget {
  // Skapar instanser av routerDelegate och routeInformationParser
  final _routerDelegate = AppRouterDelegate();
  final _routeInformationParser = AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    // Definierar en MaterialApp som använder router-API för navigation
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Slutprojekt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

// Parserklass för att omvandla ruttinformation (URL) till en AppRoutes enum
class AppRouteInformationParser extends RouteInformationParser<AppRoutes> {
  @override
  Future<AppRoutes> parseRouteInformation(RouteInformation routeInformation) async {
    // Returnerar motsvarande enum-värde baserat på URL
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
  // Omvandlar en AppRoutes enum till motsvarande URL
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

// Delegatklass för att hantera ruttbyten i appen
class AppRouterDelegate extends RouterDelegate<AppRoutes> with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutes> {
  final GlobalKey<NavigatorState> navigatorKey;
  // Stack av rutter som representerar appens navigationshistorik
  List<AppRoutes> _routeStack = [AppRoutes.home];

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  // Returnerar den nuvarande aktiva rutten
  AppRoutes? get currentConfiguration => _routeStack.last;

  @override
  // Bygger appens Navigator baserat på den nuvarande rutten
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _routeStack.map((route) {
        // Returnerar motsvarande sida för varje rutt
        switch (route) {
          case AppRoutes.register:
            return MaterialPage(child: RegisterPage());
          case AppRoutes.login:
            return MaterialPage(child: LoginPage());
          case AppRoutes.tasks:
            return MaterialPage(child: TaskPage());
          case AppRoutes.completedTasks:
            return MaterialPage(child: CompletedTasksPage());
          default:
            return MaterialPage(child: HomePage());
        }
      }).toList(),
      // Hanterar "pop"-operationer (t.ex. bakåt-navigering)
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        if (_routeStack.length > 1) {
          _routeStack.removeLast();
          notifyListeners();
        }
        return true;
      },
    );
  }

  @override
  // Lägger till en ny rutt till stacken och uppdaterar UI
  Future<void> setNewRoutePath(AppRoutes route) async {
    _routeStack.add(route);
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
