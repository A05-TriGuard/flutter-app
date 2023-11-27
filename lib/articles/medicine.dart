import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../component/navigation.dart';
import 'medicinepage.dart';

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
  var token =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiYWRtaW4iLCJpZCI6MywiZXhwIjoxNzAxMzUwNDMyLCJpYXQiOjE3MDEwOTEyMzIsImp0aSI6IjU0YmY3YWY3LWI3ZDMtNDcxMC1hMzhhLTY3ZDE1ZmM4MTQ1YyIsImF1dGhvcml0aWVzIjpbIlJPTEVfdXNlciJdfQ.E6b_y9olNKiKJAsxWuOhgM0y4ifWZT2taQ9CQJD4SH4';

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

  // Medicine API
  void fetchNShowSearchResult(String inputMed) async {
    resultList.clear();

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

    createCardList();
    createHistoryList();

    return Scaffold(
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
            Image.asset("assets/icons/medicalRecord.png",
                width: screenWidth * 0.4),
            const Text(
              "用药指南查询",
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            SizedBox(
              width: screenWidth * 0.8,
              child: TextField(
                style: const TextStyle(fontSize: 22),
                onTap: () {
                  fetchNShowHistoryResult();
                },
                onTapOutside: (event) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  //fetchNShowHistoryResult();
                },
                controller: inputController,
                decoration: InputDecoration(
                    hintText: "输入药品名称",
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
            Column(
              children: [
                Text(
                  showResult ? "相关搜索结果为：" : "历史查询记录：",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.6,
                    // child: ListView(
                    //     scrollDirection: Axis.vertical,
                    //     shrinkWrap: true,
                    //     children: showResult ? resultCardList : historyCardList),
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
            ),
          ],
        ),
      ),

      // 下方导航栏
      bottomNavigationBar: const MyNavigationBar(currentIndex: 1),
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
                          builder: (context) => MedicinePage(
                              title: "返回查询页面",
                              link: '/articles/medicine',
                              id: result["id"])));
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

// class ResultCard extends StatefulWidget {
//   late Map result;
//   late bool isResult;
//   ResultCard({super.key, required this.result, required this.isResult});

//   @override
//   State<ResultCard> createState() => _ResultCardState();
// }

// class _ResultCardState extends State<ResultCard> {
//   @override
//   Widget build(BuildContext context) {
//     print("in card:" + widget.result["name"]);
//     return Card(
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(0))),
//         shadowColor: Colors.black87,
//         elevation: 5,
//         child: InkWell(
//           onTap: widget.isResult
//               ? () {
//                   //Navigator.pushNamed(context, '/articles/medicine/page');
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => MedicinePage(
//                               title: "返回查询页面",
//                               link: '/articles/medicine',
//                               id: widget.result["id"])));
//                 }
//               : null,
//           child: ListTile(
//               minVerticalPadding: 15,
//               title: Text(
//                 widget.result["name"],
//                 maxLines: 1,
//                 style: const TextStyle(fontSize: 20),
//               ),
//               visualDensity: const VisualDensity(vertical: -4)),
//         ));
//   }
// }
