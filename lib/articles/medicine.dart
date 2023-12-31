import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'medicinepage.dart';
import '../account/token.dart';
import '../component/mainPagesBar/mainPagesBar.dart';

class Medicine extends StatefulWidget {
  const Medicine({super.key});

  @override
  State<Medicine> createState() => _MedicineState();
}

class _MedicineState extends State<Medicine> {
  final inputController = TextEditingController();
  bool showResult = false;
  var resultCardList = <ResultCard>[];
  var historyCardList = <ResultCard>[];
  var historyList = [];
  var resultList = [];

  void createCardList() {
    resultCardList.clear();
    if (resultList.isNotEmpty) {
      for (int i = 0; i < resultList.length; ++i) {
        resultCardList.add(ResultCard(
          result: resultList[i],
          isResult: true,
          updateHistory: fetchNShowHistoryResult,
        ));
      }
    } else {
      resultCardList.add(ResultCard(
        result: const {"name": "目前没有找到相关搜索结果", "id": -1},
        isResult: false,
        updateHistory: fetchNShowHistoryResult,
      ));
    }
  }

  void createHistoryList() {
    historyCardList.clear();
    if (historyList.isNotEmpty) {
      for (int i = 0; i < historyList.length; ++i) {
        historyCardList.add(ResultCard(
          result: historyList[i],
          isResult: true,
          updateHistory: fetchNShowHistoryResult,
        ));
      }
    }
  }

  // Medicine API
  void fetchNShowSearchResult(String inputMed) async {
    resultList.clear();

    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/medicine/search?keyword=$inputMed',
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

  // Medicine API
  void fetchNShowHistoryResult() async {
    historyList.clear();

    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/medicine/info-history',
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

  @override
  void initState() {
    super.initState();
    fetchNShowHistoryResult();
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    createCardList();
    createHistoryList();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MainPages(
                    arguments: {"setToArticlePage": true},
                  )),
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(
          title: const Text(
            "用药指南",
            style: TextStyle(
                fontFamily: 'BalooBhai',
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.w900),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainPages(
                              arguments: {"setToArticlePage": true},
                            )));
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
              ),
              border: Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(169, 171, 179, 1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),

        // 主体内容
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // 图标
                Image.asset("assets/icons/medicalRecord.png",
                    width: screenWidth * 0.4),
                const SizedBox(height: 20),
                // 标题
                const Text(
                  "用药指南查询",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 20),
                // 药品搜索框
                SizedBox(
                  width: screenWidth * 0.8,
                  child: TextField(
                    style: const TextStyle(fontSize: 22),
                    onTap: () {
                      fetchNShowHistoryResult();
                    },
                    onTapOutside: (event) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    controller: inputController,
                    decoration: InputDecoration(
                        hintText: "输入药品名称",
                        hintStyle: const TextStyle(
                            color: Colors.black26, fontWeight: FontWeight.w800),
                        contentPadding: const EdgeInsets.only(left: 20),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.5),
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 250, 209, 252),
                                width: 2)),
                        suffixIcon: IconButton(
                          onPressed: () {
                            fetchNShowSearchResult(inputController.text);
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          icon: Image.asset("assets/icons/searchWhite.png",
                              width: 20),
                          padding: const EdgeInsets.only(right: 10),
                        )),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 20),
                // 结果列表
                Column(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: Text(
                        showResult ? "相关搜索结果为：" : "历史查询记录：",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.45,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: showResult
                              ? resultCardList.length
                              : historyCardList.length,
                          itemBuilder: (BuildContext context, index) {
                            return showResult
                                ? resultCardList[index]
                                : historyCardList[index];
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final Map result;
  final bool isResult;
  final VoidCallback updateHistory;
  const ResultCard(
      {super.key,
      required this.result,
      required this.isResult,
      required this.updateHistory});

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        elevation: 5,
        child: InkWell(
          onTap: isResult
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MedicinePage(
                              title: "返回查询页面",
                              id: result["id"],
                              updateHistory: updateHistory,
                            )),
                  );
                }
              : null,
          child: ListTile(
              tileColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0))),
              minVerticalPadding: 15,
              title: Text(
                result["name"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20),
              ),
              visualDensity: const VisualDensity(vertical: -4)),
        ));
  }
}
