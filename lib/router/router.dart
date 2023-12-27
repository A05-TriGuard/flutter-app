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

// 活动
import '../homePage/activity/activityEdit.dart';
import '../homePage/activity/activityDetails.dart';

// 监护模块
import '../supervisor/guardianGroup.dart';
import '../supervisor/guardianPerson.dart';

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
import '../user/nutritiontarget.dart';
// 动态模块
import '../moment/moment.dart';

Map routes = {
  '/': (context) => const LoginPage(),
  '/resetPassword': (context) => const ResetPassword(),

  '/homePage': (context, {arguments}) => HomePage(arguments: arguments),

  // 血压，血糖，血脂，活动，饮食 （带参数的写法）
  '/mainPages': (context, {arguments}) => MainPages(arguments: arguments),

  //血压

  // 血压编辑
  '/homePage/BloodPressure/Edit': (context, {arguments}) =>
      BloodPressureEdit(arguments: arguments),
  // 血压详情
  '/homePage/BloodPressure/Details': (context, {arguments}) =>
      BloodPressureDetails(arguments: arguments),
  // 血压更多数据
  'homePage/BloodPressure/MoreData': (context, {arguments}) =>
      BloodPressureMoreData(arguments: arguments),

  // 血糖

  '/homePage/BloodSugar/Edit': (context, {arguments}) =>
      BloodSugarEdit(arguments: arguments),
  '/homePage/BloodSugar/Details': (context, {arguments}) =>
      BloodSugarDetails(arguments: arguments),
  'homePage/BloodSugar/MoreData': (context, {arguments}) =>
      BloodSugarMoreData(arguments: arguments),

  //血脂
  '/homePage/BloodFat/Edit': (context, {arguments}) =>
      BloodFatEdit(arguments: arguments),
  '/homePage/BloodFat/Details': (context, {arguments}) =>
      BloodFatDetails(arguments: arguments),
  'homePage/BloodFat/MoreData': (context, {arguments}) =>
      BloodFatMoreData(arguments: arguments),

  //活动
  //'/homePage/Activity/Details': (context) =>
  //    ActivityDetails(arguments: {"userId": 1, "date": DateTime.now()}),
  '/homePage/Activity/Edit': (context, {arguments}) =>
      ActivityEdit(arguments: arguments),
  '/homePage/Activity/Details': (context, {arguments}) =>
      ActivityDetails(arguments: arguments),

  // 监护模块
  '/supervisor': (context) => const Supervisor(),
  '/supervisor/person': (context, {arguments}) =>
      GuardianPersonPage(arguments: arguments),
  '/supervisor/group': (context, {arguments}) =>
      GuardianGroupPage(arguments: arguments),

  '/user': (context) => const User(),

  '/account/register': (context) => const RegisterAccount(),

  //'/': (context) => const Moment(),
  // -------------------- 动态模块 ====================
  '/moment': (context) => const Moment(),
  // ==================== 饮食模块 ====================
  '/homePage/fooddiary/Details': (context) => const FoodDiary(),
  '/user/nutritiontarget': (context) => const NutritionTarget(),
  // ==================== 科普模块 ====================
  '/articles': (context) => const Article(),
  '/articles/science': (context) => const Science(),
  '/articles/foodsearch': (context) => const Foodsearch(),
  '/articles/medicine': (context) => const Medicine(),
  '/articles/prevention': (context) => const Prevention(),
  '/articles/collection': (context) => const Collection(
        selectedButton: [true, false, false, false],
      ),
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
