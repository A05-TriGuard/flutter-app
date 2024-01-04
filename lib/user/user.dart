import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';

import '../component/header/header.dart';
import '../account/token.dart';

Widget getButtonSet(String iconPath, String text) {
  return Column(
    children: [
      Image.asset(
        iconPath,
        height: 30,
        width: 30,
      ),
      const SizedBox(height: 8),
      Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontFamily: 'BalooBhai',
        ),
      ),
    ],
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
  String username = "未知用户";
  String id = "----";
  String email = "--@qq.com";
  String selectedImagePath = "";
  String latestProfilePic = "";
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
          ? ""
          : "http://43.138.75.58:8080/static/${response.data["data"]["profile"]}";
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
                alignment: Alignment.center,
                child: Row(
                  children: [
                    // 头像，更换头像
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        //头像
                        latestProfilePic == ""
                            ? const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black45,
                                child: CircleAvatar(
                                  radius: 39,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      AssetImage("assets/images/white.jpg"),
                                ))
                            : CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black45,
                                child: CircleAvatar(
                                  radius: 39,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      NetworkImage(latestProfilePic),
                                )),
                        //更换头像
                        GestureDetector(
                          onTap: () async {
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

// 饮食目标 & 问题反馈 & 关于我们
class UserWidget1 extends StatefulWidget {
  const UserWidget1({super.key});

  @override
  State<UserWidget1> createState() => _UserWidget1State();
}

class _UserWidget1State extends State<UserWidget1> {
  void showComplainInfo(BuildContext context) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.black54,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
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
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      //内容
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //问题反馈
                              getText(
                                  '1. 您可以通过以下电子邮件向我们反馈您在使用我们软件的过程中遇到的问题，我们会尽快为您解决。'),
                              getText('beyzhexuan@gmail.com'),
                              getText('mzx21@mails.tsinghua.edu.cn'),
                              getText('limjiawenbrenda221@gmail.com'),
                              getText('linjw21@mails.tsinghua.edu.cn'),
                              getText('2374530749@qq.com'),
                              getText('yuc21@mails.tsinghua.edu.cn'),
                              getText('1914253416@qq.com'),
                              getText('weiky21@mails.tsinghua.edu.cn'),
                              getText('2. 您也可以向我们提出建议，我们会认真考虑并加以改进。'),
                              getText('5. 您的反馈是我们前进的动力，非常感谢您的支持。'),
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

  Widget getTitle(String text) {
    return Text(
      text,
      style:
          const TextStyle(fontWeight: FontWeight.bold, height: 2, fontSize: 17),
    );
  }

  void showAboutUsInfo(BuildContext context) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.black54,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      //内容
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        //height: 175,
                        child: Scrollbar(
                            thickness: 10,
                            scrollbarOrientation: ScrollbarOrientation.right,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //关于我们
                                  getText('我们的开发团队是由四位来自清华大学软件工程专业的学生组成。'),
                                  getTitle("开发团队"),
                                  getText('余超，魏科宇，林嘉纹，马喆轩'),
                                  getTitle("初版开发时间"),
                                  getText('2023年9月—2023年12月'),
                                  getTitle("我们的初衷"),
                                  getText(
                                      '我们希望能够为三高患者提供一个功能较为全面的健康助手软件，帮助用户更好地监测自己的健康情况，结合运动和饮食管理缓解病情。\n'),
                                  getText(
                                      '由于这是我们首次开发软件，若有任何让您感到不满意之处，敬请见谅，同时也感谢您对于我们的支持。我们会持续改进，为您提供更好的用户体验。'),
                                ],
                              ),
                            )),
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
        width: MediaQuery.of(context).size.width * 0.9,
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
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/user/nutritiontarget');
                },
                child: getButtonSet("assets/icons/healthy-food.png", "饮食目标"),
              ),
              GestureDetector(
                onTap: () {
                  showComplainInfo(context);
                },
                child: getButtonSet("assets/icons/complain.png", "问题反馈"),
              ),
              GestureDetector(
                onTap: () {
                  showAboutUsInfo(context);
                },
                child: getButtonSet("assets/icons/about.png", "关于我们"),
              ),
              GestureDetector(
                onTap: () async {
                  await storage.write(key: "accountId", value: "-1");
                  await storage.write(key: "username", value: "");
                  await storage.write(key: "password", value: "");
                  await storage.write(key: "isLogout", value: "1");
                  //Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
                child: getButtonSet("assets/icons/logout.png", "退出登录"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TriGuardReminder extends StatelessWidget {
  const TriGuardReminder({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.85,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Text(
              "一定要照顾好自己，\n坚持良好的生活习惯，\n爱护自己，健康路上您不孤单。",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  height: 2,
                  color: Colors.black,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 10),
            const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "—— TriGuard 团队",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                )),
            const SizedBox(height: 10),
            Image.asset(
              "assets/images/best-friends.png",
              width: screenWidth * 0.52,
            )
          ],
        ),
      ),
    );
  }
}

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  bool returnLogin = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          //退出app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: getAppBar(0, false, "TriGuard"),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: ListView(shrinkWrap: true, children: [
              // 标题组件
              UnconstrainedBox(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
        ),
      ),
    );
  }
}
