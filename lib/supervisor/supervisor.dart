import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';
import './guardianPerson.dart';
import './guardianGroup.dart';
import '../account/token.dart';

//import 'package:flutter_echarts/flutter_echarts.dart';
typedef UpdateVisibleInvitationWidgetCallback = void Function(bool visible);
typedef UpdateVisibleCreateGroupWidgetCallback = void Function(bool visible);
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
  List<bool> isExpandedList = List.generate(17, (index) => false);
  TextEditingController usernameController = TextEditingController();
  int inviteStatus = 0;

  void updateView(int id) {
    setState(() {
      isExpandedList[id] = !isExpandedList[id];
      for (int i = 0; i < isExpandedList.length; i++) {
        if (i != id) {
          isExpandedList[i] = false;
        }
      }
    });
  }

  // 什么是监护模式?
  void showInfo(BuildContext context) {
    OverlayEntry? overlayEntry;
    TextEditingController usernameController = TextEditingController();

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
                height: 300,
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

                      //标题
                      const SizedBox(
                        height: 175,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            '''当你接受邀请成为监护人之后，你就有权限看到监护对象的所记录的所有数据。你也可以直接用你的账号直接帮监护对象记录数据，数据是同步的。此外，你也可以看到监护对象的记录活动，也可以导出监护对象的数据等等。 你也可以组建群组来方便查看成员的数据，支持编辑昵称，删除成员等。''',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "BalooBhai",
                            ),
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

  Widget getGuardianPersonWidget(int id) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0,
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0),
      child: GestureDetector(
        onTap: () {
          print(id);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => GuardianPersonPage()));
          //updateView(id);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 50,
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
                      Text(
                        "${id}.   妈妈",
                        style: TextStyle(fontSize: 18, fontFamily: "BalooBhai"),
                      ),
                      //删除
                      IconButton(
                        icon: Image.asset("assets/icons/right-arrow.png",
                            width: 15, height: 15),
                        onPressed: () {
                          //print("删除监护人");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GuardianPersonPage()));
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

  Widget getGuardianPersonWidget2(int id) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0,
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0),
      child: GestureDetector(
        onTap: () {
          print(id);
          updateView(id);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width * 0.85,
          height: isExpandedList[id] ? 100 : 40,
          decoration: BoxDecoration(
            border: const Border(
              bottom: BorderSide(
                color: Color.fromRGBO(0, 0, 0, 0.2),
              ),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: isExpandedList[id]
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${id}.   妈妈",
                            style: TextStyle(
                                fontSize: 18, fontFamily: "BalooBhai"),
                          ),
                          //删除
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              print("删除监护人");
                            },
                          ),
                        ],
                      ),
                      // 修改昵称
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "昵称",
                            style: TextStyle(
                                fontSize: 18, fontFamily: "BalooBhai"),
                          ),
                          //删除
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              print("修改昵称");
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${id}.   妈妈",
                        style: TextStyle(fontSize: 18, fontFamily: "BalooBhai"),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget getGuardianGroupWidget(int id) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0,
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0),
      child: GestureDetector(
        onTap: () {
          print(id);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => GuardianGroupPage()));
          //updateView(id);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 50,
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
                      Text(
                        "${id}.   群组1",
                        style: TextStyle(fontSize: 18, fontFamily: "BalooBhai"),
                      ),
                      //删除
                      IconButton(
                        icon: Image.asset("assets/icons/right-arrow.png",
                            width: 15, height: 15),
                        onPressed: () {
                          //print("删除监护人");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GuardianGroupPage()));
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

  Widget getInviteGuardianWidget() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 200,
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
              //标题
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 40,
                    alignment: Alignment.center,
                    //color: Colors.green,
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
                    //color: Colors.blueAccent,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        //widget.onClose();
                        /* setState(() {
                          widget.visibleInviteGuardianWidget = false;
                        }); */
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
                        //fillColor: Color.fromARGB(190, 255, 255, 255),
                        fillColor: const Color.fromARGB(187, 250, 250, 250),
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
                    child: Text('取消'),
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
                    child: Text('确定'),
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
    return Stack(
        //alignment: Alignment.center,

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
                //crossAxisAlignment: CrossAxisAlignment.center,
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
                      print("监护模式是什么？");
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

            /*  Padding(
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
            ), */

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // “监护人”
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.15 * 0.5, 0, 0, 0),
                  child: const PageTitle(
                    title: "监护对象",
                    icons: "assets/icons/audience.png",
                    fontSize: 18,
                  ),
                ),
                // 添加监护人
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, 0, MediaQuery.of(context).size.width * 0.15 * 0.6, 0),
                  child: GestureDetector(
                    onTap: () {
                      print("添加监护人");
                      /* setState(() {
                      widget.visibleInviteGuardianWidget = true;
                    }); */
                      if (widget.visibleCreateGroupWidget == false) {
                        widget.updateVisibleCreateGroupWidgetCallback(true);
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        "assets/icons/add.png",
                        width: 20,
                        height: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // add

            getGuardianGroupWidget(1),
            for (int i = 2; i <= 6; i++) getGuardianPersonWidget(i),

            const SizedBox(
              height: 30,
            ),
          ]),
          widget.visibleCreateGroupWidget == true
              ? getInviteGuardianWidget()
              : const SizedBox(),
        ]);
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
  List<bool> isExpandedList = List.generate(17, (index) => false);

  bool editNickname = false;
  TextEditingController usernameController = TextEditingController();
  int inviteStatus = 0;
  List<dynamic> guardianList = [];

  // 获取监护人列表
  Future<void> getGuardianListFromServer() async {
    // 提取登录获取的token
    var token = await storage.read(key: 'token');
    //print(value);

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guardian/list",
      );
      if (response.data["code"] == 200) {
        // print("获取监护人列表成功");
        guardianList = response.data["data"];
      } else {
        print(response);
        guardianList = [];
      }
    } catch (e) {
      print(e);
      guardianList = [];
    }

    print("监护人：$guardianList");
  }

  void updateView(int id) {
    setState(() {
      editNickname = false;
      isExpandedList[id] = !isExpandedList[id];
      for (int i = 0; i < isExpandedList.length; i++) {
        if (i != id) {
          isExpandedList[i] = false;
        }
      }
    });
  }

  Widget getGuardianWidget(int count, int accountId, String username,
      String nickname, String email) {
    TextEditingController nicknameController =
        TextEditingController(text: nickname.isEmpty ? username : nickname);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0,
          MediaQuery.of(context).size.width * 0.15 * 0.5,
          0),
      child: GestureDetector(
        onTap: () {
          print(accountId);
          updateView(accountId);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width * 0.85,
          height: isExpandedList[count] ? 110 : 50,
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
            child: isExpandedList[count]
                //展开式
                ? SingleChildScrollView(
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
                            //color: Colors.greenAccent,
                            child: editNickname == false
                                // 不编辑时
                                ? Row(
                                    children: [
                                      Container(
                                        constraints: const BoxConstraints(
                                          minHeight: 30,
                                        ),
                                        //  color: Colors.yellow,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "$count.  昵称：",
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontFamily: 'BalooBhai',
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                          minHeight: 30,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.55,
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
                                      GestureDetector(
                                        onTap: () {
                                          print("编辑监护人昵称");
                                          editNickname = !editNickname;
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
                                          Text(
                                            "${count}. ",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily: "BalooBhai"),
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
                                                border: UnderlineInputBorder(),
                                                hintText: '$nickname',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      /* const SizedBox(
                                      width: 5,
                                    ), */
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              print("编辑监护人昵称");
                                              setState(() {
                                                nicknameController.text =
                                                    nickname;
                                                editNickname = !editNickname;
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
                                          GestureDetector(
                                            onTap: () {
                                              print("编辑监护人昵称");
                                              setState(() {
                                                nickname =
                                                    nicknameController.text;
                                                print("新昵称：$nickname");
                                                editNickname = !editNickname;
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
                                  //  color: Colors.yellow,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "用户名：",
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
                                  // color: Colors.blueAccent,
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  child: Text(
                                    "$username",
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
                              Container(
                                constraints: const BoxConstraints(
                                  minHeight: 30,
                                ),
                                //color: Colors.yellow,
                                alignment: Alignment.center,
                                child: const Text(
                                  "邮箱：",
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
                                //color: Colors.yellowAccent,
                                width: MediaQuery.of(context).size.width * 0.55,
                                child: Text(
                                  "$email",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "BalooBhai",
                                  ),
                                ),
                              ),
                              //删除
                              GestureDetector(
                                onTap: () {
                                  print("删除监护人");
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          //minHeight: 30,
                          maxWidth: MediaQuery.of(context).size.width * 0.80,
                        ),
                        height: 30,
                        child: Text(
                          "$count.   $nickname",
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "BalooBhai",
                            //fontWeight: FontWeight.bold,
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

  Widget getInviteGuardianWidget() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 200,
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
              //标题
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 40,
                    alignment: Alignment.center,
                    //color: Colors.green,
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
                    //color: Colors.blueAccent,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        //widget.onClose();
                        /* setState(() {
                          widget.visibleInviteGuardianWidget = false;
                        }); */
                        widget.updateVisibleInvitationWidgetCallback(false);
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
                        //fillColor: Color.fromARGB(190, 255, 255, 255),
                        fillColor: const Color.fromARGB(187, 250, 250, 250),
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
                      widget.updateVisibleInvitationWidgetCallback(false);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 118, 246, 255)),
                    ),
                    child: Text('取消'),
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
                    child: Text('确定'),
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
    //print("重建？");
    //getGuardianListFromServer();
    return FutureBuilder(
        // Replace getDataFromServer with the Future you want to wait for
        future: getGuardianListFromServer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
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
                      //crossAxisAlignment: CrossAxisAlignment.center,
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
                          onTap: () {
                            print("监护模式是什么？");
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
                  /* Padding(
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
          ), */
                  // “监护人” 与 添加监护人
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
                      // 添加监护人
                      /*  Padding(
                padding: EdgeInsets.fromLTRB(
                    0, 0, MediaQuery.of(context).size.width * 0.15 * 0.5, 0),
                child: GestureDetector(
                  onTap: () {
                    print("添加监护人");
                    /* setState(() {
                      widget.visibleInviteGuardianWidget = true;
                    }); */
                    if (widget.visibleInviteGuardianWidget == false) {
                      widget.updateVisibleInvitationWidgetCallback(true);
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      "assets/icons/add.png",
                      width: 20,
                      height: 30,
                    ),
                  ),
                ),
              ),
             */
                    ],
                  ),

                  // add
                  //for (int i = 1; i <= 16; i++)
                  // getGuardianWidget(i, i, "beyzhexuan@gmail.com", "妈妈"),
                  getGuardianWidget(
                      1, 1, "admin", "妈妈", "beyzhexuan@gmail.com"),
                  getGuardianWidget(
                      2, 2, "hellowdd", "爸爸", "bedsfjkduan@gmail.com"),
                  getGuardianWidget(
                      3, 3, "shadjkasd", "usertest", "edw@qq.com"),
                  getGuardianWidget(4, 4, "af325fsd", "admin", "wdi@dfkasd.cn"),

                  const SizedBox(
                    height: 30,
                  ),
                ]),
                widget.visibleInviteGuardianWidget == true
                    ? getInviteGuardianWidget()
                    : const SizedBox(),
              ],
            );
          } else {
            //return const Center(child: CircularProgressIndicator());
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
                    //crossAxisAlignment: CrossAxisAlignment.center,
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
                        onTap: () {
                          print("监护模式是什么？");
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

// -----------------------邀请监护人--------------------------
class InviteGuardian extends StatefulWidget {
  const InviteGuardian({Key? key}) : super(key: key);

  @override
  State<InviteGuardian> createState() => _InviteGuardianState();
}

class _InviteGuardianState extends State<InviteGuardian> {
  TextEditingController usernameController = TextEditingController();
  int inviteStatus = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            //olor: Color.fromRGBO(255, 255, 255, 0.8),
            //color: Colors.white,
            child: GestureDetector(
              onTap: () {
                // 点击Overlay时移除它
                //overlayEntry?.remove();
              },
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200,
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
                        //标题
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 40,
                              alignment: Alignment.center,
                              //color: Colors.green,
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
                              //color: Colors.blueAccent,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  //widget.onClose();
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
                                      const EdgeInsets.fromLTRB(10, 10, 15, 10),
                                  counterStyle:
                                      const TextStyle(color: Colors.black38),

                                  labelText: '邮箱',
                                  labelStyle: const TextStyle(
                                    color: Color.fromARGB(96, 104, 104, 104),
                                  ),
                                  //fillColor: Color.fromARGB(190, 255, 255, 255),
                                  fillColor:
                                      const Color.fromARGB(187, 250, 250, 250),
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

                        // 取消，确定
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // 在这里添加Overlay上按钮的操作
                                // 关闭
                                //widget.onClose();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 118, 246, 255)),
                              ),
                              child: Text('取消'),
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
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.greenAccent),
                              ),
                              child: Text('确定'),
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
      ],
    );
  }
}

// ===================================================
// 此页面 监护

class Supervisor extends StatefulWidget {
  const Supervisor({super.key});

  @override
  State<Supervisor> createState() => _SupervisorState();
}

class _SupervisorState extends State<Supervisor> {
  // 第0页为监护模式，第1页为关爱模式
  final PageController pageController = PageController(initialPage: 0);
  int inviteStatus = 0; // 0: 未邀请，1：邀请成功，2：邀请失败
  OverlayEntry? overlayEntry;
  bool visibleInviteGuardianWidget = false;
  bool visibleCreateGroupWidget = false;
  List<bool> ccount = [false, false, false, false, false];
  List<dynamic> invitationList = [];
  bool shouldLoadData = true;

  @override
  void initState() {
    super.initState();
    //pageController = PageController(initialPage: 0);
    pageController.addListener(_onPageChanged);
    print("init");
    //invitationNotification(context);
    // WidgetsBinding.instance!
    //     .addPostFrameCallback((_) => invitationNotification(context));
  }

  void _onPageChanged() {
    setState(() {
      // Update the state when the page changes
    });
  }

  void updateView() {
    setState(() {});
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

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

      print(response.data);

      if (response.data['code'] == 200) {
        print("邀请成功");
        return true;
      } else {
        print("邀请失败");
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        print(response.data);
        print("邀请失败1");
      } else {
        print(error.requestOptions);
        print(error.message);
        print("邀请失败2");
      }
    }
    return false;
  }

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
        print("获取血压数据成功");
        invitationList = response.data["data"];
      } else {
        print(response);
        invitationList = [];
      }
    } catch (e) {
      print(e);
      invitationList = [];
    }
    print('invitationList: $invitationList');
    return;
  }

  // 接受成为监护人
  void acceptGuardian() {
    return;
  }

  // 拒绝成为监护人
  void rejectGuardian() {
    return;
  }

  // 邀请监护人弹窗
  void updateVisibleInvitationWidget(bool isVisible) {
    setState(() {
      visibleInviteGuardianWidget = isVisible;
    });
  }

  // 邀请监护人
  void showInviteGuardianWidget(BuildContext context) {
    //OverlayEntry? overlayEntry;
    TextEditingController emailController = TextEditingController();

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
            child: GestureDetector(
              onTap: () {
                // 点击Overlay时移除它
                //overlayEntry?.remove();
              },
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200,
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
                        //标题
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 40,
                              alignment: Alignment.center,
                              //color: Colors.green,
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
                              //color: Colors.blueAccent,
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
                                  //fillColor: Color.fromARGB(190, 255, 255, 255),
                                  fillColor:
                                      const Color.fromARGB(187, 250, 250, 250),
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
                                          color: Color.fromARGB(
                                              179, 145, 145, 145))),
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
                              child: Text('取消'),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                // 在这里添加Overlay上按钮的操作
                                //overlayEntry?.remove();
                                bool status =
                                    await inviteGuardian(emailController.text);
                                status == true
                                    ? inviteStatus = 1
                                    : inviteStatus = 2;
                                //inviteStatus++;
                                //inviteStatus %= 3;
                                setState(() {});
                                overlayEntry?.markNeedsBuild();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.greenAccent),
                              ),
                              child: Text('确定'),
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

    // Overlay.of(context).insert(overlayEntry);
    Overlay.of(context).insert(overlayEntry!);
  }

  // 邀请消息通知栏
  void invitationNotification(BuildContext context) async {
    print("invitationgrd");
    //OverlayEntry? overlayEntry;
    await getInvitationNotification();

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
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  //color: Colors.greenAccent,
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
                            //color: Colors.green,
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
                            //color: Colors.blueAccent,
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

                      Container(
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
    //Overlay.of(context).insert(overlayEntry!);
    overlay.insert(overlayEntry!);
  }

  // 创建群组弹窗
  void createGroup(bool isVisible) {
    setState(() {
      visibleCreateGroupWidget = isVisible;
    });
  }

  // 获取所有通知
  Widget getAllNotification() {
    List<Widget> notificationList = [];
    for (int i = 0; i < invitationList.length; i++) {
      notificationList.add(showNotification(
        invitationList[i]["invitationId"],
        invitationList[i]["wardId"],
        invitationList[i]["wardName"],
        "2023-12-6",
        //invitationList[i]["date"], // TODO 日期格式不对
      ));
    }

    return Column(
      children: notificationList,
    );

    /*  return Column(
      children: [
        showNotification(0, 0, "admin", "2023-11-11"),
        showNotification(1, 1, "hellowww", "2023-11-23"),
        showNotification(2, 2, "admin1", "2023-11-31"),
        showNotification(3, 3, "admin2", "2023-11-11"),
        showNotification(4, 4, "admin3", "2023-11-11"),
      ],
    ); */
  }

  // 每一个通知
  Widget showNotification(
      int invitationId, int guardianId, String username, String date) {
    //username = "admin";
    //date = "2023-11-11";
    bool count = false;

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
            onTap: () {
              print("拒绝 $invitationId");
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
            onTap: () {
              print("接受 $invitationId");
              // setState(() {
              count = !count;
              ccount[guardianId] = !ccount[guardianId];
              //});
              overlayEntry?.markNeedsBuild();
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
          //height: 1, // 设置分割线的高度
          height: 1,
          color: Color.fromRGBO(169, 171, 179, 1), // 设置分割线的颜色
        ),
        //ccount[guardianId] == true ? Text("count") : Text("count2"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print("监护rebuild");

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            "TriGuard",
            style: TextStyle(
                fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
          ),
          flexibleSpace: getHeader(MediaQuery.of(context).size.width,
              (MediaQuery.of(context).size.height * 0.1 + 11)),
          automaticallyImplyLeading: false,
          actions: [
            Builder(
              builder: (context) {
                if (pageController.page == 1) {
                  return IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      print("添加监护人");
                      showInviteGuardianWidget(context);
                    },
                  );
                } else {
                  return IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () async {
                      print("通知");
                      //getInvitationNotification();
                      invitationNotification(context);
                    },
                  );
                }
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        body: Stack(children: [
          PageView(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (int page) {
              // This callback will be called when the page changes
              print("Page changed to: $page");
              // You can trigger a rebuild or perform actions based on the page change
              setState(() {});
            },
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
                //color: Colors.white,
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
