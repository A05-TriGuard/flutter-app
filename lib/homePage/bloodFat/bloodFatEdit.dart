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
Widget addDataButtonWidget = addDataButton();
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
  final TextEditingController tcController = TextEditingController();
  final TextEditingController tc_Controller = TextEditingController();
  final TextEditingController tgController = TextEditingController();
  final TextEditingController tg_Controller = TextEditingController();
  final TextEditingController ldlController = TextEditingController();
  final TextEditingController ldl_Controller = TextEditingController();
  final TextEditingController hdlController = TextEditingController();
  final TextEditingController hdl_Controller = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

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
      "tc": double.parse(tcController.text + "." + tc_Controller.text),
      "tg": double.parse(tgController.text + "." + tg_Controller.text),
      "ldl": double.parse(ldlController.text + "." + ldl_Controller.text),
      "hdl": double.parse(hdlController.text + "." + hdl_Controller.text),
      "feeling": feelingsButtons.getSelectedButtonIndex(),
    };

    if (remarkController.text != "") {
      newVal["remark"] = remarkController.text;
    }

    if (widget.accountId >= 0) {
      newVal["accountId"] = widget.accountId.toString();
    }

    final Dio dio = Dio();

    const String addDataApi =
        'http://43.138.75.58:8080/api/blood-lipids/create';

    try {
      var token = await storage.read(key: 'token');
      dio.options.headers["Authorization"] = "Bearer $token";
      Response response = await dio.post(
        addDataApi,
        //queryParameters: newVal,
        data: newVal,
      );

      print(response.data);

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

  //填写的框
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
    return UnconstrainedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            // height: MediaQuery.of(context).size.height * 0.62,
            height: 460,
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
                            getTitle("总胆固醇", "TC"),
                            getTitle("甘油三酯", "TG"),
                            getTitle("低密度脂蛋白胆固醇", "LDL"),
                            getTitle("高密度脂蛋白胆固醇", "HDL"), //高密度脂蛋白胆固醇
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
                            // 修改tc
                            getEditWidget(
                                tcController, tc_Controller, "4", "1"),

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            // 修改tg
                            getEditWidget(
                                tgController, tg_Controller, "1", "0"),

                            //
                            const SizedBox(
                              height: 15,
                            ),

                            // 修改ldl
                            getEditWidget(
                                ldlController, ldl_Controller, "2", "5"),

                            //
                            const SizedBox(
                              height: 15,
                            ),

                            // 修改hdl
                            getEditWidget(
                                hdlController, hdl_Controller, "1", "3"),

                            //
                            const SizedBox(
                              height: 20,
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
                              print("取消添加数据");
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
                        "修改血脂",
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
                  ? 470 //MediaQuery.of(context).size.height * 0.65
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
                Row(
                  children: [
                    const Text('总胆固醇: ',
                        style:
                            TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
                    Text('${widget.tc}.${widget.tc_}',
                        style: const TextStyle(
                            fontSize: 20, fontFamily: "BalooBhai")),
                  ],
                ),
                Row(
                  children: [
                    const Text('甘油三酯: ',
                        style:
                            TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
                    Text('${widget.tg}.${widget.tg_}',
                        style: const TextStyle(
                            fontSize: 20, fontFamily: "BalooBhai")),
                  ],
                ),
                Row(
                  children: [
                    const Text('低密度脂蛋白胆固醇: ',
                        style:
                            TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
                    Text('${widget.ldl}.${widget.ldl_}',
                        style: const TextStyle(
                            fontSize: 20, fontFamily: "BalooBhai")),
                  ],
                ),
                Row(
                  children: [
                    const Text('高密度脂蛋白胆固醇: ',
                        style:
                            TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
                    Text('${widget.hdl}.${widget.hdl_}',
                        style: const TextStyle(
                            fontSize: 20, fontFamily: "BalooBhai")),
                  ],
                ),
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
                            getTitle("时间", "TIME"),
                            getTitle("总胆固醇", "TC"),
                            getTitle("甘油三酯", "TG"),
                            getTitle("低密度脂蛋白胆固醇", "LDL"),
                            getTitle("高密度脂蛋白胆固醇", "HDL"), //高密度脂蛋白胆固醇
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

                            // 修改tc
                            getEditWidget(tcController, tc_Controller,
                                widget.tc.toString(), widget.tc_.toString()),

                            //
                            const SizedBox(
                              height: 5,
                            ),

                            // 修改tg
                            getEditWidget(tgController, tg_Controller,
                                widget.tg.toString(), widget.tg_.toString()),

                            //
                            const SizedBox(
                              height: 15,
                            ),

                            // 修改ldl
                            getEditWidget(ldlController, ldl_Controller,
                                widget.ldl.toString(), widget.ldl_.toString()),

                            //
                            const SizedBox(
                              height: 15,
                            ),

                            // 修改hdl
                            getEditWidget(hdlController, hdl_Controller,
                                widget.hdl.toString(), widget.hdl_.toString()),

                            //
                            const SizedBox(
                              height: 20,
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
class BloodFatEdit extends StatefulWidget {
  final Map arguments;
  // 需要 accountId, nickname, date, bfDataId

  const BloodFatEdit({Key? key, required this.arguments}) : super(key: key);
  @override
  _BloodFatEditState createState() => _BloodFatEditState();
}

class _BloodFatEditState extends State<BloodFatEdit> {
  DateTime addTime = DateTime.now();
  DateTime date = DateTime.now();
  int bfDataId = -1;

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
      String TC = (data[i]["tc"]).toString();
      String TG = (data[i]["tg"]).toString();
      String LDL = (data[i]["ldl"]).toString();
      String HDL = (data[i]["hdl"]).toString();
      int feeling_ = data[i]["feeling"];
      String remark_ = data[i]["remark"] ?? "暂无备注";
      data[i]["isExpanded"] = 0; // 默认收起

      if (id_ == widget.arguments["bfDataId"]) {
        data[i]["isExpanded"] = 1;
        widget.arguments["bfDataId"] = -1;
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
      dataWidget.add(NoDataWidget());
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    date = widget.arguments['date'];
    widget.arguments['bfDataId'];
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
          print("我要添加血脂数据");
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
