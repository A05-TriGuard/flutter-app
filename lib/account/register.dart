import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../component/header/header.dart';

const List<String> method = <String>['手机号', '邮箱'];

// 注册下拉菜单
class RegisterDropdownButton extends StatefulWidget {
  const RegisterDropdownButton({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  final Function(String?) onChanged;
  @override
  State<RegisterDropdownButton> createState() => _RegisterDropdownButtonState();
}

class _RegisterDropdownButtonState extends State<RegisterDropdownButton> {
  String dropdownValue = method.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,

            style: const TextStyle(color: Color.fromARGB(255, 56, 56, 56)),
            //修改宽度，与高度，然后要圆角
            borderRadius: BorderRadius.circular(25),
            isExpanded: true,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            underline: Container(
              height: 0,
              //color: Colors.deepPurpleAccent,
              color: Colors.transparent,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
                widget.onChanged(dropdownValue);
              });
            },
            items: method.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// 注册状态对话框
class RegisterStateDialog extends StatefulWidget {
  final String content;
  const RegisterStateDialog({Key? key, required this.content})
      : super(key: key);

  @override
  State<RegisterStateDialog> createState() => _RegisterStateDialogState();
}

class _RegisterStateDialogState extends State<RegisterStateDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Container(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "注册失败",
              style: TextStyle(
                  fontSize: 25,
                  //文字阴影
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(0.0, 1),
                      blurRadius: 5.0,
                      color: Color.fromARGB(100, 0, 0, 0),
                    ),
                  ]),
            ),
            Icon(
              Icons.cancel,
              color: Colors.red,
              size: 30,
            ),
          ],
        ),
      ),
      //content: const Text("注册失败，您可能已经注册过了！或者验证码不正确！"),
      content: Text(widget.content),

      // 尝试登录按钮
      actions: <Widget>[
        /* TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                  // 导航到登录页面
                  Navigator.pushNamed(context, '/');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 211, 211, 211),
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                /* style: FilledButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 211, 211, 211),
                  textStyle: const TextStyle(),
                ), */
                child: Container(
                  width: 90,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "尝试登录",
                        style: TextStyle(color: Colors.black),
                      ),
                      Icon(Icons.login, color: Colors.black),
                    ],
                  ),
                ),
              ), */
        // 再试一次按钮
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
            // 导航到登录页面
            //Navigator.pushNamed(context, '/');
          },
          style: FilledButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 211, 211, 211),
            textStyle: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          child: Container(
            width: 90,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "再试一次",
                  style: TextStyle(color: Colors.black),
                ),
                Icon(Icons.subdirectory_arrow_left, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 注册页面
class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController validCodeController = TextEditingController();
  String methodLabelText = "邮箱";
  String methodIconPath = "assets/icons/email.png";
  String methodPrexifText = "";
  String validCodeSentHintText = "验证码已经发送";
  bool isSignedUp = false;
  int sentValidCodeState = 0;
  Dio dio = Dio();

  // 成功注册对话框
  void showSuccessSignUpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "注册成功",
                style: TextStyle(
                    fontSize: 25,
                    //文字阴影
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(0.0, 1),
                        blurRadius: 5.0,
                        color: Color.fromARGB(100, 0, 0, 0),
                      ),
                    ]),
              ),
              Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 30,
              ),
            ],
          ),
          content: const Text("欢迎使用TriGuard！让我们一切打造幸福健康的生活吧！"),

          // 立即登录按钮
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
                // 导航到登录页面
                Navigator.pushNamed(context, '/');
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 211, 211, 211),
                textStyle: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              child: const SizedBox(
                width: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "立即登录",
                      style: TextStyle(color: Colors.black),
                    ),
                    Icon(Icons.login, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 注册失败对话框
  void showFailSignUpDialog(String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RegisterStateDialog(
          content: content,
        );
      },
    );
  }

  // 注册函数
  Future<void> signUp() async {
    // 获取用户所输入的内容
    final user = userController.text;
    final validCode = validCodeController.text;
    final username = usernameController.text;
    final password = passwordController.text;

    // 校验：手机号/邮箱，用户名，密码，验证码其中一者不能为空
    if (user.isEmpty ||
        validCode.isEmpty ||
        username.isEmpty ||
        password.isEmpty) {
      showFailSignUpDialog("邮箱，用户名，密码，验证码其中一者不能为空！");
      return;
    }

    print(
        'user: $user, validCode: $validCode, username: $username, password: $password');

    // 向后端发起注册请求（邮箱）
    const String emailRegisterApi =
        'http://43.138.75.58:8080/api/auth/email-register';

    // 成功发送请求
    try {
      Response response = await dio.post(emailRegisterApi, data: {
        'email': user,
        'username': username,
        'password': password,
        'code': validCode,
      });
      print(response.data);

      if (response.data["code"] == 200) {
        print("注册成功");
        showSuccessSignUpDialog();
      } else {
        showFailSignUpDialog("注册失败！${response.data["message"]}");
      }
    }
    // 失败：请求参数有误（长度过短，邮箱格式错误）
    on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        print(response.data);
        showFailSignUpDialog("注册失败！你可能已经注册过，或者验证码不正确，用户名密码格式不正确！");
      } else {
        print(error.requestOptions);
        print(error.message);
        showFailSignUpDialog("注册失败！");
      }
    }
  }

  // 请求验证码
  Future<void> getValidCode() async {
    final String email = userController.text;
    final String emailGetValidCodeApi =
        "http://43.138.75.58:8080/api/auth/email-code?email=${email}&type=register";

    Response response;
    response = await dio.get(emailGetValidCodeApi);
    print(response.data.toString());

    if (response.data["code"] == 200) {
      print("获取验证码成功");
      validCodeSentHintText = "验证码已经发送";
      sentValidCodeState = 1;
    } else {
      print("获取验证码失败");
      validCodeSentHintText = response.data["message"];

      if (response.data["message"] ==
          "askVerifyCode.email: must be a well-formed email address") {
        validCodeSentHintText = "邮箱格式错误！";
      }

      if (response.data["message"] == "请求参数有误") {
        validCodeSentHintText = "邮箱格式错误！";
      }
      sentValidCodeState = -1;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(0, true, "TriGuard"),
      resizeToAvoidBottomInset: false,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/loginBg1.png"),
            fit: BoxFit.cover,
            opacity: 0.66,
          ),
        ),
        alignment: Alignment.center,
        child: Column(children: [
          // 顶部间距
          SizedBox(height: MediaQuery.of(context).size.width * 0.15),

          //账号注册 标题
          Container(
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width * 0.75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "账号注册",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Blinker',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 3, 0, 0),
                  child: Image.asset(
                    "assets/icons/signup.png",
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 邮箱输入
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TextField(
              controller: userController,
              maxLines: 1,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Colors.black38,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                //取消奇怪的高度
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 15, 10),
                counterStyle: const TextStyle(color: Colors.black38),
                prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Image.asset(
                      methodIconPath,
                      width: 20,
                      height: 20,
                    )),
                prefixText: methodPrexifText,
                prefixStyle: const TextStyle(
                  color: Colors.black38,
                  fontSize: 16,
                  //fontFamily: 'Blinker',
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 60),
                labelText: methodLabelText,
                labelStyle: const TextStyle(
                  color: Color.fromARGB(96, 104, 104, 104),
                ),
                fillColor: const Color.fromARGB(187, 250, 250, 250),
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide:
                      const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(179, 145, 145, 145))),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 用户名输入
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TextField(
              controller: usernameController,
              maxLines: 1,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Colors.black38,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                //取消奇怪的高度
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 15, 10),
                counterStyle: const TextStyle(color: Colors.black38),
                prefixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Image.asset(
                    "assets/icons/profile.png",
                    width: 20,
                    height: 20,
                  ),
                ),
                prefixStyle: const TextStyle(
                  color: Colors.black38,
                  fontSize: 16,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 60),
                labelText: "用户名",
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

          // 用户名提示
          const Text("谨慎填写，用户名不可再修改!", style: TextStyle(color: Colors.red)),
          const SizedBox(height: 10),

          // 密码输入
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TextField(
              controller: passwordController,
              maxLines: 1,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Colors.black38,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                //取消奇怪的高度
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 15, 10),
                counterStyle: const TextStyle(color: Colors.black38),
                prefixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Image.asset(
                    "assets/icons/lock.png",
                    width: 20,
                    height: 20,
                  ),
                ),
                prefixStyle: const TextStyle(
                  color: Colors.black38,
                  fontSize: 16,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 60),
                labelText: "密码(至少6位)",
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

          const SizedBox(height: 20),

          // 验证码
          Stack(alignment: Alignment.centerRight, children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: TextField(
                controller: validCodeController,
                maxLines: 1,
                maxLength: 6,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Colors.black38,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  //取消奇怪的高度
                  isCollapsed: true,
                  counterText: "", // 隐藏“0/4”最大长度
                  contentPadding: const EdgeInsets.fromLTRB(0, 10, 15, 10),
                  counterStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Image.asset("assets/icons/otp.png",
                          width: 22, height: 22)),
                  prefixIconConstraints: const BoxConstraints(minWidth: 60),
                  labelText: '验证码',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(96, 104, 104, 104),
                  ),
                  fillColor: const Color.fromARGB(187, 250, 250, 250),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide:
                        const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(179, 145, 145, 145))),
                ),
              ),
            ),
            // 获取验证码按钮

            Container(
              height: 25,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: FilledButton(
                  onPressed: () async {
                    await getValidCode();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(219, 219, 219, 1),
                    textStyle: const TextStyle(
                      fontSize: 12.0,
                      fontFamily: 'Blinker',
                    ),
                  ),
                  child: const Text(
                    "获取验证码",
                    style: TextStyle(color: Color.fromARGB(167, 0, 0, 0)),
                  ),
                ),
              ),
            ),
          ]),

          // 已经发送验证码的提示
          sentValidCodeState != 0
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: MediaQuery.of(context).size.width * 0.05,
                  alignment: Alignment.topRight,
                  child: Text(
                    validCodeSentHintText,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.red,
                      fontFamily: "BalooBhai",
                    ),
                  ),
                )
              : SizedBox(height: MediaQuery.of(context).size.width * 0.05),

          //注册按钮
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
              width: MediaQuery.of(context).size.width * 0.75,
              child: FilledButton(
                onPressed: () async {
                  await signUp();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 132, 176),
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                child: const Text('注册'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
