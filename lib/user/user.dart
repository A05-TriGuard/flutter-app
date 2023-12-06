import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../component/header/header.dart';
import '../router/router.dart';

Widget getButtonSet(String IconPath, String text) {
  return Container(
    //height: 100,
    //width: 100,
    //color: Colors.yellow,
    child: Column(
      children: [
        Image.asset(
          //"assets/icons/supervisor.png",
          IconPath,
          height: 30,
          width: 30,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontFamily: 'BalooBhai',
          ),
        ),
      ],
    ),
  );
}

// 头像，昵称，ID
class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        //color: Colors.yellow,
        alignment: Alignment.center,
        child: Row(
          children: [
            // 头像，更换头像
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                //头像
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    //borderRadius: BorderRadius.circular(15),
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage("assets/images/loginBg1.png"),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Color.fromARGB(74, 104, 103, 103),
                      width: 1,
                    ),
                  ),
                ),
                //更换头像
                GestureDetector(
                  onTap: () {
                    print("更换头像");
                  },
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      //borderRadius: BorderRadius.circular(15),
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 59, 59, 59),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              width: 15,
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 昵称
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    "测试用户1",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontFamily: 'BalooBhai',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // ID
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    "ID: 123456789",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: 'BalooBhai',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 我的资料，监护人，目标，积分
class UserWidget1 extends StatefulWidget {
  const UserWidget1({super.key});

  @override
  State<UserWidget1> createState() => _UserWidget1State();
}

class _UserWidget1State extends State<UserWidget1> {
  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.2),
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              offset: Offset(0, 5),
              blurRadius: 5.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        //color: Colors.yellow,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  print("我的资料");
                },
                child: getButtonSet("assets/icons/user.png", "我的资料"),
              ),
              GestureDetector(
                onTap: () {
                  print("我的资料");
                },
                child: getButtonSet("assets/icons/user.png", "我的资料"),
              ),
              GestureDetector(
                onTap: () {
                  print("我的资料");
                },
                child: getButtonSet("assets/icons/user.png", "我的资料"),
              ),
              GestureDetector(
                onTap: () {
                  print("我的资料");
                },
                child: getButtonSet("assets/icons/user.png", "我的资料"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 我的资料，监护人，目标，积分
class UserWidget2 extends StatefulWidget {
  const UserWidget2({super.key});

  @override
  State<UserWidget2> createState() => _UserWidget2State();
}

class _UserWidget2State extends State<UserWidget2> {
  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.2),
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              offset: Offset(0, 5),
              blurRadius: 5.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        //color: Colors.yellow,
        alignment: Alignment.center,
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "我的资料"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                        Navigator.pop(context);
                      },
                      child: getButtonSet("assets/icons/logout.png", "退出登录"),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}

class TriGuardReminder extends StatelessWidget {
  const TriGuardReminder({super.key});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
        child: Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                offset: Offset(0, 5),
                blurRadius: 5.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          //color: Colors.yellow,
          alignment: Alignment.center,
          child: const Padding(
            padding: const EdgeInsets.all(15),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Text(
                  "一定要照顾好自己，不要让我担心，你的身体比什么都重要。",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: 'BalooBhai',
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 15, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "——TriGuard团队",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'BalooBhai',
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Image.asset("assets/icons/emoji-nice.png", height: 18, width: 18),
            ],
          ),
        ),
      ],
    ));
  }
}

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  bool returnLogin = false;

  void _showBackDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Are you sure you want to leave this page?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Nevermind'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Leave'),
              onPressed: () {
                Navigator.pop(context);
                //Navigator.pop(context);
                SystemNavigator.pop();
                //exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: returnLogin,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        print("确定退出？");
        _showBackDialog();
        // TODO: 弹出确认退出的对话框
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "我的",
            style: TextStyle(
                fontFamily: 'BalooBhai',
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
          // flexibleSpace: header,
          // toolbarHeight: 45,
          flexibleSpace: getHeader(MediaQuery.of(context).size.width,
              (MediaQuery.of(context).size.height * 0.1 + 11)),
          automaticallyImplyLeading: false,

          actions: [
            GestureDetector(
              onTap: () {
                print("设置");
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: const Row(
                  children: [
                    Text("设置",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontFamily: 'BalooBhai',
                            fontWeight: FontWeight.bold)),
                    Icon(
                      Icons.settings,
                      size: 30,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        /*
          // ==================== 别删 =============================
         body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("用户"),
              //退出登录的按钮
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    returnLogin = true;
                  });
                  Navigator.pop(context);
                  //Navigator.pushNamed(context, '/');
                  //Navigator.pushReplacement(context, routes['/']!);
                },
                child: Text("退出登录"),
              ),
            ],
          ),
        ), */

        body: Container(
          color: Colors.white,
          child: ListView(shrinkWrap: true, children: [
            // 标题组件
            UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    const SizedBox(
                      height: 10,
                    ),
                    UserInfo(),
                    const SizedBox(
                      height: 25,
                    ),
                    UserWidget1(),
                    const SizedBox(
                      height: 25,
                    ),
                    const UserWidget2(),
                    SizedBox(
                      height: 25,
                    ),
                    TriGuardReminder(),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
            // 过滤器
          ]),
        ),
      ),
    );
  }
}
