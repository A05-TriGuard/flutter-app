import 'package:flutter/material.dart';
// 科普模块
import '../articles/foodsearch.dart';
import '../articles/foodsearchpage.dart';
import '../articles/articles.dart';
import '../articles/science.dart';
import '../articles/sciencepage.dart';
import '../articles/medicine.dart';
import '../articles/medicinepage.dart';
import '../articles/prevention.dart';
import '../articles/collection.dart';
// 饮食模块
import '../fooddiary/fooddiary.dart';

Map routes = {
  '/': (context) => const FoodDiary(),
  // ==================== 饮食模块 ====================
  '/fooddiary': (context) => const FoodDiary(),
  // ==================== 科普模块 ====================
  '/articles': (context) => const Article(),
  '/articles/science': (context) => const Science(),
  '/articles/science/page': (context) =>
      const SciencePage(title: "返回文章列表", link: '/articles/science'),
  '/articles/foodsearch': (context) => const Foodsearch(),
  '/articles/foodsearch/page': (context) =>
      const FoodsearchPage(title: "返回查询页面", link: '/articles/foodsearch'),
  '/articles/medicine': (context) => const Medicine(),
  '/articles/medicine/page': (context) =>
      const MedicinePage(title: "返回查询页面", link: '/articles/medicine'),
  '/articles/prevention': (context) => const Prevention(),
  '/articles/collection': (context) => const Collection(),
  '/articles/collection/articlepage': (context) =>
      const SciencePage(title: "返回收藏列表", link: '/articles/collection'),
  '/articles/collection/medicinepage': (context) =>
      const MedicinePage(title: "返回收藏列表", link: '/articles/collection'),
  '/articles/collection/foodsearchpage': (context) =>
      const FoodsearchPage(title: "返回收藏列表", link: '/articles/collection'),
};

var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name;
  final Function pageContentBuilder = routes[name] as Function;
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
};
