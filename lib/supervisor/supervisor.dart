import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:filter_list/filter_list.dart';

import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';
import '../account/token.dart';

typedef UpdateVisibleInvitationWidgetCallback = void Function(bool visible);
typedef UpdateVisibleCreateGroupWidgetCallback = void Function(bool visible);
typedef UpdateViewCallback = void Function(int id);
PageController pageController = PageController(initialPage: 0);

// 监护/关爱模式是什么的说明文字
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

// ====================监护模式===============================

// 监护页面
// ignore: must_be_immutable
class GuardianWidget extends StatefulWidget {
  bool visibleCreateGroupWidget;
  final UpdateVisibleCreateGroupWidgetCallback
      updateVisibleCreateGroupWidgetCallback;
  GuardianWidget({
    Key? key,
    required this.visibleCreateGroupWidget,
    required this.updateVisibleCreateGroupWidgetCallback,
  }) : super(key: key);

  @override
  State<GuardianWidget> createState() => _GuardianWidgetState();
}

class _GuardianWidgetState extends State<GuardianWidget> {
  TextEditingController usernameController = TextEditingController();
  int inviteStatus = 0;
  List<dynamic> wardList = [];
  List<dynamic> groupList = [];
  List<Widget> wardedListWidget = [];
  bool refreshData = true;

  // 什么是监护模式?
  void showInfo(BuildContext context) {
    OverlayEntry? overlayEntry;

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
                        "什么是监护模式？",
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getText(
                                  '1. 当你接受邀请成为监护人之后，你就有权限看到监护对象的所记录的所有数据，也有劝修改它们。'),
                              getText('2. 你也可以直接用你的账号直接帮监护对象记录数据，数据是同步的。'),
                              getText('3. 你也可以看到监护对象的记录活动，也可以导出监护对象的数据等等。'),
                              getText('4. 你也可以组建群组来方便查看成员的活动与数据，支持编辑昵称，删除成员等。'),
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

  // 获取监护对象列表
  Future<void> getWardedListFromServer() async {
    // 判断是否在监护模式页面
    if (pageController.offset != 0) {
      return;
    }
    // 判断是否需要刷新
    if (!refreshData) return;

    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/ward/list",
      );
      if (response.data["code"] == 200) {
        groupList = response.data["data"]["groupList"];
        wardList = response.data["data"]["wardList"];
      } else {
        wardList = [];
        groupList = [];
      }
    } catch (e) {
      wardList = [];
      groupList = [];
    }

    await getWardedListWidget();
  }

  // 个人的组件
  Widget getGuardianPersonWidget(int wardId, String name, String image) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0,
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0),
      child: GestureDetector(
        onTap: () {
          var result =
              wardList.where((element) => element["accountId"] == wardId);
          if (result.isNotEmpty) {
            var arguments = {
              "accountId": wardId,
              "email": result.first["email"],
              "username": result.first["username"],
              "nickname": result.first["nickname"],
              "image": image,
            };
            Navigator.pushNamed(context, '/supervisor/person',
                    arguments: arguments)
                .then((value) => setState(() {}));
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(minHeight: 50),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(
                color: Color.fromRGBO(0, 0, 0, 0.2),
              ),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // 个人头像
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(image),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: const Color.fromARGB(74, 104, 103, 103),
                                width: 1,
                              ),
                            ),
                          ),
                          // 群组名
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 30,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.55,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '  $name',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "BalooBhai",
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 跳转
                      IconButton(
                        icon: Image.asset("assets/icons/right-arrow.png",
                            width: 15, height: 15),
                        onPressed: () {
                          var result = wardList.where(
                              (element) => element["accountId"] == wardId);

                          var arguments = {
                            "accountId": wardId,
                            "nickname": result.first["nickname"],
                            "username": result.first["username"],
                            "email": result.first["email"],
                            "image":
                                "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png",
                          };
                          Navigator.pushNamed(context, '/supervisor/person',
                                  arguments: arguments)
                              .then((value) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                  // 修改昵称
                ],
              )),
        ),
      ),
    );
  }

  // 群组的组件
  Widget getGuardianGroupWidget(int wardId, String name, String image) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0,
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0),
      child: GestureDetector(
        onTap: () {
          var args = {"groupId": wardId, "groupName": name};
          Navigator.pushNamed(context, '/supervisor/group', arguments: args)
              .then((value) => setState(() {}));
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(minHeight: 50),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(
                color: Color.fromARGB(255, 143, 216, 250),
              ),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 群组头像 + 群组名
                      Row(
                        children: [
                          // 群组头像
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: AssetImage("assets/icons/group2.png"),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: const Color.fromARGB(74, 104, 103, 103),
                                width: 1,
                              ),
                            ),
                          ),
                          // 群组名
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 30,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.55,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '  $name',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "BalooBhai",
                              ),
                            ),
                          ),
                        ],
                      ),
                      //跳转按钮
                      IconButton(
                        icon: Image.asset("assets/icons/right-arrow.png",
                            width: 15, height: 15),
                        onPressed: () {
                          var args = {"groupId": wardId, "groupName": name};
                          Navigator.pushNamed(context, '/supervisor/group',
                                  arguments: args)
                              .then((value) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                  // 修改昵称
                ],
              )),
        ),
      ),
    );
  }

  // 群组+个人的展示列表
  Future<void> getWardedListWidget() async {
    wardedListWidget = [];
    for (int i = 0; i < wardList.length; i++) {
      String imageUrl =
          "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png";
      if (wardList[i]["image"] != null) {
        imageUrl = "http://43.138.75.58:8080/static/";
        imageUrl += wardList[i]["image"];
      }
      wardedListWidget.add(getGuardianPersonWidget(
          wardList[i]["accountId"], wardList[i]["nickname"], imageUrl));
    }

    for (int i = 0; i < groupList.length; i++) {
      String imageUrl =
          "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png";

      wardedListWidget.add(getGuardianGroupWidget(
          groupList[i]["groupId"], groupList[i]["groupName"], imageUrl));
    }
  }

  // 新建群组
  Widget getInviteGuardianWidget() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 200,
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
              //标题
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 40,
                    alignment: Alignment.center,
                    child: const Text(
                      "邀请监护人",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "BalooBhai",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 关闭
                  Container(
                    width: 30,
                    height: 40,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        widget.updateVisibleCreateGroupWidgetCallback(false);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/icons/cancel.png",
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 5,
              ),

              // 输入邮箱
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "邮箱: ",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "BalooBhai",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: TextFormField(
                      controller: usernameController,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Colors.black38,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      decoration: InputDecoration(
                        //取消奇怪的高度
                        isCollapsed: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(10, 10, 15, 10),
                        counterStyle: const TextStyle(color: Colors.black38),

                        labelText: '邮箱',
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
                ],
              ),

              // 邀请失败提示
              inviteStatus > 0
                  ? Center(
                      child: Text(
                        inviteStatus == 1 ? "发送邀请成功" : "邀请失败，邮箱不存在或已被邀请过",
                        style: TextStyle(
                          color: inviteStatus == 1
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    )
                  : const SizedBox(),

              // 取消，确定
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.updateVisibleCreateGroupWidgetCallback(false);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 118, 246, 255)),
                    ),
                    child: const Text('取消'),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 在这里添加Overlay上按钮的操作
                      //overlayEntry?.remove();
                      inviteStatus++;
                      inviteStatus %= 3;
                      setState(() {});
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getWardedListFromServer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(children: [
              ListView(shrinkWrap: true, children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      20,
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "监护模式",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: "BalooBhai",
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          showInfo(context);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Image.asset("assets/icons/question.png",
                              width: 20, height: 30),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // “监护人”
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width * 0.15 * 0.5,
                          0,
                          0,
                          0),
                      child: const PageTitle(
                        title: "监护对象",
                        icons: "assets/icons/audience.png",
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Container(
                  constraints: BoxConstraints(
                    minHeight: 50,
                    maxHeight: MediaQuery.of(context).size.height * 0.62,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: wardedListWidget,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ]),
            ]);
          } else {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      20,
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "监护模式",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: "BalooBhai",
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Image.asset("assets/icons/question.png",
                              width: 20, height: 30),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      0,
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      0),
                  child: const PageTitle(
                    title: "监护对象",
                    icons: "assets/icons/audience.png",
                    fontSize: 18,
                  ),
                ),
                Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.pink, size: 25),
                )
              ],
            );
          }
        });
  }
}

// ====================关爱模式============================

// 被监护页面
// ignore: must_be_immutable
class UnderGuardianshipWidget extends StatefulWidget {
  bool visibleInviteGuardianWidget;
  final UpdateVisibleInvitationWidgetCallback
      updateVisibleInvitationWidgetCallback;
  UnderGuardianshipWidget(
      {Key? key,
      required this.visibleInviteGuardianWidget,
      required this.updateVisibleInvitationWidgetCallback})
      : super(key: key);

  @override
  State<UnderGuardianshipWidget> createState() =>
      _UnderGuardianshipWidgetState();
}

class _UnderGuardianshipWidgetState extends State<UnderGuardianshipWidget> {
  bool editNickname = false;
  final TextEditingController nicknameController = TextEditingController();
  int inviteStatus = 0;
  List<dynamic> guardianList = [];
  Map<int, bool> isExpanded = <int, bool>{};
  bool refreshData = true;

  // 展开收缩更新
  void updateView(int id) {
    setState(() {
      editNickname = false;
      bool? isExpand = isExpanded[id];
      isExpanded.forEach((key, value) {
        isExpanded[key] = false;
      });
      if (isExpand == true) {
        isExpanded[id] = false;
      } else {
        isExpanded[id] = true;
      }
    });
  }

  void update() {
    setState(() {});
  }

  // 什么是关爱模式
  void showInfo(BuildContext context) {
    OverlayEntry? overlayEntry;

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
                        "什么是关爱模式？",
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getText(
                                  '1. 点击右上角的+号，你可以通过邮箱来向你的想添加的监护人发起邀请。当对方收到邀请后，有权拒绝或接受。'),
                              getText(
                                  '2. 当对方接受之后，他就能直接用他的账号直接查看你的血压，血糖，血脂，运动，饮食记录数据，你们的数据是同步的。但是你的监护人无法看到你收藏的文章，动态等等。'),
                              getText(
                                  '3. 如果邀请错人，而对方也接受了，没关系，你可以删除他，之后他就无法看到你的数据记录了。'),
                              getText('4. 你可以编辑编辑监护人的备注。'),
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

  // 获取监护人列表
  Future<void> getGuardianListFromServer() async {
    // 判断是否在监护模式页面
    if (pageController.page! != 1.0) {
      return;
    }
    // 判断是否需要刷新
    if (refreshData == false || editNickname == true) {
      return;
    }
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guardian/list",
      );
      if (response.data["code"] == 200) {
        guardianList = response.data["data"];
      } else {
        guardianList = [];
      }
    } catch (e) {
      guardianList = [];
    }
  }

  // 修改昵称
  Future<void> setGuardianNickname(int accountId, String nickname) async {
    final Dio dio = Dio();

    try {
      var token = await storage.read(key: 'token');
      dio.options.headers["Authorization"] = "Bearer $token";
      Response response = await dio.post(
        'http://43.138.75.58:8080/api/guardian/set-nickname',
        queryParameters: {
          "guardianId": accountId,
          "nickname": nickname,
        },
      );

      if (response.data['code'] == 200) {
        return;
      } else {
        return;
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        return;
      } else {
        return;
      }
    }
  }

  // 删除监护人
  Future<void> deleteGuardian(int accountId) async {
    var token = await storage.read(key: 'token');
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guardian/delete?guardianId=$accountId",
      );
      if (response.data["code"] == 200) {
        return;
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }

  // 每一个监护人的widget
  Widget getGuardianWidget(int count, int accountId, String image,
      String username, String nickname, String email) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0,
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0),
      child: GestureDetector(
        onTap: () {
          refreshData = false;
          updateView(accountId);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width * 0.85,
          height: isExpanded[accountId] == true ? 110 : 50,
          constraints: const BoxConstraints(
            minHeight: 50,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(
                color: Color.fromRGBO(0, 0, 0, 0.2),
              ),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: isExpanded[accountId] == true
                ?
                //展开式
                SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 昵称与编辑昵称
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 30,
                            ),
                            child: editNickname == false
                                // 不编辑时
                                ? Row(
                                    children: [
                                      Row(children: [
                                        // 头像
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: NetworkImage(image),
                                              fit: BoxFit.cover,
                                            ),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  74, 104, 103, 103),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        // “昵称：”
                                        Container(
                                          constraints: const BoxConstraints(
                                            minHeight: 30,
                                          ),
                                          //  color: Colors.yellow,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            " 昵称：",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontFamily: 'BalooBhai',
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ]),
                                      // 昵称
                                      Container(
                                        constraints: BoxConstraints(
                                          minHeight: 30,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.50,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          nickname,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: "BalooBhai",
                                          ),
                                        ),
                                      ),

                                      // 编辑昵称按钮
                                      GestureDetector(
                                        onTap: () {
                                          editNickname = !editNickname;
                                          isExpanded[accountId] = true;

                                          refreshData = false;
                                          setState(() {});
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.bottomCenter,
                                          child: const Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                // 编辑时
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // 编辑昵称
                                      Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(image),
                                                fit: BoxFit.cover,
                                              ),
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                    74, 104, 103, 103),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                            height: 30,
                                            child: TextFormField(
                                              controller: nicknameController,
                                              decoration: InputDecoration(
                                                isCollapsed: true,
                                                border:
                                                    const UnderlineInputBorder(),
                                                hintText: nickname,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // 确认与取消编辑昵称按钮
                                      Row(
                                        children: [
                                          // 取消
                                          GestureDetector(
                                            onTap: () {
                                              // 不用刷新
                                              refreshData = false;
                                              setState(() {
                                                editNickname = !editNickname;
                                                nicknameController.text = "";
                                              });
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.bottomCenter,
                                              child: Image.asset(
                                                  "assets/icons/cancel.png",
                                                  width: 20,
                                                  height: 20),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          //确认
                                          GestureDetector(
                                            onTap: () async {
                                              //print(
                                              //    "编辑监护人昵称 $accountId ${nicknameController.text}");
                                              if (nicknameController
                                                  .text.isEmpty) {
                                                return;
                                              }
                                              // 需要刷新
                                              refreshData = true;
                                              await setGuardianNickname(
                                                  accountId,
                                                  nicknameController.text);
                                              setState(() {
                                                editNickname = false;
                                                nicknameController.text = "";
                                              });
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.bottomCenter,
                                              child: Image.asset(
                                                  "assets/icons/confirm.png",
                                                  width: 24,
                                                  height: 24),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        // 用户名
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 30,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "   用户名：",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: 'BalooBhai',
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 30,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  child: Text(
                                    username,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: "BalooBhai",
                                    ),
                                  ),
                                ),
                              ]),
                        ),

                        // 邮箱与删除
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 0, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // “邮箱”
                              Container(
                                constraints: const BoxConstraints(
                                  minHeight: 30,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "   邮箱：",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'BalooBhai',
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // 邮箱
                              Container(
                                constraints: const BoxConstraints(
                                  minHeight: 30,
                                ),
                                alignment: Alignment.centerLeft,
                                width: MediaQuery.of(context).size.width * 0.50,
                                child: Text(
                                  email,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "BalooBhai",
                                  ),
                                ),
                              ),
                              //删除
                              GestureDetector(
                                onTap: () async {
                                  await deleteGuardian(accountId);
                                  refreshData = true;
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.bottomCenter,
                                  child: Image.asset("assets/icons/delete2.png",
                                      width: 25, height: 25),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                // 不展开时
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 头像(图片)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: const Color.fromARGB(74, 104, 103, 103),
                            width: 1,
                          ),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        height: 30,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "  $nickname",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "BalooBhai",
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // 获取监护人列表
  List<Widget> getAllGuardianWidget() {
    List<Widget> allGuardianWidget = [];

    for (int i = 0; i < guardianList.length; i++) {
      String imageUrl =
          "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png";
      if (guardianList[i]["image"] != null) {
        imageUrl = "http://43.138.75.58:8080/static/";
        imageUrl += guardianList[i]["image"];
      }

      allGuardianWidget.add(getGuardianWidget(
          i,
          guardianList[i]["accountId"],
          imageUrl,
          guardianList[i]["username"],
          guardianList[i]["nickname"],
          guardianList[i]["email"]));
      // 如果是展开着的就保持展开
      if (isExpanded[guardianList[i]["accountId"]] != null) {
        continue;
      }
      // 如果是新加的就默认不展开
      isExpanded[guardianList[i]["accountId"]] = false;
    }

    return allGuardianWidget;
  }

  Widget getAllGuardianListWidget() {
    return Column(
      children: [
        ListView(shrinkWrap: true, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.15 * 0.5,
                20,
                MediaQuery.of(context).size.width * 0.15 * 0.5,
                0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "关爱模式"标题
                const Text(
                  "关爱模式",
                  style: TextStyle(
                      fontSize: 22,
                      fontFamily: "BalooBhai",
                      fontWeight: FontWeight.bold),
                ),
                //
                const SizedBox(
                  width: 5,
                ),
                // 关爱模式是什么
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Image.asset("assets/icons/question.png",
                        width: 20, height: 30),
                  ),
                ),
              ],
            ),
          ),

          // “监护人” 与 添加监护人
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // “监护人”
              Padding(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.15 * 0.5, 0, 0, 0),
                child: const PageTitle(
                  title: "监护人",
                  icons: "assets/icons/audience.png",
                  fontSize: 18,
                ),
              ),
              // 添加监护人
            ],
          ),

          Column(
            children: getAllGuardianWidget(),
          ),

          const SizedBox(
            height: 30,
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 在点击编辑昵称的文字框时候，不刷新数据
    if (editNickname == true || refreshData == false) {
      return Column(
        children: [
          ListView(shrinkWrap: true, children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.15 * 0.5,
                  20,
                  MediaQuery.of(context).size.width * 0.15 * 0.5,
                  0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "关爱模式"标题
                  const Text(
                    "关爱模式",
                    style: TextStyle(
                        fontSize: 22,
                        fontFamily: "BalooBhai",
                        fontWeight: FontWeight.bold),
                  ),
                  //
                  const SizedBox(
                    width: 5,
                  ),
                  // 关爱模式是什么
                  GestureDetector(
                    onTap: () {
                      showInfo(context);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Image.asset("assets/icons/question.png",
                          width: 20, height: 30),
                    ),
                  ),
                ],
              ),
            ),

            // “监护人” 与 添加监护人
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // “监护人”
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.15 * 0.5, 0, 0, 0),
                  child: const PageTitle(
                    title: "监护人",
                    icons: "assets/icons/audience.png",
                    fontSize: 18,
                  ),
                ),
                // 添加监护人
              ],
            ),

            Container(
              constraints: BoxConstraints(
                minHeight: 50,
                maxHeight: MediaQuery.of(context).size.height * 0.62,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: getAllGuardianWidget(),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),
          ]),
        ],
      );
    }

    return FutureBuilder(
        future: getGuardianListFromServer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                ListView(shrinkWrap: true, children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * 0.15 * 0.5,
                        20,
                        MediaQuery.of(context).size.width * 0.15 * 0.5,
                        0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // "关爱模式"标题
                        const Text(
                          "关爱模式",
                          style: TextStyle(
                              fontSize: 22,
                              fontFamily: "BalooBhai",
                              fontWeight: FontWeight.bold),
                        ),
                        //
                        const SizedBox(
                          width: 5,
                        ),
                        // 关爱模式是什么
                        GestureDetector(
                          onTap: () {
                            showInfo(context);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Image.asset("assets/icons/question.png",
                                width: 20, height: 30),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // “监护人”
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // “监护人”
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.15 * 0.5,
                            0,
                            0,
                            0),
                        child: const PageTitle(
                          title: "监护人",
                          icons: "assets/icons/audience.png",
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: getAllGuardianWidget(),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                ]),
              ],
            );
          }
          // 加载时
          else {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      20,
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "关爱模式",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: "BalooBhai",
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Image.asset("assets/icons/question.png",
                              width: 20, height: 30),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      0,
                      MediaQuery.of(context).size.width * 0.15 * 0.5,
                      0),
                  child: const PageTitle(
                    title: "监护人",
                    icons: "assets/icons/audience.png",
                    fontSize: 18,
                  ),
                ),
                Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.pink, size: 25),
                )
              ],
            );
          }
        });
  }
}

// ===================================================
// 此页面 监护

class WardSelection {
  final String? nickname;
  final String? wardId;
  WardSelection({this.nickname, this.wardId});
}

class Supervisor extends StatefulWidget {
  const Supervisor({super.key});

  @override
  State<Supervisor> createState() => _SupervisorState();
}

class _SupervisorState extends State<Supervisor> {
  // 第0页为监护模式，第1页为关爱模式
  int inviteStatus = 0; // 0: 未邀请，1：邀请成功，2：邀请失败
  OverlayEntry? overlayEntry;
  bool visibleInviteGuardianWidget = false;
  bool visibleCreateGroupWidget = false;
  List<bool> ccount = [false, false, false, false, false];
  List<dynamic> invitationList = [];
  bool shouldLoadData = true;
  List<String> wardList = ["admin1", "admin2"]; // TODO 删除
  List<String> selectedWardList = []; // TODO 删除
  List<WardSelection> wardSelectionList = [];
  List<WardSelection> selectedWardSelectionList = [];
  TextEditingController groupNameController = TextEditingController();

  // ^^^^^^^^^^^^^^^^^其他函数^^^^^^^^^^^^^^^^^
  @override
  void initState() {
    super.initState();
    pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void updateView() {
    setState(() {});
  }

  // +++++++++++++++++++++后端API++++++++++++++++++++++

  // 邀请监护人
  Future<bool> inviteGuardian(String email) async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/guardian/invite",
        queryParameters: {
          "email": email,
        },
      );

      if (response.data['code'] == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        return false;
      } else {
        return false;
      }
    }
  }

  // 获取邀请消息
  Future<void> getInvitationNotification() async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/ward/invitation/list",
      );
      if (response.data["code"] == 200) {
        invitationList = response.data["data"];
      } else {
        invitationList = [];
      }
    } catch (e) {
      invitationList = [];
    }
    return;
  }

  // 接受/拒绝成为监护人
  Future<bool> acceptRejectGuardianRequest(
    int invitationId,
    bool isAccept,
  ) async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/ward/invitation/accept",
        queryParameters: {
          "invitationId": invitationId,
          "isAccepted": isAccept ? "true" : "false",
        },
      );

      if (response.data['code'] == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        return false;
      } else {
        return false;
      }
    }
  }

  // 获取（个人）列表供选择成员进行组建群组
  Future<void> getWardListFromServer() async {
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    List<dynamic> list;

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/ward/list",
      );
      if (response.data["code"] == 200) {
        list = response.data["data"]["wardList"];
      } else {
        list = [];
      }
    } catch (e) {
      list = [];
    }

    wardList.clear();
    wardSelectionList.clear();

    for (int i = 0; i < list.length; i++) {
      wardList.add(list[i]["nickname"]);
      wardSelectionList.add(WardSelection(
          nickname: list[i]["nickname"],
          wardId: (list[i]["accountId"]).toString()));
    }
  }

  // 创建群组
  Future<bool> createWardGroup() async {
    //
    String wardIds = "";
    for (int i = 0; i < selectedWardSelectionList.length; i++) {
      wardIds += selectedWardSelectionList[i].wardId!;
      if (i != selectedWardSelectionList.length - 1) {
        wardIds += ",";
      }
    }

    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/guard-group/create",
        queryParameters: {
          "groupName": groupNameController.text,
          "wardIds": wardIds,
        },
      );

      if (response.data['code'] == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        return false;
      } else {
        return false;
      }
    }
  }

  // ~~~~~~~~~~~~~~~~~~弹窗~~~~~~~~~~~~~~

  // 邀请监护人弹窗
  void updateVisibleInvitationWidget(bool isVisible) {
    setState(() {
      visibleInviteGuardianWidget = isVisible;
    });
  }

  // 邀请监护人
  void showInviteGuardianWidget(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: GestureDetector(
              onTap: () {},
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200,
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
                        //标题
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 40,
                              alignment: Alignment.center,
                              child: const Text(
                                "邀请监护人",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "BalooBhai",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 关闭
                            Container(
                              width: 30,
                              height: 40,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  inviteStatus = 0;
                                  overlayEntry?.remove();
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.asset("assets/icons/cancel.png",
                                      width: 25, height: 25),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        // 输入邮箱
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "邮箱: ",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "BalooBhai",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: TextFormField(
                                controller: emailController,
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
                                      const EdgeInsets.fromLTRB(10, 10, 15, 10),
                                  counterStyle:
                                      const TextStyle(color: Colors.black38),

                                  labelText: '邮箱',
                                  labelStyle: const TextStyle(
                                    color: Color.fromARGB(96, 104, 104, 104),
                                  ),
                                  fillColor:
                                      const Color.fromARGB(187, 250, 250, 250),
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
                          ],
                        ),

                        // 邀请失败提示
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            inviteStatus > 0
                                ? Center(
                                    child: Text(
                                      inviteStatus == 1
                                          ? "发送邀请成功"
                                          : "邀请失败，邮箱不存在或已被邀请过",
                                      style: TextStyle(
                                        color: inviteStatus == 1
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),

                        // 取消，确定
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                inviteStatus = 0;

                                overlayEntry?.remove();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 118, 246, 255)),
                              ),
                              child: const Text('取消'),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                // 在这里添加Overlay上按钮的操作
                                bool status =
                                    await inviteGuardian(emailController.text);
                                status == true
                                    ? inviteStatus = 1
                                    : inviteStatus = 2;
                                setState(() {});
                                overlayEntry?.markNeedsBuild();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.greenAccent),
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
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  // 邀请消息通知栏
  void invitationNotification(BuildContext context) async {
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
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
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
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //标题 与 关闭
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 40,
                            alignment: Alignment.center,
                            child: const Text(
                              "邀请消息",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "BalooBhai",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // 关闭
                          Container(
                            width: 30,
                            height: 40,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {});
                                overlayEntry?.remove();
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Image.asset("assets/icons/cancel.png",
                                    width: 25, height: 25),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 300,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(children: [
                            // 通知
                            getAllNotification(),
                          ]),
                        ),
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
    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry!);
  }

  // 创建群组弹窗
  void createGroup(bool isVisible) {
    setState(() {
      visibleCreateGroupWidget = isVisible;
    });
  }

  // 1. 选择要添加的成员
  void openFilterDialog() async {
    selectedWardList.clear();
    selectedWardSelectionList.clear();

    await FilterListDialog.display<WardSelection>(
      context,
      listData: wardSelectionList,
      selectedListData: selectedWardSelectionList,
      choiceChipLabel: (user) => user!.nickname,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (user, query) {
        return user.nickname!.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        selectedWardSelectionList = List.from(list!);

        groupNameController.text = "";

        setState(() {});
        // 先pop再显示 填写群组名

        // 必须至少一个成员才能创建群组
        if (selectedWardSelectionList.isNotEmpty) {
          selectGroupNameWidget(context);
        }
      },
      height: MediaQuery.of(context).size.height * 0.7,
      headlineText: "创建群组，选择成员",
      applyButtonText: "确认",
      resetButtonText: "重置",
      allButtonText: "全选",
      selectedItemsText: "人被选择",
    );
  }

  // 2. 填写群组名
  void selectGroupNameWidget(BuildContext context) {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: GestureDetector(
              onTap: () {},
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200,
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
                        //标题
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 40,
                              alignment: Alignment.center,
                              child: const Text(
                                "填写群组名",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "BalooBhai",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 关闭
                            Container(
                              width: 30,
                              height: 40,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  inviteStatus = 0;
                                  overlayEntry?.remove();
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.asset("assets/icons/cancel.png",
                                      width: 25, height: 25),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        // 输入群名
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "群名: ",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "BalooBhai",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: TextFormField(
                                controller: groupNameController,
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
                                      const EdgeInsets.fromLTRB(10, 10, 15, 10),
                                  counterStyle:
                                      const TextStyle(color: Colors.black38),

                                  labelText: '群名',
                                  labelStyle: const TextStyle(
                                    color: Color.fromARGB(96, 104, 104, 104),
                                  ),
                                  fillColor:
                                      const Color.fromARGB(187, 250, 250, 250),
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
                          ],
                        ),

                        // 邀请失败提示
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            inviteStatus > 0
                                ? Center(
                                    child: Text(
                                      inviteStatus == 1
                                          ? "发送邀请成功"
                                          : "邀请失败，邮箱不存在或已被邀请过",
                                      style: TextStyle(
                                        color: inviteStatus == 1
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),

                        // 取消，确定
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //取消
                            ElevatedButton(
                              onPressed: () {
                                inviteStatus = 0;

                                overlayEntry?.remove();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 118, 246, 255)),
                              ),
                              child: const Text('取消'),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            //确定
                            ElevatedButton(
                              onPressed: () async {
                                await createWardGroup();
                                setState(() {});
                                overlayEntry?.remove();
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                                //overlayEntry?.markNeedsBuild();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.greenAccent),
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
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  // -----------------组件----------------------

  // 获取所有通知
  Widget getAllNotification() {
    return FutureBuilder(
      future: getInvitationNotification(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<Widget> notificationList = [];
          for (int i = 0; i < invitationList.length; i++) {
            notificationList.add(showNotification(
              invitationList[i]["invitationId"],
              invitationList[i]["wardId"],
              invitationList[i]["wardName"],
              invitationList[i]["invitationTime"],
            ));
          }

          if (invitationList.isEmpty) {
            notificationList.add(
              const Text(
                "暂无消息",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "BalooBhai",
                ),
              ),
            );
          }

          return Column(
            children: notificationList,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // 每一个通知
  Widget showNotification(
      int invitationId, int guardianId, String username, String date) {
    // 从后端获取数据
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(
            minHeight: 50,
          ),
          child: Text(
            "$date $username 邀请你成为成为监护人.",
            style: const TextStyle(
              fontSize: 18,
              fontFamily: "BalooBhai",
            ),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          GestureDetector(
            onTap: () async {
              bool status =
                  await acceptRejectGuardianRequest(invitationId, false);
              if (status) {
                overlayEntry?.markNeedsBuild();
              }
            },
            child: Container(
              width: 60,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 251, 111, 101),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "拒绝",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () async {
              bool status =
                  await acceptRejectGuardianRequest(invitationId, true);
              if (status) {
                overlayEntry?.markNeedsBuild();
              }
            },
            child: Container(
              width: 60,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 74, 255, 80),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "接受",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ]),
        const SizedBox(
          height: 5,
        ),
        const Divider(
          height: 1,
          color: Color.fromRGBO(169, 171, 179, 1), // 设置分割线的颜色
        ),
      ],
    );
  }

  // ————————————————————此页面——————————————————————
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBar(
          0,
          false,
          "TriGuard",
          actions: [
            Builder(
              builder: (context) {
                if (pageController.page == null || pageController.page! < 0.5) {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          await getWardListFromServer();
                          openFilterDialog();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () async {
                          invitationNotification(context);
                        },
                      )
                    ],
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showInviteGuardianWidget(context);
                    },
                  );
                }
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        body: Stack(alignment: Alignment.bottomCenter, children: [
          PageView(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              // 监护模式
              Container(
                constraints: const BoxConstraints.expand(),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/2278.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.66,
                  ),
                ),
                child: GuardianWidget(
                  visibleCreateGroupWidget: visibleCreateGroupWidget,
                  updateVisibleCreateGroupWidgetCallback: createGroup,
                ),
              ),
              // 关爱模式
              Container(
                constraints: const BoxConstraints.expand(),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/5234772.jpg"),
                    fit: BoxFit.cover,
                    opacity: 0.86,
                  ),
                ),
                child: UnderGuardianshipWidget(
                  visibleInviteGuardianWidget: visibleInviteGuardianWidget,
                  updateVisibleInvitationWidgetCallback:
                      updateVisibleInvitationWidget,
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
