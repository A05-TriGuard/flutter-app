import 'package:flutter/material.dart';
import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';

class GuardianGroupPage extends StatefulWidget {
  const GuardianGroupPage({super.key});

  @override
  State<GuardianGroupPage> createState() => _GuardianGroupPageState();
}

class _GuardianGroupPageState extends State<GuardianGroupPage> {
  List<bool> isExpandedList = [false, false, false, false, false];

  Widget getGroupMemberWidget() {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        //height: 250,
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 头像+昵称+修改昵称
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "昵称：爸爸",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'BalooBhai',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  // Edit

                  GestureDetector(
                    onTap: () {
                      print("修改昵称");
                      // Navigator.pushNamed(context, '/edit');
                    },
                    child: Container(
                      width: 25,
                      height: 25,
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              //
              const SizedBox(height: 10),

              // ID
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "ID: ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'BalooBhai',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    " 19249384380",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'BalooBhai',
                        fontSize: 18,
                        //fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),

              //
              const SizedBox(height: 10),

              // 删除按钮
              // 靠右

              GestureDetector(
                onTap: () {
                  print("删除");
                  // Navigator.pushNamed(context, '/edit');
                },
                child: Container(
                  width: 80,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 183, 183),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: const Color.fromRGBO(0, 0, 0, 0.2),
                    ),
                  ),
                  child: const Center(
                    child: Text("删除",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'BalooBhai',
                            fontSize: 16,
                            //fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getGroupMemberWidgetLess(int id) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset("assets/icons/exercising.png", width: 20, height: 20),
        const SizedBox(width: 10),
        Text(
          "爸爸",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'BalooBhai',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
      ],
    );
  }

  Widget getGroupMemberWidgetMore(int id) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像+昵称+修改昵称
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "昵称：爸爸",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'BalooBhai',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            // Edit

            GestureDetector(
              onTap: () {
                print("修改昵称");
                // Navigator.pushNamed(context, '/edit');
              },
              child: Container(
                width: 25,
                height: 25,
                child: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),

        //
        const SizedBox(height: 10),

        // ID
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "ID: ",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'BalooBhai',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              " 19249384380",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'BalooBhai',
                  fontSize: 18,
                  //fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),

        //
        const SizedBox(height: 10),

        // 删除按钮
        // 靠右

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //删除
            GestureDetector(
              onTap: () {
                print("移出群组$id");
                // Navigator.pushNamed(context, '/edit');
              },
              child: Container(
                width: 80,
                height: 30,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 124, 124),
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
                print("查看数据详情$id");
                // Navigator.pushNamed(context, '/edit');
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

  Widget getGroupMemberWidget2(int id) {
    return UnconstrainedBox(
        child: GestureDetector(
      onTap: () {
        print("点击");
        isExpandedList[id] = !isExpandedList[id];
        for (int i = 0; i < isExpandedList.length; i++) {
          if (i != id) {
            isExpandedList[i] = false;
          }
        }
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width * 0.85,
        height: isExpandedList[id] == false ? 55 : 140,
        decoration: BoxDecoration(
          color: isExpandedList[id] == false
              ? Color.fromARGB(255, 255, 255, 255)
              : Color.fromARGB(137, 200, 184, 250),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: const Border(
            //bottom
            bottom: BorderSide(
              color: Color.fromRGBO(0, 0, 0, 0.2),
            ),
            //color: const Color.fromRGBO(0, 0, 0, 0.2),
          ),
          /* boxShadow: [
            BoxShadow(
              color: Color.fromARGB(120, 151, 151, 151),
              offset: Offset(0, 5),
              blurRadius: 5.0,
              spreadRadius: 0.0,
            ),
          ], */
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: isExpandedList[id] == false
              ? getGroupMemberWidgetLess(id)
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: getGroupMemberWidgetMore(id),
                ),
        ),
      ),
    ));
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
        // white background
        color: Colors.white,
        child: ListView(shrinkWrap: true, children: [
          //
          const SizedBox(height: 20),
          //标题
          /* const Center(
            child: Text("监护群组",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'BalooBhai',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),

          const Center(
            child: PageTitle(
              title: "监护群组",
              icons: "assets/icons/group.png",
              fontSize: 22,
            ),
          ),
          //
          const SizedBox(height: 10), */

          //群组名
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PageTitle(
                title: "我们一家人 (5)",
                icons: "assets/icons/group.png",
                fontSize: 22,
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          //监护群组名
          /* Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.15 * 0.5,
                0,
                MediaQuery.of(context).size.width * 0.15 * 0.5,
                0),
            child: const PageTitle(
              title: "我们一家人 (5)",
              icons: "assets/icons/audience.png",
              fontSize: 18,
            ),
          ), */
          //

          getGroupMemberWidget2(0),
          getGroupMemberWidget2(1),
          getGroupMemberWidget2(2),

          getGroupMemberWidget2(3),
          getGroupMemberWidget2(4),
        ]),
      ),
    );
  }
}
