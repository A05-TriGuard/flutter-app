import 'package:flutter/material.dart';

Widget header = Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      //colors: [Color(0xFFf7418c), Color(0xFFfbab66)],
      colors: [
        Color.fromARGB(255, 250, 209, 252),
        Color.fromARGB(255, 255, 255, 255)
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
);

Widget getHeader(double width, double height, {int? color = 0}) {
  return Column(
    children: [
      Container(
        width: width,
        height: height - 11,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color == 0
                  ? Color.fromARGB(255, 250, 209, 252)
                  : Color.fromARGB(255, 182, 234, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      //SizedBox(height: 10),
      Container(
        width: width,
        height: 9,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      const Divider(
        //height: 1, // 设置分割线的高度
        height: 1,
        color: Color.fromRGBO(169, 171, 179, 1), // 设置分割线的颜色
      ),
    ],
  );
}

PreferredSizeWidget getAppBar() {
  return AppBar(
    automaticallyImplyLeading: false,
    title: const Text(
      "TriGuard",
      style:
          TextStyle(fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 250, 209, 252),
            Color.fromARGB(255, 255, 255, 255),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(169, 171, 179, 1),
            width: 1,
          ),
        ),
      ),
    ),
  );
}
