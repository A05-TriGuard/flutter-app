import 'package:dio/dio.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../account/token.dart';
import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';

typedef RefreshDataCallback = void Function(List<bool> refreshData);
String groupname = "";

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
        activities = [];
      }
    } catch (e) {
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
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
          "http://43.138.75.58:8080/api/guard-group/activity?groupId=${widget.groupId}");
      if (response.data["code"] == 200) {
        wardInfos = response.data["data"]["wardInfos"];
      } else {
        wardInfos = [];
      }
    } catch (e) {
      wardInfos = [];
    }

    wardInfoWidgets.clear();

    // 生成监护人列表
    for (int i = 0; i < wardInfos.length; i++) {
      if (wardInfos[i] != null) {
        String imageUrl =
            "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png";

        if (wardInfos[i]["image"] != null) {
          imageUrl = "http://43.138.75.58:8080/static/${wardInfos[i]["image"]}";
        }

        isExpanded[wardInfos[i]["id"]] = false;
        wardInfoWidgets.add(getGroupMemberWidget(
          wardInfos[i]["id"],
          wardInfos[i]["username"],
          wardInfos[i]["email"],
          wardInfos[i]["nickname"],
          imageUrl,
        ));
      }
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

  // 将成员移出群组
  Future<bool> removeMember(int wardId) async {
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guard-group/member/delete?groupId=${widget.groupId}&wardId=$wardId",
      );
      if (response.data["code"] == 200) {
        return true;
      } else {
        wardInfos = [];
      }
    } catch (e) {
      wardInfos = [];
    }

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
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(image),
        ),
        const SizedBox(width: 2),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 昵称
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

                    // 昵称名
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 30,
                        maxWidth: MediaQuery.of(context).size.width * 0.55,
                      ),
                      alignment: Alignment.centerLeft,
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
                      child: GestureDetector(
                        onTap: () {
                          nicknameController.text = nickname;
                          isEditingNickname = !isEditingNickname;
                          List<bool> refresh = [false, false, false];
                          widget.refreshCallback(refresh);
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
              )
            // 编辑昵称时
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    height: 30,
                    child: Row(
                      children: [
                        //取消
                        GestureDetector(
                          onTap: () {
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
                            List<bool> refresh = [false, true, true];
                            isEditingNickname = !isEditingNickname;
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(
                  minHeight: 30,
                ),
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
                width: MediaQuery.of(context).size.width * 0.55,
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
                bool status = await removeMember(accountId);
                if (status) {
                  isExpanded[accountId] = false;
                  List<bool> refresh = [true, true, true];
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
                        color: Colors.black),
                  ),
                ),
              ),
            ),
            //查看数据详情
            GestureDetector(
              onTap: () {
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
                      color: Colors.black,
                    ),
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
    if (!widget.refresh[1]) {
      wardInfoWidgets.clear();
      for (int i = 0; i < wardInfos.length; i++) {
        String imageUrl =
            "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png";

        if (wardInfos[i] != null) {
          if (wardInfos[i]["image"] != null) {
            imageUrl =
                "http://43.138.75.58:8080/static/${wardInfos[i]["image"]}";
          }

          wardInfoWidgets.add(getGroupMemberWidget(
            wardInfos[i]["id"],
            wardInfos[i]["username"],
            wardInfos[i]["email"],
            wardInfos[i]["nickname"],
            imageUrl,
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
            refreshData = false;
            if (wardInfoWidgets.isEmpty) {
              return noMemberWidget();
            }
            return Column(
              children: wardInfoWidgets,
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
        wardInfos = response.data["data"]["wardInfos"];
      } else {
        wardInfos = [];
      }
    } catch (e) {
      wardInfos = [];
    }
    int count = 0;
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
        groupList = response.data["data"]["groupList"];
      } else {
        groupList = [];
      }
    } catch (e) {
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

    try {
      var token = await storage.read(key: 'token');
      dio.options.headers["Authorization"] = "Bearer $token";
      Response response = await dio.post(
        'http://43.138.75.58:8080/api/guard-group/set-name',
        queryParameters: {
          "groupId": widget.groupId,
          "groupName": groupNameController.text,
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
                  List<bool> refresh = [false, false, false];
                  isEditingGroupName = !isEditingGroupName;
                  groupNameController.text = groupName;

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
                  List<bool> refresh = [false, false, false];

                  // 不能为空
                  if (groupNameController.text.isEmpty) {
                    isEditingGroupName = !isEditingGroupName;
                    widget.refreshCallback(refresh);
                    return;
                  }

                  bool status = await changeGroupName();

                  // 更改失败
                  if (!status) {
                    isEditingGroupName = !isEditingGroupName;
                    widget.refreshCallback(refresh);
                    return;
                  }

                  refresh[0] = true;
                  isEditingGroupName = !isEditingGroupName;
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
            widget.refreshCallback(refresh);
          },
          child: SizedBox(
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
  const GuardianGroupPage({
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
        wardInfos = [];
        activities = [];
      }
    } catch (e) {
      wardInfos = [];
      activities = [];
    }
    memberCount = (wardInfos.length).toString();
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
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
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
        allWardInfos = response.data["data"]["wardList"];
      } else {
        allWardInfos = [];
      }
    } catch (e) {
      allWardInfos = [];
    }

    // 获取当前群里的成员
    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/guard-group/activity?groupId=${widget.arguments["groupId"]}",
      );
      if (response.data["code"] == 200) {
        currentGroupWardInfos = response.data["data"]["wardInfos"];
      } else {
        currentGroupWardInfos = [];
      }
    } catch (e) {
      currentGroupWardInfos = [];
    }

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

    final Dio dio = Dio();

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
        setState(() {});
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

  // ------------------弹窗-----------------

  //
  Future<void> openFilterDelegate() async {
    await FilterListDelegate.show<User2>(
      context: context,
      list: userList,
      selectedListData: selectedUserList,
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
      onItemSearch: (user, query) {
        return user.name!.toLowerCase().contains(query.toLowerCase());
      },
      tileLabel: (user) => user!.name,
      emptySearchChild: const Center(child: Text('No user found')),
      searchFieldHint: 'Search Here..',
      onApplyButtonClick: (list) {
        setState(() {
          selectedUserList = list!;
          /* if (selectedUserList.isNotEmpty) {
            for (int i = 0; i < selectedUserList.length; i++) {
              print(selectedUserList[i].name);
            }
          } */
        });
      },
    );
  }

  // 选择要添加的成员 no use
  void openFilterDialog() async {
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

        Navigator.pop(context);

        if (selectedWardSelectionList.isNotEmpty) {
          bool status = await addMember();
          if (status) {
            List<bool> refresh = [true, true, true];
            widget.arguments["refresh"] = refresh;
            setState(() {});
          }
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
                height: 500,
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
                      const Text(
                        "添加成员",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // 选择要添加的成员
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: FilterListWidget<User2>(
                          listData: userList,
                          selectedListData: selectedUserList,
                          onApplyButtonClick: (list) {},
                          choiceChipLabel: (item) {
                            return item!.name;
                          },
                          validateSelectedItem: (list, val) {
                            return list!.contains(val);
                          },
                          onItemSearch: (user, query) {
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
                                  const Color.fromARGB(255, 118, 246, 255)),
                            ),
                            child: const Text('取消'),
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
                // ignore: use_build_context_synchronously
                Navigator.pop(context);

                if (status) {
                  // ignore: use_build_context_synchronously
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TriGuard",
          style: TextStyle(
              fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
        ),
        flexibleSpace: getHeader(
          MediaQuery.of(context).size.width,
          (MediaQuery.of(context).size.height * 0.1 + 11),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              await getOtherWardForSelection();

              addMemberDialog();
            },
            child: SizedBox(
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
              showDismissDialog(context);
            },
            child: SizedBox(
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
