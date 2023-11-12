import 'package:flutter/material.dart';
import '../component/header/header.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

class Article extends StatefulWidget {
  const Article({super.key});

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
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
        //toolbarHeight: MediaQuery.of(context).size.height * 0.1 + 11,

        flexibleSpace: getHeader(MediaQuery.of(context).size.width,
            (MediaQuery.of(context).size.height * 0.1 + 11)),
      ),
      body: const Center(
        child: Text("文章/资讯"),
      ),
    );
  }
}
