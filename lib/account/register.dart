import 'package:flutter/material.dart';

const List<String> method = <String>['手机号', '邮箱'];

class RegisterDropdownButton extends StatefulWidget {
  //const RegisterDropdownButton({super.key, required this.onChanged});

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

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  String methodLabelText = "手机号";
  String methodIconPath = "assets/icons/smartphone.png";
  String methodPrexifText = "+86";

  final TextEditingController userController = TextEditingController();
  final TextEditingController validCodeController = TextEditingController();
  bool isSignedUp = false;

  void signUp() {
    final user = userController.text;
    final validCode = validCodeController.text;

    // 校验
    if (user == "1111" && validCode == "1111") {
      setState(() {
        isSignedUp = true;
      });

      //Navigator.pushNamed(context, '/mainPages', arguments: {"id": 1});
      //弹出注册成功的对话框
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Container(
              child: const Row(
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
      print("signup ok");
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
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
            content: const Text("注册失败，您可能已经注册过了！"),

            // 尝试登录按钮
            actions: <Widget>[
              TextButton(
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
              ),
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
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = true;
    final VoidCallback? onPressed = enabled
        ? () {
            print("获取验证码");
          }
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TriGuard",
          style: TextStyle(
              fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/loginBg.jpg"),
            fit: BoxFit.cover,
            opacity: 0.66,
          ),
        ),
        alignment: Alignment.center,
        child: Column(children: [
          // 间距
          SizedBox(height: MediaQuery.of(context).size.width * 0.3),

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
          SizedBox(height: MediaQuery.of(context).size.width * 0.05),

          //下拉菜单 选择 “手机号”或“邮箱”
          Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(187, 250, 250, 250),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.2))),
            width: MediaQuery.of(context).size.width * 0.75,
            height: 45,
            child: RegisterDropdownButton(
              onChanged: (String? newValue) {
                setState(() {
                  //dropdownValue = newValue!;
                  if (newValue == "手机号") {
                    methodLabelText = "手机号";
                    methodIconPath = "assets/icons/smartphone.png";
                    methodPrexifText = "+86";
                  } else if (newValue == "邮箱") {
                    methodLabelText = "邮箱";
                    methodIconPath = "assets/icons/email.png";
                    methodPrexifText = "";
                  }
                });
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.width * 0.05),

          // 手机号输入
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

          SizedBox(height: MediaQuery.of(context).size.width * 0.05),

          // 验证码
          Stack(alignment: Alignment.centerRight, children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: TextField(
                controller: validCodeController,
                maxLines: 1,
                maxLength: 4,
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
                  onPressed: onPressed,
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

          SizedBox(height: MediaQuery.of(context).size.width * 0.05),

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
                onPressed: () {
                  signUp();
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
