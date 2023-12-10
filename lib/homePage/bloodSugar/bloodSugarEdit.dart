import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:triguard/component/titleDate/titleDate.dart';
import 'package:dio/dio.dart';

import '../../component/header/header.dart';
import "bsData.dart";
import '../../account/token.dart';
import "../../other/other.dart";

// 删除 取消 确定
List<String> armButtonTypes = ["左手", "右手", "不选"];
List<String> feelingButtonTypes = ["开心", "还好", "不好"];
List<String> functionButtonTypes = ["删除", "取消", "确定"];
List<String> invalidValueText = ["", "血糖必须填写"];
List<Color> functionButtonColors = const [
  Color.fromRGBO(253, 108, 108, 1),
  Color.fromRGBO(144, 235, 235, 1),
  Color.fromRGBO(173, 255, 144, 1),
];

List<dynamic> data = [];
List<Widget> dataWidget = [];

late Widget titleDateWidget;
Widget addDataButtonWidget = addDataButton();
int randomId = 100;
typedef UpdateTimeCallback = void Function(DateTime newTime);
typedef UpdateDateCallback = void Function(DateTime newDate);

class newValue {
  int id = 0;
  //int hour = 0;
  //int minute = 0;
  DateTime time = DateTime.now();
  double bloodSugar = 0;
  int mealIndex = 0;
  int feelingIndex = 0;
  String remarks = "";

  newValue(this.id, this.time, this.bloodSugar, this.mealIndex,
      this.feelingIndex, this.remarks);

  void clear() {
    id = 0;
    time = DateTime.now();
    bloodSugar = 0;
    mealIndex = 0;
    feelingIndex = 0;
    remarks = "";
  }

  void printValue() {
    print("id: $id");
    print("time: $time");
    print("bloodSugar: $bloodSugar");
    print("mealIndex: $mealIndex");
    print("feelingIndex: $feelingIndex");
    print("remarks: $remarks");
  }
}

String getRemarById(int id) {
  for (int i = 0; i < data.length; i++) {
    if (data[i]["id"] == id) {
      return data[i]["remark"];
    }
  }
  return "";
}

void setRemrakById(int id, String newRemarks) {
  for (int i = 0; i < data.length; i++) {
    if (data[i]["id"] == id) {
      data[i]["remark"] = newRemarks;
      return;
    }
  }
  print("set failed");
}

// 获取某个id的数据
int getDataById(int id, String type) {
  for (int i = 0; i < data.length; i++) {
    if (data[i]["id"] == id) {
      return data[i][type];
    }
  }
  return 0;
}

void setDataById(int id, String type, int value) {
  for (int i = 0; i < data.length; i++) {
    if (data[i]["id"] == id) {
      data[i][type] = value;
      //print('${id}:${bpdata[i][type]}');
      return;
    }
  }
  print("set failed");
}

DateTime getTimeById(int id) {
  for (int i = 0; i < data.length; i++) {
    if (data[i]["id"] == id) {
      int hour = int.parse(bpdata[i]["time"].toString().split(":")[0]);
      int minute = int.parse(bpdata[i]["time"].toString().split(":")[1]);
      return DateTime(2023, 11, 11, hour, minute);
    }
  }
  return DateTime.now();
}

void setTimeById(int id, DateTime time) {
  for (int i = 0; i < data.length; i++) {
    if (data[i]["id"] == id) {
      data[i]["time"] =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      return;
    }
  }
  print("set failed");
}

late newValue afterEditedValue; //= newValue(0, "0", "0", "0", "0", "0", 0, 0);
bool deleteDataMark = false;

int invalidValue(newValue value) {
  return 0;
}

// =================================================================================

// 添加数据按钮
class addDataButton extends StatefulWidget {
  const addDataButton({super.key});

  @override
  State<addDataButton> createState() => _addDataButtonState();
}

class _addDataButtonState extends State<addDataButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("我要添加数据");
      },
      child: UnconstrainedBox(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.85,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            //color: Colors.white,
            color: const Color.fromARGB(255, 167, 167, 167),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(120, 151, 151, 151),
                offset: Offset(0, 5),
                blurRadius: 5.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            size: 50,
            color: Color.fromARGB(255, 17, 17, 17),
          ),
        ),
      ),
    );
  }
}

// 添加数据的 填写框
// ignore: must_be_immutable
class addDataWidget extends StatefulWidget {
  final int accountId;
  DateTime date;
  final VoidCallback updateData;
  DateTime time = DateTime.now();

  addDataWidget(
      {Key? key,
      required this.accountId,
      required this.updateData,
      required this.time,
      required this.date})
      : super(key: key);

  @override
  State<addDataWidget> createState() => _addDataWidgetState();
}

class _addDataWidgetState extends State<addDataWidget> {
  // 输入框的控制器
  // ignore: non_constant_identifier_names
  TextEditingController bloodSugarController = TextEditingController();
  TextEditingController bloodSugar_Controller = TextEditingController(); //小数
  final TextEditingController remarkController = TextEditingController();
  MealButtonsRow mealButtons = MealButtonsRow(
    selectedIndex: 2,
  );
  FeelingsButtonsRow feelingsButtons = FeelingsButtonsRow(
    selectedIndex: 1,
  );
  DateTime time = DateTime.now();

  // 错误类型
  int invalidValueType = 0;

  // ===================================================

  // 添加血压数据至后端
  Future<void> addBloodPressureData() async {
    var newVal = {
      "date":
          "${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}",
      "time":
          "${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}",
      "bs": int.parse(bloodSugarController.text),
      "meal": mealButtons.getSelectedButtonIndex(),
      "feeling": feelingsButtons.getSelectedButtonIndex(),
    };

    if (remarkController.text != "") {
      newVal["remark"] = remarkController.text;
    }

    if (widget.accountId >= 0) {
      newVal["accountId"] = widget.accountId.toString();
    }

    //print(newVal);

    final Dio dio = Dio();

    const String addDataApi = 'http://43.138.75.58:8080/api/blood-sugar/create';

    try {
      var token = await storage.read(key: 'token');
      dio.options.headers["Authorization"] = "Bearer $token";
      Response response = await dio.post(
        addDataApi,
        //queryParameters: newVal,
        data: newVal,
      );

      //print(response.data);

      if (response.data['code'] == 200) {
        print("添加数据成功");
      } else {
        print("添加数据失败");
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        print(response.data);
        print("添加数据请求失败1");
      } else {
        print(error.requestOptions);
        print(error.message);
        print("添加数据请求失败2");
      }
    }
  }

  // 更新显示的时间
  void updateTime(DateTime newTime) {
    setState(() {
      widget.time = newTime;
    });
  }

  // 获取标题 中文+英文
  Widget getTitle(String TitleChn, String TitleEng) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.center,
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${TitleChn}",
          style: const TextStyle(fontSize: 18, fontFamily: "BalooBhai"),
        ),
        Text(
          "${TitleEng}",
          style: const TextStyle(
              fontSize: 14,
              fontFamily: "Blinker",
              color: Color.fromARGB(255, 109, 109, 109)),
        )
      ],
    );
  }

  // 血糖值输入框
  Widget getEditWidget(TextEditingController controller,
      TextEditingController controller_, String hintText, String hintText_) {
    double height = 41;
    return Container(
      height: height,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: height - 1,
            child: TextField(
              maxLength: 2,
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  counterText: "",
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 167, 166, 166),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5)),
              textAlign: TextAlign.right,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
            ),
          ),
          Container(
            height: 40,
            width: 10,
            /* child: const Text(
              " . ",
              style: TextStyle(fontSize: 35, fontFamily: "Blinker"),
            ), */
            //alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Container(
                  height: 20,
                  width: 10,
                  color: Colors.white,
                ),
                Image.asset("assets/icons/dot.png", width: 10, height: 10),
              ],
            ),
          ),
          SizedBox(
            width: 25,
            height: height - 1,
            child: TextField(
              maxLength: 1,
              controller: controller_,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  counterText: "",
                  hintText: hintText_,
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 167, 166, 166),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5)),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "mmol/L",
            style: TextStyle(fontSize: 16, fontFamily: "Blinker"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            // height: MediaQuery.of(context).size.height * 0.62,
            height: 340,
            decoration: BoxDecoration(
              //color: Colors.white,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(120, 151, 151, 151),
                  offset: Offset(0, 5),
                  blurRadius: 5.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            getTitle("时间", "TIME"),
                            getTitle("血糖", "BS"),
                            getTitle("用餐", "MEAL"),
                            getTitle("感觉", "FEELINGS"),
                            getTitle("备注", "REMARKS"),
                          ],
                        ),
                      ),

                      const SizedBox(width: 5),

                      // 右边的子容器
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 时间
                            Container(
                              height: 41,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: TimePicker(
                                    time: widget.time, updateTime: updateTime),
                              ),
                            ),
                            //
                            const SizedBox(
                              height: 5,
                            ),

                            // 修改收缩压
                            /*  Container(
                              height: 41,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 75,
                                    height: 40,
                                    child: TextField(
                                      maxLength: 3,
                                      controller: bloodSugarController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      //initialValue: widget.SBloodpressure,
                                      decoration: const InputDecoration(
                                          counterText: "",
                                          hintText: "100",
                                          contentPadding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 5)),
                                      textAlign: TextAlign.center,
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      style: const TextStyle(
                                          fontSize: 30,
                                          fontFamily: "BalooBhai"),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Text(
                                    "mmHg",
                                    style: TextStyle(
                                        fontSize: 16, fontFamily: "Blinker"),
                                  ),
                                ],
                              ),
                            ),
 */

                            // 修改血糖值
                            getEditWidget(bloodSugarController,
                                bloodSugar_Controller, "3", "2"),

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            // 修改手臂
                            mealButtons,

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            //修改感觉
                            feelingsButtons,

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            //备注
                            Container(
                              height: 41,
                              child: SizedBox(
                                width: 150,
                                height: 40,
                                child: TextFormField(
                                  controller: remarkController,
                                  //initialValue: widget.SBloodpressure,
                                  decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: "-",
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 167, 166, 166),
                                      ),
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 6)),
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: const TextStyle(
                                      fontSize: 20, fontFamily: "BalooBhai"),
                                ),
                              ),
                            ),
                            //
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),

                  //警告信息
                  invalidValueType > 0
                      ? Container(
                          height: 20,
                          alignment: Alignment.centerRight,
                          child: Text(
                            invalidValueText[invalidValueType],
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontFamily: "Blinker"),
                          ),
                        )
                      : const SizedBox(
                          height: 10,
                        ),

                  //
                  const SizedBox(height: 10),

                  //删除，取消，确定
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //取消添加数据
                        OtherButton(
                            onPressed: () {
                              //print("取消添加数据");
                              setState(() {
                                // 不显示 添加数据的填写框
                                dataWidget.removeAt(1);
                                widget.updateData();
                              });
                            },
                            type: 1),
                        const SizedBox(width: 5),

                        //确定添加
                        OtherButton(
                            onPressed: () {
                              // 检测是否正确填写

                              randomId += 1;

                              if (bloodSugarController.text == "") {
                                invalidValueType = 1;
                              } else {
                                invalidValueType = 0;
                              }

                              if (invalidValueType > 0) {
                                //print(
                                //    "invalidvalue: $invalidValueType ${invalidValueText[invalidValueType]}");
                                setState(() {});
                                return;
                              }

                              // 添加数据至后端
                              /* addBloodPressureData();

                              setState(() {
                                print("更新已添加的数据");
                                if (data.isEmpty) {
                                  print('长度: ${dataWidget.length}');
                                  dataWidget.removeLast();
                                  dataWidget.removeLast();
                                } else {
                                  dataWidget.removeAt(1);
                                }
                                widget.updateData();
                              }); */

                              addBloodPressureData().then((_) {
                                if (data.isEmpty) {
                                  //print('长度: ${dataWidget.length}');
                                  dataWidget.removeLast();
                                  dataWidget.removeLast();
                                } else {
                                  dataWidget.removeAt(1);
                                }
                                widget.updateData();
                              });
                            },
                            type: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

// 其他按钮 （删除，取消，确定）
class OtherButton extends StatefulWidget {
  final VoidCallback onPressed;
  final int type;

  const OtherButton({Key? key, required this.onPressed, required this.type})
      : super(key: key);

  @override
  State<OtherButton> createState() => _OtherButtonState();
}

class _OtherButtonState extends State<OtherButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        height: 25,
        width: 40,
        padding: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: functionButtonColors[widget.type],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color.fromRGBO(122, 119, 119, 0.43)),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Text(
            functionButtonTypes[widget.type],
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.0,
              fontFamily: 'Blinker',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// 进食的按钮
class MealButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSelected;

  const MealButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      required this.isSelected})
      : super(key: key);

  @override
  State<MealButton> createState() => _MealButtonState();
}

class _MealButtonState extends State<MealButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        height: 40,
        width: 50,
        padding: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color.fromRGBO(253, 134, 255, 0.66)
              : Color.fromRGBO(218, 218, 218, 0.66),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color.fromRGBO(122, 119, 119, 0.43)),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.isSelected
                  ? Color.fromRGBO(66, 9, 119, 0.773)
                  : Color.fromRGBO(94, 68, 68, 100),
              fontSize: 16.0,
              fontFamily: 'Blinker',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// 进食的按钮（空腹，餐后，不选）
// ignore: must_be_immutable
class MealButtonsRow extends StatefulWidget {
  int selectedIndex;

  MealButtonsRow({required this.selectedIndex});

  @override
  _MealButtonsRowState createState() => _MealButtonsRowState();

  int getSelectedButtonIndex() {
    return selectedIndex;
  }
}

class _MealButtonsRowState extends State<MealButtonsRow> {
  //late int selectedButtonIndex;

  @override
  void initState() {
    super.initState();
    //selectedButtonIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MealButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 0;
              });
//print("左手按钮被点击了！");
            },
            text: "空腹",
            isSelected: widget.selectedIndex == 0,
          ),
          const SizedBox(width: 5),
          MealButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 1;
              });
              // print("右手按钮被点击了！");
            },
            text: "餐后",
            isSelected: widget.selectedIndex == 1,
          ),
          const SizedBox(width: 5),
          MealButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 2;
              });
              // print("不选按钮被点击了！");
            },
            text: "不选",
            isSelected: widget.selectedIndex == 2,
          ),
        ],
      ),
    );
  }
}

// 感觉按钮
class FeelingsButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final bool isSelected;

  const FeelingsButton({
    required this.onPressed,
    required this.iconPath,
    required this.isSelected,
  });

  @override
  State<FeelingsButton> createState() => _FeelingsButtonState();
}

class _FeelingsButtonState extends State<FeelingsButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        height: 40,
        width: 50,
        padding: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color.fromRGBO(253, 134, 255, 0.66)
              : Color.fromRGBO(218, 218, 218, 0.66),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color.fromRGBO(122, 119, 119, 0.43)),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 25,
          width: 25,
          // color: widget.isSelected
          //     ? Color.fromRGBO(66, 9, 119, 0.773)
          //     : Color.fromRGBO(94, 68, 68, 100),
          child: Image.asset(
            widget.iconPath,
          ),
        ),
      ),
    );
  }
}

// 感觉的按钮（较好，还好，较差）
// ignore: must_be_immutable
class FeelingsButtonsRow extends StatefulWidget {
  int selectedIndex;

  FeelingsButtonsRow({required this.selectedIndex});

  @override
  _FeelingsButtonsRowState createState() => _FeelingsButtonsRowState();

  int getSelectedButtonIndex() {
    return selectedIndex;
  }
}

class _FeelingsButtonsRowState extends State<FeelingsButtonsRow> {
  @override
  void initState() {
    super.initState();
    //selectedButtonIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FeelingsButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 0;
              });
              //print("开心按钮被点击了！");
            },
            iconPath: "assets/icons/emoji-nice.png",
            isSelected: widget.selectedIndex == 0,
          ),
          const SizedBox(width: 5),
          FeelingsButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 1;
              });
              // print("还好按钮被点击了！");
            },
            iconPath: "assets/icons/emoji-ok.png",
            isSelected: widget.selectedIndex == 1,
          ),
          const SizedBox(width: 5),
          FeelingsButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 2;
              });
              // print("不好按钮被点击了！");
            },
            iconPath: "assets/icons/emoji-bad.png",
            isSelected: widget.selectedIndex == 2,
          ),
        ],
      ),
    );
  }
}

// “修改血压”标题 与 日期选择
class TitleDate extends StatefulWidget {
  final DateTime date;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  const TitleDate(
      {Key? key,
      required this.date,
      required this.updateView,
      required this.updateDate})
      : super(key: key);

  @override
  State<TitleDate> createState() => _TitleDateState();
}

class _TitleDateState extends State<TitleDate> {
  DateTime date = DateTime.now();
  DateTime oldDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  //DateTime newDate = DateTime(2023, 11, 11);

  String getWeekDay() {
    switch (widget.date.weekday) {
      case 1:
        return "(一)";
      case 2:
        return "(二)";
      case 3:
        return "(三)";
      case 4:
        return "(四)";
      case 5:
        return "(五)";
      case 6:
        return "(六)";
      case 7:
        return "(日)";
    }
    return "(一)";
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 如果是从详情页面跳转过来，就要这两行 日期与详情页面的日期一样
    date = widget.date;
    oldDate = widget.date;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(
                height: 5,
              ),
              Container(
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "修改血糖",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Image.asset("assets/icons/bloodSugar.png",
                          width: 20, height: 20),
                    ]),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        //"${widget.date.year}年${widget.date.month}月${widget.date.day}日",
                        '${date.year}年${date.month}月${date.day}日 ${getWeekDay()}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "BalooBhai",
                            color: Color.fromRGBO(48, 48, 48, 1)),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: const Icon(Icons.calendar_month),
                          iconSize: 25,
                          /* onPressed: () {
                            print("editDate");
                          }, */

                          onPressed: () => _showDialog(Column(
                            children: [
                              Expanded(
                                //height: 220,
                                child: CupertinoDatePicker(
                                  initialDateTime: date,
                                  maximumDate: DateTime.now(),
                                  mode: CupertinoDatePickerMode.date,
                                  use24hFormat: true,
                                  // This shows day of week alongside day of month
                                  showDayOfWeek: true,
                                  // This is called when the user changes the date.
                                  onDateTimeChanged: (DateTime newDate) {
                                    // setState(() => date = newDate);
                                    date = newDate;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                width: 320,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: 120,
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            date = oldDate;
                                          });

                                          Navigator.of(context).pop();
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            const Color.fromARGB(
                                                255, 221, 223, 223),
                                          ),
                                        ),
                                        child: const Text(
                                          '取消',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 120,
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            oldDate = date;
                                          });
                                          Navigator.of(context).pop();
                                          // bpdata
                                          // widget.updateDate(date);
                                          //widget.updateView();

                                          // 后端
                                          widget.updateDate(date);
                                          //widget.updateView();
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    const Color.fromARGB(
                                                        255, 118, 241, 250))),
                                        child: const Text(
                                          '确定',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                        ),
                      )
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 生成血压数据的显示模块
// ignore: must_be_immutable
class BloodPressureEditWidget extends StatefulWidget {
  final int accountId;
  final int id;
  DateTime date = DateTime.now();
  DateTime time = DateTime.now();
  final int bloodSugar;
  final int bloodSugar_;
  final int meal;
  final int feeling;
  final String remark;
  final VoidCallback updateParent;
  final VoidCallback updateData;
  int isExpanded;

  BloodPressureEditWidget({
    Key? key,
    required this.accountId,
    required this.id,
    required this.date,
    required this.time,
    required this.bloodSugar,
    required this.bloodSugar_,
    required this.feeling,
    required this.meal,
    required this.remark,
    required this.isExpanded,
    required this.updateParent,
    required this.updateData,
  }) : super(key: key);

  @override
  State<BloodPressureEditWidget> createState() =>
      _BloodPressureEditWidgetState();
}

class _BloodPressureEditWidgetState extends State<BloodPressureEditWidget> {
  //bool isExpanded = false;
  Widget? BPEditWidget;

  Future<void> deleteData(int id) async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    //print("getDataFromServer");
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    response =
        await dio.get("http://43.138.75.58:8080/api/blood-sugar/delete?id=$id");
    if (response.data["code"] == 200) {
      print("删除血糖数据成功");
      //print(response.data["data"]);
      // data = response.data["data"];
      //bpdata = response.data["data"];
    } else {
      print(response);
      print("删除血糖数据失败");
      //data = [];
    }
  }

  Future<void> editData(int id, newValue afterEditedValue) async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    var newVal = {
      "id": afterEditedValue.id,
      "time":
          "${afterEditedValue.time.hour.toString().padLeft(2, '0')}:${afterEditedValue.time.minute.toString().padLeft(2, '0')}",
      "bs": afterEditedValue.bloodSugar,
      "meal": afterEditedValue.mealIndex,
      "feeling": afterEditedValue.feelingIndex,
      "remark": afterEditedValue.remarks,
    };

    if (widget.accountId >= 0) {
      newVal["accountId"] = widget.accountId.toString();
    }

    //print("==========进行修改 参数=========");
    //print(newVal);

    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/blood-sugar/update",
        data: newVal,
      );

      //print(response.data);

      if (response.data['code'] == 200) {
        print("修改数据成功");
      } else {
        print("修改数据失败");
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        print(response.data);
        print("修改数据请求失败1");
      } else {
        print(error.requestOptions);
        print(error.message);
        print("修改数据请求失败2");
      }
    }
  }

  void printBP() {
    print("***************************************");
    print("id: ${widget.id}");
    print("date: ${widget.date}");
    print("time: ${widget.time}");
    print("bloodSugar: ${widget.bloodSugar}");
    print("meal: ${widget.meal}");
    print("feeling: ${widget.feeling}");
    print("remark: ${widget.remark}");
    print("isExpanded: ${widget.isExpanded}");
    print("***************************************");
  }

  @override
  Widget build(BuildContext context) {
    //printBP();
    return GestureDetector(
        onTap: () {
          // 当收起时，点击任意地方可以展开

          // print('${widget.id}被点击了！！！！');

          if (getDataById(widget.id, "isExpanded") == 0) {
            setState(() {
              setDataById(widget.id, "isExpanded", 1);

              // 其他的一律收起
              for (int i = 0; i < data.length; i++) {
                if (data[i]["id"] != widget.id) {
                  //  print('其他收起: ${data[i]["id"]}');
                  setDataById(data[i]["id"], "isExpanded", 0);
                }
              }
            });
            widget.updateParent();
          }
        },
        //child: BPEditWidget,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
              height: getDataById(widget.id, "isExpanded") == 1
                  ? 350 //MediaQuery.of(context).size.height * 0.65
                  : MediaQuery.of(context).size.height * 0.15,
              // height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.85,

              alignment: Alignment.center,
              //https://stackoverflow.com/questions/56298325/overflow-warning-in-animatedcontainer-adjusting-height
              //切换的一瞬间会overflow，用SingleChildScrollView包裹一下解决
              child: getDataById(widget.id, "isExpanded") == 1
                  ? SingleChildScrollView(
                      child: BloodSugarEditWidgetMore(
                        id: widget.id,
                        time: widget.time,
                        bloodSugar: widget.bloodSugar,
                        bloodSugar_: widget.bloodSugar_,
                        meal: widget.meal,
                        feeling: widget.feeling,
                        remark: widget.remark,
                        deleteData: () {
                          /* setState(() {
                            setDataById(widget.id, "isExpanded", 0);
                            print('删除 ${widget.id}');
                            // 删除id为widget.id的数据
                            /* bpdata.removeWhere(
                                (element) => element["id"] == widget.id);
                            print(bpdata); */
                            deleteData(widget.id);

                            widget.updateData();
                          }); */

                          deleteData(widget.id).then((_) {
                            widget.updateData();
                          });
                        },
                        cancelEditData: () {
                          setState(() {
                            setDataById(widget.id, "isExpanded", 0);
                            //print('取消修改 ${widget.id}');
                          });
                        },
                        confirmEditData: () {
                          /*  print("==========进行修改=========");
                          print("日期：${widget.date}");
                          print('确定修改 ${widget.id}');
                          afterEditedValue.printValue();
                          print("======================"); */

                          // editData(widget.id, afterEditedValue);
                          // //afterEditedValue.clear();
                          // widget.updateData();

                          editData(widget.id, afterEditedValue).then((_) {
                            widget.updateData();
                          });
                        },
                      ),
                    )
                  : SingleChildScrollView(
                      child: BloodSugarEditWidgetLess(
                        id: widget.id,
                        time: widget.time,
                        bloodSugar:
                            widget.bloodSugar + (widget.bloodSugar_ / 10),
                        meal: widget.meal,
                        feeling: widget.feeling,
                        remark: widget.remark,
                      ),
                    ),
            )
          ],
        ));
  }
}

// 只展示
// ignore: must_be_immutable
class BloodSugarEditWidgetLess extends StatefulWidget {
  final int id;
  DateTime time;
  final double bloodSugar;
  final int meal;
  final int feeling;
  final String remark;

  BloodSugarEditWidgetLess(
      {Key? key,
      required this.id,
      required this.time,
      required this.bloodSugar,
      required this.meal,
      required this.feeling,
      required this.remark})
      : super(key: key);

  @override
  State<BloodSugarEditWidgetLess> createState() =>
      _BloodSugarEditWidgetLessState();
}

class _BloodSugarEditWidgetLessState extends State<BloodSugarEditWidgetLess> {
  List<String> mealButtonTypes = ["空腹", "餐后", "不选"];
  List<String> feelingButtonTypes = ["开心", "还好", "不好"];
  bool showRemark = false;
  PageController pageController = PageController();

  Widget getInfoPage() {
    return Container(
      //duration: Duration(milliseconds: 1000),
      //curve: Curves.easeInOut,
      height: 80,
      width: MediaQuery.of(context).size.width * 0.85,

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.2),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
                '${widget.time.hour < 10 ? "0${widget.time.hour}" : widget.time.hour}:${widget.time.minute < 10 ? "0${widget.time.minute}" : widget.time.minute}',
                style: const TextStyle(fontSize: 20, fontFamily: "BalooBhai")),
            /* Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('血糖: ${widget.bloodSugar}',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
              ],
            ), */

            Row(
              children: [
                Text('血糖: ',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
                Text('${widget.bloodSugar}',
                    style:
                        const TextStyle(fontSize: 20, fontFamily: "BalooBhai")),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('进食: ${mealButtonTypes[widget.meal]}',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
                Text('感觉: ${feelingButtonTypes[widget.feeling]}',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getRemarkPage() {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.2),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "备注",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "BalooBhai",
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Image.asset("assets/icons/remark.png", width: 15, height: 15),
                ],
              ),
              Text(
                widget.remark == "" ? "暂无备注" : widget.remark,
                style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getPageNum(bool showRemark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: showRemark ? Colors.grey : Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: showRemark ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(5),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget infoPage = getInfoPage();

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.primaryDelta! > 10) {
          setState(() {
            showRemark = false;
          });
        } else if (details.primaryDelta! < -10) {
          setState(() {
            showRemark = true;
          });
        }
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    firstChild: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: infoPage,
                    ),
                    secondChild: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: getRemarkPage(),
                    ),
                    crossFadeState: showRemark
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
              SizedBox(
                //height: 5,
                child: getPageNum(showRemark),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

// 可编辑
// ignore: must_be_immutable
class BloodSugarEditWidgetMore extends StatefulWidget {
  final int id;
  DateTime time;
  int bloodSugar;
  int bloodSugar_;
  int meal;
  int feeling;
  String remark;
  final VoidCallback deleteData;
  final VoidCallback cancelEditData;
  final VoidCallback confirmEditData;

  BloodSugarEditWidgetMore({
    Key? key,
    required this.id,
    required this.time,
    required this.bloodSugar,
    required this.bloodSugar_,
    required this.feeling,
    required this.meal,
    required this.remark,
    required this.deleteData,
    required this.cancelEditData,
    required this.confirmEditData,
  }) : super(key: key);

  @override
  State<BloodSugarEditWidgetMore> createState() =>
      _BloodSugarEditWidgetMoreState();
}

class _BloodSugarEditWidgetMoreState extends State<BloodSugarEditWidgetMore> {
  int invalidValueType = 0;
  TextEditingController bloodSugarController = TextEditingController();
  TextEditingController bloodSugar_Controller = TextEditingController(); //小数
  TextEditingController remarkController = TextEditingController();
  MealButtonsRow mealButtons = MealButtonsRow(
    selectedIndex: 0,
  );
  FeelingsButtonsRow feelingsButtons = FeelingsButtonsRow(
    selectedIndex: 0,
  );

  void updateTime(DateTime newTime) {
    setState(() {
      widget.time = newTime;
      widget.bloodSugar = int.parse(bloodSugarController.text);
      widget.bloodSugar_ = int.parse(bloodSugar_Controller.text);
      widget.feeling = feelingsButtons.getSelectedButtonIndex();
      widget.meal = mealButtons.getSelectedButtonIndex();
      widget.remark = remarkController.text;
    });
  }

  // 显示未修改前的值
  void getBeforeEditValue() {
    bloodSugarController =
        TextEditingController(text: widget.bloodSugar.toString());
    bloodSugar_Controller =
        TextEditingController(text: widget.bloodSugar_.toString());
    remarkController = TextEditingController(text: widget.remark);
    mealButtons = MealButtonsRow(
      selectedIndex: widget.meal,
    );
    feelingsButtons = FeelingsButtonsRow(
      selectedIndex: widget.feeling,
    );
  }

  // 获取标题 中文+英文
  Widget getTitle(String TitleChn, String TitleEng) {
    return Column(
      children: [
        Text(
          "${TitleChn}",
          style: const TextStyle(fontSize: 18, fontFamily: "BalooBhai"),
        ),
        Text(
          "${TitleEng}",
          style: const TextStyle(
              fontSize: 14,
              fontFamily: "Blinker",
              color: Color.fromARGB(255, 109, 109, 109)),
        )
      ],
    );
  }

  // 值的输入框
  Widget getEditWidget(TextEditingController controller,
      TextEditingController controller_, String hintText, String hintText_) {
    double height = 41;
    return Container(
      height: height,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: height - 1,
            child: TextFormField(
              maxLength: 2,
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  counterText: "",
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 167, 166, 166),
                  ),
                  hintText: hintText,
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5)),
              textAlign: TextAlign.right,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
            ),
          ),
          Container(
            height: 40,
            width: 10,
            /* child: const Text(
              " . ",
              style: TextStyle(fontSize: 35, fontFamily: "Blinker"),
            ), */
            //alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Container(
                  height: 20,
                  width: 10,
                  color: Colors.white,
                ),
                Image.asset("assets/icons/dot.png", width: 10, height: 10),
              ],
            ),
          ),
          SizedBox(
            width: 25,
            height: height - 1,
            child: TextFormField(
              maxLength: 1,
              controller: controller_,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  counterText: "",
                  hintText: hintText_,
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 167, 166, 166),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5)),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "mmol/L",
            style: TextStyle(fontSize: 16, fontFamily: "Blinker"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 输入的controller
    getBeforeEditValue();

    //DateTime time = DateTime.now();
    return UnconstrainedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              //color: Colors.white,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.2),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(120, 151, 151, 151),
                  offset: Offset(0, 5),
                  blurRadius: 5.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 左边标题
                      Container(
                        child: Column(
                          children: [
                            getTitle("时间", "TIME"),
                            getTitle("血糖", "BS"),
                            getTitle("用餐", "MEAL"),
                            getTitle("感觉", "FEELINGS"),
                            getTitle("备注", "REMARKS"),
                          ],
                        ),
                      ),

                      const SizedBox(width: 5),

                      // 右边的子容器 （值）
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 时间
                            Container(
                              height: 41,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: TimePicker(
                                    time: widget.time, updateTime: updateTime),
                              ),
                            ),
                            //
                            const SizedBox(
                              height: 5,
                            ),

                            // 修改血糖
                            getEditWidget(
                                bloodSugarController,
                                bloodSugar_Controller,
                                bloodSugarController.text,
                                bloodSugar_Controller.text),

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            // 修改手臂
                            mealButtons,

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            //修改感觉
                            feelingsButtons,

                            //
                            const SizedBox(height: 5),

                            // 备注
                            Container(
                              height: 41,
                              child: SizedBox(
                                width: 150,
                                height: 40,
                                child: TextFormField(
                                  controller: remarkController,
                                  //initialValue: widget.SBloodpressure,
                                  decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: "-",
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 167, 166, 166),
                                      ),
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 6)),
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: const TextStyle(
                                      fontSize: 20, fontFamily: "BalooBhai"),
                                ),
                              ),
                            ),

                            //
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),

                  //警告信息
                  invalidValueType > 0
                      ? Container(
                          height: 20,
                          alignment: Alignment.centerRight,
                          child: Text(
                            invalidValueText[invalidValueType],
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontFamily: "Blinker"),
                          ),
                        )
                      : const SizedBox(
                          height: 10,
                        ),

                  //
                  const SizedBox(height: 10),

                  //删除，取消，确定
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //取消修改数据
                      OtherButton(
                          onPressed: () {
                            deleteDataMark = true;
                            widget.deleteData();
                          },
                          type: 0),

                      // 确定修改数据
                      Container(
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OtherButton(
                                onPressed: widget.cancelEditData, type: 1),
                            const SizedBox(width: 5),
                            OtherButton(
                                onPressed: () {
                                  if (bloodSugarController.text == "" ||
                                      bloodSugar_Controller.text == "") {
                                    invalidValueType = 1;
                                  } else {
                                    invalidValueType = 0;
                                  }

                                  if (invalidValueType > 0) {
                                    // print(
                                    //      "invalidvalue: $invalidValueType ${invalidValueText[invalidValueType]}");
                                    setState(() {});
                                    return;
                                  }

                                  /*  print(widget.id);
                            print(widget.time);
                            print(SBloodpressureController.text);
                            print(DBloodpressureController.text);
                            print(heartRateController.text);
                            print(armButtons.getSelectedButtonIndex());
                            print(feelingsButtons.getSelectedButtonIndex()); */
                                  double newBloodSugar = double.parse(
                                      bloodSugarController.text +
                                          "." +
                                          bloodSugar_Controller.text);
                                  afterEditedValue = newValue(
                                      widget.id,
                                      widget.time,
                                      //double.parse(bloodSugarController.text),
                                      newBloodSugar,
                                      mealButtons.getSelectedButtonIndex(),
                                      feelingsButtons.getSelectedButtonIndex(),
                                      remarkController.text);
                                  widget.confirmEditData();
                                },
                                type: 2),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

// 暂无数据
class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(120, 151, 151, 151),
              offset: Offset(0, 5),
              blurRadius: 5.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "暂无数据",
            style: TextStyle(
                fontSize: 20,
                fontFamily: "BalooBhai",
                color: Color.fromRGBO(48, 48, 48, 1)),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// 页面模块

// 此页面
class BloodSugarEdit extends StatefulWidget {
  final Map arguments; // 需要 accountId, nickname, date, bsDataId

  BloodSugarEdit({Key? key, required this.arguments});
  @override
  _BloodSugarEditState createState() => _BloodSugarEditState();
}

class _BloodSugarEditState extends State<BloodSugarEdit> {
  DateTime addTime = DateTime.now();
  DateTime date = DateTime.now();
  //int bsDataId = -1;
  // int prevPage = 0;

  void getDataFromServer() async {
    //print(
    //    '血糖修改页面请求日期：${date.year}-${date.month}-${date.day}....................................');
    String requestDate = getFormattedDate(date);

    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    response = await dio.get(
      widget.arguments["accountId"] >= 0
          ? "http://43.138.75.58:8080/api/blood-sugar/get-by-date?date=$requestDate&accountId=${widget.arguments["accountId"]}"
          : "http://43.138.75.58:8080/api/blood-sugar/get-by-date?date=$requestDate",
      /* queryParameters: {
        "startDate": requestDate,
        "endDate": requestDate,
      }, */
    );
    if (response.data["code"] == 200) {
      //print("获取血糖数据成功EDIT");
      //print(response.data["data"]);
      data = response.data["data"];
      //bpdata = response.data["data"];
    } else {
      print(response);
      data = [];
    }

    titleDateWidget =
        TitleDate(date: date, updateView: updateView, updateDate: updateDate);
    dataWidget = [];
    dataWidget.add(titleDateWidget);
    //data = [];

    for (int i = 0; i < data.length; i++) {
      int id_ = data[i]["id"];
      String date_ = data[i]["date"];
      String timeStr = data[i]["time"];
      int hour = int.parse(timeStr.split(":")[0]);
      int minute = int.parse(timeStr.split(":")[1]);
      DateTime time_ = DateTime(2023, 01, 01, hour, minute);
      String BS = (data[i]["bs"]).toString();
      int meal_ = data[i]["meal"];
      int feeling_ = data[i]["feeling"];
      String remark_ = data[i]["remark"] ?? "暂无备注";
      data[i]["isExpanded"] = 0; // 默认收起

      if (id_ == widget.arguments['bsDataId']) {
        data[i]["isExpanded"] = 1;
        widget.arguments['bsDataId'] = -1;
      }

      /* print("第$i条数据");
      print("id: $id_");
      print("date: $date_");
      print("time: $time_");
      print("sbp: $sbp_");
      print("dbp: $dbp_");
      print("heartRate: $heartRate_");
      print("arm: $arm_");
      print("feeling: $feeling_");
      print("remark: $remark_");
      print("============"); */

      dataWidget.add(UnconstrainedBox(
        child: BloodPressureEditWidget(
          accountId: widget.arguments["accountId"],
          id: id_,
          date: date,
          time: time_,
          bloodSugar: int.parse(BS.split(".")[0]),
          bloodSugar_: int.parse(BS.split(".")[1]),
          meal: meal_,
          feeling: feeling_,
          isExpanded: 0,
          remark: remark_,
          updateParent: updateView,
          updateData: updateData,
        ),
      ));
    }

    if (data.isEmpty) {
      dataWidget.add(NoDataWidget());
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    date = widget.arguments['date'];
    //bsDataId = widget.arguments['bsDataId'];
    // 先从后端获取数据
    getDataFromServer();
  }

  void updateDate(DateTime newDate) {
    //print("new date: $newDate");
    date = newDate;
    getDataFromServer();
  }

  void updateData() {
    //print("刷新，日期：${date.year}年${date.month}月${date.day}日");
    getDataFromServer();
  }

  // 控制同一时间只有一个能展开进行编辑，不会影响数据
  void updateView() {
    //print("updateView");

    List<int> isExpandedArray = [];
    for (int i = 0; i < data.length; i++) {
      //print("展开状态 isExpanded: ${data[i]["id"]} ${data[i]["isExpanded"]}");
      isExpandedArray.add(data[i]["isExpanded"]);
    }

    List<Widget> dataWidgetTemp = [];
    dataWidgetTemp.add(titleDateWidget);
    for (int i = 0; i < data.length; i++) {
      String timeStr = data[i]["time"];
      int hour = int.parse(timeStr.split(":")[0]);
      int minute = int.parse(timeStr.split(":")[1]);
      DateTime time_ = DateTime(2023, 01, 01, hour, minute);
      String BS = (data[i]["bs"].toString());
      dataWidgetTemp.add(UnconstrainedBox(
        child: BloodPressureEditWidget(
          accountId: widget.arguments["accountId"],
          id: data[i]["id"],
          date: date,
          time: time_,
          bloodSugar: int.parse(BS.split(".")[0]),
          bloodSugar_: int.parse(BS.split(".")[1]),
          meal: data[i]["meal"],
          feeling: data[i]["feeling"],
          isExpanded: isExpandedArray[i],
          remark: data[i]["remark"] ?? "暂无备注",
          updateParent: updateView,
          updateData: updateData,
        ),
      ));
    }

    if (data.length == 0) {
      dataWidget.add(NoDataWidget());
    }

    dataWidget = dataWidgetTemp;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print("血压修改页面刷新");
    return Scaffold(
      /*  appBar: AppBar(
        title: const Text(
          "TriGuard",
          style: TextStyle(
            fontFamily: 'BalooBhai',
            fontSize: 26,
            color: Colors.black,
          ),
        ),
        flexibleSpace: getHeader(MediaQuery.of(context).size.width,
            (MediaQuery.of(context).size.height * 0.1 + 11)),
      ), */

      appBar: widget.arguments["accountId"] < 0
          ? getAppBar(0, true, "TriGuard")
          : getAppBar(1, true, widget.arguments["nickname"]),

      // 标题，日期与数据
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: dataWidget.length,
          itemBuilder: (BuildContext context, int index) {
            return dataWidget[index];
          },
        ),
      ),

      // 添加数据的按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //print("我要添加血糖数据");
          setState(() {
            dataWidget.insert(
                1,
                addDataWidget(
                  accountId: widget.arguments["accountId"],
                  date: date,
                  time: addTime,
                  updateData: updateData,
                ));
          });
        },
        shape: const CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 237, 136, 247),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
