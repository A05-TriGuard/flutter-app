import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:filter_list/filter_list.dart';

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
              color: colors[username.hashCode % colors.length],
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
                    username,
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

  Widget getActivityWidget() {
    return Column(
      children: [
        getActivity("08:00", "爸爸", "血压测量", true, false),
        getActivity("08:30", "妈妈", "血糖测量", false, false),
        getActivity("09:00", "爷爷", "血脂测量", false, false),
        getActivity("09:30", "奶奶", "血压测量", false, false),
        getActivity("10:00", "弟弟", "血糖测量", false, false),
        getActivity("10:30", "妈妈", "血脂测量", false, false),
        getActivity("11:00", "爷爷", "血压测量", false, false),
        getActivity("11:30", "弟弟", "血糖测量", false, false),
        getActivity("12:00", "爸爸", "血脂测量", false, false),
        getActivity("12:30", "妈妈", "血压测量", false, false),
        getActivity("13:00", "爷爷", "血糖测量", false, false),
        getActivity("13:30", "奶奶", "血脂测量", false, false),
        getActivity("14:00", "爸爸", "血压测量", false, false),
        getActivity("14:30", "姐姐", "血糖测量", false, false),
        getActivity("15:00", "爷爷", "血脂测量", false, false),
        getActivity("15:30", "奶奶", "血压测量", false, false),
        getActivity("16:00", "弟弟", "血糖测量", false, false),
        getActivity("16:30", "妈妈", "血脂测量", false, false),
        getActivity("17:00", "爷爷", "血压测量", false, true),
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
            title: "今日日记",
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

// ==============================================
// 此页面
class GuardianGroupPage extends StatefulWidget {
  const GuardianGroupPage({super.key});

  @override
  State<GuardianGroupPage> createState() => _GuardianGroupPageState();
}

class _GuardianGroupPageState extends State<GuardianGroupPage> {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  List<bool> isExpandedList = [false, false, false, false, false];
  List<User2> selectedUserList = [];
  bool isEditingNickname = false;
  bool isEditingGroupName = false;
  String groupName = "我们一家人";
  int memberCount = 5;

  Widget getGroupMemberWidgetLess(
      int userId, String username, String email, String nickname) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset("assets/icons/exercising.png", width: 20, height: 20),
        const SizedBox(width: 10),
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
                color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget getGroupMemberWidgetMore(
      int userId, String username, String email, String nickname) {
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
                          setState(() {
                            isEditingNickname = !isEditingNickname;
                          });
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
                        GestureDetector(
                          onTap: () {
                            print("编辑监护人昵称");
                            setState(() {
                              isEditingNickname = !isEditingNickname;
                              print("新昵称：${nicknameController.text}");
                              nickname = nicknameController.text;
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
                print("移出群组$userId");
                // Navigator.pushNamed(context, '/edit');
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

  Widget getGroupMemberWidget(
      int userId, String username, String email, String nickname) {
    return UnconstrainedBox(
      child: GestureDetector(
        onTap: () {
          print("点击");
          isExpandedList[userId] = !isExpandedList[userId];
          for (int i = 0; i < isExpandedList.length; i++) {
            if (i != userId) {
              isExpandedList[i] = false;
            }
          }
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: MediaQuery.of(context).size.width * 0.85,
          height: isExpandedList[userId] == false ? 55 : 160,
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
            child: isExpandedList[userId] == false
                ? getGroupMemberWidgetLess(userId, username, email, nickname)
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: getGroupMemberWidgetMore(
                      userId,
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

  // 选择要添加的成员
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

  Widget editingGroupNameWidget() {
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
                  border: UnderlineInputBorder(),
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
                  print("取消编辑群名");
                  setState(() {
                    isEditingGroupName = !isEditingGroupName;
                    groupNameController.text = groupName;
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

              // 确定
              GestureDetector(
                onTap: () {
                  print("编辑监护人昵称");
                  setState(() {
                    isEditingGroupName = !isEditingGroupName;
                    print("新群名：${groupNameController.text}");
                    groupName = groupNameController.text;
                    groupNameController.text = groupName;
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
    );
  }

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
            print("修改群组名");
            setState(() {
              isEditingGroupName = !isEditingGroupName;
            });
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

  @override
  Widget build(BuildContext context) {
    //print("rebuild");
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
            onTap: () {
              print("添加成员");
              //showOverlay(context);
              openFilterDelegate();
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
              print("删除成员");
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
        child: ListView(shrinkWrap: true, children: [
          //
          const SizedBox(height: 20),

          //editingGroupNameWidget(),
          //群组名
          isEditingGroupName == false
              ? groupNameHeader()
              : editingGroupNameWidget(),

          const SizedBox(
            height: 10,
          ),

          getGroupMemberWidget(
              0,
              "无敌暴龙兽卫计委来加了及4零2加来及4来4殴342",
              "haha@qq.com34543广东人当日哥哥哥热管424让他给",
              "爸爸fdssssssssssadasd啊是多久啊扣税的23很健康会发生卡"),
          getGroupMemberWidget(1, "哈哈哈哈哈哈哈", "wjd124@hotmail.com.cn", "妈妈"),
          getGroupMemberWidget(2, "admin124", "wjd124@hotmail.com.cn", "爷爷"),

          getGroupMemberWidget(3, "19429393239", "no@gmail.com", "奶奶"),
          getGroupMemberWidget(4, "testuser",
              "helloworld123@gmail.comoooooooooooooooooooo", "弟弟"),
          const SizedBox(
            height: 20,
          ),

          TodayActivities(),
        ]),
      ),
    );
  }
}
