import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';
import '../component/icons.dart';
import 'dart:convert';

class FoodInfo {
  final String name;
  final int weight;
  final int calorie;
  final int id;
  FoodInfo(
      {required this.name,
      required this.weight,
      required this.calorie,
      required this.id});
}

class FoodDiary extends StatefulWidget {
  final Map arguments;
  const FoodDiary({required this.arguments, super.key});

  @override
  State<FoodDiary> createState() => _FoodDiaryState();
}

class _FoodDiaryState extends State<FoodDiary> {
  var haveRecord = <bool>[false, false, false, false];
  var breakfastRecord = <FoodInfo>[];
  var lunchRecord = <FoodInfo>[];
  var dinnerRecord = <FoodInfo>[];
  var otherRecord = <FoodInfo>[];
  var breakfastRowList = <FoodRow>[];
  var lunchRowList = <FoodRow>[];
  var dinnerRowList = <FoodRow>[];
  var otherRowList = <FoodRow>[];
  var classSelected = <bool>[true, false, false, false, false];
  int curSelected = 0;
  var nutritionName = <String>["卡路里", "碳水化合物", "胆固醇", "纤维素", "蛋白质", "脂肪", "钠"];
  var indToNut = [
    "calories",
    "carbohydrates",
    "cholesterol",
    "fiber",
    "proteins",
    "lipids",
    "sodium"
  ];
  var nutritionCur = <double>[414, 57.5, 648, 2, 19.4, 12.2, 195.5];
  var nutritionUni = <String>["千卡", "克", "毫克", "克", "克", "克", "克"];
  DateTime selectedDate = DateTime.now();
  var weekDay = ["", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"];
  bool expandNutrition = false;
  var mealTarget = {};
  var mealCur = {};
  var mealList = [];
  var allMealInfo = {};
  var specificMealInfo = {};
  var dataFilter = ["全部", "早餐", "午餐", "晚餐", "其他"];
  final foodNameInputController = TextEditingController();
  final foodWeightInputController = TextEditingController();
  bool loadTarget = false;
  bool hasTarget = false;

  // Meal API
  void postMeal(String category) async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map["accountId"] = widget.arguments["accountId"];
      map['date'] = getFormattedDate(selectedDate);
      map['category'] = category;
      map['food'] = foodNameInputController.value.text;
      map['weight'] = int.parse(foodWeightInputController.value.text);
      String jsonString = jsonEncode(map);

      final response = await dio.post(
        'http://43.138.75.58:8080/api/meal/create',
        data: jsonString,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        getAllMealInfo();
        getSpecificMealInfo();
        foodNameInputController.clear();
        foodWeightInputController.clear();
      } else {
        print(response);
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
          widget.arguments["isOwner"]
              ? 'http://43.138.75.58:8080/api/meal/get-goal'
              : 'http://43.138.75.58:8080/api/meal/get-goal?accountId=${widget.arguments["accountId"]}',
          //queryParameters: queryParams,
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        if (response.data["data"] == null) {
          setState(() {
            loadTarget = true;
            mealTarget = {
              "calories": 0,
              "carbohydrates": 0,
              "lipids": 0,
              "cholesterol": 0,
              "proteins": 0,
              "fiber": 0,
              "sodium": 0
            };
          });
        } else {
          setState(() {
            loadTarget = true;
            hasTarget = true;
            mealTarget = response.data["data"];
          });
        }
      } else {
        mealTarget = {
          "calories": 0,
          "carbohydrates": 0,
          "lipids": 0,
          "cholesterol": 0,
          "proteins": 0,
          "fiber": 0,
          "sodium": 0
        };
      }
    } catch (e) {/**/}
  }

  // Meal API
  void getAllMealInfo() async {
    var token = await storage.read(key: 'token');
    var curDate = getFormattedDate(selectedDate);

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          widget.arguments["isOwner"]
              ? 'http://43.138.75.58:8080/api/meal/get?date=$curDate&category=全部'
              : 'http://43.138.75.58:8080/api/meal/get?date=$curDate&category=全部&accountId=${widget.arguments["accountId"]}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          allMealInfo = response.data["data"];
        });
      } else {
        allMealInfo = {
          "mealList": [],
          "calories": 0,
          "carbohydrates": 0,
          "lipids": 0,
          "cholesterol": 0,
          "proteins": 0,
          "fiber": 0,
          "sodium": 0
        };
      }
    } catch (e) {/**/}
  }

  // Meal API
  void getSpecificMealInfo() async {
    var token = await storage.read(key: 'token');
    var curDate = getFormattedDate(selectedDate);

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          widget.arguments["isOwner"]
              ? 'http://43.138.75.58:8080/api/meal/get?date=$curDate&category=${dataFilter[curSelected]}'
              : 'http://43.138.75.58:8080/api/meal/get?date=$curDate&category=${dataFilter[curSelected]}&accountId=${widget.arguments["accountId"]}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          specificMealInfo = response.data["data"];
        });
      } else {
        specificMealInfo = {
          "mealList": [],
          "calories": 0,
          "carbohydrates": 0,
          "lipids": 0,
          "cholesterol": 0,
          "proteins": 0,
          "fiber": 0,
          "sodium": 0
        };
      }
    } catch (e) {/**/}
  }

  void preset() {
    mealList = allMealInfo["mealList"] ?? [];
    mealCur["carbohydrates"] = specificMealInfo["carbohydrates"];
    mealCur["calories"] = specificMealInfo["calories"];
    mealCur["lipids"] = specificMealInfo["lipids"];
    mealCur["cholesterol"] = specificMealInfo["cholesterol"];
    mealCur["proteins"] = specificMealInfo["proteins"];
    mealCur["fiber"] = specificMealInfo["fiber"];
    mealCur["sodium"] = specificMealInfo["sodium"];
  }

  void classifyMeal() {
    breakfastRecord.clear();
    lunchRecord.clear();
    dinnerRecord.clear();
    otherRecord.clear();

    int len = mealList.length;
    for (int i = 0; i < len; ++i) {
      var curMeal = mealList[i];
      FoodInfo curFoodInfo = FoodInfo(
          name: curMeal["food"],
          weight: curMeal["weight"],
          calorie: curMeal["calories"],
          id: curMeal["id"]);

      switch (curMeal["category"]) {
        case "早餐":
          breakfastRecord.add(curFoodInfo);
          break;

        case "午餐":
          lunchRecord.add(curFoodInfo);
          break;

        case "晚餐":
          dinnerRecord.add(curFoodInfo);
          break;

        default:
          otherRecord.add(curFoodInfo);
          break;
      }
    }
  }

  // 获取格式化后的日期 2023-8-1 => 2023-08-01
  String getFormattedDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 选择日期弹窗
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary:
                  Color.fromARGB(178, 250, 151, 205), // header background color
              onPrimary: Colors.black, // header text color
              onSurface: Color.fromARGB(255, 43, 43, 43), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color.fromARGB(255, 58, 58, 58), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        print(getFormattedDate(selectedDate));
      });
      getAllMealInfo();
      getSpecificMealInfo();
    }
  }

  List<FoodRow> createRecordRowList(List info, double totalwidth) {
    var tempList = <FoodRow>[];
    for (int i = 0; i < info.length; ++i) {
      tempList.add(FoodRow(
        info: info[i],
        totalWidth: totalwidth,
        updateMealList: [getAllMealInfo, getSpecificMealInfo],
      ));
    }
    return tempList;
  }

  List<NutritionRow> createNutritionRowList(
      int start, int count, double width) {
    var tempList = <NutritionRow>[];
    for (int i = 0; i < count; ++i) {
      int ind = start + i;
      tempList.add(
        NutritionRow(
          nutritionType: nutritionName[ind],
          barWidth: width,
          total: mealTarget[indToNut[ind]] ?? 0,
          current: mealCur[indToNut[ind]] ?? 0,
          unit: nutritionUni[ind], // TOCHANGE
        ),
      );
    }
    return tempList;
  }

  void showAddFoodDialog(BuildContext context, String category) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "添加【$category】饮食数据",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: foodNameInputController,
                  decoration: const InputDecoration(
                      hintText: "食物名称",
                      hintStyle: TextStyle(color: Colors.black26)),
                ),
                TextField(
                  controller: foodWeightInputController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      hintText: "食物分量（以克为单位）",
                      hintStyle: TextStyle(color: Colors.black26)),
                )
              ],
            ),
            actions: [
              TextButton(
                child: const Text('确认'),
                onPressed: () {
                  postMeal(category);
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.arguments["date"];
    getMealTarget();
    getAllMealInfo();
    getSpecificMealInfo();
  }

  @override
  Widget build(BuildContext context) {
    preset();
    classifyMeal();

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    breakfastRowList = createRecordRowList(breakfastRecord, screenWidth * 0.6);
    lunchRowList = createRecordRowList(lunchRecord, screenWidth * 0.6);
    dinnerRowList = createRecordRowList(dinnerRecord, screenWidth * 0.6);
    otherRowList = createRecordRowList(otherRecord, screenWidth * 0.6);
    var calorieDiff =
        (mealTarget[indToNut[0]] ?? 0) - (allMealInfo["calories"] ?? 0);
    var caloriePer =
        (allMealInfo["calories"] ?? 0) / (mealTarget[indToNut[0]] ?? 0);

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          widget.arguments["isOwner"] ? "饮食记录" : widget.arguments["nickname"],
          style: TextStyle(
              fontFamily: 'BalooBhai',
              fontSize: 24,
              color: Colors.black,
              fontWeight: widget.arguments["isOwner"]
                  ? FontWeight.w900
                  : FontWeight.normal),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "在页面上方，可更改日期并添加进食记录。",
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
                              const SizedBox(height: 15),
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
                                  children: [
                                    Text(
                                      "在页面中部，可筛选查看指定时间段内所摄入的营养成分含量。",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text("1. 点击【时段按钮】=> 筛选指定时间段的记录。")
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
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
                                  children: [
                                    Text(
                                      "在页面下方，可查看选择的时间段中详细的进食记录。",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text("1. 点击【删除按钮】=> 删除对应的进食记录。")
                                  ],
                                ),
                              )
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
          decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(169, 171, 179, 1),
                  width: 1,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  widget.arguments["isOwner"]
                      ? const Color.fromARGB(255, 250, 209, 252)
                      : const Color.fromARGB(255, 182, 234, 255),
                  const Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )),
        ),
      ),

      // 主体内容
      body: ListView(
        shrinkWrap: true,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  height: 15,
                ),
                // 上面那栏
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 0),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38,
                          offset: Offset(0, 3),
                          spreadRadius: 0.5,
                          blurRadius: 7)
                    ],
                  ),
                  child: Column(children: [
                    InkWell(
                      onTap: () {
                        selectDate(context);
                      },
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  child: Text(
                                    selectedDate.month > 9
                                        ? (selectedDate.day < 10
                                            ? "${selectedDate.year}年${selectedDate.month}月0${selectedDate.day}日"
                                            : "${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日")
                                        : ((selectedDate.day < 10
                                            ? "${selectedDate.year}年0${selectedDate.month}月0${selectedDate.day}日"
                                            : "${selectedDate.year}年0${selectedDate.month}月${selectedDate.day}日")),
                                    style: const TextStyle(
                                        letterSpacing: 2,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Text(
                                  weekDay[selectedDate.weekday],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 5,
                                      fontWeight: FontWeight.w600),
                                ),
                              ])),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap: () {
                              setState(() {
                                haveRecord[0] = !haveRecord[0];
                              });
                            },
                            onLongPress: () {
                              showAddFoodDialog(context, "早餐");
                            },
                            child: FoodButton(
                                width: screenWidth * 0.9 * 0.45,
                                haveRecord: haveRecord[0],
                                title: "  早餐",
                                color: MyIcons().breakfastColor(),
                                bnw: MyIcons().breakfastBnW())),
                        InkWell(
                            onTap: () {
                              setState(() {
                                haveRecord[1] = !haveRecord[1];
                              });
                            },
                            onLongPress: () {
                              showAddFoodDialog(context, "午餐");
                            },
                            child: FoodButton(
                                width: screenWidth * 0.9 * 0.45,
                                haveRecord: haveRecord[1],
                                title: "  午餐",
                                color: MyIcons().lunchColor(),
                                bnw: MyIcons().lunchBnW())),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              haveRecord[2] = !haveRecord[2];
                            });
                          },
                          onLongPress: () {
                            showAddFoodDialog(context, "晚餐");
                          },
                          child: FoodButton(
                              width: screenWidth * 0.9 * 0.45,
                              haveRecord: haveRecord[2],
                              title: "  晚餐",
                              color: MyIcons().dinnerColor(),
                              bnw: MyIcons().dinnerBnW()),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              haveRecord[3] = !haveRecord[3];
                            });
                          },
                          onLongPress: () {
                            showAddFoodDialog(context, "其他");
                          },
                          child: FoodButton(
                              width: screenWidth * 0.9 * 0.45,
                              haveRecord: haveRecord[3],
                              title: "  其他",
                              color: MyIcons().snackColor(),
                              bnw: MyIcons().snackBnW()),
                        )
                      ],
                    )
                  ]),
                ),
                const SizedBox(
                  height: 20,
                ),
                // 中间那栏
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 0),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38,
                          offset: Offset(0, 3),
                          spreadRadius: 0.5,
                          blurRadius: 7)
                    ],
                  ),
                  child: loadTarget
                      ? (hasTarget
                          ? Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  // 切换按钮
                                  ToggleButtons(
                                      fillColor: widget.arguments["isOwner"]
                                          ? const Color.fromARGB(
                                              255, 250, 209, 252)
                                          : const Color.fromARGB(
                                              255, 182, 234, 255),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: Colors.black38,
                                      selectedColor: Colors.black,
                                      borderRadius: BorderRadius.circular(15),
                                      constraints: BoxConstraints.expand(
                                          width: screenWidth * 0.8 * 0.2,
                                          height: 25),
                                      isSelected: classSelected,
                                      children: const [
                                        Text("全天"),
                                        Text("早餐"),
                                        Text("午餐"),
                                        Text("晚餐"),
                                        Text("其他")
                                      ],
                                      onPressed: (index) {
                                        setState(() {
                                          classSelected[curSelected] = false;
                                          classSelected[index] = true;
                                          curSelected = index;
                                        });
                                        getSpecificMealInfo();
                                      }),
                                  const SizedBox(height: 10),
                                  // 卡路里圈
                                  CircularPercentIndicator(
                                    radius: 55,
                                    lineWidth: 4,
                                    percent: caloriePer,
                                    center: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("还可摄入",
                                            textAlign: TextAlign.center),
                                        Text(
                                          calorieDiff >= 0
                                              ? "$calorieDiff"
                                              : "0",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text("千卡",
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                    progressColor:
                                        const Color.fromARGB(255, 24, 165, 247),
                                  ),
                                  const SizedBox(height: 20),
                                  // 营养成分
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        expandNutrition = !expandNutrition;
                                      });
                                    },
                                    child: Container(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: [
                                            Icon(
                                              expandNutrition
                                                  ? Icons.arrow_drop_down
                                                  : Icons.arrow_right,
                                              size: 40,
                                            ),
                                            const Text(
                                              "营养成分",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2),
                                            ),
                                          ],
                                        )),
                                  ),
                                  Visibility(
                                    visible: expandNutrition,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: createNutritionRowList(
                                          1, 6, screenWidth * 0.5),
                                    ),
                                  ),
                                ])
                          : const Center(
                              child: Text(
                                "请先前往【首页】->【饮食目标】\n完成饮食目标设置，\n方可解锁数据分析模块",
                                textAlign: TextAlign.center,
                                style: TextStyle(height: 2, fontSize: 16),
                              ),
                            ))
                      : Container(),
                ),
                const SizedBox(
                  height: 20,
                ),
                // 下面那栏
                Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.4,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 0),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black38,
                              offset: Offset(0, 3),
                              spreadRadius: 0.5,
                              blurRadius: 7)
                        ]),
                    child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const Center(
                            child: Text(
                              "今日进食记录",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Visibility(
                              visible: haveRecord[0],
                              child: FoodHeader(
                                  text: "   早餐 Breakfast",
                                  icon: MyIcons().breakfastColorBig())),
                          Visibility(
                              visible: haveRecord[0],
                              child: Column(children: breakfastRowList)),
                          Visibility(
                              visible: haveRecord[0] && haveRecord[1],
                              child: const Divider(thickness: 2)),
                          Visibility(
                              visible: haveRecord[1],
                              child: FoodHeader(
                                  text: "   午餐 Lunch",
                                  icon: MyIcons().lunchColorBig())),
                          Visibility(
                              visible: haveRecord[1],
                              child: Column(children: lunchRowList)),
                          Visibility(
                              visible: haveRecord[2] &&
                                  (haveRecord[1] || haveRecord[0]),
                              child: const Divider(thickness: 2)),
                          Visibility(
                              visible: haveRecord[2],
                              child: FoodHeader(
                                  text: "   晚餐 Dinner",
                                  icon: MyIcons().dinnerColorBig())),
                          Visibility(
                              visible: haveRecord[2],
                              child: Column(children: dinnerRowList)),
                          Visibility(
                              visible: haveRecord[3] &&
                                  (haveRecord[2] ||
                                      haveRecord[1] ||
                                      haveRecord[0]),
                              child: const Divider(thickness: 2)),
                          Visibility(
                              visible: haveRecord[3],
                              child: FoodHeader(
                                  text: "   其他 Others",
                                  icon: MyIcons().snackColorBig())),
                          Visibility(
                              visible: haveRecord[3],
                              child: Column(children: otherRowList)),
                        ])),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
      // 下方导航栏
    );
  }
}

class FoodButton extends StatefulWidget {
  final double width;
  final bool haveRecord;
  final String title;
  final Image color;
  final Image bnw;

  const FoodButton(
      {super.key,
      required this.width,
      required this.haveRecord,
      required this.title,
      required this.color,
      required this.bnw});

  @override
  State<FoodButton> createState() => _FoodButtonState();
}

class _FoodButtonState extends State<FoodButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: widget.haveRecord
                ? const Color.fromARGB(255, 252, 235, 253)
                : Colors.transparent,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          widget.haveRecord ? widget.color : widget.bnw,
          Text(
            widget.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          )
        ]));
  }
}

class FoodHeader extends StatelessWidget {
  final String text;
  final Image icon;
  const FoodHeader({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          icon,
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ]),
        const SizedBox(height: 10)
      ],
    );
  }
}

class FoodRow extends StatelessWidget {
  final double totalWidth;
  final FoodInfo info;
  final List<Function()> updateMealList;
  const FoodRow(
      {super.key,
      required this.info,
      required this.totalWidth,
      required this.updateMealList});

  // Meal API
  void deleteMeal() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/meal/delete?id=${info.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        print("delete meal");
        updateMealList[0]();
        updateMealList[1]();
      } else {/**/}
    } catch (e) {/**/}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                width: totalWidth * 0.4,
                child: Text(
                  info.name,
                  style: const TextStyle(fontSize: 16),
                )),
            SizedBox(
                width: totalWidth * 0.25,
                child: Text(
                  "${info.weight.toString()}克",
                  style: const TextStyle(fontSize: 16),
                )),
            SizedBox(
                width: totalWidth * 0.35,
                child: Text(
                  "${info.calorie.toString()}千卡",
                  style: const TextStyle(fontSize: 16),
                )),
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("提示"),
                          content: Text(
                            "确认删除 \"${info.name}\" ？",
                            style: const TextStyle(fontSize: 18),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  deleteMeal();
                                },
                                child: const Text(
                                  "确认",
                                  style: TextStyle(fontSize: 18),
                                )),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "取消",
                                  style: TextStyle(fontSize: 18),
                                ))
                          ],
                        );
                      });
                },
                visualDensity: const VisualDensity(vertical: -4),
                color: Colors.black12,
                icon: MyIcons().delete())
          ],
        )
      ],
    );
  }
}

class NutritionRow extends StatefulWidget {
  final String nutritionType;
  final double barWidth;
  final int total;
  final int current;
  final String unit;
  const NutritionRow(
      {super.key,
      required this.nutritionType,
      required this.barWidth,
      required this.total,
      required this.current,
      required this.unit});

  @override
  State<NutritionRow> createState() => _NutritionRowState();
}

class _NutritionRowState extends State<NutritionRow> {
  // Meal API
  void getMealInfo() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/meal/delete?id=5',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
      } else {/**/}
    } catch (e) {/**/}
  }

  @override
  Widget build(BuildContext context) {
    var cur = widget.current;
    var tot = widget.total;
    var per = cur / tot;
    var uni = widget.unit;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(children: [
              Text(
                "$cur/$tot$uni",
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.left,
              ),
              LinearPercentIndicator(
                width: widget.barWidth - 5,
                lineHeight: 7,
                percent: per > 1 ? 1 : per,
                backgroundColor: Colors.black12,
                progressColor: per > 1
                    ? const Color.fromARGB(255, 255, 0, 0)
                    : const Color.fromARGB(255, 163, 123, 228),
              )
            ]),
            SizedBox(
              width: widget.barWidth * 0.6,
              child: Text(
                widget.nutritionType,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 3,
        )
      ],
    );
  }
}
