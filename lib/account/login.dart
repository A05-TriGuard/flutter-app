import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 获取用户输入的资料与密码
  final TextEditingController usernameController =
      TextEditingController(text: "admin");
  final TextEditingController passwordController =
      TextEditingController(text: "123456");
  bool isLoggedIn = false;
  bool isLoginFailed = false;
  Dio dio = Dio();

  // 登录函数
  void login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (!(username.isEmpty || password.isEmpty)) {
      const String loginApi = 'http://43.138.75.58:8080/api/auth/login';
      Response response = await dio.post(loginApi, queryParameters: {
        'username': username,
        'password': password,
      });

      print(response.data);

      if (response.data['code'] == 200) {
        print("登录成功");
        Navigator.pushNamed(context, '/mainPages', arguments: {"id": 1});
      } else {
        isLoginFailed = true;
        setState(() {});
      }
    }

    // ======================================================
    // http

    //https://blog.csdn.net/DongShanYuXiao/article/details/132031108

    // 定义API端点
    /* final String apiUrl = 'http://43.138.75.58:8080/api/auth/login';
      debugPrint("username: ${username}, password: ${password}");

      // 准备请求体数据
      Map<String, dynamic> requestBody = {
        'username': username,
        'password': password,
      };

      // 将请求体数据转为JSON格式
      //String requestBodyJson = jsonEncode(requestBody);

      try {
        // 发起POST请求
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded', // 指定请求体格式为JSON
            //'Content-Type': 'application/json',
          },
          body: requestBody,
        );
        // 检查请求是否成功
        if (response.statusCode == 200) {
          // 解析响应数据
          Map<String, dynamic> responseData = jsonDecode(response.body);

          // 处理响应数据，根据需要进行其他操作
          print('$responseData');

          if (responseData['code'] == 200) {
            print("登录成功");
            Navigator.pushNamed(context, '/mainPages', arguments: {"id": 1});
          }
        } else {
          // 请求失败时的处理
          print('请求失败，状态码：${response.statusCode}');
        }
      } catch (error) {
        // 发生异常时的处理
        print('发生异常：$error');
      }
    } */
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = true;
    final VoidCallback? onPressed = enabled
        ? () {
            print("object");
          }
        : null;
    return
        //SafeArea(  // 可以避免摄像头等
        //child:
        Scaffold(
      //避免键盘弹出时，出现overFlow现象
      //https://stackoverflow.com/questions/54156420/flutter-bottom-overflowed-by-119-pixels
      resizeToAvoidBottomInset: false,
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/loginBg1.png"),
            fit: BoxFit.cover,
            opacity: 0.66,
          ),
        ),
        child: Column(
          children: [
            // TriGuard白透明背景标题
            Padding(
                padding: const EdgeInsets.only(top: 70, bottom: 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      //height: 220, // 设置Logo图片的高度
                      //width: 357, // 设置Logo图片的宽度
                      width: MediaQuery.of(context).size.width *
                          0.85, // 宽度占屏幕宽度的90%
                      height: MediaQuery.of(context).size.height *
                          0.3, // 高度占屏幕高度的30%
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/loginLogo.png"),
                          fit: BoxFit.contain,
                          opacity: 1,
                          //alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: 50,
                        //color: Color.fromARGB(190, 255, 255, 255),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Color.fromARGB(220, 255, 255, 255),
                        )),
                    const Text(
                      "TriGuard",
                      style: TextStyle(
                          fontFamily: 'BalooBhai',
                          fontSize: 36,
                          color: Colors.black),
                    ),
                  ],
                )),

            // 登录组件
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 用户名输入框
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        // TODO
                        child: TextFormField(
                          controller: usernameController,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: Colors.black38,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          decoration: InputDecoration(
                            //取消奇怪的高度
                            isCollapsed: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 10, 15, 10),
                            counterStyle:
                                const TextStyle(color: Colors.black38),
                            prefixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Image.asset(
                                  "assets/icons/profile.png",
                                  width: 16,
                                  height: 16,
                                )),
                            prefixIconConstraints: BoxConstraints(minWidth: 60),
                            labelText: '用户名/手机号/邮箱',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(96, 104, 104, 104),
                            ),
                            //fillColor: Color.fromARGB(190, 255, 255, 255),
                            fillColor: Color.fromARGB(187, 250, 250, 250),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(0, 0, 0, 0.2)),
                              //borderSide: BorderSide.none
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(179, 145, 145, 145))),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      //密码框
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        //height: 45,
                        // TODO
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true, //隐藏密码
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.top,
                          //maxLines: 1,
                          cursorColor: Colors.black38,
                          style: const TextStyle(color: Colors.black),

                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 10, 15, 10),
                            prefixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Image.asset(
                                  "assets/icons/lock.png",
                                  width: 20,
                                  height: 20,
                                )),
                            prefixIconConstraints: BoxConstraints(minWidth: 60),
                            labelText: '密码',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(96, 104, 104, 104),
                            ),
                            //fillColor: Color.fromARGB(190, 255, 255, 255),
                            fillColor: Color.fromARGB(187, 250, 250, 250),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(0, 0, 0, 0.2)),
                              //borderSide: BorderSide.none
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(179, 145, 145, 145))),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      //登录按钮
                      Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(146, 155, 155, 155),
                                spreadRadius: 0.4,
                                blurRadius: 5,
                                offset: Offset(0, 4),
                              )
                            ]),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: FilledButton(
                            onPressed: () {
                              login();
                              //Navigator.pushNamed(context, '/mainPages');
                              // print("object");
                            },
                            //onPressed: onPressed,

                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 132, 176),
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            child: const Text('登录'),
                          ),
                        ),
                      ),

                      // 登录失败显示提示信息
                      isLoginFailed == true
                          ? Column(
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  alignment: Alignment.centerRight,
                                  child: const Text(
                                    "用户或密码错误",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.red,
                                      fontFamily: "BalooBhai",
                                    ),
                                  ),
                                ),
                              ],
                            )
                          :
                          // 登录失败时显示

                          const SizedBox(
                              height: 15,
                            ),

                      //忘记密码 或选择
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0, 0, 15, 0), //(0, 0, 10, 0),
                                child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isLoginFailed = false;
                                      });
                                      Navigator.pushNamed(
                                          context, '/resetPassword');
                                    },
                                    child: const Text(
                                      "忘记密码",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                              255, 106, 116, 207)),
                                    ))),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(
                                  10, 0, 25, 0), //(10, 0, 15, 0),
                              child: Text(
                                "或选择",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black38),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //其他登录方式
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.7 *
                                  0.48,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(115, 180, 180, 180),
                                      spreadRadius: 0.4,
                                      blurRadius: 4,
                                      offset: Offset(0, 3),
                                    ),
                                  ]),
                              child: FilledButton(
                                onPressed: onPressed,
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.black38),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Icon(
                                        Icons.phone_iphone,
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                        size: 16,
                                      ),
                                    ),
                                    Text(
                                      "短信登录",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.7 *
                                  0.48,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(115, 180, 180, 180),
                                      spreadRadius: 0.4,
                                      blurRadius: 4,
                                      offset: Offset(0, 3),
                                    )
                                  ]),
                              child: FilledButton(
                                onPressed: onPressed,
                                // text with icon
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Icon(
                                        Icons.email,
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                        size: 16,
                                      ),
                                    ),
                                    Text(
                                      "邮箱登录",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 短信/邮箱登录下的分割线
                      const SizedBox(
                        height: 15,
                      ),

                      //没有账号? 点此注册

                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 没有账号
                            const Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                "没有账号?",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black38),
                              ),
                            ),

                            // 点此注册
                            Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isLoginFailed = false;
                                      });
                                      Navigator.pushNamed(
                                          context, '/account/register');
                                    },
                                    child: const Text(
                                      "点此注册",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                              255, 106, 116, 207)),
                                    ))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      //),
    );
  }
}
