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
