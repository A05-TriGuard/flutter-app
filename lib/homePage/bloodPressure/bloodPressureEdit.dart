import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:triguard/component/titleDate/titleDate.dart';
import 'package:dio/dio.dart';

import '../../component/header/header.dart';
import '../../account/token.dart';
import "../../other/other.dart";

// 自定义函数
typedef UpdateTimeCallback = void Function(DateTime newTime);
typedef UpdateDateCallback = void Function(DateTime newDate);

// 删除 取消 确定
List<String> armButtonTypes = ["左手", "右手", "不选"];
List<String> feelingButtonTypes = ["开心", "还好", "不好"];
List<String> functionButtonTypes = ["删除", "取消", "确定"];
List<String> invalidValueText = ["", "收缩压必须填写", "舒张压必须填写", "心率必须填写"];
List<Color> functionButtonColors = const [
  Color.fromRGBO(253, 108, 108, 1),
  Color.fromRGBO(144, 235, 235, 1),
  Color.fromRGBO(173, 255, 144, 1),
];

// 血压数据
List<dynamic> data = [];
// 血压数据列表
List<Widget> dataWidget = [];

// 标题组件
late Widget titleDateWidget;

// 修改血压数据的填写框
late newValue afterEditedValue;
bool deleteDataMark = false;

// 修改血压数据的新值
// ignore: camel_case_types
class newValue {
  int id = 0;
  DateTime time = DateTime.now();
  int SBloodpressure = 0;
  int DBloodpressure = 0;
  int heartRate = 0;
  int armIndex = 0;
  int feelingIndex = 0;
  String remarks = "";

  newValue(this.id, this.time, this.SBloodpressure, this.DBloodpressure,
      this.heartRate, this.armIndex, this.feelingIndex, this.remarks);

  void clear() {
    id = 0;
    time = DateTime.now();
    SBloodpressure = 0;
    DBloodpressure = 0;
    heartRate = 0;
    armIndex = 0;
    feelingIndex = 0;
    remarks = "";
  }

  void printValue() {
    print("id: $id");
    print("time: $time");
    print("SBloodpressure: $SBloodpressure");
    print("DBloodpressure: $DBloodpressure");
    print("heartRate: $heartRate");
    print("armIndex: $armIndex");
    print("feelingIndex: $feelingIndex");
    print("remarks: $remarks");
  }
}

// 获取某个id的type数据
int getDataById(int id, String type) {
  for (int i = 0; i < data.length; i++) {
    if (data[i]["id"] == id) {
      return data[i][type];
    }
  }
  return 0;
}

// 修改某个id的type数据
void setDataById(int id, String type, int value) {
  for (int i = 0; i < data.length; i++) {
    if (data[i]["id"] == id) {
      data[i][type] = value;
      return;
    }
  }
}

// =================================================================================

// 添加数据的 填写框
// ignore: must_be_immutable
class AddDataWidget extends StatefulWidget {
  final int accountId;
  final VoidCallback updateData;
  DateTime date;
  DateTime time = DateTime.now();

  AddDataWidget({
    Key? key,
    required this.updateData,
    required this.time,
    required this.date,
    required this.accountId,
  }) : super(key: key);

  @override
  State<AddDataWidget> createState() => _AddDataWidgetState();
}

class _AddDataWidgetState extends State<AddDataWidget> {
  // 输入框的控制器
  // ignore: non_constant_identifier_names
  final TextEditingController SBloodpressureController =
      TextEditingController();
  // ignore: non_constant_identifier_names
  final TextEditingController DBloodpressureController =
      TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  // 所选的手臂
  ArmButtonsRow armButtons = ArmButtonsRow(
    selectedIndex: 2,
  );
  // 所选的感觉
  FeelingsButtonsRow feelingsButtons = FeelingsButtonsRow(
    selectedIndex: 1,
  );
  // 时间
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
      "sbp": int.parse(SBloodpressureController.text),
      "dbp": int.parse(DBloodpressureController.text),
      "heartRate": int.parse(heartRateController.text),
      "arm": armButtons.getSelectedButtonIndex(),
      "feeling": feelingsButtons.getSelectedButtonIndex(),
    };

    if (remarkController.text != "") {
      newVal["remark"] = remarkController.text;
    }

    if (widget.accountId >= 0) {
      newVal["accountId"] = widget.accountId;
    }

    final Dio dio = Dio();

    const String addDataApi =
        'http://43.138.75.58:8080/api/blood-pressure/create';

    try {
      var token = await storage.read(key: 'token');
      dio.options.headers["Authorization"] = "Bearer $token";
      Response response = await dio.post(
        addDataApi,
        data: newVal,
      );

      if (response.data['code'] == 200) {
        return;
      } else {
        return;
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        return;
      } else {
        return;
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
  Widget getTitle(String titleChn, String titleEng) {
    return Column(
      children: [
        Text(
          titleChn,
          style: const TextStyle(fontSize: 18, fontFamily: "BalooBhai"),
        ),
        Text(
          titleEng,
          style: const TextStyle(
              fontSize: 14,
              fontFamily: "Blinker",
              color: Color.fromARGB(255, 109, 109, 109)),
        )
      ],
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
            height: 430,
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 左边的标题
                      Column(
                        children: [
                          getTitle("时间", "TIME"),
                          getTitle("收缩压", "SBP"),
                          getTitle("舒张压", "DBP"),
                          getTitle("心率", "PULSE"),
                          getTitle("手臂", "ARM"),
                          getTitle("感觉", "FEELINGS"),
                          getTitle("备注", "REMARKS"),
                        ],
                      ),

                      const SizedBox(width: 5),

                      // 右边的子容器（值的填写）
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 时间
                          SizedBox(
                            height: 41,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: TimePicker(
                                  time: widget.time, updateTime: updateTime),
                            ),
                          ),
                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 收缩压
                          SizedBox(
                            height: 41,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 75,
                                  height: 40,
                                  child: TextField(
                                    maxLength: 3,
                                    controller: SBloodpressureController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: "100",
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 167, 166, 166),
                                      ),
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    ),
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    style: const TextStyle(
                                        fontSize: 30, fontFamily: "BalooBhai"),
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

                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 舒张压
                          SizedBox(
                            height: 41,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 75,
                                  height: 40,
                                  child: TextField(
                                    maxLength: 3,
                                    controller: DBloodpressureController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: "70",
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 167, 166, 166),
                                      ),
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    ),
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    style: const TextStyle(
                                        fontSize: 30, fontFamily: "BalooBhai"),
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
                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 心率
                          SizedBox(
                            height: 41,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 75,
                                  height: 40,
                                  child: TextField(
                                    maxLength: 3,
                                    controller: heartRateController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: "90",
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 167, 166, 166),
                                      ),
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    ),
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    style: const TextStyle(
                                        fontSize: 30, fontFamily: "BalooBhai"),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  "次/分",
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: "Blinker"),
                                ),
                              ],
                            ),
                          ),

                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 修改手臂
                          armButtons,

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
                          SizedBox(
                            height: 41,
                            child: SizedBox(
                              width: 150,
                              height: 40,
                              child: TextFormField(
                                controller: remarkController,
                                decoration: const InputDecoration(
                                  counterText: "",
                                  hintText: "-",
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 167, 166, 166),
                                  ),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 6),
                                ),
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //取消添加数据
                      OtherButton(
                          onPressed: () {
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
                            if (SBloodpressureController.text == "") {
                              invalidValueType = 1;
                            } else if (DBloodpressureController.text == "") {
                              invalidValueType = 2;
                            } else if (heartRateController.text == "") {
                              invalidValueType = 3;
                            } else {
                              invalidValueType = 0;
                            }

                            if (invalidValueType > 0) {
                              setState(() {});
                              return;
                            }

                            // 添加数据至后端
                            addBloodPressureData().then((_) {
                              if (data.isEmpty) {
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

  const OtherButton({
    Key? key,
    required this.onPressed,
    required this.type,
  }) : super(key: key);

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
        padding: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: functionButtonColors[widget.type],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: const Color.fromRGBO(122, 119, 119, 0.43),
          ),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Text(
            functionButtonTypes[widget.type],
            style: const TextStyle(
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

// 手臂的按钮
class ArmButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSelected;

  const ArmButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<ArmButton> createState() => _ArmButtonState();
}

class _ArmButtonState extends State<ArmButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        height: 40,
        width: 50,
        padding: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color.fromRGBO(253, 134, 255, 0.66)
              : const Color.fromRGBO(218, 218, 218, 0.66),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: const Color.fromRGBO(122, 119, 119, 0.43),
          ),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.isSelected
                  ? const Color.fromRGBO(66, 9, 119, 0.773)
                  : const Color.fromRGBO(94, 68, 68, 100),
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

// 感觉按钮
class FeelingsButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final bool isSelected;

  const FeelingsButton({
    super.key,
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
        padding: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color.fromRGBO(253, 134, 255, 0.66)
              : const Color.fromRGBO(218, 218, 218, 0.66),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: const Color.fromRGBO(122, 119, 119, 0.43)),
        ),
        alignment: Alignment.center,
        child: SizedBox(
          height: 25,
          width: 25,
          child: Image.asset(
            widget.iconPath,
          ),
        ),
      ),
    );
  }
}

// 手臂的按钮（左手，右手，不选）
// ignore: must_be_immutable
class ArmButtonsRow extends StatefulWidget {
  int selectedIndex;

  ArmButtonsRow({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ArmButtonsRowState createState() => _ArmButtonsRowState();

  int getSelectedButtonIndex() {
    return selectedIndex;
  }
}

class _ArmButtonsRowState extends State<ArmButtonsRow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 41,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ArmButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 0;
              });
            },
            text: "左手",
            isSelected: widget.selectedIndex == 0,
          ),
          const SizedBox(width: 5),
          ArmButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 1;
              });
            },
            text: "右手",
            isSelected: widget.selectedIndex == 1,
          ),
          const SizedBox(width: 5),
          ArmButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 2;
              });
            },
            text: "不选",
            isSelected: widget.selectedIndex == 2,
          ),
        ],
      ),
    );
  }
}

// 感觉的按钮（较好，还好，较差）
// ignore: must_be_immutable
class FeelingsButtonsRow extends StatefulWidget {
  int selectedIndex;

  FeelingsButtonsRow({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FeelingsButtonsRowState createState() => _FeelingsButtonsRowState();

  int getSelectedButtonIndex() {
    return selectedIndex;
  }
}

class _FeelingsButtonsRowState extends State<FeelingsButtonsRow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 41,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FeelingsButton(
            onPressed: () {
              setState(() {
                widget.selectedIndex = 0;
              });
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
  const TitleDate({
    Key? key,
    required this.date,
    required this.updateView,
    required this.updateDate,
  }) : super(key: key);

  @override
  State<TitleDate> createState() => _TitleDateState();
}

class _TitleDateState extends State<TitleDate> {
  DateTime date = DateTime.now();
  DateTime oldDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // 获取星期几
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

  // 显示日期选择框
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
              Row(children: [
                const Text(
                  "修改血压",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Image.asset("assets/icons/bloodPressure.png",
                    width: 20, height: 20),
              ]),
              const SizedBox(
                height: 10,
              ),
              Row(children: [
                Text(
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
                    onPressed: () => _showDialog(Column(
                      children: [
                        Expanded(
                          child: CupertinoDatePicker(
                            initialDateTime: date,
                            maximumDate: DateTime.now(),
                            mode: CupertinoDatePickerMode.date,
                            use24hFormat: true,
                            showDayOfWeek: true,
                            onDateTimeChanged: (DateTime newDate) {
                              date = newDate;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: 320,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 取消按钮
                              SizedBox(
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
                                      const Color.fromARGB(255, 221, 223, 223),
                                    ),
                                  ),
                                  child: const Text(
                                    '取消',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // 确定按钮
                              SizedBox(
                                width: 120,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      oldDate = date;
                                    });
                                    Navigator.of(context).pop();

                                    // 后端
                                    widget.updateDate(date);
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              const Color.fromARGB(
                                                  255, 118, 241, 250))),
                                  child: const Text(
                                    '确定',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
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
              ])
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
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int feeling;
  final int arm;
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
    required this.SBloodpressure,
    required this.DBloodpressure,
    required this.heartRate,
    required this.feeling,
    required this.arm,
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
  // ignore: non_constant_identifier_names
  Widget? BPEditWidget;

  // 删除数据
  Future<void> deleteData(int id) async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    response = await dio.get(widget.accountId >= 0
        ? "http://43.138.75.58:8080/api/blood-pressure/delete?id=$id&accountId=${widget.accountId}"
        : "http://43.138.75.58:8080/api/blood-pressure/delete?id=$id");
    if (response.data["code"] == 200) {
      return;
    }
  }

  // 修改数据
  Future<void> editData(int id, newValue afterEditedValue) async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    var newVal = {
      "id": afterEditedValue.id,
      "time":
          "${afterEditedValue.time.hour.toString().padLeft(2, '0')}:${afterEditedValue.time.minute.toString().padLeft(2, '0')}",
      "sbp": afterEditedValue.SBloodpressure,
      "dbp": afterEditedValue.DBloodpressure,
      "heartRate": afterEditedValue.heartRate,
      "arm": afterEditedValue.armIndex,
      "feeling": afterEditedValue.feelingIndex,
      "remark": afterEditedValue.remarks,
    };

    if (widget.accountId >= 0) {
      newVal["accountId"] = widget.accountId;
    }

    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/blood-pressure/update",
        data: newVal,
      );

      if (response.data['code'] == 200) {
        return;
      }
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        return;
      } else {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 当收起时，点击任意地方可以展开

        if (getDataById(widget.id, "isExpanded") == 0) {
          setState(() {
            setDataById(widget.id, "isExpanded", 1);

            // 其他的一律收起
            for (int i = 0; i < data.length; i++) {
              if (data[i]["id"] != widget.id) {
                setDataById(data[i]["id"], "isExpanded", 0);
              }
            }
          });
          widget.updateParent();
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
            height: getDataById(widget.id, "isExpanded") == 1
                ? 430
                : MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.85,

            alignment: Alignment.center,
            //https://stackoverflow.com/questions/56298325/overflow-warning-in-animatedcontainer-adjusting-height
            //切换的一瞬间会overflow，用SingleChildScrollView包裹一下解决
            child: getDataById(widget.id, "isExpanded") == 1
                // 展开
                ? SingleChildScrollView(
                    child: BloodPressureEditWidgetMore(
                      id: widget.id,
                      time: widget.time,
                      SBloodpressure: widget.SBloodpressure,
                      DBloodpressure: widget.DBloodpressure,
                      heartRate: widget.heartRate,
                      arm: widget.arm,
                      feeling: widget.feeling,
                      remark: widget.remark,
                      deleteData: () {
                        deleteData(widget.id).then((_) {
                          widget.updateData();
                        });
                      },
                      cancelEditData: () {
                        setState(() {
                          setDataById(widget.id, "isExpanded", 0);
                        });
                      },
                      confirmEditData: () {
                        afterEditedValue.printValue();

                        editData(widget.id, afterEditedValue).then((_) {
                          widget.updateData();
                        });
                      },
                    ),
                  )
                // 收起
                : SingleChildScrollView(
                    child: BloodPressureEditWidgetLess(
                      id: widget.id,
                      time: widget.time,
                      SBloodpressure: widget.SBloodpressure,
                      DBloodpressure: widget.DBloodpressure,
                      heartRate: widget.heartRate,
                      arm: widget.arm,
                      feeling: widget.feeling,
                      remark: widget.remark,
                    ),
                  ),
          )
        ],
      ),
    );
  }
}

// 只展示
// ignore: must_be_immutable
class BloodPressureEditWidgetLess extends StatefulWidget {
  final int id;
  DateTime time;
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int arm;
  final int feeling;
  final String remark;

  BloodPressureEditWidgetLess(
      {Key? key,
      required this.id,
      required this.time,
      required this.SBloodpressure,
      required this.DBloodpressure,
      required this.heartRate,
      required this.feeling,
      required this.arm,
      required this.remark})
      : super(key: key);

  @override
  State<BloodPressureEditWidgetLess> createState() =>
      _BloodPressureEditWidgetLessState();
}

class _BloodPressureEditWidgetLessState
    extends State<BloodPressureEditWidgetLess> {
  List<String> armButtonTypes = ["左手", "右手", "不选"];
  List<String> feelingButtonTypes = ["开心", "还好", "不好"];
  PageController pageController = PageController();
  bool showRemark = false;

  // 获取数据信息
  Widget getInfoPage() {
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
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
                '${widget.time.hour < 10 ? "0${widget.time.hour}" : widget.time.hour}:${widget.time.minute < 10 ? "0${widget.time.minute}" : widget.time.minute}',
                style: const TextStyle(fontSize: 20, fontFamily: "BalooBhai")),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '血压: ${widget.SBloodpressure} / ${widget.DBloodpressure}',
                  style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Text(
                  '心率: ${widget.heartRate} ',
                  style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '手臂: ${armButtonTypes[widget.arm]}',
                  style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Text(
                  '感觉: ${feelingButtonTypes[widget.feeling]}',
                  style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 获取备注信息
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

  // 获取页码
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
class BloodPressureEditWidgetMore extends StatefulWidget {
  final int id;
  DateTime time;
  int SBloodpressure;
  int DBloodpressure;
  int heartRate;
  int feeling;
  int arm;
  String remark;
  final VoidCallback deleteData;
  final VoidCallback cancelEditData;
  final VoidCallback confirmEditData;

  BloodPressureEditWidgetMore({
    Key? key,
    required this.id,
    required this.time,
    required this.SBloodpressure,
    required this.DBloodpressure,
    required this.heartRate,
    required this.feeling,
    required this.arm,
    required this.remark,
    required this.deleteData,
    required this.cancelEditData,
    required this.confirmEditData,
  }) : super(key: key);

  @override
  State<BloodPressureEditWidgetMore> createState() =>
      _BloodPressureEditWidgetMoreState();
}

class _BloodPressureEditWidgetMoreState
    extends State<BloodPressureEditWidgetMore> {
  int invalidValueType = 0;
  TextEditingController SBloodpressureController = TextEditingController();
  TextEditingController DBloodpressureController = TextEditingController();
  TextEditingController heartRateController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  ArmButtonsRow armButtons = ArmButtonsRow(
    selectedIndex: 0,
  );
  FeelingsButtonsRow feelingsButtons = FeelingsButtonsRow(
    selectedIndex: 0,
  );

  void updateTime(DateTime newTime) {
    setState(() {
      widget.time = newTime;
      widget.DBloodpressure = int.parse(DBloodpressureController.text);
      widget.SBloodpressure = int.parse(SBloodpressureController.text);
      widget.heartRate = int.parse(heartRateController.text);
      widget.feeling = feelingsButtons.getSelectedButtonIndex();
      widget.arm = armButtons.getSelectedButtonIndex();
      widget.remark = remarkController.text;
    });
  }

  // 显示未修改前的值
  void getBeforeEditValue() {
    SBloodpressureController =
        TextEditingController(text: widget.SBloodpressure.toString());
    DBloodpressureController =
        TextEditingController(text: widget.DBloodpressure.toString());
    heartRateController =
        TextEditingController(text: widget.heartRate.toString());
    remarkController = TextEditingController(text: widget.remark);
    armButtons = ArmButtonsRow(
      selectedIndex: widget.arm,
    );
    feelingsButtons = FeelingsButtonsRow(
      selectedIndex: widget.feeling,
    );
  }

  // 获取标题 中文+英文
  Widget getTitle(String titleChn, String titleEng) {
    return Column(
      children: [
        Text(
          titleChn,
          style: const TextStyle(fontSize: 18, fontFamily: "BalooBhai"),
        ),
        Text(
          titleEng,
          style: const TextStyle(
              fontSize: 14,
              fontFamily: "Blinker",
              color: Color.fromARGB(255, 109, 109, 109)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    getBeforeEditValue();

    return UnconstrainedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
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
                      Column(
                        children: [
                          getTitle("时间", "TIME"),
                          getTitle("收缩压", "SBP"),
                          getTitle("舒张压", "DBP"),
                          getTitle("心率", "PULSE"),
                          getTitle("手臂", "ARM"),
                          getTitle("感觉", "FEELINGS"),
                          getTitle("备注", "REMARKS"),
                        ],
                      ),

                      const SizedBox(width: 5),

                      // 右边的子容器 （值）
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 时间
                          SizedBox(
                            height: 41,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: TimePicker(
                                  time: widget.time, updateTime: updateTime),
                            ),
                          ),
                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 修改收缩压
                          SizedBox(
                            height: 41,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 75,
                                  height: 40,
                                  child: TextFormField(
                                    maxLength: 3,
                                    controller: SBloodpressureController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                        counterText: "",
                                        hintText: "${widget.SBloodpressure}",
                                        hintStyle: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 167, 166, 166),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                0, 0, 0, 5)),
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    style: const TextStyle(
                                        fontSize: 30, fontFamily: "BalooBhai"),
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

                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 修改舒张压
                          SizedBox(
                            height: 41,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 75,
                                  height: 40,
                                  child: TextFormField(
                                    maxLength: 3,
                                    controller: DBloodpressureController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                        counterText: "",
                                        hintText: "${widget.DBloodpressure}",
                                        hintStyle: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 167, 166, 166),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                0, 0, 0, 5)),
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    style: const TextStyle(
                                        fontSize: 30, fontFamily: "BalooBhai"),
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

                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 修改心率
                          SizedBox(
                            height: 41,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 75,
                                  height: 40,
                                  child: TextFormField(
                                    maxLength: 3,
                                    controller: heartRateController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                        counterText: "",
                                        hintText: "${widget.heartRate}",
                                        hintStyle: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 167, 166, 166),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                0, 0, 0, 5)),
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    style: const TextStyle(
                                        fontSize: 30, fontFamily: "BalooBhai"),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  "次/分",
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: "Blinker"),
                                ),
                              ],
                            ),
                          ),

                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 修改手臂
                          armButtons,

                          //
                          const SizedBox(
                            height: 5,
                          ),

                          //修改感觉
                          feelingsButtons,

                          //
                          const SizedBox(height: 5),

                          // 备注
                          SizedBox(
                            height: 41,
                            child: SizedBox(
                              width: 150,
                              height: 40,
                              child: TextFormField(
                                controller: remarkController,
                                decoration: const InputDecoration(
                                  counterText: "",
                                  hintText: "-",
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 167, 166, 166),
                                  ),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 6),
                                ),
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
                      Row(
                        children: [
                          OtherButton(
                              onPressed: widget.cancelEditData, type: 1),
                          const SizedBox(width: 5),
                          OtherButton(
                              onPressed: () {
                                if (SBloodpressureController.text == "") {
                                  invalidValueType = 1;
                                } else if (DBloodpressureController.text ==
                                    "") {
                                  invalidValueType = 2;
                                } else if (heartRateController.text == "") {
                                  invalidValueType = 3;
                                } else {
                                  invalidValueType = 0;
                                }

                                if (invalidValueType > 0) {
                                  setState(() {});
                                  return;
                                }
                                afterEditedValue = newValue(
                                    widget.id,
                                    widget.time,
                                    int.parse(SBloodpressureController.text),
                                    int.parse(DBloodpressureController.text),
                                    int.parse(heartRateController.text),
                                    armButtons.getSelectedButtonIndex(),
                                    feelingsButtons.getSelectedButtonIndex(),
                                    remarkController.text);
                                widget.confirmEditData();
                              },
                              type: 2),
                        ],
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
class BloodPressureEdit extends StatefulWidget {
  final Map arguments;
  // 需要 accountId, nickname, date, bpDataId

  const BloodPressureEdit({Key? key, required this.arguments})
      : super(key: key);
  @override
  _BloodPressureEditState createState() => _BloodPressureEditState();
}

class _BloodPressureEditState extends State<BloodPressureEdit> {
  DateTime addTime = DateTime.now();
  DateTime date = DateTime.now();
  int bpDataId = -1;
  //int prevPage = 0;

  void getDataFromServer() async {
    String requestDate = getFormattedDate(date);

    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    //print("getDataFromServer");
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    response = await dio.get(widget.arguments["accountId"] >= 0
        ? "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range?startDate=$requestDate&endDate=$requestDate&accountId=${widget.arguments["accountId"]}"
        : "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range?startDate=$requestDate&endDate=$requestDate");
    if (response.data["code"] == 200) {
      data = response.data["data"];
    } else {
      data = [];
    }

    titleDateWidget =
        TitleDate(date: date, updateView: updateView, updateDate: updateDate);
    dataWidget = [];
    dataWidget.add(titleDateWidget);

    for (int i = 0; i < data.length; i++) {
      int id_ = data[i]["id"];
      String timeStr = data[i]["time"];
      int hour = int.parse(timeStr.split(":")[0]);
      int minute = int.parse(timeStr.split(":")[1]);
      DateTime time_ = DateTime(2023, 01, 01, hour, minute);
      int sbp_ = data[i]["sbp"];
      int dbp_ = data[i]["dbp"];
      int heartRate_ = data[i]["heartRate"];
      int arm_ = data[i]["arm"];
      int feeling_ = data[i]["feeling"];
      String remark_ = data[i]["remark"] ?? "暂无备注";
      data[i]["isExpanded"] = 0; // 默认收起

      if (id_ == bpDataId) {
        data[i]["isExpanded"] = 1;
        bpDataId = -1;
      }

      dataWidget.add(UnconstrainedBox(
        child: BloodPressureEditWidget(
          accountId: widget.arguments["accountId"],
          id: id_,
          date: date,
          time: time_,
          SBloodpressure: sbp_,
          DBloodpressure: dbp_,
          heartRate: heartRate_,
          arm: arm_,
          feeling: feeling_,
          isExpanded: 0,
          remark: remark_,
          updateParent: updateView,
          updateData: updateData,
        ),
      ));
    }

    if (data.isEmpty) {
      dataWidget.add(const NoDataWidget());
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    date = widget.arguments['date'];
    bpDataId = widget.arguments['bpDataId'];
    // 先从后端获取数据
    getDataFromServer();
  }

  // 更新日期
  void updateDate(DateTime newDate) {
    date = newDate;
    getDataFromServer();
  }

  // 更新数据
  void updateData() {
    getDataFromServer();
  }

  // 控制同一时间只有一个能展开进行编辑，不会影响数据
  void updateView() {
    List<int> isExpandedArray = [];
    for (int i = 0; i < data.length; i++) {
      isExpandedArray.add(data[i]["isExpanded"]);
    }

    List<Widget> dataWidgetTemp = [];
    dataWidgetTemp.add(titleDateWidget);
    for (int i = 0; i < data.length; i++) {
      String timeStr = data[i]["time"];
      int hour = int.parse(timeStr.split(":")[0]);
      int minute = int.parse(timeStr.split(":")[1]);
      DateTime time_ = DateTime(2023, 01, 01, hour, minute);
      dataWidgetTemp.add(UnconstrainedBox(
        child: BloodPressureEditWidget(
          accountId: widget.arguments["accountId"],
          id: data[i]["id"],
          date: date,
          time: time_,
          SBloodpressure: data[i]["sbp"],
          DBloodpressure: data[i]["dbp"],
          heartRate: data[i]["heartRate"],
          arm: data[i]["arm"],
          feeling: data[i]["feeling"],
          isExpanded: isExpandedArray[i],
          remark: data[i]["remark"] ?? "暂无备注",
          updateParent: updateView,
          updateData: updateData,
        ),
      ));
    }

    if (data.length == 0) {
      dataWidget.add(const NoDataWidget());
    }

    dataWidget = dataWidgetTemp;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          setState(() {
            dataWidget.insert(
              1,
              AddDataWidget(
                accountId: widget.arguments["accountId"],
                date: date,
                time: addTime,
                updateData: updateData,
              ),
            );
          });
        },
        shape: const CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 237, 136, 247),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
