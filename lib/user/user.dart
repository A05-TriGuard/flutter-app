import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';

import '../component/header/header.dart';
import '../account/token.dart';

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
        const SizedBox(height: 5),
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

Widget getText(String content) {
  return Column(
    children: [
      Text(
        content,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: "BalooBhai",
        ),
      ),
      const SizedBox(
        height: 8,
      ),
    ],
  );
}

Future<void> logout(BuildContext context) async {
  //Navigator.pop(context);
  //Navigator.pushNamed(context, '/');
  //Navigator.pushReplacement(context, routes['/']!);
  //Navigator.pushReplacementNamed(context
  //Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  //Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  //Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  //Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
}

// 头像，昵称，ID
class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String username = "admin";
  String id = "12345678900";
  String email = "admin@qq.com";
  String selectedImagePath = "";
  String latestProfilePic =
      "https://png.pngtree.com/png-vector/20220705/ourmid/pngtree-loading-icon-vector-transparent-png-image_5687537.png";
  XFile? pickedImage;

  Future<void> getUserInfo() async {
    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    response = await dio.get("http://43.138.75.58:8080/api/account/info");
    if (response.data["code"] == 200) {
      username = response.data["data"]["username"];
      id = (response.data["data"]["id"]).toString();
      email = response.data["data"]["email"];
      latestProfilePic = response.data["data"]["profile"] == null
          ? "https://static.vecteezy.com/system/resources/previews/020/765/399/non_2x/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg"
          : "http://43.138.75.58:8080/static/${response.data["data"]["profile"]}";
      //print("username: $username id: $id email: $email ");
    } else {
      print("获取用户信息失败");
    }
  }

  // Moment API
  Future<void> changeProfilePic() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map['profile'] = await MultipartFile.fromFile(pickedImage!.path);

      FormData formData = FormData.fromMap(map);

      final response = await dio.post(
        'http://43.138.75.58:8080/api/account/set-profile',
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (count, total) {
          print("当前进度 $count, 总进度 $total");
        },
      );

      if (response.statusCode == 200) {
        setState(() {});
      }
    } catch (e) {/**/}
  }

  @override
  Widget build(BuildContext context) {
    //getUserInfo();
    return FutureBuilder(
        future: getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
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
                        CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.black45,
                            child: CircleAvatar(
                              radius: 39,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(latestProfilePic),
                            )),
                        //更换头像
                        GestureDetector(
                          onTap: () async {
                            print("更换头像");
                            pickedImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setState(() {
                                selectedImagePath = pickedImage!.path;
                              });
                              changeProfilePic();
                            }
                          },
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: const BoxDecoration(
                              //borderRadius: BorderRadius.circular(15),
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 59, 59, 59),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
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
                            username,
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontFamily: 'BalooBhai',
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // ID
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            "ID: $id",
                            style: const TextStyle(
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
          } else {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            );
          }
        });
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  print("饮食目标");
                  Navigator.pushNamed(context, '/user/nutritiontarget');
                },
                child: getButtonSet("assets/icons/foodTarget.png", "饮食目标"),
              ),
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  print("我的资料");
                },
                child: getButtonSet("assets/icons/user.png", "我的资料"),
              ),
              /* GestureDetector(
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
              ), */
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
  void showComplainInfo(BuildContext context) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            //olor: Color.fromRGBO(255, 255, 255, 0.8),
            //color: Colors.white,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                //height: 300,
                height: MediaQuery.of(context).size.height * 0.6,
                // color: Colors.white,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 标题
                      const Text(
                        "问题反馈",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      //内容
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        //height: 175,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //问题反馈
                              getText('1. 你可以通过以下的电子邮件反馈你在使用过程中遇到的问题，我们会尽快解决。'),
                              getText('2. 你也可以在这里提出你的建议，我们会尽快改进。'),
                              getText('3. beyzhexuan@gmail.com'),
                              getText('4. mzx21@mails.tsinghua.edu.cn'),
                              getText('5. 你的反馈是我们前进的动力，感谢你的支持。'),
                            ],
                          ),
                        ),
                      ),

                      // 取消，确定
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              overlayEntry?.remove();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.greenAccent),
                            ),
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  void showAboutUsInfo(BuildContext context) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            //olor: Color.fromRGBO(255, 255, 255, 0.8),
            //color: Colors.white,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                //height: 300,
                height: MediaQuery.of(context).size.height * 0.6,
                // color: Colors.white,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 标题
                      const Text(
                        "关于我们",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      //内容
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        //height: 175,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //关于我们
                              getText('我们的开发团队是由四位来自清华大学软件工程专业的学生组成。'),
                              getText('开发团队成员：余超，魏科宇，林嘉纹，马喆轩'),
                              getText(
                                  '开发目的：为了帮助三高患者更好地管理自己的病情，并且通过运动或饮食来改善病情，甚至拜托病情，因此我们开发了这款APP。'),
                              getText('开发时间：2023年9月-2023年12月'),
                              getText(
                                  '由于首次开发APP，若有任何让您感到不满意之处，敬请原谅，同时也感谢您对于我们的支持。'),
                            ],
                          ),
                        ),
                      ),

                      // 取消，确定
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              overlayEntry?.remove();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.greenAccent),
                            ),
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

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
                /* Row(
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
                */
                /* const SizedBox(
                  height: 10,
                ),
                */ /* Row(
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
            */
                /* const SizedBox(
                  height: 10,
                ), */
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    /* GestureDetector(
                      onTap: () {
                        print("我的资料");
                      },
                      child: getButtonSet("assets/icons/user.png", "帮助中心"),
                    ), */
                    GestureDetector(
                      onTap: () {
                        showComplainInfo(context);
                      },
                      child: getButtonSet("assets/icons/complain.png", "问题反馈"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("我的资料");
                        showAboutUsInfo(context);
                      },
                      child: getButtonSet("assets/icons/about.png", "关于我们"),
                    ),
                    GestureDetector(
                      onTap: () async {
                        print("我的资料");
                        await storage.write(key: "accountId", value: "-1");
                        //Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
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
    return
        // PopScope(
        //   canPop: returnLogin,
        //   onPopInvoked: (bool didPop) {
        //     if (didPop) {
        //       return;
        //     }
        //     print("确定退出？");
        //     _showBackDialog();
        //     // TODO: 弹出确认退出的对话框
        //   },
        //   child:
        Scaffold(
      /* appBar: AppBar(
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
                            fontSize: 18,
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
        ), */
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
      appBar: getAppBar(0, false, "TriGuard"),
      body: Container(
        color: Colors.white,
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: ListView(shrinkWrap: true, children: [
          // 标题组件
          UnconstrainedBox(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  SizedBox(
                    height: 20,
                  ),
                  UserInfo(),
                  SizedBox(
                    height: 25,
                  ),
                  UserWidget1(),
                  SizedBox(
                    height: 25,
                  ),
                  UserWidget2(),
                  SizedBox(
                    height: 25,
                  ),
                  TriGuardReminder(),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ),
          // 过滤器
        ]),
      ),
      //),
    );
  }
}
