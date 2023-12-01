import 'package:flutter/material.dart';
import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';
import './guardianPerson.dart';
import './guardianGroup.dart';

//import 'package:flutter_echarts/flutter_echarts.dart';

// ====================监护===============================

// 监护页面
class GuardianWidget extends StatefulWidget {
  const GuardianWidget({super.key});

  @override
  State<GuardianWidget> createState() => _GuardianWidgetState();
}

class _GuardianWidgetState extends State<GuardianWidget> {
  List<bool> isExpandedList = List.generate(17, (index) => false);

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

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: [
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

      // add

      getGuardianGroupWidget(1),
      for (int i = 2; i <= 16; i++) getGuardianPersonWidget(i),

      const SizedBox(
        height: 30,
      ),
    ]);
  }
}

// ====================被监护============================

// 添加监护人
class AddGuardianWidget extends StatefulWidget {
  const AddGuardianWidget({super.key});

  @override
  State<AddGuardianWidget> createState() => _AddGuardianWidgetState();
}

class _AddGuardianWidgetState extends State<AddGuardianWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 被监护页面
class UnderGuardianshipWidget extends StatefulWidget {
  const UnderGuardianshipWidget({super.key});

  @override
  State<UnderGuardianshipWidget> createState() =>
      _UnderGuardianshipWidgetState();
}

class _UnderGuardianshipWidgetState extends State<UnderGuardianshipWidget> {
  List<bool> isExpandedList = List.generate(17, (index) => false);

  bool editNickname = false;

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

  Widget getGuardianWidget(
      int count, int accountId, String username, String nickname) {
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
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: MediaQuery.of(context).size.width * 0.85,
          height: isExpandedList[count] ? 80 : 50,
          constraints: BoxConstraints(
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
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: isExpandedList[count]
                //展开式
                ? SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 昵称与编辑昵称
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: editNickname == false
                              // 不编辑时
                              ? Row(
                                  children: [
                                    Text(
                                      "$count.   $nickname",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: "BalooBhai",
                                        //fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
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
                                        child: Image.asset(
                                          "assets/icons/pencil.png",
                                          width: 20,
                                          height: 20,
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
                                          "${count}.  ",
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

                        //
                        const SizedBox(
                          height: 5,
                        ),

                        // ID与删除
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: 30,
                                ),
                                width: MediaQuery.of(context).size.width * 0.62,
                                child: Text(
                                  "ID: $username",
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
                      Text(
                        "$count.   $nickname",
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: "BalooBhai",
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("重建？");
    return ListView(shrinkWrap: true, children: [
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

      // add
      for (int i = 1; i <= 16; i++)
        getGuardianWidget(i, i, "beyzhexuan@gmail.com", "妈妈"),

      const SizedBox(
        height: 30,
      ),
    ]);
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
  final PageController pageController = PageController(initialPage: 0);

  //late PageController pageController;

  @override
  void initState() {
    super.initState();
    //pageController = PageController(initialPage: 0);
    pageController.addListener(_onPageChanged);
    print("init");
  }

  void _onPageChanged() {
    setState(() {
      // Update the state when the page changes
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // 显示Overlay
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
            child: GestureDetector(
              onTap: () {
                // 点击Overlay时移除它
                overlayEntry?.remove();
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
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //const SizedBox(height: 10,),

                        //标题
                        const Text(
                          "邀请监护人",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "BalooBhai",
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // 输入ID
                        Row(
                          children: [
                            const Text(
                              "用户ID: ",
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
                              width: MediaQuery.of(context).size.width * 0.5,
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
                                      EdgeInsets.fromLTRB(10, 10, 15, 10),
                                  counterStyle:
                                      const TextStyle(color: Colors.black38),

                                  labelText: '用户名/邮箱',
                                  labelStyle: const TextStyle(
                                    color: Color.fromARGB(96, 104, 104, 104),
                                  ),
                                  //fillColor: Color.fromARGB(190, 255, 255, 255),
                                  fillColor: Color.fromARGB(187, 250, 250, 250),
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

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    /* if (pageController.page == 0) {
      pageController
          .nextPage(
              duration: const Duration(milliseconds: 40), curve: Curves.easeIn)
          .whenComplete(() => pageController.previousPage(
              duration: const Duration(milliseconds: 1), curve: Curves.easeIn));
    } else {
      pageController
          .previousPage(
              duration: const Duration(milliseconds: 40), curve: Curves.easeIn)
          .whenComplete(() => pageController.nextPage(
              duration: const Duration(milliseconds: 1), curve: Curves.easeIn));
    } */

    return PopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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

          automaticallyImplyLeading: false,
          actions: [
            // Use a Builder to get the Scaffold context in order to show SnackBars
            Builder(
              builder: (context) {
                //pageController.page ??= 0;
                if (pageController.page == 0) {
                  return IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      print("通知");
                      // Add your notification button logic here
                    },
                  );
                } else if (pageController.page == 1) {
                  return IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      print("添加监护人");

                      showOverlay(context);
                    },
                  );
                } else {
                  // return SizedBox.shrink();
                  return IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      print("通知");
                      // Add your notification button logic here
                    },
                  );
                }
              },
            ),
          ],
        ),
        body: PageView(
          controller: pageController,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            //GuardianWidget(),
            //ListView
            Container(
              color: Colors.white,
              child: GuardianWidget(),
            ),
            UnderGuardianshipWidget(),
          ],
        ),
      ),
    );
  }
}
