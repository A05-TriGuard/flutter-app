import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';
import './homePageSupervisor.dart';

class TodayActivities extends StatefulWidget {
  const TodayActivities({super.key});

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

  // TODO: 从服务器获取数据
  Future<void> getDataFromServer() async {}

  // 每个人的单条记录
  Widget getActivity(String time, String username, String activity,
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
                //fontWeight: FontWeight.bold,
                color: Colors.black),
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
              //padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
              padding: EdgeInsets.all(10),
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

  Widget getActivityWidget() {
    return Column(
      children: [
        //
        getActivity("17:00", "爷爷", "血压测量", true, false),
        getActivity("16:30", "妈妈", "血脂测量", false, false),
        getActivity("16:00", "弟弟", "血糖测量", false, false),
        getActivity("15:30", "奶奶", "血压测量", false, false),
        getActivity("15:00", "爷爷", "血脂测量", false, false),
        getActivity("14:30", "姐姐", "血糖测量", false, false),
        getActivity("14:00", "爸爸", "血压测量", false, false),
        getActivity("13:30", "奶奶", "血脂测量", false, false),
        getActivity("13:00", "爷爷", "血糖测量", false, true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          getActivityWidget(), const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class GuardianPersonPage extends StatefulWidget {
  String nickname = "测试人员";
  GuardianPersonPage({super.key});

  @override
  State<GuardianPersonPage> createState() => _GuardianPersonPageState();
}

class _GuardianPersonPageState extends State<GuardianPersonPage> {
  bool isEditingNickname = false;
  TextEditingController nicknameController = TextEditingController();

  Widget getNicknameTitle() {
    return UnconstrainedBox(
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 30,
        ),
        width: MediaQuery.of(context).size.width * 0.85,
        //color: Colors.greenAccent,
        child: Center(
          child: Text(
            widget.nickname,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'BalooBhai',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget getGroupMemberWidgetMore(
      int userId, String username, String email, String nickname) {
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
                      //color: Colors.blueAccent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // “昵称：”
                          Container(
                            constraints: const BoxConstraints(
                              minHeight: 30,
                            ),
                            //  color: Colors.yellow,
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
                          Container(
                            constraints: const BoxConstraints(
                                minHeight: 30, minWidth: 20),
                            // color: Colors.red,
                            child: GestureDetector(
                              onTap: () {
                                print("修改昵称");
                                // Navigator.pushNamed(context, '/edit');
                                setState(() {
                                  isEditingNickname = !isEditingNickname;
                                });
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
                      //crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 昵称：______
                        Row(
                          children: [
                            const SizedBox(
                              height: 40,
                              child: Center(
                                child: Text(
                                  // "${count}.  ",
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
                              //color: Colors.greenAccent,
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 40,
                              child: Center(
                                child: TextFormField(
                                  controller: nicknameController,
                                  maxLength: 15,
                                  style: const TextStyle(
                                    fontFamily: 'BalooBhai',
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    border: UnderlineInputBorder(),
                                    counterText: "",
                                    hintText: nickname,
                                    hintStyle: const TextStyle(
                                      fontFamily: 'BalooBhai',
                                      fontSize: 18,
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

                                    nicknameController.text = "";
                                    /*  nicknameController.text =
                                                  nickname;
                                              editNickname = !editNickname; */
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
                                onTap: () {
                                  print("编辑监护人昵称");
                                  setState(() {
                                    isEditingNickname = !isEditingNickname;
                                    print("新昵称：${nicknameController.text}");

                                    widget.nickname = nicknameController.text;
                                    nicknameController.text = "";
                                    /* nickname =
                                                  nicknameController.text;
                                              print("新昵称：$nickname");
                                              editNickname = !editNickname; */
                                  });
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
                    onTap: () {
                      print("删除$userId");
                      // Navigator.pushNamed(context, '/edit');
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
                      print("查看数据详情$userId");
                      // Navigator.pushNamed(context, '/edit');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                              /* arguments: {
                        "bpDataId": 1,
                        "date": DateTime.now(),
                        "prevPage": 1,
                      }, */
                              ),
                        ),
                      ).then((_) {
                        print("哈哈哈");
                        //widget.updateData();
                      });
                    },
                    child: Container(
                      width: 120,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 183, 242, 255),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
        // flexibleSpace: header,
        // toolbarHeight: 45,
        flexibleSpace: getHeader(MediaQuery.of(context).size.width,
            (MediaQuery.of(context).size.height * 0.1 + 11)),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(shrinkWrap: true, children: [
          //
          const SizedBox(height: 20),

          // 昵称标题
          getNicknameTitle(),
          const SizedBox(height: 10),
          getGroupMemberWidgetMore(1, "admin使得房价快速了解2就进了进了2金额开零就2零",
              "beyzhex@gmail.com额废物废物废物34234323", widget.nickname),
          const SizedBox(height: 10),
          TodayActivities(),
        ]),
      ),
    );
  }
}
