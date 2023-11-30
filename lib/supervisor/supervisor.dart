import 'package:flutter/material.dart';
import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';
import './guardianPerson.dart';
import './guardianGroup.dart';

//import 'package:flutter_echarts/flutter_echarts.dart';

// 监护模式
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

// 被监护模式
class UnderGuardianshipWidget extends StatefulWidget {
  const UnderGuardianshipWidget({super.key});

  @override
  State<UnderGuardianshipWidget> createState() =>
      _UnderGuardianshipWidgetState();
}

class _UnderGuardianshipWidgetState extends State<UnderGuardianshipWidget> {
  Widget getGuardianWidget() {
    return Container(
      //color: Color.fromARGB(255, 236, 218, 218),
      width: MediaQuery.of(context).size.width * 0.85,
      height: 40,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "1. 妈妈",
              style: TextStyle(fontSize: 18, fontFamily: "BalooBhai"),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      // ignore: sized_box_for_whitespace
      child: Container(
        //color: Color.fromARGB(255, 236, 174, 174),
        width: MediaQuery.of(context).size.width * 0.85,
        height: 300,
        /* child: Center(
          child: Text("被监护模式"),
        ), */
        child: Column(
          children: [
            const PageTitle(
              title: "我的监护人",
              icons: "assets/icons/audience.png",
              fontSize: 18,
            ),
            // add
            getGuardianWidget(),
            getGuardianWidget(),
            getGuardianWidget(),
          ],
        ),
      ),
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
                      // Add your add button logic here
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
