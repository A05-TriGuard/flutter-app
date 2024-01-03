import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';
import '../component/icons.dart';
import '../articles/foodsearch.dart';
import '../articles/collection.dart';

class FoodsearchPage extends StatefulWidget {
  final String title;
  final int id;
  final VoidCallback updateHistory;
  const FoodsearchPage(
      {super.key,
      required this.title,
      required this.id,
      required this.updateHistory});

  @override
  State<FoodsearchPage> createState() => _FoodsearchPageState();
}

class _FoodsearchPageState extends State<FoodsearchPage> {
  bool addedCollection = false;
  Map foodInfo = {};

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

  // Food API
  void fetchNShowFoodInfo() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/food/info?id=${widget.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          foodInfo = response.data["data"];
          addedCollection = foodInfo["isFavorite"];
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  // Food API
  void addFoodToCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/food/favorites/add?foodId=${widget.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          addedCollection = true;
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  // Food API
  void removeFoodFromCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/food/favorites/delete?foodId=${widget.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          addedCollection = false;
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
    fetchNShowFoodInfo();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (widget.title == "返回查询页面") {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Foodsearch()))
              .then((value) {
            widget.updateHistory();
          });
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Collection(
                        selectedButton: [false, true, false, false],
                      ))).then((value) {
            widget.updateHistory();
          });
        }
      },
      child: Scaffold(
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
                if (widget.title == "返回查询页面") {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Foodsearch()))
                      .then((value) {
                    widget.updateHistory();
                  });
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Collection(
                                selectedButton: [false, true, false, false],
                              ))).then((value) {
                    widget.updateHistory();
                  });
                }
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: Center(
                      child: Text(
                    foodInfo["name"] ?? "",
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
                const SizedBox(height: 10),
                IconButton(
                    onPressed: () {
                      if (!addedCollection) {
                        addFoodToCollection();
                      } else {
                        removeFoodFromCollection();
                      }
                    },
                    icon:
                        addedCollection ? MyIcons().starr() : MyIcons().star()),
                const SizedBox(height: 20),
                Container(
                  height: screenHeight * 0.6,
                  width: screenWidth * 0.85,
                  padding: const EdgeInsets.all(15),
                  child: Table(
                    border: TableBorder.all(color: Colors.black),
                    children: [
                      TableRow(
                          decoration:
                              const BoxDecoration(color: Colors.black12),
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
                      createTableRow(
                          "卡路里",
                          foodInfo["calories"] != null
                              ? foodInfo["calories"].toString()
                              : "..."),
                      createTableRow(
                          "碳水化合物",
                          foodInfo["carbohydrates"] != null
                              ? foodInfo["carbohydrates"].toString()
                              : "..."),
                      createTableRow(
                          "脂肪",
                          foodInfo["lipids"] != null
                              ? foodInfo["lipids"].toString()
                              : "..."),
                      createTableRow(
                          "胆固醇",
                          foodInfo["cholesterol"] != null
                              ? foodInfo["cholesterol"].toString()
                              : "..."),
                      createTableRow(
                          "蛋白质",
                          foodInfo["proteins"] != null
                              ? foodInfo["proteins"].toString()
                              : "..."),
                      createTableRow(
                          "纤维素",
                          foodInfo["fiber"] != null
                              ? foodInfo["fiber"].toString()
                              : "..."),
                      createTableRow(
                          "钠",
                          foodInfo["sodium"] != null
                              ? foodInfo["sodium"].toString()
                              : "...")
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
