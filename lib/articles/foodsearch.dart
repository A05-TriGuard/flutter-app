import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'foodsearchpage.dart';
import '../account/token.dart';

class Foodsearch extends StatefulWidget {
  const Foodsearch({super.key});

  @override
  State<Foodsearch> createState() => _FoodsearchState();
}

class _FoodsearchState extends State<Foodsearch> {
  final inputController = TextEditingController();
  bool showResult = false;
  var resultCardList = <ResultCard>[];
  var historyCardList = <ResultCard>[];
  var resultList = [];
  var historyList = [];

  // Food API
  void fetchNShowSearchResult(String inputMed) async {
    resultList.clear();

    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/food/search?keyword=$inputMed',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          showResult = true;
          resultList = response.data["data"];
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  // Food API
  void fetchNShowHistoryResult() async {
    historyList.clear();

    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/food/info-history',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          historyList = response.data["data"];
          showResult = false;
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  void createCardList() {
    resultCardList.clear();
    if (resultList.isNotEmpty) {
      for (int i = 0; i < resultList.length; ++i) {
        resultCardList.add(ResultCard(
          result: resultList[i],
          isResult: true,
        ));
      }
    } else {
      resultCardList.add(const ResultCard(
          result: {"name": "目前没有找到相关搜索结果", "id": -1}, isResult: false));
    }
  }

  void createHistoryList() {
    historyCardList.clear();
    if (historyList.isNotEmpty) {
      for (int i = 0; i < historyList.length; ++i) {
        historyCardList.add(ResultCard(
          result: historyList[i],
          isResult: true,
        ));
      }
    } else {
      historyCardList.add(const ResultCard(
          result: {"name": "暂时没有任何搜索记录", "id": -1}, isResult: false));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNShowHistoryResult();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    createCardList();
    createHistoryList();

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
              Navigator.pop(context);
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
              "食物成分查询",
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            SizedBox(
              width: screenWidth * 0.8,
              child: TextField(
                style: const TextStyle(fontSize: 22),
                onTap: () {
                  setState(() {
                    fetchNShowHistoryResult();
                  });
                },
                onTapOutside: (event) {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                controller: inputController,
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
                          fetchNShowSearchResult(inputController.text);
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                      },
                      icon: Image.asset("assets/icons/searchWhite.png",
                          width: 20),
                      padding: const EdgeInsets.only(right: 10),
                    )),
                textAlign: TextAlign.left,
              ),
            ),
            Column(
              children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: Text(
                        showResult ? "相关搜索结果为：" : "历史查询记录：",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          fetchNShowHistoryResult();
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.black26,
                        )),
                  ],
                ),
                SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.35,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: showResult
                            ? resultCardList.length
                            : historyCardList.length,
                        itemBuilder: (BuildContext context, index) {
                          return showResult
                              ? resultCardList[index]
                              : historyCardList[index];
                        })),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final Map result;
  final bool isResult;
  const ResultCard({super.key, required this.result, required this.isResult});

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        shadowColor: Colors.black87,
        elevation: 5,
        child: InkWell(
          onTap: isResult
              ? () {
                  //Navigator.pushNamed(context, '/articles/medicine/page');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoodsearchPage(
                              title: "返回查询页面", id: result["id"])));
                }
              : null,
          child: ListTile(
              minVerticalPadding: 15,
              title: Text(
                result["name"],
                maxLines: 1,
                style: const TextStyle(fontSize: 20),
              ),
              visualDensity: const VisualDensity(vertical: -4)),
        ));
  }
}
