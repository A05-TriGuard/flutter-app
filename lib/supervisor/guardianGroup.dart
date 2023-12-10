import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:filter_list/filter_list.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';
//import './homePageSupervisor.dart';
import '../account/token.dart';

typedef RefreshDataCallback = void Function(List<bool> refreshData);
String groupname = "";
//typedef RefreshCallback = Future<void> Function(List<bool> refreshData);

// -------------------今日活动记录--------------------
class TodayActivities extends StatefulWidget {
  final int groupId;
  final List<bool> refresh;
  final RefreshDataCallback refreshCallback;
  const TodayActivities({
    Key? key,
    required this.groupId,
    required this.refresh,
    required this.refreshCallback,
  }) : super(key: key);

  @override
  State<TodayActivities> createState() => _TodayActivitiesState();
}

class _TodayActivitiesState extends State<TodayActivities> {
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
  List<dynamic> activities = [];
  List<Widget> activitiesWidget = [];
  List<String> activitiesType = ["测量血压", "测量血糖", "测量血脂", "记录运动", "记录饮食"];

  // 从服务器获取数据
  Future<void> getDataFromServer() async {
    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guard-group/activity?groupId=${widget.groupId}",
      );
      if (response.data["code"] == 200) {
        // print("获取监护人列表成功");
        activities = response.data["data"]["activities"];
      } else {
        print(response);
        activities = [];
      }
    } catch (e) {
      print(e);
      activities = [];
    }
    await provideActivitiesWidget();
  }

  // 生成组件
  Future<void> provideActivitiesWidget() async {
    activitiesWidget.clear();
    for (int i = 0; i < activities.length; i++) {
      activitiesWidget.add(getActivity(
          activities[i]["time"],
          activities[i]["nickname"],
          activitiesType[activities[i]["type"]],
          i == 0 ? true : false,
          i == activities.length - 1 ? true : false));
    }

    if (activities.isEmpty) {
      activitiesWidget.add(
        getActivity("00:00", "-", "今天没有记录", true, true),
      );
    }
  }

  // 每个人的单条记录
  Widget getActivity(String time, String nickname, String activity,
      bool isFirst, bool isLast) {
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
      endChild: Container(
        constraints: const BoxConstraints(
          minHeight: 50,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 10, 0, 5),
          child: Container(
            decoration: BoxDecoration(
              //color: Color.fromARGB(255, 151, 239, 255),
              //color: Colors.lightGreenAccent,
              color: colors[nickname.hashCode % colors.length],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'BalooBhai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    activity,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'BalooBhai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                //fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
      ),
    );
  }

  // 此模块
  @override
  Widget build(BuildContext context) {
    //print('今日活动rebuild: ---> refreshData: ${widget.refresh[2]}');
    if (!widget.refresh[2]) {
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
            //getActivityWidget(),
            Column(children: activitiesWidget),

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
                  //getActivityWidget(),
                  Column(children: activitiesWidget),

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

                  const SizedBox(height: 20),

                  Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.pink, size: 25),
                  )
                ],
              ),
            );
          }
        });
  }
}

// ---------------------成员列表信息------------------------
class MemberWidget extends StatefulWidget {
  final int groupId;
  final List<bool> refresh;
  final RefreshDataCallback refreshCallback;
  const MemberWidget({
    Key? key,
    required this.groupId,
    required this.refresh,
    required this.refreshCallback,
  }) : super(key: key);

  @override
  State<MemberWidget> createState() => _MemberWidgetState();
}

class _MemberWidgetState extends State<MemberWidget> {
  //
  TextEditingController nicknameController = TextEditingController();
  Map<int, bool> isExpanded = <int, bool>{};
  bool isEditingNickname = false;
  List<dynamic> wardInfos = [];
  List<Widget> wardInfoWidgets = [];
  bool refreshData = true;

  // +++++++++++++++++后端API++++++++++++++++++++

  // 获取所有成员信息
  Future<void> getDataFromServer() async {
    // 提取登录获取的token
    var token = await storage.read(key: 'token');
    //print(value);

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
          "http://43.138.75.58:8080/api/guard-group/activity?groupId=${widget.groupId}");
      if (response.data["code"] == 200) {
        // print("获取监护人列表成功");
        wardInfos = response.data["data"]["wardInfos"];
      } else {
        print(response);
        wardInfos = [];
      }
    } catch (e) {
      print(e);
      wardInfos = [];
    }

    //print("监护人成员列表：$wardInfos");

    wardInfoWidgets.clear();

    // 生成监护人列表
    for (int i = 0; i < wardInfos.length; i++) {
      if (wardInfos[i] != null) {
        isExpanded[wardInfos[i]["id"]] = false;
        wardInfoWidgets.add(getGroupMemberWidget(
          wardInfos[i]["id"],
          wardInfos[i]["username"],
          wardInfos[i]["email"],
          wardInfos[i]["nickname"],
          wardInfos[i]["image"] ??
              "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png",
        ));
      }
    }

    // print(wardInfoWidgets.length);
  }

  // 修改成员昵称
  Future<bool> setNickname(int accountId) async {
    final Dio dio = Dio();

    print("新昵称：${accountId} ${nicknameController.text}");

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
        print("修改昵称成功");
        return true;
      } else {
        print("修改昵称失败");
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        print(response.data);
        print("修改昵称失败1");
      } else {
        print(error.requestOptions);
        print(error.message);
        print("修改昵称失败2");
      }
    }
    return false;
  }

  // 将成员移出群组
  Future<bool> removeMember(int wardId) async {
    print('踢出去 群组： ${widget.groupId} 成员：$wardId');
    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guard-group/member/delete?groupId=${widget.groupId}&wardId=$wardId",
      );
      print(response);
      if (response.data["code"] == 200) {
        print("踢出成员成功");
        return true;
      } else {
        print(response);
        wardInfos = [];
      }
    } catch (e) {
      print(e);
      wardInfos = [];
    }

    print("踢出成员失败");
    return false;
  }

  // ------------------组件--------------------

  // 显示一个成员信息（收起）
  Widget getGroupMemberWidgetLess(int accountId, String username, String email,
      String nickname, String image) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Image.asset("assets/icons/exercising.png", width: 20, height: 20),
        // 头像
        Container(
          constraints: const BoxConstraints(
            maxHeight: 30,
            maxWidth: 40,
          ),
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
            ),
          ),
          child: Image.network(
            image,
            //width: 30,
            //height: 30,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        // 昵称
        Container(
          constraints: BoxConstraints(
            minHeight: 30,
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          child: Text(
            nickname.isEmpty ? username : nickname,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'BalooBhai',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  // 显示一个成员信息（展开）
  Widget getGroupMemberWidgetMore(
      int accountId, String username, String email, String nickname) {
    return Column(
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
                //color: Colors.blueAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 昵称
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 30,
                      ),
                      //color: Colors.yellow,
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

                    // 昵称名
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 30,
                        maxWidth: MediaQuery.of(context).size.width * 0.55,
                      ),
                      //color: Colors.amber,
                      alignment: Alignment.centerLeft,
                      //color: Colors.greenAccent,
                      //width: MediaQuery.of(context).size.width * 0.55,
                      //color: Colors.yellow,
                      child: Text(
                        nickname,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'BalooBhai',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    // 修改昵称的按钮
                    Container(
                      constraints:
                          const BoxConstraints(minHeight: 20, minWidth: 20),
                      //width: 25,
                      //height: 25,
                      //color: Colors.red,
                      child: GestureDetector(
                        onTap: () {
                          print("修改昵称?");
                          // Navigator.pushNamed(context, '/edit');
                          nicknameController.text = nickname;
                          isEditingNickname = !isEditingNickname;
                          //setState(() {});
                          List<bool> refresh = [false, false, false];
                          widget.refreshCallback(refresh);
                        },
                        /*  child: Image.asset("assets/icons/pencil.png",
                            width: 10, height: 10), */
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            // 编辑昵称时
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 昵称：______
                  Row(
                    children: [
                      const SizedBox(
                        height: 30,
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
                      // 输入框
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: 30,
                        child: Center(
                          child: TextFormField(
                            controller: nicknameController,
                            maxLength: 14,
                            style: const TextStyle(
                              fontFamily: 'BalooBhai',
                              fontSize: 16,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: const UnderlineInputBorder(),
                              counterText: "",
                              hintText: nickname,
                              hintStyle: const TextStyle(
                                fontFamily: 'BalooBhai',
                                fontSize: 16,
                                //fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 116, 116, 116),
                              ),

                              /* labelStyle: const TextStyle(
                                fontFamily: 'BalooBhai',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ), */
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 确认和取消按钮
                  Container(
                    //color: Colors.blueAccent,
                    alignment: Alignment.center,
                    height: 30,
                    child: Row(
                      children: [
                        //取消
                        GestureDetector(
                          onTap: () {
                            print("编辑监护人昵称");
                            refreshData = false;
                            isEditingNickname = !isEditingNickname;
                            setState(() {});
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
                        GestureDetector(
                          onTap: () async {
                            print("编辑监护人昵称");

                            if (nicknameController.text.isEmpty) {
                              refreshData = false;
                              isEditingNickname = !isEditingNickname;
                              setState(() {});
                              return;
                            }

                            bool status = await setNickname(accountId);

                            if (!status) {
                              refreshData = false;
                              isEditingNickname = !isEditingNickname;
                              setState(() {});
                              return;
                            }

                            refreshData = true;
                            // 活动也要刷新
                            List<bool> refresh = [
                              //widget.refresh[0], //false ####
                              false,
                              true,
                              true
                            ];
                            isEditingNickname = !isEditingNickname;
                            //setState(() {});
                            widget.refreshCallback(refresh);
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
                  username,
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
                //alignment: Alignment.centerLeft,
                //color: Colors.greenAccent,
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
                //color: Colors.yellow,
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  email,
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
                //print("移出群组$accountId");
                // Navigator.pushNamed(context, '/edit');
                bool status = await removeMember(accountId);
                if (status) {
                  isExpanded[accountId] = false;
                  List<bool> refresh = [true, true, true];
                  //setState(() {});
                  widget.refreshCallback(refresh);
                }
              },
              child: Container(
                width: 80,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 124, 124),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "移出群组",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'BalooBhai',
                        fontSize: 16,
                        //fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
            //查看数据详情
            GestureDetector(
              onTap: () {
                //print("查看群组数据详情$accountId");
                // Navigator.pushNamed(context, '/edit');
                /* Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      accountId: accountId,
                      groupId: widget.groupId,
                      nickname: nickname,
                      groupName: groupname,
                    ),
                  ),
                ).then((_) {
                  print("哈哈哈");
                  //widget.updateData();
                }); */
                var args = {
                  "accountId": accountId,
                  "groupId": widget.groupId,
                  "nickname": nickname,
                  "groupName": groupname,
                };
                Navigator.pushNamed(context, '/homePage', arguments: args);
              },
              child: Container(
                width: 120,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 183, 242, 255),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                        //fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // 显示一个成员信息（统一接口）
  Widget getGroupMemberWidget(int accountId, String username, String email,
      String nickname, String image) {
    return UnconstrainedBox(
      child: GestureDetector(
        onTap: () {
          isEditingNickname = false;
          refreshData = false;

          bool? isExpand = isExpanded[accountId];
          isExpanded.forEach((key, value) {
            isExpanded[key] = false;
          });
          if (isExpand == true) {
            isExpanded[accountId] = false;
          } else {
            isExpanded[accountId] = true;
          }
          List<bool> refresh = [false, false, false];
          //setState(() {});
          widget.refreshCallback(refresh);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: MediaQuery.of(context).size.width * 0.85,
          height: isExpanded[accountId] == false ? 55 : 160,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border(
              //bottom
              bottom: BorderSide(
                color: Color.fromRGBO(0, 0, 0, 0.2),
              ),
            ),
            boxShadow: [
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
            child: isExpanded[accountId] == false
                ? getGroupMemberWidgetLess(
                    accountId, username, email, nickname, image)
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: getGroupMemberWidgetMore(
                      accountId,
                      username,
                      email,
                      nickname,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // 没有成员
  Widget noMemberWidget() {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 55,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border(
            //bottom
            bottom: BorderSide(
              color: Color.fromRGBO(0, 0, 0, 0.2),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(120, 151, 151, 151),
              offset: Offset(0, 5),
              blurRadius: 5.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            "暂无成员",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: 'BalooBhai',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // 此模块
  @override
  Widget build(BuildContext context) {
    // print('成员rebuild: ---> refreshData: ${widget.refresh[1]}');
    //print('成员rebuild: ---> 群组id: ${widget.groupId}');
    if (!widget.refresh[1]) {
      wardInfoWidgets.clear();
      for (int i = 0; i < wardInfos.length; i++) {
        if (wardInfos[i] != null) {
          wardInfoWidgets.add(getGroupMemberWidget(
            wardInfos[i]["id"],
            wardInfos[i]["username"],
            wardInfos[i]["email"],
            wardInfos[i]["nickname"],
            wardInfos[i]["image"] ??
                "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png",
          ));
        }
      }
      if (wardInfoWidgets.isEmpty) {
        return noMemberWidget();
      }
      return Column(
        children: wardInfoWidgets,
      );
    }
    return FutureBuilder(
        future: getDataFromServer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            /*  return Column(
              children: wardInfoWidgets,
            ); */

            refreshData = false;
            if (wardInfoWidgets.isEmpty) {
              return noMemberWidget();
            }
            return Column(
              children: wardInfoWidgets,
            );

            /*  return Container(
              constraints: BoxConstraints(
                minHeight: 55,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: wardInfoWidgets,
                ),
              ),
            ); */
            /* return ListView.builder(
              shrinkWrap: true,
              //physics: const NeverScrollableScrollPhysics(),
              itemCount: wardInfoWidgets.length,
              itemBuilder: (BuildContext context, int index) {
                return wardInfoWidgets[index];
              },
            ); */
          } else {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            );
          }
        });
  }
}

// -------------------选择要添加的成员类--------------------
class User2 {
  final String? name;
  final String? avatar;
  User2({this.name, this.avatar});
}

List<User2> userList = [
  User2(name: "Jon", avatar: ""),
  User2(name: "Lindsey ", avatar: ""),
  User2(name: "Valarie ", avatar: ""),
  User2(name: "Elyse ", avatar: ""),
  User2(name: "Ethel ", avatar: ""),
  User2(name: "Emelyan ", avatar: ""),
  User2(name: "Catherine ", avatar: ""),
  User2(name: "Stepanida  ", avatar: ""),
  User2(name: "Carolina ", avatar: ""),
  User2(name: "Nail  ", avatar: ""),
  User2(name: "Kamil ", avatar: ""),
  User2(name: "Mariana ", avatar: ""),
  User2(name: "Katerina ", avatar: ""),
];

// ------------------------群名标题------------------------
class GroupNameHeader extends StatefulWidget {
  final int groupId;
  final List<bool> refresh;
  final RefreshDataCallback refreshCallback;
  const GroupNameHeader({
    Key? key,
    required this.groupId,
    required this.refresh,
    required this.refreshCallback,
  }) : super(key: key);

  @override
  State<GroupNameHeader> createState() => _GroupNameHeaderState();
}

class _GroupNameHeaderState extends State<GroupNameHeader> {
  TextEditingController groupNameController = TextEditingController();
  bool isEditingGroupName = false;
  int memberCount = 0;
  List<dynamic> wardInfos = [];
  List<dynamic> groupList = [];
  //bool refreshData = true;
  String groupName = "";

  // ++++++++++++++++后端API+++++++++++++++++

  // 获取统计人数与群名
  Future<void> getDataFromServer() async {
    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guard-group/activity?groupId=${widget.groupId}",
      );
      if (response.data["code"] == 200) {
        // print("获取监护人列表成功");
        wardInfos = response.data["data"]["wardInfos"];
      } else {
        print(response);
        wardInfos = [];
      }
    } catch (e) {
      print(e);
      wardInfos = [];
    }
    //memberCount = wardInfos.length;
    int count = 0;
    // print("memberCount: $memberCount");
    for (int i = 0; i < wardInfos.length; i++) {
      if (wardInfos[i] != null) {
        count++;
      }
    }
    memberCount = count;

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/ward/list",
      );
      if (response.data["code"] == 200) {
        // print("获取监护人列表成功");
        groupList = response.data["data"]["groupList"];
      } else {
        print(response);
        groupList = [];
      }
    } catch (e) {
      print(e);
      groupList = [];
    }

    // find where groupId == widget.groupId
    for (int i = 0; i < groupList.length; i++) {
      if (groupList[i]["groupId"] == widget.groupId) {
        groupName = groupList[i]["groupName"];
        groupname = groupName;
        break;
      }
    }
  }

  // 修改群名
  Future<bool> changeGroupName() async {
    final Dio dio = Dio();

    //print("新群名字：${widget.groupId} ${groupNameController.text}");

    try {
      var token = await storage.read(key: 'token');
      dio.options.headers["Authorization"] = "Bearer $token";
      //dio.options.requestEncoder
      Response response = await dio.post(
        'http://43.138.75.58:8080/api/guard-group/set-name',
        queryParameters: {
          "groupId": widget.groupId,
          "groupName": groupNameController.text,
        },
      );

      if (response.data['code'] == 200) {
        //print("修改群名成功");
        return true;
      } else {
        print("修改群名失败");
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        print(response.data);
        print("修改群名失败1");
      } else {
        print(error.requestOptions);
        print(error.message);
        print("修改群名失败2");
      }
    }
    return false;
  }

  // ==================组件=============
  // 群组名（编辑时）
  Widget editingGroupNameWidget() {
    groupNameController.text = groupName;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: 30,
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          child: SizedBox(
            //color: Colors.greenAccent,
            width: MediaQuery.of(context).size.width * 0.35,
            height: 40,
            child: Center(
              child: TextFormField(
                controller: groupNameController,
                maxLength: 15,
                style: const TextStyle(
                  fontFamily: 'BalooBhai',
                  fontSize: 18,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: const UnderlineInputBorder(),
                  counterText: "",
                  hintText: groupName,
                  hintStyle: const TextStyle(
                    fontFamily: 'BalooBhai',
                    fontSize: 18,
                    //fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 116, 116, 116),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Container(
          alignment: Alignment.center,
          height: 40,
          child: Row(
            children: [
              // 取消
              GestureDetector(
                onTap: () {
                  //print("取消编辑群名");
                  //refreshData = false;
                  List<bool> refresh = [false, false, false];
                  isEditingGroupName = !isEditingGroupName;
                  groupNameController.text = groupName;
                  /*  setState(() {
                    
                  }); */
                  widget.refreshCallback(refresh);
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

              // 确定
              GestureDetector(
                onTap: () async {
                  // print("编辑监护人昵称");
                  List<bool> refresh = [false, false, false];

                  // 不能为空
                  if (groupNameController.text.isEmpty) {
                    // refreshData = false;
                    isEditingGroupName = !isEditingGroupName;
                    //setState(() {});
                    widget.refreshCallback(refresh);
                    return;
                  }

                  bool status = await changeGroupName();

                  // 更改失败
                  if (!status) {
                    //refreshData = false;
                    isEditingGroupName = !isEditingGroupName;
                    //setState(() {});
                    widget.refreshCallback(refresh);
                    return;
                  }

                  refresh[0] = true;
                  isEditingGroupName = !isEditingGroupName;

                  //widget.groupName = groupNameController.text;
                  print("新群名：${groupNameController.text}");
                  // groupNameController.text = widget.groupName;
                  //setState(() {});
                  widget.refreshCallback(refresh);
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
    );
  }

  // 群组名
  Widget groupNameHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: 30,
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          child: Text(
            "$groupName ($memberCount)",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'BalooBhai',
              fontSize: 22,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            // 不用刷新
            List<bool> refresh = [false, false, false];
            isEditingGroupName = !isEditingGroupName;
            //setState(() {});
            widget.refreshCallback(refresh);
          },
          child: Container(
            width: 20,
            height: 20,
            child: Image.asset("assets/icons/pencil.png"),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  // 此模块
  @override
  Widget build(BuildContext context) {
    //print('群名标题rebuild: ---> refreshData: ${widget.refresh[0]}');
    if (!widget.refresh[0]) {
      return isEditingGroupName == false
          ? groupNameHeader()
          : editingGroupNameWidget();
    }

    return FutureBuilder(
        future: getDataFromServer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return isEditingGroupName == false
                ? groupNameHeader()
                : editingGroupNameWidget();
          } else {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            );
          }
        });
  }
}

// ===================此页面===========================

class WardSelection {
  final String? nickname;
  final String? wardId;
  WardSelection({this.nickname, this.wardId});
}

// ignore: must_be_immutable
class GuardianGroupPage extends StatefulWidget {
/*   final int groupId;
  String groupName; */
  final Map arguments;
  GuardianGroupPage({
    Key? key,
    /* required this.groupId, required this.groupName */
    required this.arguments,
  }) : super(key: key);

  @override
  State<GuardianGroupPage> createState() => _GuardianGroupPageState();
}

class _GuardianGroupPageState extends State<GuardianGroupPage> {
  //
  List<User2> selectedUserList = [];
  String memberCount = "0";
  List<dynamic> wardInfos = [];
  List<dynamic> activities = [];
  // [0] header, [1] member, [2] activity
  List<bool> refresh = [true, true, true];
  List<WardSelection> wardSelectionList = [];
  List<WardSelection> selectedWardSelectionList = [];

  // 回调函数
  void refreshView(List<bool> refreshData) {
    refresh = refreshData;
    setState(() {});
  }
  // ++++++++++++++++后端API+++++++++++++++++

  //
  Future<void> getDataFromServer() async {
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
        wardInfos = response.data["data"]["wardInfos"];
        activities = response.data["data"]["activities"];
      } else {
        print(response);
        wardInfos = [];
        activities = [];
      }
    } catch (e) {
      print(e);
      wardInfos = [];
      activities = [];
    }
    memberCount = (wardInfos.length).toString();

    //print("监护人成员列表：$wardInfos");
    //print("活动列表：$activities");
  }

  // 解散群组
  Future<bool> deleteGroup() async {
    var token = await storage.read(key: 'token');
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guard-group/disband?groupId=${widget.arguments["groupId"]}",
      );
      if (response.data["code"] == 200) {
        print("解散成功");
        return true;
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }
    print("解散失败");
    return false;
  }

  // 获取能添加的成员
  Future<void> getOtherWardForSelection() async {
    // 所有被监护人
    List<dynamic> allWardInfos = [];
    // 当前群组的成员
    List<dynamic> currentGroupWardInfos = [];

    // 获取所有被监护人
    var token = await storage.read(key: 'token');
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/ward/list",
      );
      if (response.data["code"] == 200) {
        // print("获取监护人列表成功");
        allWardInfos = response.data["data"]["wardList"];
      } else {
        print(response);
        allWardInfos = [];
      }
    } catch (e) {
      print(e);
      allWardInfos = [];
    }

    //print("监护人成员列表：$allWardInfos");

    // 获取当前群里的成员
    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guard-group/activity?groupId=${widget.arguments["groupId"]}",
      );
      if (response.data["code"] == 200) {
        currentGroupWardInfos = response.data["data"]["wardInfos"];
      } else {
        print(response);
        currentGroupWardInfos = [];
      }
    } catch (e) {
      print(e);
      currentGroupWardInfos = [];
    }
    //print("当前群组成员列表：$currentGroupWardInfos");

    // 从allWardInfos中删除currentGroupWardInfos
    /* for (int i = 0; i < currentGroupWardInfos.length; i++) {
      for (int j = 0; j < allWardInfos.length; j++) {
        if (currentGroupWardInfos[i]["id"] == allWardInfos[j]["accountId"]) {
          allWardInfos.removeAt(j);
          break;
        }
      }
    }

    wardSelectionList.clear();
    for (int i = 0; i < allWardInfos.length; i++) {
      wardSelectionList.add(
        WardSelection(
          nickname: allWardInfos[i]["nickname"],
          wardId: (allWardInfos[i]["accountId"]).toString(),
        ),
      );
    } */

    // allWardInfos [{...},{...},null] ，可能有null，先去掉
    allWardInfos.removeWhere((element) => element == null);
    currentGroupWardInfos.removeWhere((element) => element == null);

    Set<int> guardianIdsToRemove =
        Set.from(currentGroupWardInfos.map((info) => info["id"]));

    allWardInfos.removeWhere(
        (wardInfo) => guardianIdsToRemove.contains(wardInfo["accountId"]));

    // 构造wardSelectionList
    wardSelectionList.clear();

    wardSelectionList = allWardInfos.map((wardInfo) {
      return WardSelection(
        nickname: wardInfo["nickname"],
        wardId: (wardInfo["accountId"]).toString(),
      );
    }).toList();
  }

  // 添加成员
  Future<bool> addMember() async {
    String accountId = "";

    for (int i = 0; i < selectedWardSelectionList.length; i++) {
      accountId += selectedWardSelectionList[i].wardId!;
      if (i != selectedWardSelectionList.length - 1) {
        accountId += ",";
      }
    }

    print(accountId);

    //return true;

    final Dio dio = Dio();

    //print("新昵称：${accountId} ${nicknameController.text}");

    try {
      var token = await storage.read(key: 'token');
      dio.options.headers["Authorization"] = "Bearer $token";
      Response response = await dio.post(
        'http://43.138.75.58:8080/api/guard-group/member/add',
        queryParameters: {
          "wardIds": accountId,
          "groupId": widget.arguments["groupId"],
        },
      );

      if (response.data['code'] == 200) {
        print("添加成员成功");
        setState(() {});
        return true;
      } else {
        print("添加成员失败");
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        print(response.data);
        print("添加成员失败1");
      } else {
        print(error.requestOptions);
        print(error.message);
        print("添加成员失败2");
      }
    }
    return false;
  }

  // ------------------弹窗-----------------

  //
  Future<void> openFilterDelegate() async {
    await FilterListDelegate.show<User2>(
      context: context,
      list: userList,
      selectedListData: selectedUserList,
      //enableOnlySingleSelection: true,
      //applyButtonText: "??",

      theme: FilterListDelegateThemeData(
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: Colors.white,
          selectedColor: Colors.red,
          selectedTileColor: const Color(0xFF649BEC).withOpacity(.5),
          textColor: Colors.blue,
        ),
      ),
      // enableOnlySingleSelection: true,
      onItemSearch: (user, query) {
        return user.name!.toLowerCase().contains(query.toLowerCase());
      },
      tileLabel: (user) => user!.name,
      emptySearchChild: const Center(child: Text('No user found')),
      // enableOnlySingleSelection: true,
      searchFieldHint: 'Search Here..',
      /*suggestionBuilder: (context, user, isSelected) {
        return ListTile(
          title: Text(user.name!),
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
          ),
          selected: isSelected,
        );
      },*/
      onApplyButtonClick: (list) {
        setState(() {
          selectedUserList = list!;
          if (selectedUserList.isNotEmpty) {
            //print(selectedUserList[0].name);
            for (int i = 0; i < selectedUserList.length; i++) {
              print(selectedUserList[i].name);
            }
          }
        });
      },
    );
  }

  // 选择要添加的成员 no use
  void openFilterDialog() async {
    // await FilterListDelegate.show(context: context, list: userList, onItemSearch:  , onApplyButtonClick: );

    await FilterListDialog.display<User2>(
      context,
      listData: userList,
      selectedListData: selectedUserList,
      choiceChipLabel: (user) => user!.name,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (user, query) {
        return user.name!.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        setState(() {
          selectedUserList = List.from(list!);
        });
        Navigator.pop(context);
      },
    );
  }

  // 选择要添加的成员
  void addMemberDialog() async {
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
      onApplyButtonClick: (list) async {
        selectedWardSelectionList = List.from(list!);
        /* for (int i = 0; i < selectedWardSelectionList.length; i++) {
          print(
              "wardSelectionList: ${selectedWardSelectionList[i].nickname} ${selectedWardSelectionList[i].wardId}");
        } */

        //selectGroupNameWidget(context);
        // 先pop再显示 填写群组名
        //Navigator.pop(context);

        // 必须至少一个成员才能创建群组
        /* if (selectedWardSelectionList.isNotEmpty) {
          selectGroupNameWidget(context);
        } */

        Navigator.pop(context);

        if (selectedWardSelectionList.isNotEmpty) {
          await addMember();
        }
      },
      height: MediaQuery.of(context).size.height * 0.7,
      headlineText: "添加成员",
      applyButtonText: "确认",
      resetButtonText: "重置",
      allButtonText: "全选",
      selectedItemsText: "人被选择",
    );
  }

  // 添加成员
  void showOverlay(BuildContext context) {
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
                height: 500,
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
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //const SizedBox(height: 10,),

                      //标题
                      const Text(
                        "添加成员",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // 选择要添加的成员
                      Container(
                        height: 250,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: FilterListWidget<User2>(
                          listData: userList,
                          selectedListData: selectedUserList,
                          onApplyButtonClick: (list) {
                            // do something with list ..
                          },
                          choiceChipLabel: (item) {
                            /// Used to display text on chip
                            return item!.name;
                          },
                          validateSelectedItem: (list, val) {
                            ///  identify if item is selected or not
                            return list!.contains(val);
                          },
                          onItemSearch: (user, query) {
                            /// When search query change in search bar then this method will be called
                            ///
                            /// Check if items contains query
                            return user.name!
                                .toLowerCase()
                                .contains(query.toLowerCase());
                          },
                        ),
                      ),

                      // 取消，确定
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // 在这里添加Overlay上按钮的操作
                              overlayEntry?.remove();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(255, 118, 246, 255)),
                            ),
                            child: Text('取消'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // 在这里添加Overlay上按钮的操作
                              overlayEntry?.remove();
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
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  // 确定解散群组的dialog
  void showDismissDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "确定要解散群组吗？",
            style: TextStyle(
              fontFamily: "BalooBhai",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "解散群组后，群组内的所有成员将不再是该群组的成员，且无法恢复。",
            style: TextStyle(
              fontFamily: "BalooBhai",
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                print("取消解散群组");
                Navigator.pop(context);
              },
              child: const Text(
                "取消",
                style: TextStyle(
                  fontFamily: "BalooBhai",
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                bool status = await deleteGroup();
                print("确定解散群组");
                Navigator.pop(context);

                if (status) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "确定",
                style: TextStyle(
                  fontFamily: "BalooBhai",
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ###################组件#################

  // 此页面
  @override
  Widget build(BuildContext context) {
    //print("群组rebuild");
    print(widget.arguments);
    print(
        '群组ID: ${widget.arguments["groupId"]} 群组名: ${widget.arguments["groupName"]}');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TriGuard",
          style: TextStyle(
              fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
        ),
        flexibleSpace: getHeader(MediaQuery.of(context).size.width,
            (MediaQuery.of(context).size.height * 0.1 + 11)),
        actions: [
          GestureDetector(
            onTap: () async {
              print("添加成员");
              //showOverlay(context);
              //openFilterDelegate();

              await getOtherWardForSelection();
              /*  print("allWardInfos: $allWardInfos ${allWardInfos.length}");
              print(
                  "currentGroupWardInfos: $currentGroupWardInfos ${currentGroupWardInfos.length}");
              Set<int> guardianIdsToRemove =
                  Set.from(currentGroupWardInfos.map((info) => info["id"]));

              allWardInfos.removeWhere((wardInfo) =>
                  guardianIdsToRemove.contains(wardInfo["accountId"]));

              // 构造wardSelectionList
              wardSelectionList.clear();

              wardSelectionList = allWardInfos.map((wardInfo) {
                return WardSelection(
                  nickname: wardInfo["nickname"],
                  wardId: wardInfo["accountId"],
                );
              }).toList();
              /* wardSelectionList.clear();
                for (int i = 0; i < 30; i++) {
                  wardSelectionList.add(
                    WardSelection(
                      nickname: "haha",
                      wardId: "1",
                    ),
                  );
                } */ */
              addMemberDialog();

              /*  getOtherWardForSelection().then((_) {
                addMemberDialog();
              }); */
            },
            child: Container(
              width: 20,
              height: 20,
              child: Image.asset("assets/icons/add.png"),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              print("解散群组");
              showDismissDialog(context);
            },
            child: Container(
              width: 20,
              height: 20,
              child: Image.asset("assets/icons/delete.png"),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),

      //
      body: Container(
        color: Colors.white,
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: ListView(shrinkWrap: true, children: [
          //
          const SizedBox(height: 20),

          GroupNameHeader(
            groupId: widget.arguments["groupId"],
            refresh: refresh,
            refreshCallback: refreshView,
          ),

          const SizedBox(
            height: 10,
          ),

          MemberWidget(
            groupId: widget.arguments["groupId"],
            refresh: refresh,
            refreshCallback: refreshView,
          ),
          const SizedBox(
            height: 20,
          ),

          TodayActivities(
            groupId: widget.arguments["groupId"],
            refresh: refresh,
            refreshCallback: refreshView,
          ),
        ]),
      ),
    );
  }
}
