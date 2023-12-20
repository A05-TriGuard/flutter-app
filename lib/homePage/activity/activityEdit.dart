import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:triguard/component/titleDate/titleDate.dart';
import 'package:dio/dio.dart';

import '../../component/header/header.dart';
import '../../account/token.dart';
import "../../other/other.dart";

// 删除 取消 确定
List<String> feelingButtonTypes = ["较好", "还好", "较差"];
List<String> functionButtonTypes = ["删除", "取消", "确定"];
List<String> invalidValueText = [
  "",
  "总胆固醇必须填写",
  "甘油三酯必须填写",
  "低密度脂蛋白胆固醇必须填写",
  "高密度脂蛋白胆固醇必须填写"
];
List<Color> functionButtonColors = const [
  Color.fromRGBO(253, 108, 108, 1),
  Color.fromRGBO(144, 235, 235, 1),
  Color.fromRGBO(173, 255, 144, 1),
];

List<dynamic> data = [];
List<Widget> dataWidget = [];

late Widget titleDateWidget;
int randomId = 100;
typedef UpdateTimeCallback = void Function(DateTime newTime);
typedef UpdateDateCallback = void Function(DateTime newDate);

class newValue {
  int id = 0;
  //int hour = 0;
  //int minute = 0;
  DateTime time = DateTime.now();
  double tc = 0;
  double tg = 0;
  double ldl = 0;
  double hdl = 0;

  int feelingIndex = 0;
  String remarks = "";

  newValue(
    this.id,
    this.time,
    this.tc,
    this.tg,
    this.ldl,
    this.hdl,
    this.feelingIndex,
    this.remarks,
  );

  void clear() {
    id = 0;
    time = DateTime.now();
    tc = 0;
    tg = 0;
    ldl = 0;
    hdl = 0;
    feelingIndex = 0;
    remarks = "";
  }

  void printValue() {
    print("id: $id");
    print("time: $time");
    print("tc: $tc");
    print("tg: $tg");
    print("ldl: $ldl");
    print("hdl: $hdl");
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
  @override
  Widget build(BuildContext context) {
    return Container();
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
                        "修改活动",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Image.asset("assets/icons/bloodFat.png",
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
      ),
    );
  }
}

// 生成血压数据的显示模块
// ignore: must_be_immutable
class BloodFatEditWidget extends StatefulWidget {
  final int accountId;
  final int id;
  DateTime date = DateTime.now();
  DateTime time = DateTime.now();
  final int tc;
  final int tc_;
  final int tg;
  final int tg_;
  final int ldl;
  final int ldl_;
  final int hdl;
  final int hdl_;
  final int feeling;
  final String remark;
  final VoidCallback updateParent;
  final VoidCallback updateData;
  int isExpanded;

  BloodFatEditWidget({
    Key? key,
    required this.accountId,
    required this.id,
    required this.date,
    required this.time,
    required this.tc,
    required this.tc_,
    required this.tg,
    required this.tg_,
    required this.ldl,
    required this.ldl_,
    required this.hdl,
    required this.hdl_,
    required this.feeling,
    required this.remark,
    required this.isExpanded,
    required this.updateParent,
    required this.updateData,
  }) : super(key: key);

  @override
  State<BloodFatEditWidget> createState() => _BloodFatEditWidgetState();
}

class _BloodFatEditWidgetState extends State<BloodFatEditWidget> {
  //bool isExpanded = false;
  Widget? BPEditWidget;

  Future<void> deleteData(int id) async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    response = await dio.get(widget.accountId >= 0
        ? "http://43.138.75.58:8080/api/blood-lipids/delete?id=$id&accountId=${widget.accountId}"
        : "http://43.138.75.58:8080/api/blood-lipids/delete?id=$id");
    if (response.data["code"] == 200) {
      print("删除血脂数据成功");
    } else {
      print(response);
      print("删除血脂数据失败");
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
      "tc": afterEditedValue.tc,
      "tg": afterEditedValue.tg,
      "ldl": afterEditedValue.ldl,
      "hdl": afterEditedValue.hdl,
      "feeling": afterEditedValue.feelingIndex,
      "remark": afterEditedValue.remarks,
    };

    if (widget.accountId >= 0) {
      newVal["accountId"] = widget.accountId.toString();
    }

    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/blood-lipids/update",
        data: newVal,
      );

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

  void printBF() {
    print("***************************************");
    print("id: ${widget.id}");
    print("date: ${widget.date}");
    print("time: ${widget.time}");
    print("tc: ${widget.tc}");
    print("tg: ${widget.tg}");
    print("ldl: ${widget.ldl}");
    print("hdl: ${widget.hdl}");
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
        //child: BPEditWidget,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
              height: getDataById(widget.id, "isExpanded") == 1
                  ? 380 //MediaQuery.of(context).size.height * 0.65
                  //: MediaQuery.of(context).size.height * 0.15,
                  : 200,
              // height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.85,

              alignment: Alignment.center,
              //https://stackoverflow.com/questions/56298325/overflow-warning-in-animatedcontainer-adjusting-height
              //切换的一瞬间会overflow，用SingleChildScrollView包裹一下解决
              child: getDataById(widget.id, "isExpanded") == 1
                  ? SingleChildScrollView(
                      child: BloodFatEditWidgetMore(
                        id: widget.id,
                        time: widget.time,
                        tc: widget.tc,
                        tc_: widget.tc_,
                        tg: widget.tg,
                        tg_: widget.tg_,
                        ldl: widget.ldl,
                        ldl_: widget.ldl_,
                        hdl: widget.hdl,
                        hdl_: widget.hdl_,
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
                          });
                        },
                        confirmEditData: () {
                          //afterEditedValue.printValue();

                          editData(widget.id, afterEditedValue).then((_) {
                            widget.updateData();
                          });
                        },
                      ),
                    )
                  : SingleChildScrollView(
                      child: BloodFatEditWidgetLess(
                        id: widget.id,
                        time: widget.time,
                        tc: widget.tc,
                        tc_: widget.tc_,
                        tg: widget.tg,
                        tg_: widget.tg_,
                        ldl: widget.ldl,
                        ldl_: widget.ldl_,
                        hdl: widget.hdl,
                        hdl_: widget.hdl_,
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
class BloodFatEditWidgetLess extends StatefulWidget {
  final int id;
  DateTime time;
  final int tc;
  final int tc_;
  final int tg;
  final int tg_;
  final int ldl;
  final int ldl_;
  final int hdl;
  final int hdl_;
  final int feeling;
  final String remark;

  BloodFatEditWidgetLess(
      {Key? key,
      required this.id,
      required this.time,
      required this.tc,
      required this.tc_,
      required this.tg,
      required this.tg_,
      required this.ldl,
      required this.ldl_,
      required this.hdl,
      required this.hdl_,
      required this.feeling,
      required this.remark})
      : super(key: key);

  @override
  State<BloodFatEditWidgetLess> createState() => _BloodFatEditWidgetLessState();
}

class _BloodFatEditWidgetLessState extends State<BloodFatEditWidgetLess> {
  List<String> mealButtonTypes = ["空腹", "餐后", "不选"];
  List<String> feelingButtonTypes = ["较好", "还好", "较差"];
  bool showRemark = false;
  PageController pageController = PageController();

  Widget getInfoPage() {
    return Container(
      //duration: Duration(milliseconds: 1000),
      //curve: Curves.easeInOut,
      height: 180,
      width: MediaQuery.of(context).size.width * 0.85,

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.2),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '开始时间: ',
                  style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Text(
                  "2023-12-12 ${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 20, fontFamily: "BalooBhai"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '结束时间: ',
                  style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Text(
                  "2023-12-12 ${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 20, fontFamily: "BalooBhai"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '总时长: ',
                  style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Row(
                  children: [
                    Text(
                      '${widget.ldl * 50}',
                      style: const TextStyle(
                          fontSize: 20, fontFamily: "BalooBhai"),
                    ),
                    const Text(
                      '分钟',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "BalooBhai",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '运动类型: ',
                  style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Text(
                  '羽毛球',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "BalooBhai",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '感觉: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "BalooBhai",
                  ),
                ),
                Text(
                  feelingButtonTypes[widget.feeling],
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "BalooBhai",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getRemarkPage() {
    return Container(
      height: 180,
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
class BloodFatEditWidgetMore extends StatefulWidget {
  final int id;
  DateTime time;
  int tc;
  int tc_;
  int tg;
  int tg_;
  int ldl;
  int ldl_;
  int hdl;
  int hdl_;
  int feeling;
  String remark;
  final VoidCallback deleteData;
  final VoidCallback cancelEditData;
  final VoidCallback confirmEditData;

  BloodFatEditWidgetMore({
    Key? key,
    required this.id,
    required this.time,
    required this.tc,
    required this.tc_,
    required this.tg,
    required this.tg_,
    required this.ldl,
    required this.ldl_,
    required this.hdl,
    required this.hdl_,
    required this.feeling,
    required this.remark,
    required this.deleteData,
    required this.cancelEditData,
    required this.confirmEditData,
  }) : super(key: key);

  @override
  State<BloodFatEditWidgetMore> createState() => _BloodFatEditWidgetMoreState();
}

class _BloodFatEditWidgetMoreState extends State<BloodFatEditWidgetMore> {
  int invalidValueType = 0;
  OverlayEntry? overlayEntry;

  TextEditingController tcController = TextEditingController();
  TextEditingController tc_Controller = TextEditingController(); // 小数
  TextEditingController tgController = TextEditingController();
  TextEditingController tg_Controller = TextEditingController(); // 小数
  TextEditingController ldlController = TextEditingController();
  TextEditingController ldl_Controller = TextEditingController(); // 小数
  TextEditingController hdlController = TextEditingController();
  TextEditingController hdl_Controller = TextEditingController(); // 小数
  TextEditingController remarkController = TextEditingController();
  FeelingsButtonsRow feelingsButtons = FeelingsButtonsRow(
    selectedIndex: 0,
  );
  int selectedType = 0;
  List<String> items = [
    '不选',
    '跑步',
    '散步',
    '骑行',
    '游泳',
    '跳水',
    '篮球',
    '足球',
    '羽毛球',
    '乒乓球',
    '网球',
    '台球',
    '壁球',
    '排球',
    '藤球',
    '毽子',
    '健身',
    '瑜伽',
    '跳绳',
    '爬山',
    '太极',
    '武术',
    '散手',
    '气功',
    '八段锦',
    '跆拳道',
    '空手道',
    '拳击',
    '柔道',
    '飞盘',
    '滑板',
    '轮滑',
    '滑雪',
    '滑冰',
    '攀岩',
    '高尔夫',
    '保龄球',
    '桌球',
    '棒球',
    '垒球',
    '橄榄球',
    '曲棍球',
    '冰球',
    '板球',
    '其他'
  ];

  void updateTime(DateTime newTime) {
    setState(() {
      widget.time = newTime;
      widget.tc = int.parse(tcController.text);
      widget.tc_ = int.parse(tc_Controller.text);
      widget.tg = int.parse(tgController.text);
      widget.tg_ = int.parse(tg_Controller.text);
      widget.ldl = int.parse(ldlController.text);
      widget.ldl_ = int.parse(ldl_Controller.text);
      widget.hdl = int.parse(hdlController.text);
      widget.hdl_ = int.parse(hdl_Controller.text);
      widget.feeling = feelingsButtons.getSelectedButtonIndex();
      widget.remark = remarkController.text;
    });
  }

  // 显示未修改前的值
  void getBeforeEditValue() {
    tcController = TextEditingController(text: widget.tc.toString());
    tc_Controller = TextEditingController(text: widget.tc_.toString());
    tgController = TextEditingController(text: widget.tg.toString());
    tg_Controller = TextEditingController(text: widget.tg_.toString());
    ldlController = TextEditingController(text: widget.ldl.toString());
    ldl_Controller = TextEditingController(text: widget.ldl_.toString());
    hdlController = TextEditingController(text: widget.hdl.toString());
    hdl_Controller = TextEditingController(text: widget.hdl_.toString());
    remarkController = TextEditingController(text: widget.remark);
    feelingsButtons = FeelingsButtonsRow(
      selectedIndex: widget.feeling,
    );
  }

  //
  void exercisingTypeOverlay(BuildContext context) async {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            //color: const Color.fromARGB(156, 255, 255, 255),
            //child: getTypeSelector2(),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: const Color.fromARGB(217, 131, 131, 131)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                      offset: Offset(0, 0),
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: getTypeSelector2(),
              ),
            ),
          ),
        ),
      ),
    );
    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry!);
  }

  // 运动类型枚举选择
  Widget exercisingTypeSelector2() {
    //网格布局，将items中的数据放入网格中
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      height: MediaQuery.of(context).size.height * 0.5,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5,
        children: items.map((item) {
          return GestureDetector(
            onTap: () {
              selectedType = items.indexOf(item);
              //print(items[selectedType]);
              setState(() {
                // 更新被选中的运动类型

                //
              });
              overlayEntry?.markNeedsBuild();
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item == items[selectedType]
                    ? Color.fromARGB(255, 253, 184, 255)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).hintColor,
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 运动类型选择界面
  Widget getTypeSelector2() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //“开始运动”
            const Text(
              "开始运动",
              style: TextStyle(
                fontSize: 20,
                fontFamily: "BalooBhai",
                fontWeight: FontWeight.bold,
              ),
            ),

            // "选择运动类型"
            const Text(
              "选择运动类型: ",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "BalooBhai",
                fontWeight: FontWeight.bold,
              ),
            ),

            // 类型选择
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: exercisingTypeSelector2(),
              ),
            ),

            // 取消，确定
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 取消运动
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    overlayEntry?.remove();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 118, 246, 255)),
                  ),
                  child: Text('取消'),
                ),

                //确定开始运动
                ElevatedButton(
                  onPressed: () {
                    // 开始timer
                    setState(() {});
                    overlayEntry?.markNeedsBuild();
                    overlayEntry?.remove();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent),
                  ),
                  child: Text('开始'),
                ),
              ],
            ),
          ],
          //),
        ),
      ),
    );
  }

  // 修改的组件
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
                contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              ),
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

  // 获取标题 中文+英文
  Widget getTitle(String TitleChn, String TitleEng) {
    if (TitleChn.length > 4) {
      return Column(
        children: [
          Text(
            "${TitleChn.substring(0, 4)}", //前四个字
            style: const TextStyle(fontSize: 14, fontFamily: "BalooBhai"),
          ),
          Text(
            "${TitleChn.substring(4)}",
            style: const TextStyle(fontSize: 14, fontFamily: "BalooBhai"),
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
                            getTitle("开始时间", "START TIME"),
                            getTitle("结束时间", "END TIME"),
                            getTitle("总时长", "TOTAL TIME"),
                            getTitle("运动类型", "TYPE"),
                            getTitle("感觉", "FEELINGS"),
                            getTitle("备注", "REMARKS"),
                          ],
                        ),
                      ),

                      const SizedBox(width: 5),

                      // 右边的子容器 （值）
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //开始时间
                            Container(
                              //color: Colors.yellow,
                              height: 41,
                              child: Center(
                                child: Text(
                                  "2023-12-12 ${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                      fontSize: 20, fontFamily: "BalooBhai"),
                                ),
                              ),
                            ),

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            // 结束时间
                            Container(
                              //color: Colors.yellow,
                              height: 41,
                              child: Center(
                                child: Text(
                                  "2023-12-12 ${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                      fontSize: 20, fontFamily: "BalooBhai"),
                                ),
                              ),
                            ),

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            // 总时长
                            Container(
                              //color: Colors.yellow,
                              height: 41,
                              child: const Center(
                                child: Text(
                                  "120 分钟",
                                  style: TextStyle(
                                      fontSize: 20, fontFamily: "BalooBhai"),
                                ),
                              ),
                            ),

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            // 修改类型
                            Row(
                              children: [
                                Container(
                                  // color: Colors.yellow,
                                  height: 41,
                                  child: Center(
                                    child: Text(
                                      items[selectedType],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontFamily: "BalooBhai",
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 41,
                                  child: IconButton(
                                    onPressed: () {
                                      exercisingTypeOverlay(context);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                ),
                              ],
                            ),

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            //修改感觉
                            feelingsButtons,

                            //
                            //const SizedBox(height: 5),

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
                                  if (tcController.text == "" ||
                                      tc_Controller.text == "") {
                                    invalidValueType = 1;
                                  } else if (tgController.text == "" ||
                                      tg_Controller.text == "") {
                                    invalidValueType = 2;
                                  } else if (ldlController.text == "" ||
                                      ldl_Controller.text == "") {
                                    invalidValueType = 3;
                                  } else if (hdlController.text == "" ||
                                      hdl_Controller.text == "") {
                                    invalidValueType = 4;
                                  } else {
                                    invalidValueType = 0;
                                  }

                                  if (invalidValueType > 0) {
                                    print(
                                        "invalidvalue: $invalidValueType ${invalidValueText[invalidValueType]}");
                                    setState(() {});
                                    return;
                                  }
                                  afterEditedValue = newValue(
                                      widget.id,
                                      widget.time,
                                      int.parse(tcController.text) +
                                          int.parse(tc_Controller.text) / 10,
                                      int.parse(tgController.text) +
                                          int.parse(tg_Controller.text) / 10,
                                      int.parse(ldlController.text) +
                                          int.parse(ldl_Controller.text) / 10,
                                      int.parse(hdlController.text) +
                                          int.parse(hdl_Controller.text) / 10,
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

// 步数模块
class StepWidget extends StatefulWidget {
  final int step;

  const StepWidget({Key? key, required this.step}) : super(key: key);

  @override
  State<StepWidget> createState() => _StepWidgetState();
}

class _StepWidgetState extends State<StepWidget> {
  @override
  Widget build(BuildContext context) {
    // 先获取权限
    //getActivityRecognitionPermission();
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 80,
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
        //alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 标题
              Container(
                height: 50,
                alignment: Alignment.topCenter,
                child: const PageTitle(
                  title: "今日步数",
                  icons: "assets/icons/footprints.png",
                  fontSize: 20,
                ),
              ),

              Row(
                children: [
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.step}',
                      style: const TextStyle(
                        fontSize: 35,
                        //fontSize: 15,
                        fontFamily: "BalooBhai",
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 70, 165, 119),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      ' 步',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "BalooBhai",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 暂无运动数据
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
            "暂无运动数据",
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
class ActivityEdit extends StatefulWidget {
  final Map arguments;
  // 需要 accountId, nickname, date, activityDataId

  const ActivityEdit({Key? key, required this.arguments}) : super(key: key);
  @override
  _ActivityEditState createState() => _ActivityEditState();
}

class _ActivityEditState extends State<ActivityEdit> {
  DateTime addTime = DateTime.now();
  DateTime date = DateTime.now();
  int activityDataId = -1;
  String exercisingHours = '1';
  String exercisingMins = '55';
  bool isExercising = false;
  List<String> items = [
    '不选',
    '跑步',
    '散步',
    '骑行',
    '游泳',
    '跳水',
    '篮球',
    '足球',
    '羽毛球',
    '乒乓球',
    '网球',
    '台球',
    '壁球',
    '排球',
    '藤球',
    '毽子',
    '健身',
    '瑜伽',
    '跳绳',
    '爬山',
    '太极',
    '武术',
    '散手',
    '气功',
    '八段锦',
    '跆拳道',
    '空手道',
    '拳击',
    '柔道',
    '飞盘',
    '滑板',
    '轮滑',
    '滑雪',
    '滑冰',
    '攀岩',
    '高尔夫',
    '保龄球',
    '桌球',
    '棒球',
    '垒球',
    '橄榄球',
    '曲棍球',
    '冰球',
    '板球',
    '其他'
  ];
  int selectedType = 0;
  bool isExpanded = false;
  bool isPause = false;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  OverlayEntry? overlayEntry;
  int accountId = -1;
  int feelings = 1;
  TextEditingController remarksController = TextEditingController();

  //
  Widget exercisingWidget() {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      offset: Offset(0, 5),
                      blurRadius: 5.0,
                      spreadRadius: 0.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 今日运动
                      Container(
                        height: 50,
                        alignment: Alignment.topCenter,
                        child: PageTitle(
                          title: isPause == false ? "运动中" : "运动暂停",
                          icons: "assets/icons/exercising2.png",
                          fontSize: 20,
                        ),
                      ),
//运动时
                      Column(
                        children: [
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.black45,
                          ),
                          // 计时器
                          Container(
                            // color: Colors.greenAccent,
                            height: 40,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "开始时间：",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "BalooBhai",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // 计时器
                                /* Container(
                                    //color: Colors.greenAccent,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: getStopWatchTimer(),
                                  ), */
                                Container(
                                  //color: Colors.greenAccent,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${startTime.hour}:${startTime.minute}:${startTime.second}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: "BalooBhai",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 运动类型
                          Container(
                            //color: Colors.yellowAccent,
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              "运动类型：${items[selectedType]}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: "BalooBhai",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          // 暂停与结束运动按钮
                          Container(
                            //color: Colors.deepPurpleAccent,
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 暂停
                                Container(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isPause == false) {
                                        isPause = true;
                                        print("暂停运动");
                                      } else {
                                        isPause = false;
                                        print("继续运动");
                                      }
                                      setState(() {});
                                      updateView();
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 35,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isPause == false
                                            ? Colors.blueAccent
                                            : Color.fromARGB(
                                                255, 104, 255, 112),
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                              0, 0, 0, 0.2),
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        isPause == false ? '暂停运动' : '继续运动',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily: "BalooBhai",
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                //结束
                                Container(
                                  height: 100,
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      endExercisingDialog(context);

                                      if (isExercising == false) {
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 35,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 104, 104),
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                              0, 0, 0, 0.2),
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Text(
                                        '结束运动',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: "BalooBhai",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            isExercising
                ? Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: isPause ? Colors.blueAccent : Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  // 输入框的控制器
  // ignore: non_constant_identifier_names
  // 运动类型选择弹窗
  void exercisingTypeOverlay(BuildContext context) async {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            //color: const Color.fromARGB(156, 255, 255, 255),
            //child: getTypeSelector2(),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color.fromARGB(217, 131, 131, 131)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                      offset: Offset(0, 0),
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: getTypeSelector2(),
              ),
            ),
          ),
        ),
      ),
    );
    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry!);
  }

  // 确定结束运动dialog
  void endExercisingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("确定结束运动吗？",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "BalooBhai",
                fontWeight: FontWeight.bold,
              )),
          content: const Text(
            "结束运动后将无法继续记录运动数据",
            style: TextStyle(
              fontSize: 14,
              fontFamily: "BalooBhai",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                // 结束运动
                /* isExercising = false;
                isPause = false;
                watchTimer.onStopTimer();
                print(
                    "结束运动 类型:${items[selectedType]}  开始/结束：${startTime} ~ ${DateTime.now()}");

                setState(() {});
                Navigator.pop(context); */

                feelings = 1;
                exercisingFeelingsRemarksOverlay(context);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }

  // 运动类型枚举选择
  Widget exercisingTypeSelector2() {
    //网格布局，将items中的数据放入网格中
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      height: MediaQuery.of(context).size.height * 0.5,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5,
        children: items.map((item) {
          return GestureDetector(
            onTap: () {
              selectedType = items.indexOf(item);
              print(items[selectedType]);
              setState(() {
                // 更新被选中的运动类型

                //
              });
              overlayEntry?.markNeedsBuild();
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item == items[selectedType]
                    ? Color.fromARGB(255, 253, 184, 255)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).hintColor,
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 运动类型选择界面
  Widget getTypeSelector2() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //“开始运动”
            const Text(
              "开始运动",
              style: TextStyle(
                fontSize: 20,
                fontFamily: "BalooBhai",
                fontWeight: FontWeight.bold,
              ),
            ),

            // "选择运动类型"
            const Text(
              "选择运动类型: ",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "BalooBhai",
                fontWeight: FontWeight.bold,
              ),
            ),

            // 类型选择
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: exercisingTypeSelector2(),
              ),
            ),

            // 取消，确定
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 取消运动
                ElevatedButton(
                  onPressed: () {
                    isExpanded = false;

                    //setState(() {});
                    overlayEntry?.remove();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 118, 246, 255)),
                  ),
                  child: Text('取消'),
                ),

                //确定开始运动
                ElevatedButton(
                  onPressed: () {
                    isExpanded = false;
                    isExercising = true;
                    // 开始timer
                    startTime = DateTime.now();
                    //setState(() {});
                    updateView();
                    overlayEntry?.markNeedsBuild();
                    overlayEntry?.remove();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent),
                  ),
                  child: Text('开始'),
                ),
              ],
            ),
          ],
          //),
        ),
      ),
    );
  }

  // 结束运动后填写感觉与备注
  void exercisingFeelingsRemarksOverlay(BuildContext context) async {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            //color: const Color.fromARGB(156, 255, 255, 255),
            //child: getTypeSelector2(),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 225,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color.fromARGB(217, 131, 131, 131)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                      offset: Offset(0, 0),
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: getFeelingsRemarksWidget(),
              ),
            ),
          ),
        ),
      ),
    );
    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry!);
  }

  // 运动感受与备注
  Widget getFeelingsRemarksWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 标题
              const Text(
                "运动感受与备注",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "BalooBhai",
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 运动感受
                  const Text(
                    "运动感受: ",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "BalooBhai",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  // 运动感受选择
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          print("开心");
                          feelings = 0;
                          //setState(() {});
                          overlayEntry?.markNeedsBuild();
                        },
                        child: Container(
                          height: 40,
                          width: 50,
                          decoration: BoxDecoration(
                            color: feelings == 0
                                ? const Color.fromRGBO(253, 134, 255, 0.66)
                                : const Color.fromRGBO(218, 218, 218, 0.66),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    const Color.fromRGBO(122, 119, 119, 0.43)),
                          ),
                          child: const Center(
                            child: Text(
                              "开心",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("还好");
                          feelings = 1;
                          // setState(() {});
                          overlayEntry?.markNeedsBuild();
                        },
                        child: Container(
                          height: 40,
                          width: 50,
                          decoration: BoxDecoration(
                            color: feelings == 1
                                ? const Color.fromRGBO(253, 134, 255, 0.66)
                                : const Color.fromRGBO(218, 218, 218, 0.66),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    const Color.fromRGBO(122, 119, 119, 0.43)),
                          ),
                          child: const Center(
                            child: Text(
                              "还好",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("不好");
                          feelings = 2;
                          // setState(() {});
                          overlayEntry?.markNeedsBuild();
                        },
                        child: Container(
                          height: 40,
                          width: 50,
                          decoration: BoxDecoration(
                            color: feelings == 2
                                ? const Color.fromRGBO(253, 134, 255, 0.66)
                                : const Color.fromRGBO(218, 218, 218, 0.66),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    const Color.fromRGBO(122, 119, 119, 0.43)),
                          ),
                          child: const Center(
                            child: Text(
                              "不好",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                // 备注
                const Text(
                  "备注: ",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "BalooBhai",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 41,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: 40,
                    child: TextFormField(
                      controller: remarksController,
                      //initialValue: widget.SBloodpressure,
                      decoration: const InputDecoration(
                          counterText: "",
                          hintText: "-",
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 167, 166, 166),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 6)),
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.bottom,
                      style: const TextStyle(
                          fontSize: 20, fontFamily: "BalooBhai"),
                    ),
                  ),
                ),
              ]),

              const SizedBox(
                height: 10,
              ),
              // 确定，取消
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 取消
                  ElevatedButton(
                    onPressed: () {
                      isExpanded = false;
                      //setState(() {});
                      overlayEntry?.remove();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 118, 246, 255)),
                    ),
                    child: Text('取消'),
                  ),

                  //确定
                  ElevatedButton(
                    onPressed: () {
                      /* setState(() {});
                        overlayEntry?.markNeedsBuild();
                        overlayEntry?.remove();
                        Navigator.pop(context); */

                      isExercising = false;
                      isPause = false;
                      print(
                          "结束运动 类型:${items[selectedType]}  开始/结束：${startTime} ~ ${DateTime.now()}");

                      overlayEntry?.remove();
                      setState(() {});
                      updateView();
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.greenAccent),
                    ),
                    child: Text('开始'),
                  ),
                ],
              ),
            ]),
      ),
    );
  }

  void getDataFromServer() async {
    // print(
    //    '血脂修改请求日期：${date.year}-${date.month}-${date.day}....................................');
    String requestDate = getFormattedDate(date);

    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    response = await dio.get(
      widget.arguments["accountId"] >= 0
          ? "http://43.138.75.58:8080/api/blood-lipids/get-by-date?date=$requestDate&accountId=${widget.arguments["accountId"]}"
          : "http://43.138.75.58:8080/api/blood-lipids/get-by-date?date=$requestDate",
      /* queryParameters: {
        "startDate": requestDate,
        "endDate": requestDate,
      }, */
    );
    if (response.data["code"] == 200) {
      //print("获取血脂lipids数据成功EDIT");
      //print(response.data["data"]);
      data = response.data["data"];
      //bpdata = response.data["data"];
    } else {
      print(response);
      data = [];
    }

    int steps = 0;

    response = await dio.get(
      widget.arguments["accountId"] >= 0
          ? "http://43.138.75.58:8080/api/sports/steps?accountId=${widget.arguments["accountId"]}"
          : "http://43.138.75.58:8080/api/sports/steps",
    );
    if (response.data["code"] == 200) {
      steps = response.data["data"];
    } else {
      print(response);
    }

    titleDateWidget =
        TitleDate(date: date, updateView: updateView, updateDate: updateDate);
    dataWidget = [];
    dataWidget.add(titleDateWidget);
    dataWidget.add(StepWidget(step: steps)); //TODO
    dataWidget.add(const SizedBox(height: 20));

    for (int i = 0; i < data.length; i++) {
      int id_ = data[i]["id"];
      String date_ = data[i]["date"];
      String timeStr = data[i]["time"];
      int hour = int.parse(timeStr.split(":")[0]);
      int minute = int.parse(timeStr.split(":")[1]);
      DateTime time_ = DateTime(2023, 01, 01, hour, minute);
      String TC = (data[i]["tc"]).toString();
      String TG = (data[i]["tg"]).toString();
      String LDL = (data[i]["ldl"]).toString();
      String HDL = (data[i]["hdl"]).toString();
      int feeling_ = data[i]["feeling"];
      String remark_ = data[i]["remark"] ?? "暂无备注";
      data[i]["isExpanded"] = 0; // 默认收起

      if (id_ == widget.arguments["activityDataId"]) {
        data[i]["isExpanded"] = 1;
        widget.arguments["activityDataId"] = -1;
      }

      dataWidget.add(UnconstrainedBox(
        child: BloodFatEditWidget(
          accountId: widget.arguments["accountId"],
          id: id_,
          date: date,
          time: time_,
          // TC = 9.3 tc = 9 tc_ = 3
          tc: int.parse(TC.split(".")[0]),
          tc_: int.parse(TC.split(".")[1]),
          tg: int.parse(TG.split(".")[0]),
          tg_: int.parse(TG.split(".")[1]),
          ldl: int.parse(LDL.split(".")[0]),
          ldl_: int.parse(LDL.split(".")[1]),
          hdl: int.parse(HDL.split(".")[0]),
          hdl_: int.parse(HDL.split(".")[1]),
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
    widget.arguments['activityDataId'];
    // 先从后端获取数据
    getDataFromServer();
  }

  void updateDate(DateTime newDate) {
    // print("new date: $newDate");
    date = newDate;
    getDataFromServer();
  }

  void updateData() {
    //print("刷新，日期：${date.year}年${date.month}月${date.day}日");
    getDataFromServer();
  }

  // 控制同一时间只有一个能展开进行编辑，不会影响数据
  void updateView() {
    List<int> isExpandedArray = [];
    for (int i = 0; i < data.length; i++) {
      //print("展开状态 isExpanded: ${data[i]["id"]} ${data[i]["isExpanded"]}");
      isExpandedArray.add(data[i]["isExpanded"]);
    }

    List<Widget> dataWidgetTemp = [];
    dataWidgetTemp.add(titleDateWidget);
    dataWidgetTemp.add(StepWidget(step: 2460)); //TODO
    dataWidgetTemp.add(const SizedBox(height: 20));
    isExercising ? dataWidgetTemp.add(exercisingWidget()) : const SizedBox();
    isExercising
        ? dataWidgetTemp.add(const SizedBox(height: 20))
        : const SizedBox();
    for (int i = 0; i < data.length; i++) {
      String timeStr = data[i]["time"];
      int hour = int.parse(timeStr.split(":")[0]);
      int minute = int.parse(timeStr.split(":")[1]);
      String TC = (data[i]["tc"]).toString();
      String TG = (data[i]["tg"]).toString();
      String LDL = (data[i]["ldl"]).toString();
      String HDL = (data[i]["hdl"]).toString();
      DateTime time_ = DateTime(2023, 01, 01, hour, minute);
      dataWidgetTemp.add(UnconstrainedBox(
        child: BloodFatEditWidget(
          accountId: widget.arguments["accountId"],
          id: data[i]["id"],
          date: date,
          time: time_,
          tc: int.parse(TC.split(".")[0]),
          tc_: int.parse(TC.split(".")[1]),
          tg: int.parse(TG.split(".")[0]),
          tg_: int.parse(TG.split(".")[1]),
          ldl: int.parse(LDL.split(".")[0]),
          ldl_: int.parse(LDL.split(".")[1]),
          hdl: int.parse(HDL.split(".")[0]),
          hdl_: int.parse(HDL.split(".")[1]),
          feeling: data[i]["feeling"],
          isExpanded: isExpandedArray[i],
          remark: data[i]["remark"] ?? "暂无备注",
          updateParent: updateView,
          updateData: updateData,
        ),
      ));
    }

    if (data.isEmpty) {
      dataWidget.add(const NoDataWidget());
    }

    dataWidget = dataWidgetTemp;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print("血压修改页面刷新");
    return Scaffold(
      /* appBar: AppBar(
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
          //print("我要添加运动数据");
          // 如果是今天才能添加数据
          if (date.year != DateTime.now().year ||
              date.month != DateTime.now().month ||
              date.day != DateTime.now().day) {
            //snackbar提示只有今天才能添加数据
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("温馨提示：只能添加今天的运动数据"),
                duration: Duration(seconds: 1),
              ),
            );
          } else if (isExercising) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("温馨提示：请先结束运动"),
                duration: Duration(seconds: 1),
              ),
            );
          } else {
            // 开始运动
            exercisingTypeOverlay(context);
          }
        },
        shape: const CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 237, 136, 247),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
