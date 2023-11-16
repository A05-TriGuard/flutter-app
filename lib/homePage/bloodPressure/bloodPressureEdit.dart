/* import 'package:flutter/material.dart';
import '../../component/header/header.dart';

//https://stackoverflow.com/questions/51697901/programmatically-expand-expansiontile-in-flutter
class MyListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    // Initialize the list of ExpansionTile states to all false (collapsed).
    _isExpandedList = List.generate(5, (index) => false);
  }

  void _updateExpansionState(int index) {
    // Set the tapped ExpansionTile to expanded (true) and others to collapsed (false).
    setState(() {
      /* for (int i = 0; i < _isExpandedList.length; i++) {
        _isExpandedList[i] = i == index;
      } */
      _isExpandedList[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            ExpansionTile(
              onExpansionChanged: (isExpanded) {
                // When an ExpansionTile is expanded, update the expansion states.
                //if (isExpanded) {
                _updateExpansionState(index);
                //}
                print(index);
              },
              /* trailing: IgnorePointer(
                child: Switch(
                  value: isExpanded,
                  onChanged: (_) {},
                ),
              ), */
              trailing: const SizedBox(),
              /* trailing: Visibility(
                //child: Text("Invisible"),
                child: SizedBox(),
                maintainSize: false,
                maintainAnimation: true,
                maintainState: true,
                visible: false,
              ), */
              title: Container(
                //transform: Matrix4.translationValues(32, 0, 0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text("时间:"),
                  Text("09:32"),
                ]),
              ),
              //subtitle: Text('血压: 110/95 心率: 90 感觉: 还好'),
              subtitle: Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("血压:"),
                  Text(
                    "110/95",
                    style: TextStyle(fontFamily: "BalooBhai"),
                  ),
                  Text("心率:"),
                  Text(
                    "90",
                    style: TextStyle(fontFamily: "BalooBhai"),
                  ),
                  Text("感觉:"),
                  Text("还好"),
                ],
              )),
              children: <Widget>[
                // The content of each ExpansionTile.
                SizedBox(
                  height: _isExpandedList[index]
                      ? 100.0
                      : 0.0, // Set the height based on the expansion state.
                  child: Center(
                    child: Text('Expanded content'),
                  ),
                ),
              ],
            ),
            Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ],
        );
      },
    );
  }
}

//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------

class bloodPressureEdit extends StatefulWidget {
  const bloodPressureEdit({super.key});

  @override
  State<bloodPressureEdit> createState() => _bloodPressureEditState();
}

class _bloodPressureEditState extends State<bloodPressureEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          /* title: const Text(
          "返回",
          style: TextStyle(
              fontFamily: 'Blinker', fontSize: 22, color: Colors.black),
        ), */
          // flexibleSpace: header,
          //toolbarHeight: MediaQuery.of(context).size.height * 0.1 + 11,

          flexibleSpace: getHeader(MediaQuery.of(context).size.width,
              (MediaQuery.of(context).size.height * 0.1 + 11)),
        ),
        /* body: const Center(
        child: Text("修改血压"),
      ), */
        body: MyListView());
  }
}
 */

import 'package:flutter/material.dart';
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

class newValue {
  int id = 0;
  int hour = 0;
  int minute = 0;
  int SBloodpressure = 0;
  int DBloodpressure = 0;
  int heartRate = 0;
  int armIndex = 0;
  int feelingIndex = 0;

  newValue(this.id, this.hour, this.minute, this.SBloodpressure,
      this.DBloodpressure, this.heartRate, this.armIndex, this.feelingIndex);

  void clear() {
    id = 0;
    hour = 0;
    minute = 0;
    SBloodpressure = 0;
    DBloodpressure = 0;
    heartRate = 0;
    armIndex = 0;
    feelingIndex = 0;
  }

  void printValue() {
    print("id: $id");
    print("hour: $hour");
    print("minute: $minute");
    print("SBloodpressure: $SBloodpressure");
    print("DBloodpressure: $DBloodpressure");
    print("heartRate: $heartRate");
    print("armIndex: $armIndex");
    print("feelingIndex: $feelingIndex");
  }
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

late newValue afterEditedValue; //= newValue(0, "0", "0", "0", "0", "0", 0, 0);
bool deleteDataMark = false;

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

class addDataWidget extends StatefulWidget {
  final VoidCallback updateParent;

  const addDataWidget({Key? key, required this.updateParent}) : super(key: key);

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
  CustomButtonRow armButtons = CustomButtonRow(
    selectedIndex: 2,
  );
  CustomIconButtonRow feelingsButtons = CustomIconButtonRow(
    selectedIndex: 1,
  );

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
      child: Column(children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.55,
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        children: [
                          // 时间
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: TextField(
                                  maxLength: 2,
                                  controller: hourController,
                                  //initialValue: widget.hour,
                                  decoration: InputDecoration(
                                      counterText: "",
                                      hintText: "${DateTime.now().hour}",
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
                                child: TextField(
                                  maxLength: 2,
                                  controller: minuteController,
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
                                style: const TextStyle(
                                    fontSize: 16, fontFamily: "BalooBhai"),
                              ),
                            ],
                          ),

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
                                  //initialValue: widget.SBloodpressure,
                                  decoration: InputDecoration(
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
                                child: TextField(
                                  maxLength: 3,
                                  controller: DBloodpressureController,
                                  //initialValue: widget.DBloodpressure,
                                  decoration: InputDecoration(
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 75,
                                height: 40,
                                child: TextField(
                                  maxLength: 3,
                                  controller: heartRateController,
                                  //initialValue: widget.heartRate,
                                  decoration: InputDecoration(
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
                          /* CustomButtonRow(
                        initialSelectedIndex: widget.arm,
                      ), */
                          const SizedBox(
                            height: 5,
                          ),
                          //修改感觉

                          /* CustomIconButtonRow(
                        initialSelectedIndex: widget.feeling,
                      ), */
                          feelingsButtons,
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
                      //取消
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
                      OtherButton(
                          onPressed: () {
                            randomId += 1;
                            bpdata.insert(0, {
                              "id": randomId,
                              "hour": int.parse(hourController.text),
                              "minute": int.parse(minuteController.text),
                              "sbp": int.parse(SBloodpressureController.text),
                              "dbp": int.parse(DBloodpressureController.text),
                              "heartRate": int.parse(heartRateController.text),
                              "arm": armButtons.getSelectedButtonIndex(),
                              "feeling":
                                  feelingsButtons.getSelectedButtonIndex(),
                              "isExpanded": 0,
                            });

                            Widget newWidget = BloodPressureEditWidgetLess(
                              id: randomId,
                              hour: int.parse(hourController.text),
                              minute: int.parse(minuteController.text),
                              SBloodpressure:
                                  int.parse(SBloodpressureController.text),
                              DBloodpressure:
                                  int.parse(DBloodpressureController.text),
                              heartRate: int.parse(heartRateController.text),
                              arm: armButtons.getSelectedButtonIndex(),
                              feeling: feelingsButtons.getSelectedButtonIndex(),
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
class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSelected;

  const CustomButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      required this.isSelected})
      : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
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

class CustomIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final bool isSelected;

  const CustomIconButton({
    required this.onPressed,
    required this.iconPath,
    required this.isSelected,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
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
class CustomButtonRow extends StatefulWidget {
  int selectedIndex;

  CustomButtonRow({required this.selectedIndex});

  @override
  _CustomButtonRowState createState() => _CustomButtonRowState();

  int getSelectedButtonIndex() {
    return selectedIndex;
  }
}

class _CustomButtonRowState extends State<CustomButtonRow> {
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
        CustomButton(
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
        CustomButton(
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
        CustomButton(
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

class CustomIconButtonRow extends StatefulWidget {
  int selectedIndex;

  CustomIconButtonRow({required this.selectedIndex});

  @override
  _CustomIconButtonRowState createState() => _CustomIconButtonRowState();

  int getSelectedButtonIndex() {
    return selectedIndex;
  }
}

class _CustomIconButtonRowState extends State<CustomIconButtonRow> {
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
        CustomIconButton(
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
        CustomIconButton(
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
        CustomIconButton(
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

// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------
// 页面模块

class BloodPressureEdit extends StatefulWidget {
  //TODO 需要参数（初始化时主页所选的日期与这里要保持一致）
  @override
  _BloodPressureEditState createState() => _BloodPressureEditState();
}

class _BloodPressureEditState extends State<BloodPressureEdit> {
  // initial
  @override
  void initState() {
    super.initState();
    // 先从后端获取数据

    titleDateWidget = TitleDate(date: DateTime.now());
    dataWidget = [];
    dataWidget.add(titleDateWidget);

    for (int i = 0; i < bpdata.length; i++) {
      dataWidget.add(UnconstrainedBox(
        child: BloodPressureEditWidget(
          id: bpdata[i]["id"],
          hour: bpdata[i]["hour"],
          minute: bpdata[i]["minute"],
          SBloodpressure: bpdata[i]["sbp"],
          DBloodpressure: bpdata[i]["dbp"],
          heartRate: bpdata[i]["heartRate"],
          arm: bpdata[i]["arm"],
          feeling: bpdata[i]["feeling"],
          isExpanded: bpdata[i]["isExpanded"],
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
        dataWidget.add(UnconstrainedBox(
          child: BloodPressureEditWidget(
            id: bpdata[i]["id"],
            hour: bpdata[i]["hour"],
            minute: bpdata[i]["minute"],
            SBloodpressure: bpdata[i]["sbp"],
            DBloodpressure: bpdata[i]["dbp"],
            heartRate: bpdata[i]["heartRate"],
            arm: bpdata[i]["arm"],
            feeling: bpdata[i]["feeling"],
            isExpanded: bpdata[i]["isExpanded"],
            updateParent: updateView,
          ),
        ));
      }

      //dataWidget.add(addDataButtonWidget);
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        itemCount: dataWidget.length,
        itemBuilder: (BuildContext context, int index) {
          return dataWidget[index];
        },
      ),

      // 添加数据的按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("我要添加数据");
          setState(() {
            //dataWidget.add(addDataButtonWidget);
            //dataWidget.insert(1, addDataButtonWidget);
            dataWidget.insert(1, addDataWidget(updateParent: updateView));
          });
        },
        shape: CircleBorder(),
        backgroundColor: Color.fromARGB(255, 237, 136, 247),
        child: Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}

class TitleDate extends StatefulWidget {
  final DateTime date;
  const TitleDate({Key? key, required this.date}) : super(key: key);

  @override
  State<TitleDate> createState() => _TitleDateState();
}

class _TitleDateState extends State<TitleDate> {
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
                        "${widget.date.year}年${widget.date.month}月${widget.date.day}日",
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
                          onPressed: () {
                            print("editDate");
                          },
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

//@immutable
class BloodPressureEditWidget extends StatefulWidget {
  final int id;
  final int hour;
  final int minute;
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int feeling;
  final int arm;
  final VoidCallback updateParent;
  int isExpanded;

  BloodPressureEditWidget({
    Key? key,
    required this.id,
    required this.hour,
    required this.minute,
    required this.SBloodpressure,
    required this.DBloodpressure,
    required this.heartRate,
    required this.feeling,
    required this.arm,
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
              print("收起");
              for (int i = 0; i < bpdata.length; i++) {
                if (bpdata[i]["id"] != widget.id) {
                  setDataById(bpdata[i]["id"], "isExpanded", 0);
                }
              }

              print(bpdata);

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
                  ? MediaQuery.of(context).size.height * 0.55
                  : MediaQuery.of(context).size.height * 0.15,
              // height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.85,
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
              alignment: Alignment.center,
              //https://stackoverflow.com/questions/56298325/overflow-warning-in-animatedcontainer-adjusting-height
              //切换的一瞬间会overflow，用SingleChildScrollView包裹一下解决
              child: getDataById(widget.id, "isExpanded") == 1
                  ? SingleChildScrollView(
                      child: BloodPressureEditWidgetMore(
                        id: widget.id,
                        hour: widget.hour,
                        minute: widget.minute,
                        SBloodpressure: widget.SBloodpressure,
                        DBloodpressure: widget.DBloodpressure,
                        heartRate: widget.heartRate,
                        arm: widget.arm,
                        feeling: widget.feeling,
                        deleteData: () {
                          setState(() {
                            //widget.isExpanded = false;
                            //bpdata[widget.id]["isExpanded"] = 0;
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
                            //widget.isExpanded = false;
                            //bpdata[widget.id]["isExpanded"] = 0;
                            setDataById(widget.id, "isExpanded", 0);
                            print('取消修改 ${widget.id}');
                          });
                        },
                        confirmEditData: () {
                          print("接收！！");
                          afterEditedValue.printValue();
                          setState(() {
                            //widget.isExpanded = false;
                            setDataById(widget.id, "isExpanded", 0);
                            setDataById(
                                widget.id, "hour", afterEditedValue.hour);
                            setDataById(
                                widget.id, "minute", afterEditedValue.minute);
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
                            // bpdata[widget.id]["minute"] =
                            //     afterEditedValue.minute;
                            // bpdata[widget.id]["sbp"] =
                            //     afterEditedValue.SBloodpressure;
                            // bpdata[widget.id]["dbp"] =
                            //     afterEditedValue.DBloodpressure;
                            // bpdata[widget.id]["heartRate"] =
                            //     afterEditedValue.heartRate;
                            // bpdata[widget.id]["arm"] =
                            //     afterEditedValue.armIndex;
                            // bpdata[widget.id]["feeling"] =
                            //     afterEditedValue.feelingIndex;
                            print('确定修改 ${widget.id}');
                            afterEditedValue.clear();
                          });
                        },
                      ),
                    )
                  : SingleChildScrollView(
                      child: BloodPressureEditWidgetLess(
                          id: widget.id,
                          hour: getDataById(widget.id, "hour"),
                          minute: getDataById(widget.id, "minute"),
                          SBloodpressure: getDataById(widget.id, "sbp"),
                          DBloodpressure: getDataById(widget.id, "dbp"),
                          heartRate: getDataById(widget.id, "heartRate"),
                          arm: getDataById(widget.id, "arm"),
                          feeling: getDataById(widget.id, "feeling")),
                    ),
            ),
            const SizedBox(height: 10),
          ],
        ));
  }
}

// 只展示
class BloodPressureEditWidgetLess extends StatefulWidget {
  final int id;
  final int hour;
  final int minute;
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int arm;
  final int feeling;

  const BloodPressureEditWidgetLess(
      {Key? key,
      required this.id,
      required this.hour,
      required this.minute,
      required this.SBloodpressure,
      required this.DBloodpressure,
      required this.heartRate,
      required this.feeling,
      required this.arm})
      : super(key: key);

  @override
  State<BloodPressureEditWidgetLess> createState() =>
      _BloodPressureEditWidgetLessState();
}

class _BloodPressureEditWidgetLessState
    extends State<BloodPressureEditWidgetLess> {
  @override
  Widget build(BuildContext context) {
    return Container(
      /* child: Center(
        child: Text(
            'Time: ${widget.time}, Pressure: ${widget.SBloodpressure + '/' + widget.DBloodpressure}, Heart Rate: ${widget.heartRate}, Feeling: ${widget.feeling}'),
      ), */
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '时间: ${widget.hour}:${widget.minute}',
              style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
            ),
            Text(
              '血压: ${widget.SBloodpressure} / ${widget.DBloodpressure}    心率: ${widget.heartRate} ',
              style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
            ),
            Text(
              '手臂: ${armButtonTypes[widget.arm]}            感觉: ${feelingButtonTypes[widget.feeling]}',
              style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
            ),
          ]),
    );
  }
}

// 可编辑
class BloodPressureEditWidgetMore extends StatefulWidget {
  final int id;
  final int hour;
  final int minute;
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int feeling;
  final int arm;
  final VoidCallback deleteData;
  final VoidCallback cancelEditData;
  final VoidCallback confirmEditData;

  const BloodPressureEditWidgetMore({
    Key? key,
    required this.id,
    required this.hour,
    required this.minute,
    required this.SBloodpressure,
    required this.DBloodpressure,
    required this.heartRate,
    required this.feeling,
    required this.arm,
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
    final TextEditingController hourController =
        TextEditingController(text: widget.hour.toString());
    final TextEditingController minuteController =
        TextEditingController(text: widget.minute.toString());
    final TextEditingController SBloodpressureController =
        TextEditingController(text: widget.SBloodpressure.toString());
    final TextEditingController DBloodpressureController =
        TextEditingController(text: widget.DBloodpressure.toString());
    final TextEditingController heartRateController =
        TextEditingController(text: widget.heartRate.toString());
    CustomButtonRow armButtons = CustomButtonRow(
      selectedIndex: widget.arm,
    );
    CustomIconButtonRow feelingsButtons = CustomIconButtonRow(
      selectedIndex: widget.feeling,
    );

    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    children: [
                      // 时间
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextFormField(
                              maxLength: 2,
                              controller: hourController,
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
                      ),

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
                        mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 75,
                            height: 40,
                            child: TextFormField(
                              maxLength: 3,
                              controller: heartRateController,
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
                      /* CustomButtonRow(
                        initialSelectedIndex: widget.arm,
                      ), */
                      const SizedBox(
                        height: 5,
                      ),
                      //修改感觉

                      /* CustomIconButtonRow(
                        initialSelectedIndex: widget.feeling,
                      ), */
                      feelingsButtons,
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
