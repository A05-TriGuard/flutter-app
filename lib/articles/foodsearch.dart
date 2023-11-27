import 'package:flutter/material.dart';
import '../component/navigation.dart';

class Foodsearch extends StatefulWidget {
  const Foodsearch({super.key});

  @override
  State<Foodsearch> createState() => _FoodsearchState();
}

class _FoodsearchState extends State<Foodsearch> {
  bool showResult = false;
  var resultCardList = <ResultCard>[];
  var resultList = <String>[
    "first result",
    "second result",
    "third result",
    "forth result",
    "fifth result",
    "sixth result",
    "seventh result"
  ];

  void createCardList() {
    for (int i = 0; i < resultList.length; ++i) {
      resultCardList.add(ResultCard(result: resultList[i]));
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    resultCardList.clear();
    createCardList();

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: const Text(
          "食物成分",
          style: TextStyle(
              fontFamily: 'BalooBhai',
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/articles');
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
            Image.asset("assets/icons/diet.png", width: screenWidth * 0.4),
            const Text(
              "食物营养成分查询",
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            SizedBox(
              width: screenWidth * 0.8,
              child: TextField(
                style: const TextStyle(fontSize: 22),
                onTap: () {
                  setState(() {
                    showResult = false;
                  });
                },
                decoration: InputDecoration(
                    hintText: "输入食物名称",
                    hintStyle: const TextStyle(
                        color: Colors.black26, fontWeight: FontWeight.w800),
                    contentPadding: const EdgeInsets.only(left: 20),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(35)),
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 250, 209, 252),
                            width: 2)),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showResult = true;
                        });
                      },
                      icon: Image.asset("assets/icons/searchWhite.png",
                          width: 20),
                      padding: const EdgeInsets.only(right: 10),
                    )),
                textAlign: TextAlign.left,
              ),
            ),
            Visibility(
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              visible: showResult,
              child: Column(
                children: [
                  const Text(
                    "相关搜索结果为：",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.6,
                    child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: resultCardList),
                  ),
                ],
              ),
            )
          ],
        ),
      ),

      // 下方导航栏
      bottomNavigationBar: const MyNavigationBar(currentIndex: 1),
    );
  }
}

class ResultCard extends StatelessWidget {
  final String result;
  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        shadowColor: Colors.black87,
        elevation: 5,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/articles/foodsearch/page');
          },
          child: ListTile(
              minVerticalPadding: 15,
              title: Text(
                result,
                maxLines: 1,
                style: const TextStyle(fontSize: 20),
              ),
              visualDensity: const VisualDensity(vertical: -4)),
        ));
  }
}
