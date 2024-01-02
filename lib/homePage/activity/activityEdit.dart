import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:triguard/component/titleDate/titleDate.dart';
import 'package:dio/dio.dart';

import '../../component/header/header.dart';
import '../../account/token.dart';
import "../../other/other.dart";

//
typedef UpdateTimeCallback = void Function(DateTime newTime);
typedef UpdateDateCallback = void Function(DateTime newDate);

// 删除 取消 确定
List<String> feelingButtonTypes = ["开心", "还好", "不好"];
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

late Widget titleDateWidget;
bool deleteDataMark = false;

// ignore: camel_case_types
class newValue {
  int id = 0;
  int type = 0;

  int feelingIndex = 0;
  String remarks = "";

  newValue(
    this.id,
    this.type,
    this.feelingIndex,
    this.remarks,
  );

  void clear() {
    id = 0;
    type = 0;
    feelingIndex = 0;
    remarks = "";
  }
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

late newValue afterEditedValue;

// =================================================================================

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
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(
                height: 5,
              ),
              Row(children: [
                const Text(
                  "修改活动",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Image.asset("assets/icons/bloodFat.png", width: 20, height: 20),
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
                    color: Color.fromRGBO(48, 48, 48, 1),
                  ),
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
                                      const Color.fromARGB(255, 118, 241, 250),
                                    ),
                                  ),
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
        padding: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: functionButtonColors[widget.type],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: const Color.fromRGBO(122, 119, 119, 0.43)),
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

// 感觉按钮
class FeelingsButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final bool isSelected;

  const FeelingsButton({
    Key? key,
    required this.onPressed,
    required this.iconPath,
    required this.isSelected,
  }) : super(key: key);

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

// 生成血压数据的显示模块
// ignore: must_be_immutable
class ActivityEditWidget extends StatefulWidget {
  final int accountId;
  final int id;
  final String startTime;
  final String endTime;
  final int type;
  final int duration;
  final int feeling;
  final String remark;
  final VoidCallback updateParent;
  final VoidCallback updateData;
  int isExpanded;

  ActivityEditWidget({
    Key? key,
    required this.accountId,
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.duration,
    required this.feeling,
    required this.remark,
    required this.isExpanded,
    required this.updateParent,
    required this.updateData,
  }) : super(key: key);

  @override
  State<ActivityEditWidget> createState() => _ActivityEditWidgetState();
}

class _ActivityEditWidgetState extends State<ActivityEditWidget> {
  // 删除数据
  Future<void> deleteData(int id) async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    response = await dio.get(widget.accountId >= 0
        ? "http://43.138.75.58:8080/api/sports/exercise/delete?id=$id&accountId=${widget.accountId}"
        : "http://43.138.75.58:8080/api/sports/exercise/delete?id=$id");
    if (response.data["code"] == 200) {
      return;
    } else {
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
      "type": afterEditedValue.type,
      "feelings": afterEditedValue.feelingIndex,
      "remark": afterEditedValue.remarks,
    };

    if (widget.accountId >= 0) {
      newVal["accountId"] = widget.accountId.toString();
    }

    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/sports/exercise/update",
        queryParameters: newVal,
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
            height: getDataById(widget.id, "isExpanded") == 1 ? 380 : 200,
            width: MediaQuery.of(context).size.width * 0.85,

            alignment: Alignment.center,
            //https://stackoverflow.com/questions/56298325/overflow-warning-in-animatedcontainer-adjusting-height
            //切换的一瞬间会overflow，用SingleChildScrollView包裹一下解决
            child: getDataById(widget.id, "isExpanded") == 1
                ? SingleChildScrollView(
                    child: ActivityEditWidgetMore(
                      id: widget.id,
                      startTime: widget.startTime,
                      endTime: widget.endTime,
                      type: widget.type,
                      duration: widget.duration,
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
                        editData(widget.id, afterEditedValue).then((_) {
                          widget.updateData();
                        });
                      },
                    ),
                  )
                : SingleChildScrollView(
                    child: ActivityEditWidgetLess(
                      id: widget.id,
                      startTime: widget.startTime,
                      endTime: widget.endTime,
                      type: widget.type,
                      duration: widget.duration,
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
class ActivityEditWidgetLess extends StatefulWidget {
  final int id;
  final String startTime;
  final String endTime;
  final int type;
  final int duration;
  final int feeling;
  final String remark;

  const ActivityEditWidgetLess(
      {Key? key,
      required this.id,
      required this.startTime,
      required this.endTime,
      required this.type,
      required this.duration,
      required this.feeling,
      required this.remark})
      : super(key: key);

  @override
  State<ActivityEditWidgetLess> createState() => _ActivityEditWidgetLessState();
}

class _ActivityEditWidgetLessState extends State<ActivityEditWidgetLess> {
  List<String> mealButtonTypes = ["空腹", "餐后", "不选"];
  List<String> feelingButtonTypes = ["开心", "还好", "不好"];
  bool showRemark = false;
  PageController pageController = PageController();

  Widget getInfoPage() {
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
                  widget.startTime,
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
                  widget.endTime,
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
                      (widget.duration).toString(),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '运动类型: ',
                  style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Text(
                  items[widget.type],
                  style: const TextStyle(
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
class ActivityEditWidgetMore extends StatefulWidget {
  final int id;
  final String startTime;
  final String endTime;
  int type;
  final int duration;
  int feeling;
  String remark;
  final VoidCallback deleteData;
  final VoidCallback cancelEditData;
  final VoidCallback confirmEditData;
  int selectedType = 0;

  ActivityEditWidgetMore({
    Key? key,
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.duration,
    required this.feeling,
    required this.remark,
    required this.deleteData,
    required this.cancelEditData,
    required this.confirmEditData,
  }) : super(key: key);

  @override
  State<ActivityEditWidgetMore> createState() => _ActivityEditWidgetMoreState();
}

class _ActivityEditWidgetMoreState extends State<ActivityEditWidgetMore> {
  int invalidValueType = 0;
  int selectedType = 0;
  OverlayEntry? overlayEntry;
  TextEditingController remarkController = TextEditingController();
  FeelingsButtonsRow feelingsButtons = FeelingsButtonsRow(
    selectedIndex: 0,
  );

  @override
  void initState() {
    super.initState();
    selectedType = widget.type;
  }

  void updateTime(DateTime newTime) {
    setState(() {
      widget.type = selectedType;
      widget.feeling = feelingsButtons.getSelectedButtonIndex();
      widget.remark = remarkController.text;
    });
  }

  // 显示未修改前的值
  void getBeforeEditValue() {
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color.fromARGB(217, 131, 131, 131),
                  ),
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
    return SizedBox(
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
              setState(() {
                // 更新被选中的运动类型
              });
              overlayEntry?.markNeedsBuild();
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item == items[selectedType]
                    ? const Color.fromARGB(255, 253, 184, 255)
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //“开始运动”
            const Text(
              "修改类型",
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
                        const Color.fromARGB(255, 118, 246, 255)),
                  ),
                  child: const Text('取消'),
                ),

                //确定开始运动
                ElevatedButton(
                  onPressed: () {
                    widget.type = selectedType;
                    setState(() {});
                    overlayEntry?.markNeedsBuild();
                    overlayEntry?.remove();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent),
                  ),
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 获取标题 中文+英文
  Widget getTitle(String titleChn, String titleEng) {
    if (titleChn.length > 4) {
      return Column(
        children: [
          Text(
            titleChn.substring(0, 4), //前四个字
            style: const TextStyle(fontSize: 14, fontFamily: "BalooBhai"),
          ),
          Text(
            titleChn.substring(4),
            style: const TextStyle(fontSize: 14, fontFamily: "BalooBhai"),
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
    // 输入的controller
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
                          getTitle("开始时间", "START TIME"),
                          getTitle("结束时间", "END TIME"),
                          getTitle("总时长", "TOTAL TIME"),
                          getTitle("运动类型", "TYPE"),
                          getTitle("感觉", "FEELINGS"),
                          getTitle("备注", "REMARKS"),
                        ],
                      ),

                      const SizedBox(width: 5),

                      // 右边的子容器 （值）
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //开始时间
                          SizedBox(
                            height: 41,
                            child: Center(
                              child: Text(
                                widget.startTime,
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
                          SizedBox(
                            height: 41,
                            child: Center(
                              child: Text(
                                widget.endTime,
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
                          SizedBox(
                            height: 41,
                            child: Center(
                              child: Text(
                                "${widget.duration} 分钟",
                                style: const TextStyle(
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
                              SizedBox(
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
                              SizedBox(
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
                                afterEditedValue = newValue(
                                    widget.id,
                                    selectedType,
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
  // ignore: library_private_types_in_public_api
  _ActivityEditState createState() => _ActivityEditState();
}

class _ActivityEditState extends State<ActivityEdit> {
  DateTime addTime = DateTime.now();
  DateTime date = DateTime.now();
  int activityDataId = -1;
  bool isExercising = false;
  int selectedType = 0;
  bool isPause = false;
  String startTime = "2023-01-01 00:00";
  String endTime = "2023-01-01 00:00";
  OverlayEntry? overlayEntry;
  int accountId = -1;
  int feelings = 1;
  int steps = 0;
  TextEditingController remarksController = TextEditingController();

  //

  // 运动类型选择弹窗
  void exercisingTypeOverlay(BuildContext context) async {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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

  // 确定结束运动dialog
  // 获取当前是否有在运动
  Future<void> getCurrentExercising() async {
    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    response = await dio.get(
      widget.arguments["accountId"] >= 0
          ? "http://43.138.75.58:8080/api/sports/exercise/current?accountId=${widget.arguments["accountId"]}"
          : "http://43.138.75.58:8080/api/sports/exercise/current",
    );
    if (response.data["code"] == 200) {
      if (response.data["data"] != null) {
        isExercising = response.data["data"]["isExercising"];
        isPause = response.data["data"]["isPausing"];
        startTime = response.data["data"]["startTime"];
        selectedType = response.data["data"]["type"];
      } else {
        isExercising = false;
        isPause = false;
        startTime = "2023-01-01 00:00";
        selectedType = 0;
      }
    } else {
      return;
    }
  }

  //开始运动
  Future<bool> startExercising() async {
    var token = await storage.read(key: 'token');
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    startTime =
        '${getFormattedDate(DateTime.now())} ${getFormattedTime(DateTime.now())}';

    var arguments = {
      "type": selectedType,
      "time":
          '${getFormattedDate(DateTime.now())} ${getFormattedTime(DateTime.now())}',
    };

    if (widget.arguments["accountId"] >= 0) {
      arguments["accountId"] = (widget.arguments["accountId"]).toString();
    }

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/sports/exercise/start",
          queryParameters: arguments);
      if (response.data["code"] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 暂停运动
  Future<bool> pauseExercising() async {
    //return true;
    var token = await storage.read(key: 'token');
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    var arguments = {
      "time":
          '${getFormattedDate(DateTime.now())} ${getFormattedTime(DateTime.now())}',
    };

    if (widget.arguments["accountId"] >= 0) {
      arguments["accountId"] = (widget.arguments["accountId"].toString());
    }

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/sports/exercise/pause",
          queryParameters: arguments);
      if (response.data["code"] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 继续运动
  Future<bool> continueExercising() async {
    //return true;
    var token = await storage.read(key: 'token');
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    var arguments = {
      "time":
          '${getFormattedDate(DateTime.now())} ${getFormattedTime(DateTime.now())}',
    };

    if (widget.arguments["accountId"] >= 0) {
      arguments["accountId"] = (widget.arguments["accountId"].toString());
    }

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/sports/exercise/continue",
          queryParameters: arguments);
      if (response.data["code"] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 结束运动
  Future<bool> endExercising() async {
    if (isPause) {
      await continueExercising();
    }

    var token = await storage.read(key: 'token');
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    var arguments = {
      "time":
          '${getFormattedDate(DateTime.now())} ${getFormattedTime(DateTime.now())}',
      "feelings": feelings,
      "remark": remarksController.text,
    };

    if (widget.arguments["accountId"] >= 0) {
      arguments["accountId"] = widget.arguments["accountId"];
    }

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/sports/exercise/end",
          queryParameters: arguments);
      if (response.data["code"] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 确定结束运动弹窗
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

  // 结束运动后填写感觉与备注
  void exercisingFeelingsRemarksOverlay(BuildContext context) async {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 225,
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

  // 运动感受与备注 （取消，确定）
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
                          feelings = 0;
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
                          feelings = 1;
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
                          feelings = 2;
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
                SizedBox(
                  height: 41,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: 40,
                    child: TextFormField(
                      controller: remarksController,
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
                      overlayEntry?.remove();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 118, 246, 255)),
                    ),
                    child: const Text('取消'),
                  ),

                  //确定
                  ElevatedButton(
                    onPressed: () async {
                      bool status = await endExercising();
                      if (status) {
                        isExercising = false;
                        isPause = false;
                        overlayEntry?.remove();
                        updateData();
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      } else {
                        overlayEntry?.remove();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.greenAccent),
                    ),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ]),
      ),
    );
  }

  // 运动类型枚举选择
  Widget exercisingTypeSelector2() {
    //网格布局，将items中的数据放入网格中
    return SizedBox(
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
              setState(() {
                // 更新被选中的运动类型
              });
              overlayEntry?.markNeedsBuild();
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item == items[selectedType]
                    ? const Color.fromARGB(255, 253, 184, 255)
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

  // 运动类型选择界面（取消，开始）
  Widget getTypeSelector2() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    overlayEntry?.remove();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 118, 246, 255)),
                  ),
                  child: const Text('取消'),
                ),

                //确定开始运动
                ElevatedButton(
                  onPressed: () async {
                    bool status = await startExercising();
                    if (status) {
                      isExercising = true;
                      overlayEntry?.markNeedsBuild();
                      overlayEntry?.remove();
                    } else {
                      overlayEntry?.remove();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent),
                  ),
                  child: const Text('开始'),
                ),
              ],
            ),
          ],
          //),
        ),
      ),
    );
  }

  Future<void> getDataFromServer() async {
    await getCurrentExercising();

    String requestDate = getFormattedDate(date);

    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    var arguments = {
      "startDate": requestDate,
      "endDate": requestDate,
    };

    if (widget.arguments["accountId"] >= 0) {
      arguments["accountId"] = (widget.arguments["accountId"]).toString();
    }

    response = await dio.get(
      "http://43.138.75.58:8080/api/sports/exercise/list",
      queryParameters: arguments,
    );
    if (response.data["code"] == 200) {
      if (response.data["data"] == null) {
        data = [];
      } else {
        data = response.data["data"];
      }
    } else {
      data = [];
    }

    response = await dio.get(
      widget.arguments["accountId"] >= 0
          ? "http://43.138.75.58:8080/api/sports/steps?accountId=${widget.arguments["accountId"]}"
          : "http://43.138.75.58:8080/api/sports/steps",
    );
    if (response.data["code"] == 200) {
      steps = response.data["data"][0]["steps"];
    } else {}

    // 如果data[i]["endTime"] == null ，则剔除这一项
    for (int i = 0; i < data.length; i++) {
      if (data[i]["endTime"] == null) {
        data.removeAt(i);
        i--;
      }
    }

    titleDateWidget =
        TitleDate(date: date, updateView: updateView, updateDate: updateDate);
    dataWidget = [];
    dataWidget.add(titleDateWidget);
    dataWidget.add(StepWidget(step: steps));
    dataWidget.add(const SizedBox(height: 20));
    dataWidget.add(getCurrentExercisingWidget());
    if (isExercising) dataWidget.add(const SizedBox(height: 20));

    for (int i = 0; i < data.length; i++) {
      if (data[i]["endTime"] == null) {
        continue;
      }
      int id_ = data[i]["id"];
      String startTime = data[i]["startTime"];
      String endTime = data[i]["endTime"];
      int duration = data[i]["duration"];
      int type = data[i]["type"];
      int feelings = data[i]["feelings"];
      String remark = data[i]["remark"] ?? "暂无备注";

      data[i]["isExpanded"] = 0; // 默认收起

      if (id_ == widget.arguments["activityDataId"]) {
        data[i]["isExpanded"] = 1;
        widget.arguments["activityDataId"] = -1;
      }

      dataWidget.add(UnconstrainedBox(
        child: ActivityEditWidget(
          accountId: widget.arguments["accountId"],
          id: id_,
          startTime: startTime,
          endTime: endTime,
          duration: duration,
          type: type,
          feeling: feelings,
          isExpanded: 0,
          remark: remark,
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
    selectedType = 0;
    date = widget.arguments['date'];
    widget.arguments['activityDataId'];
    // 先从后端获取数据
    getDataFromServer();
  }

  void updateDate(DateTime newDate) {
    date = newDate;
    getDataFromServer();
  }

  void updateData() {
    getDataFromServer();
  }

  // 控制同一时间只有一个能展开进行编辑，不会影响数据
  Future<void> updateView() async {
    await getCurrentExercising();

    // 如果data[i]["endTime"] == null ，则剔除这一项
    for (int i = 0; i < data.length; i++) {
      if (data[i]["endTime"] == null) {
        data.removeAt(i);
        i--;
      }
    }

    List<int> isExpandedArray = [];
    for (int i = 0; i < data.length; i++) {
      isExpandedArray.add(data[i]["isExpanded"]);
    }

    List<Widget> dataWidgetTemp = [];
    dataWidgetTemp.add(titleDateWidget);
    dataWidgetTemp.add(StepWidget(step: steps));
    dataWidgetTemp.add(const SizedBox(height: 20));
    dataWidgetTemp.add(getCurrentExercisingWidget());
    dataWidgetTemp.add(const SizedBox(height: 10));
    isExercising
        ? dataWidgetTemp.add(const SizedBox(height: 20))
        : const SizedBox();
    for (int i = 0; i < data.length; i++) {
      dataWidgetTemp.add(UnconstrainedBox(
        child: ActivityEditWidget(
          accountId: widget.arguments["accountId"],
          id: data[i]["id"],
          startTime: data[i]["startTime"],
          endTime: data[i]["endTime"],
          duration: data[i]["duration"],
          type: data[i]["type"],
          feeling: data[i]["feelings"],
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
    if (mounted) setState(() {});
  }

  // 运动中组件
  Widget getCurrentExercisingWidget() {
    if (isExercising == false) {
      return const SizedBox();
    }

    // 运动时长组件
    return UnconstrainedBox(
      child: SizedBox(
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
                      // 运动中或开始运动
                      //运动时
                      Column(
                        children: [
                          // 计时器
                          Container(
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
                                Container(
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    startTime,
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
                          SizedBox(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 暂停
                                Container(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (isPause == false) {
                                        bool status = await pauseExercising();

                                        if (status) {
                                          isPause = true;
                                        }
                                      } else {
                                        bool status =
                                            await continueExercising();

                                        if (status) {
                                          isPause = false;
                                        }
                                      }

                                      //###
                                      updateView();
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 35,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isPause == false
                                            ? Colors.blueAccent
                                            : const Color.fromARGB(
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
          ],
        ),
      ),
    );
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
