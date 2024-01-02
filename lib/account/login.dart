import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import './token.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 获取用户输入的资料与密码
  final TextEditingController usernameController =
      TextEditingController(text: "");
  final TextEditingController passwordController =
      TextEditingController(text: "");
  int accountId = -1;
  bool isLoggedIn = false;
  bool isLoginFailed = false;
  String loginStateHintText = "";
  OverlayEntry? overlayEntry;

  // 获取用户id
  Future<void> getAccountId() async {
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/account/info",
      );
      if (response.data["code"] == 200) {
        accountId = response.data["data"]["id"];
        await storage.write(key: "accountId", value: accountId.toString());
        String? checkId = await storage.read(key: 'accountId');
        print('checkId: $checkId');
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }
  }

  // 登录函数
  Future<void> login() async {
    // 获取用户输入的用户名与密码
    final username = usernameController.text;
    final password = passwordController.text;

    // 判断用户名与密码是否为空
    if (!(username.isEmpty || password.isEmpty)) {
      // 显示加载动画
      loginLoadingTypeOverlay(context);

      const String loginApi = 'http://43.138.75.58:8080/api/auth/login';
      print("登录请求中 $username $password");
      try {
        final Dio dio = Dio();
        Response response = await dio.post(loginApi, queryParameters: {
          'username': username,
          'password': password,
        });
        // 登录成功后，移除加载动画
        overlayEntry?.remove();

        print(response.data);

        if (response.data['code'] == 200) {
          print("登录成功");

          setState(() {
            isLoginFailed = false;
          });

          // 保存token
          await storage.write(
              key: "token", value: response.data["data"]["token"]);
          await getAccountId().then((value) => Navigator.pushNamed(
              context, '/mainPages',
              arguments: {"accountId": -1}));
        }
        // 登录失败
        else if (response.data['code'] == 403) {
          isLoginFailed = true;
          print(response.data["message"]);
          // 显示登录失败提示信息
          setState(() {
            loginStateHintText = response.data["message"];
          });
        }
        // 用户或密码不正确
        else if (response.data['code'] == 401) {
          isLoginFailed = true;
          print(response.data["message"]);
          // 显示登录失败提示信息
          setState(() {
            loginStateHintText = "用户或密码不正确";
          });
        }
      } on DioException catch (error) {
        overlayEntry?.remove();
        final response = error.response;
        if (response != null) {
          print(response.data);
          print("登录请求失败1");
        } else {
          print(error.requestOptions);
          print(error.message);
          print("登录请求失败2");
        }
      }
    }
    // 用户名或密码为空
    else {
      setState(() {
        isLoginFailed = true;
        loginStateHintText = "用户名或密码不能为空";
      });
    }
  }

  // 登录加载动画
  void loginLoadingTypeOverlay(BuildContext context) async {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.pink, size: 25),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry!);
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
        //避免键盘弹出时，出现overFlow现象
        //https://stackoverflow.com/questions/54156420/flutter-bottom-overflowed-by-119-pixels
        resizeToAvoidBottomInset: false,
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
            children: [
              // TriGuard白透明背景标题
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15, bottom: 0),
                child: Stack(
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
                        )),
                    const Text(
                      "TriGuard",
                      style: TextStyle(
                          fontFamily: 'BalooBhai',
                          fontSize: 36,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),

              // 登录组件
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 用户名输入框
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
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
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 10, 15, 10),
                            counterStyle:
                                const TextStyle(color: Colors.black38),
                            prefixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Image.asset(
                                  "assets/icons/profile.png",
                                  width: 16,
                                  height: 16,
                                )),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 60),
                            labelText: '用户名/邮箱',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(96, 104, 104, 104),
                            ),
                            fillColor: const Color.fromARGB(187, 250, 250, 250),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(179, 145, 145, 145),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      //密码框
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true, //隐藏密码
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.top,
                          cursorColor: Colors.black38,
                          style: const TextStyle(color: Colors.black),

                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 10, 15, 10),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                              child: Image.asset(
                                "assets/icons/lock.png",
                                width: 20,
                                height: 20,
                              ),
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 60),
                            labelText: '密码',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(96, 104, 104, 104),
                            ),
                            fillColor: const Color.fromARGB(187, 250, 250, 250),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(179, 145, 145, 145),
                              ),
                            ),
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
                            onPressed: () async {
                              // 等待登录
                              await login();
                            },
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
                                  child: Text(
                                    loginStateHintText,
                                    style: const TextStyle(
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

                      const SizedBox(
                        height: 10,
                      ),

                      //忘记密码/点此注册
                      SizedBox(
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
                                onPressed: () {
                                  setState(() {
                                    isLoginFailed = false;
                                  });
                                  // 跳转到重置密码页面
                                  Navigator.pushNamed(
                                      context, '/resetPassword');
                                },
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.black38),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Image.asset(
                                        "assets/icons/resetPassword2.png",
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                    const Text(
                                      "忘记密码",
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
                            // 点此注册
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
                                onPressed: () {
                                  setState(() {
                                    isLoginFailed = false;
                                  });
                                  // 跳转到注册账号页面
                                  Navigator.pushNamed(
                                      context, '/account/register');
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Image.asset(
                                        "assets/icons/register2.png",
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                    const Text(
                                      "点此注册",
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

                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
