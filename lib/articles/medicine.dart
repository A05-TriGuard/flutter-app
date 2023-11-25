import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../component/icons.dart';
import 'medicinepage.dart';

class Medicine extends StatefulWidget {
  const Medicine({super.key});

  @override
  State<Medicine> createState() => _MedicineState();
}

class _MedicineState extends State<Medicine> {
  final inputController = TextEditingController();
  bool showResult = false;
  int _currentIndex = 0;
  var resultCardList = <ResultCard>[];
  var historyCardList = <ResultCard>[];
  var historyList = [];
  var resultList = [];
  var token =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiYWRtaW4iLCJpZCI6MywiZXhwIjoxNzAxMDg2MTM1LCJpYXQiOjE3MDA4MjY5MzUsImp0aSI6IjkyYzBlOGNlLTBlNDMtNDBmNC05MmFjLWUwNmFmNDgwZDdjNyIsImF1dGhvcml0aWVzIjpbIlJPTEVfdXNlciJdfQ.vyD6DuOBUWDIiEoHh5IuY8Ri5Pmu5Qi-DjHp3hD8yVU';

  void createCardList() {
    if (resultList.isNotEmpty) {
      for (int i = 0; i < resultList.length; ++i) {
        resultCardList.add(ResultCard(
          result: resultList[i],
          isResult: true,
        ));
      }
    } else {
      resultCardList.add(
          const ResultCard(result: {"name": "目前没有找到相关搜索结果"}, isResult: false));
    }
  }

  void createHistoryList() {
    if (historyList.isNotEmpty) {
      for (int i = 0; i < historyList.length; ++i) {
        historyCardList.add(ResultCard(
          result: historyList[i],
          isResult: true,
        ));
      }
    } else {
      historyCardList.add(
          const ResultCard(result: {"name": "暂时没有任何搜索记录"}, isResult: false));
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
          'http://43.138.75.58:8080/api/medicine/search-history',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          historyList = response.data["data"];
          showResult = false;
          //print(historyList);
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    resultCardList.clear();
    createCardList();
    historyCardList.clear();
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
                  //fetchNShowHistoryResult();
                  showResult = false;
                },
                onTapOutside: (event) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  //fetchNShowHistoryResult();
                  showResult = false;
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
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: showResult ? resultCardList : historyCardList),
                ),
              ],
            ),
          ],
        ),
      ),

      // 下方导航栏
      bottomNavigationBar: BottomNavigationBar(
        //被点击时
        // if index == 0, when press the icon, change the icon "home.png" to "home_.png"

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        currentIndex: _currentIndex, //被选中的
        // https://blog.csdn.net/yechaoa/article/details/89852488
        type: BottomNavigationBarType.fixed,
        // iconSize: 24,
        fixedColor: Colors.black, //被选中时的颜色
        selectedFontSize: 12, // Set the font size for selected label
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
              //https://blog.csdn.net/qq_27494241/article/details/107167585?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-107167585-blog-85248876.235^v38^pc_relevant_default_base3&spm=1001.2101.3001.4242.2&utm_relevant_index=4
              // https://stackoverflow.com/questions/60151052/can-i-add-spacing-around-an-icon-in-flutter-bottom-navigation-bar
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 0
                      ? MyIcons().home_()
                      : MyIcons().home()),
              label: "首页"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 1
                      ? MyIcons().article_()
                      : MyIcons().article()),
              label: "文章"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 2
                      ? MyIcons().supervisor_()
                      : MyIcons().supervisor()),
              label: "监护"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 3
                      ? MyIcons().moment_()
                      : MyIcons().moment()),
              label: "动态"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 4
                      ? MyIcons().user_()
                      : MyIcons().user()),
              label: "我的"),
        ],
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
