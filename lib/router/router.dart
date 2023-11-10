import 'package:flutter/material.dart';
import '../account/login.dart';
import '../homePage/homePage.dart';
import '../articles/articles.dart';
import '../supervisor/supervisor.dart';
import '../moment/moment.dart';
import '../user/user.dart';
import '../component/mainPagesBar/mainPagesBar.dart';
import '../account/register.dart';

Map routes = {
  '/': (context) => const LoginPage(),
  '/homePage': (context) => const HomePage(),
  '/articles': (context) => const Article(),
  '/supervisor': (context) => const Supervisor(),
  '/moment': (context) => const Moment(),
  '/user': (context) => const User(),
  '/mainPages': (context, {arguments}) => MainPages(arguments: arguments),
  '/account/register': (context) => const RegisterAccount(),
};

var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name;
  final Function pageContentBuilder = routes[name] as Function;
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
