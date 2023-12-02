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
import '../homePage/bloodSugar/bloodSugarMoreData.dart';
import '../homePage/bloodFat/bloodFatMoreData.dart';
import '../homePage/activity/activityDetails.dart';

// 科普模块
import '../articles/foodsearch.dart';
import '../articles/articles.dart';
import '../articles/science.dart';
import '../articles/sciencepage.dart';
import '../articles/medicine.dart';
import '../articles/prevention.dart';
import '../articles/collection.dart';
// 饮食模块
import '../fooddiary/fooddiary.dart';
// 动态模块
import '../moment/moment.dart';

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
  'homePage/BloodSugar/MoreData': (context) => const BloodSugarMoreData(),

  //血脂
  '/homePage/BloodFat/Edit': (context) => BloodFatEdit(
      arguments: {"bfDataId": -1, "date": DateTime.now(), "prevPage": 0}),
  '/homePage/BloodFat/Details': (context) =>
      BloodFatDetails(arguments: {"userId": 1, "date": DateTime.now()}),
  'homePage/BloodFat/MoreData': (context) => const BloodFatMoreData(),

  //活动
  '/homePage/Activity/Details': (context) =>
      ActivityDetails(arguments: {"userId": 1, "date": DateTime.now()}),

  '/supervisor': (context) => const Supervisor(),
  '/user': (context) => const User(),
  '/mainPages': (context, {arguments}) => MainPages(arguments: arguments),
  '/account/register': (context) => const RegisterAccount(),

  //'/': (context) => const Moment(),
  // -------------------- 动态模块 ====================
  '/moment': (context) => const Moment(),
  // ==================== 饮食模块 ====================
  '/fooddiary': (context) => const FoodDiary(),
  // ==================== 科普模块 ====================
  '/articles': (context) => const Article(),
  '/articles/science': (context) => const Science(),
  '/articles/science/page': (context) =>
      const SciencePage(title: "返回文章列表", link: '/articles/science'),
  '/articles/foodsearch': (context) => const Foodsearch(),

  '/articles/medicine': (context) => const Medicine(),
  '/articles/prevention': (context) => const Prevention(),
  '/articles/collection': (context) => const Collection(),
  '/articles/collection/articlepage': (context) =>
      const SciencePage(title: "返回收藏列表", link: '/articles/collection'),
};

var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name;
  final Function pageContentBuilder = routes[name] as Function;
  // ignore: unnecessary_null_comparison
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
