import 'package:flutter/material.dart';
import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

class GuardianWidget extends StatefulWidget {
  const GuardianWidget({super.key});

  @override
  State<GuardianWidget> createState() => _GuardianWidgetState();
}

class _GuardianWidgetState extends State<GuardianWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("监护模式"),
    );
  }
}

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
      child: Container(
        //color: Color.fromARGB(255, 236, 174, 174),
        width: MediaQuery.of(context).size.width * 0.85,
        height: 300,
        /* child: Center(
          child: Text("被监护模式"),
        ), */
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PageTitle(
                  title: "我的监护人",
                  icons: "assets/icons/audience.png",
                  fontSize: 18,
                ),
                // add
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    print("添加监护人");
                  },
                ),
              ],
            ),
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
        ),
        body: PageView(
          controller: pageController,
          scrollDirection: Axis.horizontal,
          children: const <Widget>[
            GuardianWidget(),
            UnderGuardianshipWidget(),
          ],
        ),
      ),
    );
  }
}
