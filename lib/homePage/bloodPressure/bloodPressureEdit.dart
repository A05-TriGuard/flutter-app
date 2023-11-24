import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:triguard/component/titleDate/titleDate.dart';

import '../../component/header/header.dart';
import "bpData.dart";

// 删除 取消 确定
List<String> armButtonTypes = ["左手", "右手", "不选"];
List<String> feelingButtonTypes = ["开心", "还好", "不好"];
List<String> functionButtonTypes = ["删除", "取消", "确定"];
List<Color> functionButtonColors = const [
  Color.fromRGBO(253, 108, 108, 1),
  Color.fromRGBO(144, 235, 235, 1),
  Color.fromRGBO(173, 255, 144, 1),
];

late List<Widget> dataWidget;
late Widget titleDateWidget;
Widget addDataButtonWidget = addDataButton();
int randomId = 100;
typedef UpdateTimeCallback = void Function(DateTime newTime);

class newValue {
  int id = 0;
  //int hour = 0;
  //int minute = 0;
  DateTime time = DateTime.now();
  int SBloodpressure = 0;
  int DBloodpressure = 0;
  int heartRate = 0;
  int armIndex = 0;
  int feelingIndex = 0;

  newValue(this.id, this.time, this.SBloodpressure, this.DBloodpressure,
      this.heartRate, this.armIndex, this.feelingIndex);

  void clear() {
    id = 0;
    time = DateTime.now();
    SBloodpressure = 0;
    DBloodpressure = 0;
    heartRate = 0;
    armIndex = 0;
    feelingIndex = 0;
  }

  void printValue() {
    print("id: $id");
    //print("hour: $hour");
    //print("minute: $minute");
    print("time: $time");
    print("SBloodpressure: $SBloodpressure");
    print("DBloodpressure: $DBloodpressure");
    print("heartRate: $heartRate");
    print("armIndex: $armIndex");
    print("feelingIndex: $feelingIndex");
  }
}

String getRemarById(int id) {
  for (int i = 0; i < bpdata.length; i++) {
    if (bpdata[i]["id"] == id) {
      return bpdata[i]["remark"];
    }
  }
  return "";
}

// 获取某个id的数据
int getDataById(int id, String type) {
  for (int i = 0; i < bpdata.length; i++) {
    if (bpdata[i]["id"] == id) {
      return bpdata[i][type];
    }
  }
  return 0;
}

void setDataById(int id, String type, int value) {
  for (int i = 0; i < bpdata.length; i++) {
    if (bpdata[i]["id"] == id) {
      bpdata[i][type] = value;
      //print('${id}:${bpdata[i][type]}');
      return;
    }
  }
  print("set failed");
}

DateTime getTimeById(int id) {
  for (int i = 0; i < bpdata.length; i++) {
    if (bpdata[i]["id"] == id) {
      int hour = int.parse(bpdata[i]["time"].toString().split(":")[0]);
      int minute = int.parse(bpdata[i]["time"].toString().split(":")[1]);
      return DateTime(2023, 11, 11, hour, minute);
    }
  }
  return DateTime.now();
}

void setTimeById(int id, DateTime time) {
  for (int i = 0; i < bpdata.length; i++) {
    if (bpdata[i]["id"] == id) {
      bpdata[i]["time"] =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      return;
    }
  }
  print("set failed");
}

late newValue afterEditedValue; //= newValue(0, "0", "0", "0", "0", "0", 0, 0);
bool deleteDataMark = false;

int invalidValue() {
  return 0;
}

// =================================================================================

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
            color: Color.fromARGB(255, 167, 167, 167),
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
          child: Icon(
            Icons.add,
            size: 50,
            color: const Color.fromARGB(255, 17, 17, 17),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class addDataWidget extends StatefulWidget {
  final VoidCallback updateParent;
  DateTime time = DateTime.now();

  addDataWidget({Key? key, required this.updateParent, required this.time})
      : super(key: key);

  @override
  State<addDataWidget> createState() => _addDataWidgetState();
}

class _addDataWidgetState extends State<addDataWidget> {
  final TextEditingController hourController = TextEditingController();
  final TextEditingController minuteController = TextEditingController();

  final TextEditingController SBloodpressureController =
      TextEditingController();
  final TextEditingController DBloodpressureController =
      TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  ArmButtonsRow armButtons = ArmButtonsRow(
    selectedIndex: 2,
  );
  FeelingsButtonsRow feelingsButtons = FeelingsButtonsRow(
    selectedIndex: 1,
  );
  DateTime time = DateTime.now();

  void updateTime(DateTime newTime) {
    setState(() {
      widget.time = newTime;
    });
    //widget.updateParent();
  }

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

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.66,
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
            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      //color: Colors.blue, // 左边容器的颜色

                      child: Column(
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
                    ),

                    const SizedBox(width: 5),

                    // 右边的子容器
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 时间
                          /* Row(
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: TextField(
                                  maxLength: 2,
                                  controller: hourController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  //initialValue: widget.hour,
                                  decoration: InputDecoration(
                                      counterText: "",
                                      hintText: "${DateTime.now().hour}",
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 2)),
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: const TextStyle(
                                      fontSize: 30, fontFamily: "BalooBhai"),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                "时",
                                style: TextStyle(
                                    fontSize: 16, fontFamily: "BalooBhai"),
                              ),
                              SizedBox(
                                width: 50,
                                child: TextField(
                                  maxLength: 2,
                                  controller: minuteController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  //initialValue: widget.minute,
                                  decoration: InputDecoration(
                                      counterText: "",
                                      hintText: "${DateTime.now().minute}",
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 2)),
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: const TextStyle(
                                      fontSize: 30, fontFamily: "BalooBhai"),
                                ),
                              ),
                              const Text(
                                "分",
                                style: TextStyle(
                                    fontSize: 16, fontFamily: "BalooBhai"),
                              ),
                            ],
                          ), */

                          TimePicker(time: widget.time, updateTime: updateTime),

                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 修改收缩压
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.start,
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
                                  //initialValue: widget.SBloodpressure,
                                  decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: "100",
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 5)),
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

                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 修改舒张压
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.start,
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
                                  //initialValue: widget.DBloodpressure,
                                  decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: "80",
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 5)),
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

                          //
                          const SizedBox(
                            height: 5,
                          ),

                          // 修改心率
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.start,
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
                                  //initialValue: widget.heartRate,
                                  decoration: const InputDecoration(
                                      counterText: "",
                                      hintText: "90",
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 5)),
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: const TextStyle(
                                      fontSize: 30, fontFamily: "BalooBhai"),
                                ),
                              ),
                              SizedBox(width: 2),
                              const Text(
                                "次/分",
                                style: TextStyle(
                                    fontSize: 16, fontFamily: "Blinker"),
                              ),
                            ],
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
                          const SizedBox(
                            height: 5,
                          ),

                          //备注
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: TextFormField(
                              controller: remarkController,
                              //initialValue: widget.SBloodpressure,
                              decoration: const InputDecoration(
                                  counterText: "",
                                  hintText: "-",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 6)),
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(
                                  fontSize: 20, fontFamily: "BalooBhai"),
                            ),
                          ),

                          //
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                //删除，取消，确定
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //取消添加数据
                      OtherButton(
                          onPressed: () {
                            print("取消添加数据");
                            setState(() {
                              dataWidget.removeAt(1);
                              widget.updateParent();
                            });
                          },
                          type: 1),
                      const SizedBox(width: 5),

                      //确定添加
                      OtherButton(
                          onPressed: () {
                            randomId += 1;

                            print("确定添加数据：${widget.time}");
                            bpdata.insert(0, {
                              "id": randomId,
                              //"hour": int.parse(hourController.text),
                              //"minute": int.parse(minuteController.text),
                              // time pad 0, example 09:03
                              "time":
                                  "${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}",
                              "hour": widget.time.hour,
                              "minute": widget.time.minute,
                              "sbp": int.parse(SBloodpressureController.text),
                              "dbp": int.parse(DBloodpressureController.text),
                              "heartRate": int.parse(heartRateController.text),
                              "arm": armButtons.getSelectedButtonIndex(),
                              "feeling":
                                  feelingsButtons.getSelectedButtonIndex(),
                              "isExpanded": 0,
                              "remark": remarkController.text,
                            });

                            Widget newWidget = BloodPressureEditWidgetLess(
                              id: randomId,
                              //hour: int.parse(hourController.text),
                              // minute: int.parse(minuteController.text),
                              time: widget.time,
                              SBloodpressure:
                                  int.parse(SBloodpressureController.text),
                              DBloodpressure:
                                  int.parse(DBloodpressureController.text),
                              heartRate: int.parse(heartRateController.text),
                              arm: armButtons.getSelectedButtonIndex(),
                              feeling: feelingsButtons.getSelectedButtonIndex(),
                              remark: remarkController.text,
                            );

                            setState(() {
                              dataWidget.removeAt(1);
                              dataWidget.insert(1, newWidget);
                              widget.updateParent();
                            });

                            /* print(widget.id);
                            print(hourController.text);
                            print(minuteController.text);
                            print(SBloodpressureController.text);
                            print(DBloodpressureController.text);
                            print(heartRateController.text);
                            print(armButtons.getSelectedButtonIndex());
                            print(feelingsButtons.getSelectedButtonIndex());
                            //armButtons

                            afterEditedValue = newValue(
                                widget.id,
                                int.parse(hourController.text),
                                int.parse(minuteController.text),
                                int.parse(SBloodpressureController.text),
                                int.parse(DBloodpressureController.text),
                                int.parse(heartRateController.text),
                                armButtons.getSelectedButtonIndex(),
                                feelingsButtons.getSelectedButtonIndex());
                            widget.confirmEditData(); */
                          },
                          type: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ]),
    );
  }
}

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

// 手臂的按钮
class ArmButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSelected;

  const ArmButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      required this.isSelected})
      : super(key: key);

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

// ignore: must_be_immutable
class ArmButtonsRow extends StatefulWidget {
  int selectedIndex;

  ArmButtonsRow({required this.selectedIndex});

  @override
  _ArmButtonsRowState createState() => _ArmButtonsRowState();

  int getSelectedButtonIndex() {
    return selectedIndex;
  }
}

class _ArmButtonsRowState extends State<ArmButtonsRow> {
  //late int selectedButtonIndex;

  @override
  void initState() {
    super.initState();
    //selectedButtonIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ArmButton(
          onPressed: () {
            setState(() {
              widget.selectedIndex = 0;
            });
            print("左手按钮被点击了！");
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
            print("右手按钮被点击了！");
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
            print("不选按钮被点击了！");
          },
          text: "不选",
          isSelected: widget.selectedIndex == 2,
        ),
      ],
    );
  }
}

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FeelingsButton(
          onPressed: () {
            setState(() {
              widget.selectedIndex = 0;
            });
            print("开心按钮被点击了！");
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
            print("还好按钮被点击了！");
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
            print("不好按钮被点击了！");
          },
          iconPath: "assets/icons/emoji-bad.png",
          isSelected: widget.selectedIndex == 2,
        ),
      ],
    );
  }
}

// “修改血压”标题 与 日期选择
class TitleDate extends StatefulWidget {
  final DateTime date;
  const TitleDate({Key? key, required this.date}) : super(key: key);

  @override
  State<TitleDate> createState() => _TitleDateState();
}

class _TitleDateState extends State<TitleDate> {
  DateTime date = DateTime(2023, 11, 11);
  DateTime oldDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  //DateTime newDate = DateTime(2023, 11, 11);

  // This function displays a CupertinoModalPopup with a reasonable fixed height
  // which hosts CupertinoDatePicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "修改血压",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Image.asset("assets/icons/edit.png",
                          width: 20, height: 20),
                    ]),
              ),
              Container(
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        //"${widget.date.year}年${widget.date.month}月${widget.date.day}日",
                        '${date.year}年${date.month}月${date.day}日',
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
                          padding: EdgeInsets.all(0),
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
                                            Color.fromARGB(255, 221, 223, 223),
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
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .all<Color>(Color.fromARGB(
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
  final int id;
  DateTime time = DateTime.now();
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int feeling;
  final int arm;
  final String remark;
  final VoidCallback updateParent;
  int isExpanded;

  BloodPressureEditWidget({
    Key? key,
    required this.id,
    required this.time,
    required this.SBloodpressure,
    required this.DBloodpressure,
    required this.heartRate,
    required this.feeling,
    required this.arm,
    required this.remark,
    required this.isExpanded,
    required this.updateParent,
  }) : super(key: key);

  @override
  State<BloodPressureEditWidget> createState() =>
      _BloodPressureEditWidgetState();
}

class _BloodPressureEditWidgetState extends State<BloodPressureEditWidget> {
  //bool isExpanded = false;
  Widget? BPEditWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // 当收起时，点击任意地方可以展开

          if (getDataById(widget.id, "isExpanded") == 0) {
            setState(() {
              setDataById(widget.id, "isExpanded", 1);

              // 其他的一律收起
              for (int i = 0; i < bpdata.length; i++) {
                if (bpdata[i]["id"] != widget.id) {
                  setDataById(bpdata[i]["id"], "isExpanded", 0);
                }
              }

              widget.updateParent();
            });
          }
        },
        //child: BPEditWidget,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
              height: getDataById(widget.id, "isExpanded") == 1
                  ? MediaQuery.of(context).size.height * 0.65
                  : MediaQuery.of(context).size.height * 0.15,
              // height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.85,

              alignment: Alignment.center,
              //https://stackoverflow.com/questions/56298325/overflow-warning-in-animatedcontainer-adjusting-height
              //切换的一瞬间会overflow，用SingleChildScrollView包裹一下解决
              child: getDataById(widget.id, "isExpanded") == 1
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
                          setState(() {
                            setDataById(widget.id, "isExpanded", 0);
                            print('删除 ${widget.id}');
                            // 删除id为widget.id的数据
                            bpdata.removeWhere(
                                (element) => element["id"] == widget.id);
                            print(bpdata);
                            widget.updateParent();
                          });
                        },
                        cancelEditData: () {
                          setState(() {
                            setDataById(widget.id, "isExpanded", 0);
                            print('取消修改 ${widget.id}');
                          });
                        },
                        confirmEditData: () {
                          //print("======================");
                          afterEditedValue.printValue();
                          //print("======================");
                          setState(() {
                            // print(
                            //   "confirm edit data ：${DateTime(2023, 11, 11, afterEditedValue.time.hour, afterEditedValue.time.minute)}");
                            setDataById(widget.id, "isExpanded", 0);
                            setTimeById(
                                widget.id,
                                DateTime(
                                    2023,
                                    11,
                                    11,
                                    afterEditedValue.time.hour,
                                    afterEditedValue.time.minute));
                            setDataById(widget.id, "sbp",
                                afterEditedValue.SBloodpressure);
                            setDataById(widget.id, "dbp",
                                afterEditedValue.DBloodpressure);
                            setDataById(widget.id, "heartRate",
                                afterEditedValue.heartRate);
                            setDataById(
                                widget.id, "arm", afterEditedValue.armIndex);
                            setDataById(widget.id, "feeling",
                                afterEditedValue.feelingIndex);
                            print('确定修改 ${widget.id}');
                            afterEditedValue.clear();
                          });
                        },
                      ),
                    )
                  : SingleChildScrollView(
                      child: BloodPressureEditWidgetLess(
                        id: widget.id,
                        time: getTimeById(widget.id),
                        SBloodpressure: getDataById(widget.id, "sbp"),
                        DBloodpressure: getDataById(widget.id, "dbp"),
                        heartRate: getDataById(widget.id, "heartRate"),
                        arm: getDataById(widget.id, "arm"),
                        feeling: getDataById(widget.id, "feeling"),
                        remark: getRemarById(widget.id),
                      ),
                    ),
            )
          ],
        ));
  }
}

// 只展示
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('血压: ${widget.SBloodpressure} / ${widget.DBloodpressure}',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
                Text('心率: ${widget.heartRate} ',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('手臂: ${armButtonTypes[widget.arm]}',
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

  /* @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        getInfoPage(),
      ],
    );
  } */

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
      /* child: Container(
        //duration: Duration(milliseconds: 1000),
        //curve: Curves.easeIn,
        child: showRemark ? getRemarkPage() : infoPage,
      ), */

      /* child: AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        //curve: Curves.easeInOut,
        width: showRemark == true
            ? MediaQuery.of(context).size.width * 0.85
            : MediaQuery.of(context).size.width * 0.85,
        height: showRemark == true ? 160 : 80,
        curve: Curves.fastOutSlowIn,
        child: showRemark ? getRemarkPage() : infoPage,
      ), */

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
class BloodPressureEditWidgetMore extends StatefulWidget {
  final int id;
  DateTime time;
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int feeling;
  final int arm;
  final String remark;
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
  void updateTime(DateTime newTime) {
    print("????");
    setState(() {
      widget.time = newTime;
    });
    //widget.updateParent();
  }

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

  @override
  Widget build(BuildContext context) {
    // 输入的controller
    final TextEditingController SBloodpressureController =
        TextEditingController(text: widget.SBloodpressure.toString());
    final TextEditingController DBloodpressureController =
        TextEditingController(text: widget.DBloodpressure.toString());
    final TextEditingController heartRateController =
        TextEditingController(text: widget.heartRate.toString());
    final TextEditingController remarkController =
        TextEditingController(text: widget.remark);
    ArmButtonsRow armButtons = ArmButtonsRow(
      selectedIndex: widget.arm,
    );
    FeelingsButtonsRow feelingsButtons = FeelingsButtonsRow(
      selectedIndex: widget.feeling,
    );

    //DateTime time = DateTime.now();

    return Container(
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
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  //color: Colors.blue, // 左边容器的颜色

                  child: Column(
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
                ),

                const SizedBox(width: 5),

                // 右边的子容器
                Container(
                  //height: 100,
                  //width: MediaQuery.of(context).size.width * 0.85 * 0.4,
                  //color: Colors.green, // 右边容器的颜色
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 时间
                      /* Row(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextFormField(
                              maxLength: 2,
                              controller: hourController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              //initialValue: widget.hour,
                              decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "${widget.hour}",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 2)),
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(
                                  fontSize: 30, fontFamily: "BalooBhai"),
                            ),
                          ),
                          SizedBox(width: 2),
                          const Text(
                            "时",
                            style: const TextStyle(
                                fontSize: 16, fontFamily: "BalooBhai"),
                          ),
                          SizedBox(
                            width: 50,
                            child: TextFormField(
                              maxLength: 2,
                              controller: minuteController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              //initialValue: widget.minute,
                              decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "${widget.minute}",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 2)),
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(
                                  fontSize: 30, fontFamily: "BalooBhai"),
                            ),
                          ),
                          const Text(
                            "分",
                            style: const TextStyle(
                                fontSize: 16, fontFamily: "BalooBhai"),
                          ),
                        ],
                      ), */

                      TimePicker(time: widget.time, updateTime: updateTime),

                      const SizedBox(
                        height: 5,
                      ),
                      // 修改收缩压
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.start,
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
                              //initialValue: widget.SBloodpressure,
                              decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "${widget.SBloodpressure}",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 5)),
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(
                                  fontSize: 30, fontFamily: "BalooBhai"),
                            ),
                          ),
                          SizedBox(width: 2),
                          const Text(
                            "mmHg",
                            style: const TextStyle(
                                fontSize: 16, fontFamily: "Blinker"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // 修改舒张压
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.start,
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
                              //initialValue: widget.DBloodpressure,
                              decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "${widget.DBloodpressure}",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 5)),
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(
                                  fontSize: 30, fontFamily: "BalooBhai"),
                            ),
                          ),
                          SizedBox(width: 2),
                          const Text(
                            "mmHg",
                            style: const TextStyle(
                                fontSize: 16, fontFamily: "Blinker"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // 修改心率
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.start,
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
                              //initialValue: widget.heartRate,
                              decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "${widget.heartRate}",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 5)),
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(
                                  fontSize: 30, fontFamily: "BalooBhai"),
                            ),
                          ),
                          SizedBox(width: 2),
                          const Text(
                            "次/分",
                            style: const TextStyle(
                                fontSize: 16, fontFamily: "Blinker"),
                          ),
                        ],
                      ),
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
                        width: 150,
                        height: 40,
                        child: TextFormField(
                          controller: remarkController,
                          //initialValue: widget.SBloodpressure,
                          decoration: InputDecoration(
                              counterText: "",
                              hintText: "-",
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 6)),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: const TextStyle(
                              fontSize: 20, fontFamily: "BalooBhai"),
                        ),
                      ),

                      const SizedBox(height: 10), // 备注
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            //删除，取消，确定
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OtherButton(
                    onPressed: () {
                      deleteDataMark = true;
                      widget.deleteData();
                    },
                    type: 0),
                Container(
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OtherButton(onPressed: widget.cancelEditData, type: 1),
                      const SizedBox(width: 5),
                      OtherButton(
                          onPressed: () {
                            print(widget.id);
                            //print(hourController.text);
                            //print(minuteController.text);
                            print(widget.time);
                            print(SBloodpressureController.text);
                            print(DBloodpressureController.text);
                            print(heartRateController.text);
                            print(armButtons.getSelectedButtonIndex());
                            print(feelingsButtons.getSelectedButtonIndex());
                            //armButtons

                            afterEditedValue = newValue(
                                widget.id,
                                //int.parse(hourController.text),
                                ////int.parse(minuteController.text),
                                widget.time,
                                int.parse(SBloodpressureController.text),
                                int.parse(DBloodpressureController.text),
                                int.parse(heartRateController.text),
                                armButtons.getSelectedButtonIndex(),
                                feelingsButtons.getSelectedButtonIndex());
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
  //TODO 需要参数（初始化时主页所选的日期与这里要保持一致）
  @override
  _BloodPressureEditState createState() => _BloodPressureEditState();
}

class _BloodPressureEditState extends State<BloodPressureEdit> {
  DateTime addTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 先从后端获取数据

    titleDateWidget = TitleDate(date: DateTime.now());
    dataWidget = [];
    dataWidget.add(titleDateWidget);

    for (int i = 0; i < bpdata.length; i++) {
      int hour = int.parse(bpdata[i]["time"].toString().split(":")[0]);
      int minute = int.parse(bpdata[i]["time"].toString().split(":")[1]);
      dataWidget.add(UnconstrainedBox(
        child: BloodPressureEditWidget(
          id: bpdata[i]["id"],
          time: DateTime(2023, 11, 11, hour, minute),
          SBloodpressure: bpdata[i]["sbp"],
          DBloodpressure: bpdata[i]["dbp"],
          heartRate: bpdata[i]["heartRate"],
          arm: bpdata[i]["arm"],
          feeling: bpdata[i]["feeling"],
          isExpanded: bpdata[i]["isExpanded"],
          remark: bpdata[i]["remark"],
          updateParent: updateView,
        ),
      ));
    }

    // TODO 添加的模块
    //dataWidget.add(addDataButtonWidget);
  }

  void updateView() {
    // TODO 更新ListView.builder
    setState(() {
      /* if (deleteDataMark) {
        dataWidget.removeAt(0);
        deleteDataMark = false;
        return;
      } */

      titleDateWidget = TitleDate(date: DateTime.now());
      dataWidget.clear();
      dataWidget.add(titleDateWidget);

      for (int i = 0; i < bpdata.length; i++) {
        // 09:03 提取小时和分钟
        int hour = int.parse(bpdata[i]["time"].toString().split(":")[0]);
        int minute = int.parse(bpdata[i]["time"].toString().split(":")[1]);

        dataWidget.add(UnconstrainedBox(
          child: BloodPressureEditWidget(
            id: bpdata[i]["id"],
            time: DateTime(2023, 11, 11, hour, minute),
            SBloodpressure: bpdata[i]["sbp"],
            DBloodpressure: bpdata[i]["dbp"],
            heartRate: bpdata[i]["heartRate"],
            arm: bpdata[i]["arm"],
            feeling: bpdata[i]["feeling"],
            isExpanded: bpdata[i]["isExpanded"],
            remark: (bpdata[i]["remark"].toString()).isEmpty
                ? "暂无备注"
                : bpdata[i]["remark"].toString(),
            updateParent: updateView,
          ),
        ));
      }

      //dataWidget.add(addDataButtonWidget);
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("血压修改页面刷新");
    return Scaffold(
      appBar: AppBar(
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
      ),
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
          print("我要添加数据");
          setState(() {
            /* DateTime time = DateTime.now();

             void updateTime(DateTime newTime) {
                print("!!!");
                setState(() {
                  time = newTime;
                });
              }  */
            //dataWidget.add(addDataButtonWidget);
            //dataWidget.insert(1, addDataButtonWidget);
            dataWidget.insert(
                1,
                addDataWidget(
                  time: addTime,
                  updateParent: updateView,
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
