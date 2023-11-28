import 'package:flutter/material.dart';
import 'package:triguard/homePage/bloodPressure/bloodPressureMoreData.dart';
import '../account/login.dart';
import '../account/resetPassword.dart';
import '../homePage/homePage.dart';
import '../articles/articles.dart';
import '../supervisor/supervisor.dart';
import '../moment/moment.dart';
import '../user/user.dart';
import '../component/mainPagesBar/mainPagesBar.dart';
import '../account/register.dart';
import '../homePage/bloodPressure/bloodPressureEdit.dart';
import '../homePage/bloodPressure/bloodPressureDetails.dart';
import '../homePage/bloodSugar/bloodSugarEdit.dart';
import '../homePage/bloodFat/bloodFatEdit.dart';
import '../homePage/bloodSugar/bloodSugarDetails.dart';
import '../homePage/bloodFat/bloodFatDetails.dart';

Map routes = {
  '/': (context) => const LoginPage(),
  '/resetPassword': (context) => const ResetPassword(),

  '/homePage': (context) => const HomePage(),

  //血压
  '/homePage/BloodPressure/Edit': (context) => BloodPressureEdit(
      arguments: {"bpDataId": -1, "date": DateTime.now(), "prevPage": 0}),
  '/homePage/BloodPressure/Details': (context) =>
      BloodPressureDetails(arguments: {"userId": 1, "date": DateTime.now()}),
  'homePage/BloodPressure/MoreData': (context) => const BloodPressureMoreData(),

  // 血糖
  '/homePage/BloodSugar/Edit': (context) => BloodSugarEdit(
      arguments: {"bsDataId": -1, "date": DateTime.now(), "prevPage": 0}),
  '/homePage/BloodSugar/Details': (context) =>
      BloodSugarDetails(arguments: {"userId": 1, "date": DateTime.now()}),

  //血脂
  '/homePage/BloodFat/Edit': (context) => BloodFatEdit(
      arguments: {"bfDataId": -1, "date": DateTime.now(), "prevPage": 0}),
  '/homePage/BloodFat/Details': (context) =>
      BloodFatDetails(arguments: {"userId": 1, "date": DateTime.now()}),

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
