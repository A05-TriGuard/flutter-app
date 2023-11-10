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

Widget getHeader(double width, double height) {
  return Column(
    children: [
      Container(
        width: width,
        height: height - 11,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 209, 252),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      SizedBox(height: 10),
      const Divider(
        //height: 1, // 设置分割线的高度
        height: 1,
        color: Color.fromRGBO(169, 171, 179, 1), // 设置分割线的颜色
      ),
    ],
  );
}
