import 'package:flutter/material.dart';
import '../component/navigation.dart';
import '../component/icons.dart';

class FoodsearchPage extends StatefulWidget {
  final String title;
  final String link;
  const FoodsearchPage({super.key, required this.title, required this.link});

  @override
  State<FoodsearchPage> createState() => _FoodsearchPageState();
}

class _FoodsearchPageState extends State<FoodsearchPage> {
  bool addedCollection = false;

  TableRow createTableRow(String left, String right) {
    return TableRow(children: [
      Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            left,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          )),
      Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            right,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
              fontFamily: 'BalooBhai',
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, widget.link);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 30,
            )),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 209, 252),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
        ),
      ),

      // 主体内容
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: screenWidth * 0.8,
            child: const Center(
                child: Text(
              "Food name",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  addedCollection = !addedCollection;
                });
              },
              icon: addedCollection ? MyIcons().starr() : MyIcons().star()),
          Container(
              height: screenHeight * 0.6,
              width: screenWidth * 0.85,
              padding: const EdgeInsets.all(15),
              child: Table(
                border: TableBorder.all(color: Colors.black),
                children: [
                  TableRow(
                      decoration: const BoxDecoration(color: Colors.black12),
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              "营养素",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2),
                            )),
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              "含量",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2),
                            )),
                      ]),
                  createTableRow("卡路里", "..."),
                  createTableRow("碳水化合物", "..."),
                  createTableRow("脂肪", "..."),
                  createTableRow("胆固醇", "..."),
                  createTableRow("蛋白质", "..."),
                  createTableRow("纤维素", "..."),
                  createTableRow("钠", "...")
                ],
              )),
          const SizedBox(height: 10),
        ],
      )),

      // 下方导航栏
      bottomNavigationBar: const MyNavigationBar(currentIndex: 1),
    );
  }
}
