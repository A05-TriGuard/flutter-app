import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';
import '../component/mainPagesBar/mainPagesBar.dart';

class NutritionTarget extends StatefulWidget {
  const NutritionTarget({super.key});

  @override
  State<NutritionTarget> createState() => _NutritionTargetState();
}

class _NutritionTargetState extends State<NutritionTarget> {
  bool showSetting = false;
  String selectedRadio = "自定义";
  String selectedCondition = "几乎不动";
  List<String> bodyIndex = ["性别", "年龄", "身高", "体重"];
  List<String> category = ["卡路里", "碳水化合物", "脂肪", "胆固醇", "蛋白质", "纤维素", "钠"];
  final List<TextEditingController> inputController = [];
  List<double> factor = [1.2, 1.375, 1.55, 1.725, 1.9];
  var mealTarget = {};
  var toPostBodyIndex = {};
  var toPostMealTarget = <String, double>{};

  int exerciseCondition(String cond) {
    switch (cond) {
      case "几乎不动":
        return 0;
      case "稍微运动":
        return 1;
      case "中度运动":
        return 2;
      case "积极运动":
        return 3;
      case "专业运动":
        return 4;
      default:
        return 0;
    }
  }

  // Meal API
  void postBodyIndex() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map['sex'] = toPostBodyIndex["sex"];
      map['age'] = toPostBodyIndex["age"];
      map['height'] = toPostBodyIndex["height"];
      map['weight'] = toPostBodyIndex["weight"];
      map['level'] = toPostBodyIndex["level"];
      //FormData formData = FormData.fromMap(map);
      String jsonString = jsonEncode(map);

      final response = await dio.post(
        'http://43.138.75.58:8080/api/body-index/set',
        data: jsonString,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {}
    } catch (e) {/**/}
  }

  // Meal API
  void postMealTarget(bool useMap) async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      if (useMap) {
        map = toPostMealTarget;
      } else {
        map['calories'] = inputController[0].value.text;
        map['carbohydrates'] = int.parse(inputController[1].value.text);
        map['lipids'] = int.parse(inputController[2].value.text);
        map['cholesterol'] = int.parse(inputController[3].value.text);
        map['proteins'] = int.parse(inputController[4].value.text);
        map['fiber'] = int.parse(inputController[5].value.text);
        map['sodium'] = int.parse(inputController[6].value.text);
      }

      //FormData formData = FormData.fromMap(map);
      String jsonString = jsonEncode(map);

      final response = await dio.post(
        'http://43.138.75.58:8080/api/meal/set-goal',
        data: jsonString,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        getMealTarget();
      }
    } catch (e) {/**/}
  }

  // Meal API
  void getMealTarget() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/meal/get-goal',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          mealTarget = response.data["data"];
          showSetting = false;
        });
      } else {/**/}
    } catch (e) {/**/}
  }

  void calculateMealTarget() {
    double minCalorie;
    if (toPostBodyIndex["sex"] == "F") {
      minCalorie = 655 +
          (9.6 * toPostBodyIndex["weight"]) +
          (1.8 * toPostBodyIndex["height"]) -
          (4.7 * toPostBodyIndex["age"]);
    } else {
      minCalorie = 66 +
          (13.7 * toPostBodyIndex["weight"]) +
          (5 * toPostBodyIndex["height"]!) -
          (6.8 * toPostBodyIndex["age"]);
    }
    double neededCalorie = minCalorie * factor[toPostBodyIndex["level"]];
    toPostMealTarget["calories"] =
        double.parse(neededCalorie.toStringAsFixed(2));
    toPostMealTarget["carbohydrates"] =
        double.parse((neededCalorie * 0.55).toStringAsFixed(2));
    toPostMealTarget["lipids"] =
        double.parse((neededCalorie * 0.25).toStringAsFixed(2));
    toPostMealTarget["cholesterol"] = 150;
    toPostMealTarget["proteins"] =
        double.parse((toPostBodyIndex["weight"] * 1.2).toStringAsFixed(2));
    toPostMealTarget["fiber"] = 25.00;
    toPostMealTarget["sodium"] = 2.00;
    print(toPostMealTarget);
  }

  bool checkInput(int count) {
    for (int i = 0; i < count; ++i) {
      if (inputController[i].text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  TableRow createTableRow(String left, String right) {
    return TableRow(children: [
      Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            left,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          )),
      Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            right,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          )),
    ]);
  }

  Row createInputRow(String unit, int index, double width, bool isBodyIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: width * 0.35,
          child: Text(
            isBodyIndex ? bodyIndex[index] : category[index],
            style: const TextStyle(fontSize: 18),
          ),
        ),
        SizedBox(
          width: width * 0.35,
          child: TextField(
            keyboardType: (isBodyIndex && index == 0)
                ? TextInputType.text
                : const TextInputType.numberWithOptions(),
            inputFormatters: (isBodyIndex && index == 0)
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[FM]')),
                  ]
                : [FilteringTextInputFormatter.digitsOnly],
            controller: inputController[index],
            decoration: InputDecoration(hintText: unit),
            onTapOutside: (event) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    for (int i = 0; i < 7; ++i) {
      inputController.add(TextEditingController());
    }
    super.initState();
    getMealTarget();
  }

  @override
  void dispose() {
    for (var controller in inputController) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MainPages(
                    arguments: {"setToUserPage": true},
                  )),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "饮食目标",
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
                            arguments: {"setToUserPage": true},
                          )),
                );
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 30,
              )),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            "使用说明",
                            textAlign: TextAlign.center,
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                            offset: Offset(1, 1),
                                            color: Colors.black38,
                                            blurRadius: 2),
                                      ],
                                      borderRadius: BorderRadius.circular(15)),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text("1. 点击【日期按钮】=> 自定义目标日期。"),
                                      Text("2. 长按【分类按钮】=> 添加该时间段的进食记录。"),
                                      Text("3. 点击【分类按钮】=> 查看该时间段的进食记录。")
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
                icon: const Icon(
                  Icons.question_mark_rounded,
                  color: Colors.redAccent,
                  size: 25,
                ))
          ],
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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  "assets/icons/foodTarget.png",
                  height: 60,
                ),
                // 上面那栏
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          "当前目标",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Table(
                        border: TableBorder.all(color: Colors.black),
                        children: [
                          createTableRow(
                              "卡路里",
                              mealTarget["calories"] != null
                                  ? "${mealTarget["calories"]} (千卡)"
                                  : "..."),
                          createTableRow(
                              "碳水化合物",
                              mealTarget["carbohydrates"] != null
                                  ? "${mealTarget["carbohydrates"]} (克)"
                                  : "..."),
                          createTableRow(
                              "脂肪",
                              mealTarget["lipids"] != null
                                  ? "${mealTarget["lipids"]} (克)"
                                  : "..."),
                          createTableRow(
                              "胆固醇",
                              mealTarget["cholesterol"] != null
                                  ? "${mealTarget["cholesterol"]} (毫克)"
                                  : "..."),
                          createTableRow(
                              "蛋白质",
                              mealTarget["proteins"] != null
                                  ? "${mealTarget["proteins"]} (克)"
                                  : "..."),
                          createTableRow(
                              "纤维素",
                              mealTarget["fiber"] != null
                                  ? "${mealTarget["fiber"]} (克)"
                                  : "..."),
                          createTableRow(
                              "钠",
                              mealTarget["sodium"] != null
                                  ? "${mealTarget["sodium"]} (克)"
                                  : "...")
                        ],
                      ),
                      const SizedBox(height: 10)
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 目标设置栏
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            showSetting = !showSetting;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            const Center(
                                child: Text(
                              "目标设置",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )),
                            Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Icon(
                                  showSetting
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_right,
                                  size: 40),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: showSetting,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            RadioListTile(
                              title: const Text("自定义"),
                              value: "自定义",
                              groupValue: selectedRadio,
                              onChanged: (value) {
                                setState(() {
                                  selectedRadio = "自定义";
                                });
                              },
                            ),
                            RadioListTile(
                              title: const Text("自动推荐"),
                              value: "自动推荐",
                              groupValue: selectedRadio,
                              onChanged: (value) {
                                setState(() {
                                  selectedRadio = "自动推荐";
                                });
                              },
                            ),
                            // 自定义设置目标
                            Visibility(
                              visible: selectedRadio == "自定义",
                              child: Column(children: [
                                const SizedBox(height: 10),
                                createInputRow(
                                    "千卡", 0, screenWidth * 0.9, false),
                                createInputRow(
                                    "克", 1, screenWidth * 0.9, false),
                                createInputRow(
                                    "克", 2, screenWidth * 0.9, false),
                                createInputRow(
                                    "毫克", 3, screenWidth * 0.9, false),
                                createInputRow(
                                    "克", 4, screenWidth * 0.9, false),
                                createInputRow(
                                    "克", 5, screenWidth * 0.9, false),
                                createInputRow(
                                    "克", 6, screenWidth * 0.9, false),
                                const SizedBox(height: 20),
                                TextButton(
                                    onPressed: () {
                                      if (checkInput(7)) {
                                        postMealTarget(false);
                                      } else {
                                        showDialog(
                                            barrierColor: Colors.black87,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const AlertDialog(
                                                content: Text(
                                                  "请确保数据都已正确填写!",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            });
                                      }
                                    },
                                    child: const Text(
                                      "设置",
                                      style: TextStyle(fontSize: 18),
                                    ))
                              ]),
                            ),
                            // 自动推荐目标
                            Visibility(
                              visible: selectedRadio == "自动推荐",
                              child: Column(children: [
                                const SizedBox(height: 10),
                                createInputRow(
                                    "F / M", 0, screenWidth * 0.9, true),
                                createInputRow("", 1, screenWidth * 0.9, true),
                                createInputRow(
                                    "cm", 2, screenWidth * 0.9, true),
                                createInputRow(
                                    "kg", 3, screenWidth * 0.9, true),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: screenWidth * 0.9 * 0.35,
                                        child: const Text(
                                          "运动情况",
                                          style: TextStyle(fontSize: 18),
                                        )),
                                    SizedBox(
                                        width: screenWidth * 0.9 * 0.35,
                                        child: DropdownButton(
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          iconSize: 30,
                                          hint: Text(selectedCondition,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black)),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                          items: const [
                                            DropdownMenuItem(
                                                value: "几乎不动",
                                                child: Text("几乎不动")),
                                            DropdownMenuItem(
                                                value: "稍微运动",
                                                child: Text("稍微运动")),
                                            DropdownMenuItem(
                                                value: "中度运动",
                                                child: Text("中度运动")),
                                            DropdownMenuItem(
                                                value: "积极运动",
                                                child: Text("积极运动")),
                                            DropdownMenuItem(
                                                value: "专业运动",
                                                child: Text("专业运动")),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCondition = value!;
                                            });
                                          },
                                        ))
                                  ],
                                ),
                                const SizedBox(height: 20),
                                TextButton(
                                    onPressed: () {
                                      if (checkInput(4)) {
                                        toPostBodyIndex["sex"] =
                                            inputController[0].value.text;
                                        toPostBodyIndex["age"] = int.parse(
                                            inputController[1].value.text);
                                        toPostBodyIndex["height"] = int.parse(
                                            inputController[2].value.text);
                                        toPostBodyIndex["weight"] = int.parse(
                                            inputController[3].value.text);
                                        toPostBodyIndex["level"] =
                                            exerciseCondition(
                                                selectedCondition);
                                        calculateMealTarget();
                                        postBodyIndex();
                                        postMealTarget(true);
                                      } else {
                                        showDialog(
                                            barrierColor: Colors.black87,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const AlertDialog(
                                                content: Text(
                                                  "请确保数据都已正确填写!",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            });
                                      }
                                    },
                                    child: const Text(
                                      "设置",
                                      style: TextStyle(fontSize: 18),
                                    ))
                              ]),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
