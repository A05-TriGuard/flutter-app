import 'package:flutter/material.dart';
//import '../component/mainPagesBar/mainPagesBar.dart';
import '../component/header/header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /* leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ), */
        title: const Text(
          "TriGuard",
          style: TextStyle(
              fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
        ),
        /* actions: [
            IconButton(
              icon: Icon(
                Icons.search,
              ),
              onPressed: () {
                print("搜索");
              },
              color: Colors.black,
            )
          ], */
        flexibleSpace: header,
        toolbarHeight: 45,
      ),
      body: const Center(
        child: Text("首页"),
      ),
      // bottomNavigationBar: footer(),
    );
  }
}
