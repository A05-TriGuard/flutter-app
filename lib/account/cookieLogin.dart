import 'dart:async';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../account/token.dart';

class CookieLogin extends StatefulWidget {
  const CookieLogin({Key? key}) : super(key: key);

  @override
  State<CookieLogin> createState() => _CookieLoginState();
}

class _CookieLoginState extends State<CookieLogin> {
  bool isLoginFailed = true;

  // 登录函数

  Future<void> login2() async {
    var username = await storage.read(key: 'username');
    var password = await storage.read(key: 'password');
    final dio = Dio();
    Response response;

    Completer<void> completer = Completer<void>();

    try {
      response = await dio
          .post("http://43.138.75.58:8080/api/auth/login", queryParameters: {
        'username': username,
        'password': password,
      });
      print(response.data);

      if (response.data["code"] == 200) {
        await storage.write(key: "isLogout", value: "0");
        isLoginFailed = false;
        // print("Login successful");
        completer.complete();
      } else {
        setState(() {
          isLoginFailed = true;
        });
        //print("Login failed");
      }
    } catch (error) {}

    if (!completer.isCompleted) {
      setState(() {
        isLoginFailed = true;
      });
    }
  }

  @override
  void initState() {
    isLoginFailed = true;
    super.initState();
    loginWithTimeout();
  }

  void loginWithTimeout() async {
    var isLogout = await storage.read(key: 'isLogout');
    if (isLogout == null || isLogout == "1") {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/login');
      return;
    }

    const Duration timeout = Duration(seconds: 3);

    login2();

    Future.delayed(timeout, () async {
      if (!mounted) {
        return;
      }
      // 自动登录成功，跳转至首页
      if (isLoginFailed == false) {
        // 保存token
        await storage.write(key: "isLogout", value: "0");
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/mainPages',
            arguments: {"accountId": -1});
      }
      // 自动登录失败，跳转至登录页面
      else {
        Navigator.pushNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool didPop) {
        if (didPop) {
          //退出app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Container(
          // 背景图片
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/loginBg1.png"),
              fit: BoxFit.cover,
              opacity: 0.66,
            ),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // TriGuard白透明背景标题
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // 图片
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.85, // 宽度占屏幕宽度的90%
                      height: MediaQuery.of(context).size.height *
                          0.3, // 高度占屏幕高度的30%
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/loginLogo.png"),
                          fit: BoxFit.contain,
                          opacity: 1,
                        ),
                      ),
                    ),

                    // TriGuard文字
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: 50,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Color.fromARGB(220, 255, 255, 255),
                      ),
                    ),
                    const Text(
                      "TriGuard",
                      style: TextStyle(
                          fontFamily: 'BalooBhai',
                          fontSize: 36,
                          color: Colors.black),
                    ),
                  ],
                ),

                const Text(
                  "打造健康生活，共享健康生活",
                  style: TextStyle(
                    fontFamily: 'BalooBhai',
                    fontSize: 20,
                    color: Color.fromARGB(255, 43, 42, 42),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
