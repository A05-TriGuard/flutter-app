/*import 'package:flutter/material.dart';
import '../component/footer/footer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoggedIn = false;

  void login() {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username == "abc" && password == "1234") {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return new footer();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}*/

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /*  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoggedIn = false;

  void login() {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username == "abc" && password == "1234") {
      setState(() {
        isLoggedIn = true;
      });
    }
  } */

  @override
  Widget build(BuildContext context) {
    final bool enabled = true;
    final VoidCallback? onPressed = enabled
        ? () {
            print("object");
          }
        : null;
    return SafeArea(
      child: Scaffold(
        //避免键盘弹出时，出现overFlow现象
        //https://stackoverflow.com/questions/54156420/flutter-bottom-overflowed-by-119-pixels
        resizeToAvoidBottomInset: false,
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/loginBg.jpg"),
              fit: BoxFit.cover,
              opacity: 0.66,
            ),
          ),
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 0),
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

              // 登录框
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
                          //height: 45,
                          //alignment: Alignment.center,
                          child: TextField(
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
                                  EdgeInsets.fromLTRB(0, 10, 15, 10),
                              counterStyle:
                                  const TextStyle(color: Colors.black38),
                              prefixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Image.asset(
                                    "assets/icons/profile.png",
                                    width: 16,
                                    height: 16,
                                  )),
                              prefixIconConstraints:
                                  BoxConstraints(minWidth: 60),
                              labelText: '用户名',
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
                                      color:
                                          Color.fromARGB(179, 145, 145, 145))),
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
                          child: TextField(
                            obscureText: true, //隐藏密码
                            textAlign: TextAlign.left,
                            textAlignVertical: TextAlignVertical.top,
                            //maxLines: 1,
                            cursorColor: Colors.black38,
                            style: const TextStyle(color: Colors.black),

                            decoration: InputDecoration(
                              isCollapsed: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(0, 10, 15, 10),
                              prefixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Image.asset(
                                    "assets/icons/lock.png",
                                    width: 20,
                                    height: 20,
                                  )),
                              prefixIconConstraints:
                                  BoxConstraints(minWidth: 60),
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
                                      color:
                                          Color.fromARGB(179, 145, 145, 145))),
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
                                Navigator.pushNamed(context, '/mainPages');
                                // print("object");
                              },
                              //onPressed: onPressed,
                              child: const Text('登录'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 132, 176),
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),

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
                                      onPressed: onPressed,
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                        color:
                                            Color.fromARGB(115, 180, 180, 180),
                                        spreadRadius: 0.4,
                                        blurRadius: 4,
                                        offset: Offset(-4, 3),
                                      ),
                                    ]),
                                //child: Padding(
                                //  padding:
                                //      const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: FilledButton(
                                  onPressed: onPressed,
                                 
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shadowColor: Colors.black38),
                                   child: const Text(
                                    "短信登录",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Color.fromARGB(255, 119, 119, 119),
                                    ),
                                  ),
                                ),
                                //),
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
                                        color:
                                            Color.fromARGB(115, 180, 180, 180),
                                        spreadRadius: 0.4,
                                        blurRadius: 4,
                                        offset: Offset(4, 3),
                                      )
                                    ]),
                                child: //Padding(
                                    //padding:
                                    // const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    //child:
                                    FilledButton(
                                  onPressed: onPressed,
                                  
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),

                                  child: const Text(
                                    "邮箱登录",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Color.fromARGB(255, 119, 119, 119),
                                    ),
                                  ),
                                ),
                                // ),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: TextButton(
                                      onPressed: onPressed,
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
      ),
    );
  }
}



















/*import 'package:flutter/material.dart';
import '../component/footer/footer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoggedIn = false;

  void login() {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username == "abc" && password == "1234") {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return new footer();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}*/

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /*  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoggedIn = false;

  void login() {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username == "abc" && password == "1234") {
      setState(() {
        isLoggedIn = true;
      });
    }
  } */

  @override
  Widget build(BuildContext context) {
    final bool enabled = true;
    final VoidCallback? onPressed = enabled
        ? () {
            print("object");
          }
        : null;
    return SafeArea(
      child: Scaffold(
        //避免键盘弹出时，出现overFlow现象
        //https://stackoverflow.com/questions/54156420/flutter-bottom-overflowed-by-119-pixels
        resizeToAvoidBottomInset: false,
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/loginBg.jpg"),
              fit: BoxFit.cover,
              opacity: 0.66,
            ),
          ),
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 0),
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

              // 登录框
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
                          //height: 45,
                          //alignment: Alignment.center,
                          child: TextField(
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
                                  EdgeInsets.fromLTRB(0, 10, 15, 10),
                              counterStyle:
                                  const TextStyle(color: Colors.black38),
                              prefixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Image.asset(
                                    "assets/icons/profile.png",
                                    width: 16,
                                    height: 16,
                                  )),
                              prefixIconConstraints:
                                  BoxConstraints(minWidth: 60),
                              labelText: '用户名',
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
                                      color:
                                          Color.fromARGB(179, 145, 145, 145))),
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
                          child: TextField(
                            obscureText: true, //隐藏密码
                            textAlign: TextAlign.left,
                            textAlignVertical: TextAlignVertical.top,
                            //maxLines: 1,
                            cursorColor: Colors.black38,
                            style: const TextStyle(color: Colors.black),

                            decoration: InputDecoration(
                              isCollapsed: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(0, 10, 15, 10),
                              prefixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Image.asset(
                                    "assets/icons/lock.png",
                                    width: 20,
                                    height: 20,
                                  )),
                              prefixIconConstraints:
                                  BoxConstraints(minWidth: 60),
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
                                      color:
                                          Color.fromARGB(179, 145, 145, 145))),
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
                                Navigator.pushNamed(context, '/mainPages');
                                // print("object");
                              },
                              //onPressed: onPressed,
                              child: const Text('登录'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 132, 176),
                                textStyle: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),

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
                                      onPressed: onPressed,
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                        color:
                                            Color.fromARGB(115, 180, 180, 180),
                                        spreadRadius: 0.4,
                                        blurRadius: 4,
                                        offset: Offset(-4, 3),
                                      ),
                                    ]),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: FilledButton(
                                    onPressed: onPressed,
                                    child: const Text(
                                      "短信登录",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shadowColor: Colors.black38),
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
                                        color:
                                            Color.fromARGB(115, 180, 180, 180),
                                        spreadRadius: 0.4,
                                        blurRadius: 4,
                                        offset: Offset(4, 3),
                                      )
                                    ]),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: FilledButton(
                                    onPressed: onPressed,
                                    child: Text(
                                      "邮箱登录",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color:
                                            Color.fromARGB(255, 119, 119, 119),
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: TextButton(
                                      onPressed: onPressed,
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
      ),
    );
  }
}
