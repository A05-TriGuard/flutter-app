import 'package:flutter/material.dart';
// import 'package:triguard/homePage/homePage.dart';
// import 'component/mainPagesBar/mainPagesBar.dart';
import 'account/login.dart';
import './router/router.dart';

void main() {
  runApp(MyApp());
}

/* 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const footer());
    //home: const _LoginPageState());
  }
} */
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: LoginPage(),
      //home: const MainPages(),
      // home: HomePage(),
      //initialRoute: "/homePage",
      initialRoute: "/",
      onGenerateRoute: onGenerateRoute,
    );
  }
}
