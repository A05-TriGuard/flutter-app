import 'package:flutter/material.dart';
import '../component/header/header.dart';
import '../component/titleDate/titleDate.dart';

class TodayStatisticsWidget extends StatefulWidget {
  const TodayStatisticsWidget({super.key});

  @override
  State<TodayStatisticsWidget> createState() => _TodayStatisticsWidgetState();
}

class _TodayStatisticsWidgetState extends State<TodayStatisticsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class GuardianPersonPage extends StatefulWidget {
  const GuardianPersonPage({super.key});

  @override
  State<GuardianPersonPage> createState() => _GuardianPersonPageState();
}

class _GuardianPersonPageState extends State<GuardianPersonPage> {
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
          //Padding(padding: padding)
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "妈妈",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'BalooBhai',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          const SizedBox(height: 10),
          UnconstrainedBox(
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
                          "昵称：妈妈",
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
                            print("删除");
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
                                    //fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        //查看数据详情
                        GestureDetector(
                          onTap: () {
                            print("查看数据详情");
                            // Navigator.pushNamed(context, '/edit');
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
                                    //fontWeight: FontWeight.bold,
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
          )
        ]),
      ),
    );
  }
}
