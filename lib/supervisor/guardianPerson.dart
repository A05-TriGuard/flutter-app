import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';
import '../account/token.dart';

// -------------今日记录模块--------------------
// ignore: must_be_immutable
class TodayActivities extends StatefulWidget {
  final int accountId;
  bool refreshActivitiesData;
  TodayActivities({
    Key? key,
    required this.accountId,
    required this.refreshActivitiesData,
  }) : super(key: key);

  @override
  State<TodayActivities> createState() => _TodayActivitiesState();
}

class _TodayActivitiesState extends State<TodayActivities> {
  List<dynamic> activities = [];
  List<Color> colors = const [
    Color.fromARGB(255, 185, 253, 107),
    Color.fromARGB(255, 151, 239, 255),
    Color.fromARGB(255, 255, 239, 151),
    Color.fromARGB(255, 253, 184, 250),
    Color.fromARGB(255, 255, 183, 183),
    Color.fromARGB(255, 255, 230, 183),
    Color.fromARGB(255, 183, 255, 221),
    Color.fromARGB(255, 183, 221, 255),
    Color.fromARGB(255, 221, 183, 255),
    Color.fromARGB(255, 255, 195, 227),
  ];
  List<String> activitiesType = ["测量血压", "测量血糖", "测量血脂", "记录运动", "记录饮食"];
  List<Widget> activitiesWidget = [];

  //  从服务器获取数据
  Future<void> getDataFromServer() async {
    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/ward/activity?wardId=${widget.accountId}",
      );
      if (response.data["code"] == 200) {
        activities = response.data["data"]["activities"];
      } else {
        activities = [];
      }
    } catch (e) {
      activities = [];
    }

    await provideActivitiesWidget();
  }

  // 每个人的单条记录
  Widget getActivity(String time, String activity, bool isFirst, bool isLast) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.3,
      hasIndicator: true,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: const IndicatorStyle(
        width: 15,
        color: Color.fromARGB(255, 255, 183, 183),
        padding: EdgeInsets.all(4),
      ),
      beforeLineStyle: const LineStyle(
        color: Color.fromARGB(255, 233, 127, 127),
        thickness: 3,
      ),

      // 左边（时间）
      startChild: Container(
        constraints: const BoxConstraints(
          minHeight: 50,
        ),
        child: Center(
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'BalooBhai',
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
      ),

      // 右边 （测量了什么）
      endChild: Container(
        constraints: const BoxConstraints(
          minHeight: 50,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 10, 0, 5),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: colors[activity.hashCode % colors.length],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              // 测量了什么？
              child: Text(
                activity,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'BalooBhai',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> provideActivitiesWidget() async {
    activitiesWidget.clear();
    for (int i = 0; i < activities.length; i++) {
      activitiesWidget.add(
        getActivity(
            activities[i]["time"],
            activitiesType[activities[i]["type"]],
            i == 0 ? true : false,
            i == activities.length - 1 ? true : false),
      );
    }

    if (activities.isEmpty) {
      activitiesWidget.add(
        getActivity("00:00", "今天没有记录", true, true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.refreshActivitiesData) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.15 * 0.5,
            0,
            MediaQuery.of(context).size.width * 0.15 * 0.5,
            0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 标题
            const PageTitle(
              title: "今日记录",
              icons: "assets/icons/notebook.png",
              fontSize: 20,
            ),
            const SizedBox(height: 10),
            // 活动
            Column(
              children: activitiesWidget,
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: getDataFromServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.15 * 0.5,
                0,
                MediaQuery.of(context).size.width * 0.15 * 0.5,
                0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 标题
                const PageTitle(
                  title: "今日记录",
                  icons: "assets/icons/notebook.png",
                  fontSize: 20,
                ),
                const SizedBox(height: 10),
                // 活动
                Column(
                  children: activitiesWidget,
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.15 * 0.5,
                0,
                MediaQuery.of(context).size.width * 0.15 * 0.5,
                0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 标题
                const PageTitle(
                  title: "今日记录",
                  icons: "assets/icons/notebook.png",
                  fontSize: 20,
                ),
                const SizedBox(height: 10),
                // 活动
                Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.pink,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      },
    );
  }
}

// ================此页面======================
// ignore: must_be_immutable
class GuardianPersonPage extends StatefulWidget {
  /* final int accountId;
  final String email;
  final String username;
  String nickname;
  final String image; */
  final Map arguments;
  const GuardianPersonPage({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<GuardianPersonPage> createState() => _GuardianPersonPageState();
}

class _GuardianPersonPageState extends State<GuardianPersonPage> {
  bool isEditingNickname = false;
  TextEditingController nicknameController = TextEditingController();
  bool refreshActivitiesData = true;

  // 删除监护对象
  Future<bool> deleteWard(int accountId) async {
    var token = await storage.read(key: 'token');
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/ward/delete?wardId=${widget.arguments["accountId"]}",
      );
      if (response.data["code"] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 修改成员昵称
  Future<bool> setNickname(int accountId) async {
    final Dio dio = Dio();

    try {
      var token = await storage.read(key: 'token');
      dio.options.headers["Authorization"] = "Bearer $token";
      Response response = await dio.post(
        'http://43.138.75.58:8080/api/ward/set-nickname',
        queryParameters: {
          "wardId": accountId,
          "nickname": nicknameController.text,
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

  // 获取监护对象标题
  Widget getNicknameTitle() {
    return UnconstrainedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 个人头像
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(widget.arguments["image"]),
          ),
          //
          const SizedBox(width: 10),

          // 昵称
          Container(
            constraints: BoxConstraints(
              minHeight: 30,
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Text(
              widget.arguments["nickname"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'BalooBhai',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示更多
  Widget getGroupMemberWidgetMore() {
    return UnconstrainedBox(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.2),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(120, 151, 151, 151),
              offset: Offset(0, 5),
              blurRadius: 5.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像+昵称+修改昵称
              isEditingNickname == false
                  ?
                  // 不编辑时
                  Container(
                      constraints: const BoxConstraints(
                        minHeight: 30,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // “昵称：”
                          Container(
                            constraints: const BoxConstraints(
                              minHeight: 30,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "昵称：",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'BalooBhai',
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // 昵称
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 30,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.55,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.arguments["nickname"],
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontFamily: 'BalooBhai',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          // 编辑昵称按钮
                          Container(
                            constraints: const BoxConstraints(
                                minHeight: 30, minWidth: 20),
                            child: GestureDetector(
                              onTap: () {
                                refreshActivitiesData = false;
                                isEditingNickname = !isEditingNickname;
                                nicknameController.text =
                                    widget.arguments["nickname"];
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 修改昵称的按钮
                    )
                  // 编辑昵称时
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 昵称：______
                        Row(
                          children: [
                            const SizedBox(
                              height: 40,
                              child: Center(
                                child: Text(
                                  "昵称：  ",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "BalooBhai",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 40,
                              child: Center(
                                child: TextFormField(
                                  controller: nicknameController,
                                  maxLength: 15,
                                  style: const TextStyle(
                                    fontFamily: 'BalooBhai',
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    border: const UnderlineInputBorder(),
                                    counterText: "",
                                    hintText: widget.arguments["nickname"],
                                    hintStyle: const TextStyle(
                                      fontFamily: 'BalooBhai',
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 116, 116, 116),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 确认和取消按钮
                        Container(
                          alignment: Alignment.center,
                          height: 40,
                          child: Row(
                            children: [
                              //取消
                              GestureDetector(
                                onTap: () {
                                  print("编辑监护人昵称");
                                  setState(() {
                                    isEditingNickname = !isEditingNickname;
                                    refreshActivitiesData = false;
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset("assets/icons/cancel.png",
                                      width: 27, height: 27),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              //确认
                              GestureDetector(
                                onTap: () async {
                                  // 昵称不能为空
                                  if (nicknameController.text == "") {
                                    refreshActivitiesData = false;
                                    isEditingNickname = !isEditingNickname;
                                    setState(() {});
                                    return;
                                  }

                                  bool status = await setNickname(
                                      widget.arguments["accountId"]);

                                  // 修改失败
                                  if (!status) {
                                    refreshActivitiesData = false;
                                    isEditingNickname = !isEditingNickname;
                                    setState(() {});
                                    return;
                                  }

                                  // 修改成功
                                  refreshActivitiesData = false;
                                  isEditingNickname = !isEditingNickname;
                                  widget.arguments["nickname"] =
                                      nicknameController.text;
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset("assets/icons/confirm.png",
                                      width: 30, height: 30),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

              // 用户名
              Container(
                constraints: BoxConstraints(
                  minHeight: 30,
                  minWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                //color: Colors.pinkAccent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 30,
                      ),
                      //color: Colors.yellow,
                      alignment: Alignment.centerLeft,
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
                      //color: Colors.greenAccent,
                      width: MediaQuery.of(context).size.width * 0.55,
                      //color: Colors.yellow,
                      child: Text(
                        widget.arguments["username"],
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'BalooBhai',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 邮箱
              Container(
                constraints: BoxConstraints(
                  minHeight: 30,
                  minWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                // color: Colors.pinkAccent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 30,
                      ),
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
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        widget.arguments["email"],
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'BalooBhai',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //
              const SizedBox(height: 5),

              // 删除按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //删除
                  GestureDetector(
                    onTap: () async {
                      bool status =
                          await deleteWard(widget.arguments["accountId"]);
                      if (status) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 124, 124),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                          color: const Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "删除",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'BalooBhai',
                              fontSize: 16,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  //查看数据详情
                  GestureDetector(
                    onTap: () {
                      var args = {
                        "accountId": widget.arguments["accountId"],
                        "groupId": -1,
                        "nickname": widget.arguments["nickname"],
                        "groupName": "",
                      };
                      Navigator.pushNamed(context, '/homePage',
                          arguments: args);
                    },
                    child: Container(
                      width: 120,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 183, 242, 255),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        border: Border.all(
                          color: const Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "查看数据详情",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'BalooBhai',
                              fontSize: 16,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TriGuard",
          style: TextStyle(
              fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
        ),
        flexibleSpace: getHeader(MediaQuery.of(context).size.width,
            (MediaQuery.of(context).size.height * 0.1 + 11)),
      ),
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: ListView(shrinkWrap: true, children: [
          //
          const SizedBox(height: 20),

          // 昵称标题
          getNicknameTitle(),
          const SizedBox(height: 10),
          getGroupMemberWidgetMore(),
          const SizedBox(height: 10),
          TodayActivities(
            accountId: widget.arguments["accountId"],
            refreshActivitiesData: refreshActivitiesData,
          ),
        ]),
      ),
    );
  }
}
