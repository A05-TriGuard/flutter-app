import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../component/icons.dart';

// TOIMPROVE: 在appbar右侧可以增加 ？作为使用说明

class FoodInfo {
  final String name;
  final String weight;
  final String calorie;
  FoodInfo({required this.name, required this.weight, required this.calorie});
}

class FoodDiary extends StatefulWidget {
  const FoodDiary({super.key});

  @override
  State<FoodDiary> createState() => _FoodDiaryState();
}

// TOINTERACT: 变量基本上都需要从后端获取数据
class _FoodDiaryState extends State<FoodDiary> {
  var haveRecord = <bool>[false, false, false, false];
  var breakfastRecord = <FoodInfo>[
    FoodInfo(name: "牛角面包", weight: "100克", calorie: "122千卡"),
    FoodInfo(name: "鸡蛋", weight: "150克", calorie: "89千卡")
  ];
  var lunchRecord = <FoodInfo>[
    FoodInfo(name: "披萨", weight: "500克", calorie: "1322千卡"),
    FoodInfo(name: "可乐", weight: "400克", calorie: "655千卡")
  ];
  var dinnerRecord = <FoodInfo>[];
  var otherRecord = <FoodInfo>[];
  var breakfastRowList = <FoodRow>[];
  var lunchRowList = <FoodRow>[];
  var dinnerRowList = <FoodRow>[];
  var otherRowList = <FoodRow>[];
  var classSelected = <bool>[true, false, false, false, false];
  int curSelected = 0;
  var nutritionName = <String>["卡路里", "碳水化合物", "胆固醇", "纤维素", "蛋白质", "脂肪", "钠"];
  var nutritionTgt = <double>[1852, 256, 100, 25, 93, 52, 2000];
  var nutritionCur = <double>[414, 57.5, 648, 2, 19.4, 12.2, 195.5];
  var nutritionUni = <String>["千卡", "毫克", "毫克", "克", "克", "克", "毫克"];

  List<FoodRow> createRecordRowList(List info, double totalwidth) {
    var tempList = <FoodRow>[];
    for (int i = 0; i < info.length; ++i) {
      tempList.add(FoodRow(info: info[i], totalWidth: totalwidth));
    }
    return tempList;
  }

  List<NutritionRow> createNutritionRowList(
      int start, int count, double width) {
    var tempList = <NutritionRow>[];
    for (int i = 0; i < count; ++i) {
      int ind = start + i;
      tempList.add(NutritionRow(
          nutritionType: nutritionName[ind],
          barWidth: width,
          total: nutritionTgt[ind],
          current: nutritionCur[ind],
          unit: nutritionUni[ind]));
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
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                      hintText: "食物名称",
                      hintStyle: TextStyle(color: Colors.black26)),
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: "食物分量（以克为单位）",
                      hintStyle: TextStyle(color: Colors.black26)),
                )
              ],
            ),
            actions: [
              TextButton(
                child: const Text('确认'),
                onPressed: () {
                  // TOINTERACT: 发送请求获取相关数据
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
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    breakfastRowList = createRecordRowList(breakfastRecord, screenWidth * 0.6);
    lunchRowList = createRecordRowList(lunchRecord, screenWidth * 0.6);
    var calorieDiff = nutritionTgt[0] - nutritionCur[0];

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          "返回首页",
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
      body: ListView(shrinkWrap: true, children: [
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
                //height: screenHeight * 0.15,
                height: 125,
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
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
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Center(
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                Text(
                                  "2023年11月",
                                  style: TextStyle(
                                      fontSize: 13,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "20",
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  "星期一",
                                  style: TextStyle(
                                      fontSize: 13,
                                      letterSpacing: 5,
                                      fontWeight: FontWeight.w600),
                                )
                              ]))),
                      Column(
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
                                    haveRecord: haveRecord[0],
                                    title: "  早餐",
                                    color: MyIcons().breakfastColor(),
                                    bnw: MyIcons().breakfastBnW())),
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
                                  haveRecord: haveRecord[2],
                                  title: "  晚餐",
                                  color: MyIcons().dinnerColor(),
                                  bnw: MyIcons().dinnerBnW()),
                            )
                          ]),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    haveRecord[1] = !haveRecord[1];
                                  });
                                },
                                onLongPress: () {
                                  showAddFoodDialog(context, "晚餐");
                                },
                                child: FoodButton(
                                    haveRecord: haveRecord[1],
                                    title: "  午餐",
                                    color: MyIcons().lunchColor(),
                                    bnw: MyIcons().lunchBnW())),
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
                                  haveRecord: haveRecord[3],
                                  title: "  其他",
                                  color: MyIcons().snackColor(),
                                  bnw: MyIcons().snackBnW()),
                            )
                          ])
                    ]),
              ),
              const SizedBox(
                height: 20,
              ),
              // 中间那栏
              Container(
                width: screenWidth * 0.9,
                //height: screenHeight * 0.33,
                height: 250,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 切换按钮
                      ToggleButtons(
                          fillColor: const Color.fromARGB(255, 250, 209, 252),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          color: Colors.black38,
                          selectedColor: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                          constraints: BoxConstraints.expand(
                              width: screenWidth * 0.8 * 0.2, height: 25),
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
                              // TOINTERACT: 获取数据更新显示内容
                            });
                          }),

                      // 卡路里圈
                      CircularPercentIndicator(
                        radius: 55,
                        lineWidth: 4,
                        percent: 0.75,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("还可摄入", textAlign: TextAlign.center),
                            Text(
                              "$calorieDiff",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const Text("千卡", textAlign: TextAlign.center),
                          ],
                        ),
                        progressColor: const Color.fromARGB(255, 24, 165, 247),
                      ),

                      // 营养成分
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: createNutritionRowList(
                                1, 3, screenWidth * 0.25),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: createNutritionRowList(
                                4, 3, screenWidth * 0.25),
                          )
                        ],
                      ),
                    ]),
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
                      ])),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ]),
      // 下方导航栏
    );
  }
}

class FoodButton extends StatefulWidget {
  final bool haveRecord;
  final String title;
  final Image color;
  final Image bnw;

  const FoodButton(
      {super.key,
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
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: widget.haveRecord
                ? const Color.fromARGB(255, 252, 235, 253)
                : Colors.transparent,
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(15)),
        child: Row(children: [
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
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      icon,
      Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ]);
  }
}

class FoodRow extends StatelessWidget {
  final double totalWidth;
  final FoodInfo info;
  const FoodRow({super.key, required this.info, required this.totalWidth});

  void showDialogFunction() async {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //const SizedBox(height: 10),
        Row(
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
                  info.weight,
                  style: const TextStyle(fontSize: 16),
                )),
            SizedBox(
                width: totalWidth * 0.35,
                child: Text(
                  info.calorie,
                  style: const TextStyle(fontSize: 16),
                )),
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("提示"),
                          content: Text("确认删除 \"${info.name}\" ？"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  // TOINTERACT: 发送删除请求给后端进行删除，再获取新的数据更新页面
                                },
                                child: const Text("确认")),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("取消"))
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
  final double total;
  final double current;
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
  @override
  Widget build(BuildContext context) {
    var cur = widget.current;
    var tot = widget.total;
    var per = cur / tot;
    var uni = widget.unit;

    return Row(
      children: [
        Column(children: [
          Text(
            "$cur/$tot$uni",
            style: const TextStyle(fontSize: 9),
            textAlign: TextAlign.left,
          ),
          LinearPercentIndicator(
            width: widget.barWidth - 5,
            lineHeight: 5,
            percent: per > 1 ? 1 : per,
            backgroundColor: Colors.black12,
            progressColor: const Color.fromARGB(255, 163, 123, 228),
          )
        ]),
        Text(
          widget.nutritionType,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
