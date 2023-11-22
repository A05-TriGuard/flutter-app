import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import '../../component/header/header.dart';
import '../../component/titleDate/titleDate.dart';
import '../../other/gradientBorder/gradient_borders.dart';
import './bpData.dart';

//typedef UpdateDateCallback = void Function(DateTime newDate);
//typedef UpdateDaysCallback = void Function(String newDays);
typedef UpdateHeartRateFilterCallback = void Function(
    int minHeartRate, int maxHeartRate);
typedef UpdateArmFilterCallback = void Function(List<bool> armsSelected);
typedef UpdateFeelingsFilterCallback = void Function(
    List<bool> feelingsSelected);
typedef UpdateDateCallback = void Function(DateTime newDate);

List<bool> prevArmsSelected1 = [false, false, false, true];
List<bool> prevFeelingsSelected1 = [false, false, false, true];

class BloodPressureFilterParam {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));

  DateTime endDate = DateTime.now();
  List<bool> armsSelected = [false, false, false, true];
  List<bool> feelingsSelected = [false, false, false, true];
  bool refresh = false;
  TextEditingController minHeartRateController = TextEditingController();
  TextEditingController maxHeartRateController = TextEditingController();
  TextEditingController maxSBPController = TextEditingController();
  TextEditingController minSBPController = TextEditingController();
  TextEditingController maxDBPController = TextEditingController();
  TextEditingController minDBPController = TextEditingController();
  TextEditingController startHourController = TextEditingController();
  TextEditingController startMinuteController = TextEditingController();
  TextEditingController endHourController = TextEditingController();
  TextEditingController endMinuteController = TextEditingController();
  BloodPressureFilterParam({
    required this.startDate,
    required this.endDate,
    required this.armsSelected,
    required this.feelingsSelected,
    required this.refresh,
    required this.minHeartRateController,
    required this.maxHeartRateController,
    required this.minSBPController,
    required this.maxSBPController,
    required this.minDBPController,
    required this.maxDBPController,
    required this.startHourController,
    required this.startMinuteController,
    required this.endHourController,
    required this.endMinuteController,
  });

  void printFilterParams() {
    print('日期：${startDate} ~ ${endDate}');
    print(
        '时间： ${startHourController.text}:${startMinuteController.text} ~ ${endHourController.text}:${endMinuteController.text}');
    print('收缩压： ${minSBPController.text} ~  ${maxSBPController.text}');
    print('舒张压： ${minDBPController.text} ~  ${maxDBPController.text}');
    print(
        '心率： ${minHeartRateController.text} ~  ${maxHeartRateController.text}');
    print('手臂：${armsSelected}');
    print('感觉：${feelingsSelected}');
    print('刷新：${refresh}');
    print("====================");
  }
}

// 血压表格记录
// ignore: must_be_immutable
class BloodPressureRecordWidget extends StatefulWidget {
  BloodPressureFilterParam filterParam;
  bool oldParam = false;
  final VoidCallback updateGraph;
  BloodPressureRecordWidget(
      {Key? key,
      required this.filterParam,
      required this.oldParam,
      required this.updateGraph})
      : super(key: key);

  @override
  State<BloodPressureRecordWidget> createState() =>
      _BloodPressureRecordWidgetState();
}

class _BloodPressureRecordWidgetState extends State<BloodPressureRecordWidget> {
  @override
  Widget build(BuildContext context) {
    // 原始数据
    /* if (widget.filterParam.refresh == true && widget.oldParam == true) {
      print("数据表格刷新（完全无设置过滤器）");
      widget.filterParam.printFilterParams();
      widget.oldParam = false;
    } else if (widget.filterParam.refresh == true && widget.oldParam == false) {
      print("数据表格刷新（已经设置过滤器）");
      widget.filterParam.printFilterParams();
    } */

    if (widget.filterParam.refresh == true) {
      print("数据表格刷新");
      widget.filterParam.printFilterParams();
      //widget.oldParam = false;
      widget.filterParam.refresh = false;
    } else {
      print("数据表格 (不) 刷新");
      widget.filterParam.printFilterParams();
      widget.filterParam.refresh = false;
    }

    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromARGB(255, 129, 127, 127),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 240, 186),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text("血压记录"),
            ),
          ),
        ),
      ),
    );
  }
}

// 统计情况
class BloodPressureStatisticsWidget extends StatefulWidget {
  const BloodPressureStatisticsWidget({super.key});

  @override
  State<BloodPressureStatisticsWidget> createState() =>
      _BloodPressureStatisticsWidgetState();
}

class _BloodPressureStatisticsWidgetState
    extends State<BloodPressureStatisticsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 手臂选择按钮
// ignore: must_be_immutable
class ArmButtonsWidget extends StatefulWidget {
  //final VoidCallback onPressed;
  //final String iconPath;
  //final bool isSelected;
  List<bool> isSelected = [false, false, false, true];
  ArmButtonsWidget({
    Key? key,
    //required this.onPressed,
    //required this.iconPath,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<ArmButtonsWidget> createState() => _ArmButtonsWidgetState();
}

class _ArmButtonsWidgetState extends State<ArmButtonsWidget> {
  List<String> buttonText = ["左手", "右手", "不选", "-"];

  Widget getButton(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == 3) {
            for (int i = 0; i < widget.isSelected.length; i++) {
              widget.isSelected[i] = false;
            }
            widget.isSelected[index] = true;
          } else {
            widget.isSelected[3] = false;
            widget.isSelected[index] = !widget.isSelected[index];
            int totalSelected = 0;
            for (int i = 0; i < 3; i++) {
              widget.isSelected[i] ? totalSelected++ : null;
            }
            if (totalSelected == 3) {
              for (int i = 0; i < 3; i++) {
                widget.isSelected[i] = false;
              }
              widget.isSelected[3] = true;
            }
          }
        });
      },
      child: Container(
        child: Row(children: [
          Container(
            height: 40,
            width: 50,
            padding: EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              color: widget.isSelected[index] == true
                  ? const Color.fromRGBO(253, 134, 255, 0.66)
                  : Color.fromRGBO(218, 218, 218, 0.66),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Color.fromRGBO(122, 119, 119, 0.43)),
            ),
            alignment: Alignment.center,
            child: Center(
              child: Text(
                buttonText[index],
                style: TextStyle(
                  color: widget.isSelected[index] == true
                      ? Color.fromRGBO(66, 9, 119, 0.773)
                      : Color.fromRGBO(94, 68, 68, 100),
                  fontSize: 16.0,
                  fontFamily: 'Blinker',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 5),
        ]),
      ),
    );
  }

  Widget getButtonSet() {
    List<Widget> buttonSet = [];
    for (int i = 0; i < buttonText.length; i++) {
      buttonSet.add(getButton(i));
    }

    return Row(
      children: buttonSet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: getButtonSet(),
    );
  }
}

// 感觉选择按钮
// ignore: must_be_immutable
class FeelingsButtonsWidget extends StatefulWidget {
  BloodPressureFilterParam newFilterParam;
  FeelingsButtonsWidget({
    Key? key,
    required this.newFilterParam,
  }) : super(key: key);

  @override
  State<FeelingsButtonsWidget> createState() => _FeelingsButtonsWidgetState();
}

class _FeelingsButtonsWidgetState extends State<FeelingsButtonsWidget> {
  List<String> buttonText = ["较好", "还好", "较差", "-"];

  Widget getButton(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == 3) {
            for (int i = 0;
                i < widget.newFilterParam.feelingsSelected.length;
                i++) {
              widget.newFilterParam.feelingsSelected[i] = false;
            }
            widget.newFilterParam.feelingsSelected[index] = true;
          } else {
            widget.newFilterParam.feelingsSelected[3] = false;
            widget.newFilterParam.feelingsSelected[index] =
                !widget.newFilterParam.feelingsSelected[index];
            int totalSelected = 0;
            for (int i = 0; i < 3; i++) {
              widget.newFilterParam.feelingsSelected[i]
                  ? totalSelected++
                  : null;
            }
            if (totalSelected == 3) {
              for (int i = 0; i < 3; i++) {
                widget.newFilterParam.feelingsSelected[i] = false;
              }
              widget.newFilterParam.feelingsSelected[3] = true;
            }
          }
        });
      },
      child: Container(
        child: Row(children: [
          Container(
            height: 40,
            width: 50,
            padding: EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              color: widget.newFilterParam.feelingsSelected[index] == true
                  ? const Color.fromRGBO(253, 134, 255, 0.66)
                  : Color.fromRGBO(218, 218, 218, 0.66),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Color.fromRGBO(122, 119, 119, 0.43)),
            ),
            alignment: Alignment.center,
            child: Center(
              child: Text(
                buttonText[index],
                style: TextStyle(
                  color: widget.newFilterParam.feelingsSelected[index] == true
                      ? Color.fromRGBO(66, 9, 119, 0.773)
                      : Color.fromRGBO(94, 68, 68, 100),
                  fontSize: 16.0,
                  fontFamily: 'Blinker',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 5),
        ]),
      ),
    );
  }

  Widget getButtonSet() {
    List<Widget> buttonSet = [];
    for (int i = 0; i < buttonText.length; i++) {
      buttonSet.add(getButton(i));
    }

    return Row(
      children: buttonSet,
    );
  }

  @override
  Widget build(BuildContext context) {
    //print('感觉里面：${widget.isSelected}');

    /* if (widget.reset) {
      widget.isSelected = widget.prevIsSelected;
    } */

    return Container(
      child: getButtonSet(),
    );
  }
}

// 心率区间
// ignore: must_be_immutable
class PulseFilterWidget extends StatefulWidget {
  int minHeartRate = 0;
  int maxHeartRate = 1000;
  TextEditingController minHeartRateController = TextEditingController();
  TextEditingController maxHeartRateController = TextEditingController();
  PulseFilterWidget(
      {Key? key,
      required this.minHeartRateController,
      required this.maxHeartRateController})
      : super(key: key);

  @override
  State<PulseFilterWidget> createState() => _PulseFilterWidgetState();
}

class _PulseFilterWidgetState extends State<PulseFilterWidget> {
  // final TextEditingController minHeartRateController = TextEditingController();
  // final TextEditingController maxHeartRateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          height: 40,
          child: TextFormField(
            maxLength: 3,
            controller: widget.minHeartRateController,
            //initialValue: widget.heartRate,
            decoration: InputDecoration(
                counterText: "",
                hintText: "-",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        SizedBox(width: 5),
        const Text(
          "至",
          style: const TextStyle(fontSize: 16, fontFamily: "BaloonBhai"),
        ),
        SizedBox(width: 5),
        SizedBox(
          width: 75,
          height: 40,
          child: TextFormField(
            maxLength: 3,
            controller: widget.maxHeartRateController,
            //initialValue: widget.heartRate,
            decoration: InputDecoration(
                counterText: "",
                hintText: "-",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        SizedBox(width: 2),
        const Text(
          "次/分",
          style: const TextStyle(fontSize: 16, fontFamily: "Blinker"),
        ),
      ],
    );
  }
}

// SBP区间
// ignore: must_be_immutable
class SBPFilterWidget extends StatefulWidget {
  TextEditingController minSBPController = TextEditingController();
  TextEditingController maxSBPController = TextEditingController();
  SBPFilterWidget(
      {Key? key,
      required this.minSBPController,
      required this.maxSBPController})
      : super(key: key);

  @override
  State<SBPFilterWidget> createState() => _SBPFilterWidgetState();
}

class _SBPFilterWidgetState extends State<SBPFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          height: 40,
          child: TextFormField(
            maxLength: 3,
            controller: widget.minSBPController,
            //initialValue: widget.heartRate,
            decoration: InputDecoration(
                counterText: "",
                hintText: "-",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        SizedBox(width: 5),
        const Text(
          "至",
          style: const TextStyle(fontSize: 16, fontFamily: "BaloonBhai"),
        ),
        SizedBox(width: 5),
        SizedBox(
          width: 75,
          height: 40,
          child: TextFormField(
            maxLength: 3,
            controller: widget.maxSBPController,
            //initialValue: widget.heartRate,
            decoration: InputDecoration(
                counterText: "",
                hintText: "-",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        SizedBox(width: 2),
        const Text(
          "mmHg",
          style: const TextStyle(fontSize: 16, fontFamily: "Blinker"),
        ),
      ],
    );
  }
}

//DBP区间
// ignore: must_be_immutable
class DBPFilterWidget extends StatefulWidget {
  TextEditingController minDBPController = TextEditingController();
  TextEditingController maxDBPController = TextEditingController();
  DBPFilterWidget(
      {Key? key,
      required this.minDBPController,
      required this.maxDBPController})
      : super(key: key);

  @override
  State<DBPFilterWidget> createState() => _DBPFilterWidgetState();
}

class _DBPFilterWidgetState extends State<DBPFilterWidget> {
  // final TextEditingController minHeartRateController = TextEditingController();
  // final TextEditingController maxHeartRateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          height: 40,
          child: TextFormField(
            maxLength: 3,
            controller: widget.minDBPController,
            //initialValue: widget.heartRate,
            decoration: InputDecoration(
                counterText: "",
                hintText: "-",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        SizedBox(width: 5),
        const Text(
          "至",
          style: const TextStyle(fontSize: 16, fontFamily: "BaloonBhai"),
        ),
        SizedBox(width: 5),
        SizedBox(
          width: 75,
          height: 40,
          child: TextFormField(
            maxLength: 3,
            controller: widget.maxDBPController,
            //initialValue: widget.heartRate,
            decoration: InputDecoration(
                counterText: "",
                hintText: "-",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        SizedBox(width: 2),
        const Text(
          "mmHg",
          style: const TextStyle(fontSize: 16, fontFamily: "Blinker"),
        ),
      ],
    );
  }
}

// 时间选择
class TimeFilterWidget extends StatefulWidget {
  TextEditingController startHourController = TextEditingController();
  TextEditingController startMinuteController = TextEditingController();
  TextEditingController endHourController = TextEditingController();
  TextEditingController endMinuteController = TextEditingController();
  TimeFilterWidget({
    Key? key,
    required this.startHourController,
    required this.startMinuteController,
    required this.endHourController,
    required this.endMinuteController,
  }) : super(key: key);

  @override
  State<TimeFilterWidget> createState() => _TimeFilterWidgetState();
}

class _TimeFilterWidgetState extends State<TimeFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.start,
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: TextField(
            maxLength: 2,
            controller: widget.startHourController,
            //initialValue: widget.hour,
            decoration: InputDecoration(
                counterText: "",
                hintText: "00",
                contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 2)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        const SizedBox(width: 2),
        const Text(
          "时",
          style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
        ),
        SizedBox(
          width: 50,
          child: TextField(
            maxLength: 2,
            controller: widget.startMinuteController,
            //initialValue: widget.minute,
            decoration: InputDecoration(
                counterText: "",
                hintText: "00",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 2)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        const Text(
          "分",
          style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
        ),
        const SizedBox(width: 5),
        const Text(
          "至",
          style: const TextStyle(fontSize: 16, fontFamily: "BaloonBhai"),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: 50,
          height: 50,
          child: TextField(
            maxLength: 2,
            controller: widget.endHourController,
            //initialValue: widget.hour,
            decoration: InputDecoration(
                counterText: "",
                hintText: "24",
                contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 2)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        const SizedBox(width: 2),
        const Text(
          "时",
          style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
        ),
        SizedBox(
          width: 50,
          child: TextField(
            maxLength: 2,
            controller: widget.endMinuteController,
            //initialValue: widget.minute,
            decoration: InputDecoration(
                counterText: "",
                hintText: "00",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 2)),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
          ),
        ),
        const Text(
          "分",
          style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
        ),
      ],
    );
  }
}

// 日期选择
class DateFilterWidget extends StatefulWidget {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final UpdateDateCallback updateStartDate;
  final UpdateDateCallback updateEndDate;
  final VoidCallback updateGraph;

  DateFilterWidget({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.updateStartDate,
    required this.updateEndDate,
    required this.updateGraph,
  }) : super(key: key);

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DatePicker2(date: widget.startDate, updateDate: widget.updateStartDate),
        const SizedBox(width: 10),
        const Text(
          "至",
          style: TextStyle(fontSize: 16, fontFamily: "BaloonBhai"),
        ),
        const SizedBox(width: 10),
        DatePicker2(date: widget.endDate, updateDate: widget.updateEndDate),
      ],
    );
  }
}

// 确定取消按钮
// ignore: must_be_immutable
class OKCancelButtonsWidget extends StatefulWidget {
  BloodPressureFilterParam filterParam;
  List<bool> prevArmsSelected = [false, false, false, true];
  List<bool> prevFeelingsSelected = [false, false, false, true];
  final VoidCallback updateGraph;

  OKCancelButtonsWidget({
    Key? key,
    required this.filterParam,
    required this.updateGraph,
    required this.prevArmsSelected,
    required this.prevFeelingsSelected,
  }) : super(key: key);

  @override
  State<OKCancelButtonsWidget> createState() => _OKCancelButtonsWidgetState();
}

class _OKCancelButtonsWidgetState extends State<OKCancelButtonsWidget> {
  List<bool> _localPrevArmsSelected = [false, false, false, true];
  List<bool> _localPrevFeelingsSelected = [false, false, false, true];

  @override
  void initState() {
    super.initState();
    // resetLocalPrevSelected();
    _localPrevArmsSelected = [false, false, false, true];
    _localPrevFeelingsSelected = [false, false, false, true];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            print("重置");
            // print('私有手臂：${_localPrevArmsSelected}');
            // print('私有感觉：${_localPrevFeelingsSelected}');
            // print('class手臂：${widget.prevArmsSelected}');
            // print('class感觉：${widget.prevFeelingsSelected}');
            widget.filterParam.startDate =
                DateTime.now().subtract(const Duration(days: 7));
            widget.filterParam.endDate = DateTime.now();
            widget.filterParam.startHourController.text = "";
            widget.filterParam.startMinuteController.text = "";
            widget.filterParam.endHourController.text = "";
            widget.filterParam.endMinuteController.text = "";
            widget.filterParam.minSBPController.text = "";
            widget.filterParam.maxSBPController.text = "";
            widget.filterParam.minDBPController.text = "";
            widget.filterParam.maxDBPController.text = "";
            widget.filterParam.minHeartRateController.text = "";
            widget.filterParam.maxHeartRateController.text = "";
            widget.filterParam.armsSelected = [false, false, false, true];
            widget.filterParam.feelingsSelected = [false, false, false, true];

            // widget.filterParam.armsSelected = _localPrevArmsSelected;
            // widget.filterParam.feelingsSelected = _localPrevFeelingsSelected;

            widget.filterParam.refresh = false;
            widget.updateGraph();
          },
          child: Container(
            height: 25,
            width: 40,
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 151, 156, 154),
              borderRadius: BorderRadius.circular(10.0),
              border:
                  Border.all(color: const Color.fromRGBO(122, 119, 119, 0.43)),
            ),
            alignment: Alignment.center,
            child: const Center(
              child: Text(
                "重置",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                  fontFamily: 'Blinker',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
          onTap: () {
            //widget.updateGraph();
            print("确定");

            //更新旧的参数
            //resetLocalPrevSelected();
            // _localPrevArmsSelected = List.from(widget.filterParam.armsSelected);
            // _localPrevFeelingsSelected =
            //     List.from(widget.filterParam.feelingsSelected);
            //widget.prevArmsSelected = widget.filterParam.armsSelected;
            //widget.prevFeelingsSelected = widget.filterParam.feelingsSelected;

            // print('私有手臂：${_localPrevArmsSelected}');
            // print('私有感觉：${_localPrevFeelingsSelected}');
            // print('class手臂：${widget.prevArmsSelected}');
            // print('class感觉：${widget.prevFeelingsSelected}');

            widget.filterParam.refresh = true;

            // 进行数据表的刷新
            widget.updateGraph();
          },
          child: Container(
            height: 25,
            width: 40,
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.circular(10.0),
              border:
                  Border.all(color: const Color.fromRGBO(122, 119, 119, 0.43)),
            ),
            alignment: Alignment.center,
            child: const Center(
              child: Text(
                "确定",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                  fontFamily: 'Blinker',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 筛选过滤器
// ignore: must_be_immutable
class BloodPressureFilterWidget extends StatefulWidget {
  // 默认展示过去一周的数据（含今天）

  BloodPressureFilterParam filterParam;
  List<bool> prevArmsSelected = [false, false, false, true];
  List<bool> prevFeelingsSelected = [false, false, false, true];

  final VoidCallback updateGraph;
  final UpdateDateCallback updateStartDate;
  final UpdateDateCallback updateEndDate;

  BloodPressureFilterWidget({
    Key? key,
    required this.filterParam,
    required this.updateGraph,
    required this.prevArmsSelected,
    required this.prevFeelingsSelected,
    required this.updateStartDate,
    required this.updateEndDate,
  }) : super(key: key);

  @override
  State<BloodPressureFilterWidget> createState() =>
      _BloodPressureFilterWidgetState();
}

class _BloodPressureFilterWidgetState extends State<BloodPressureFilterWidget> {
  bool isExpanded = false;

  // 标题
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
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          // 过滤器标题
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            //alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("过滤与筛选",
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: "BalooBhai",
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    Image.asset(
                      "assets/icons/filter.png",
                      height: 18,
                      width: 18,
                    ),
                  ],
                ),

                // 筛选按钮
                GestureDetector(
                  onTap: () {
                    print("筛选按钮");
                    isExpanded = !isExpanded;
                    setState(() {});
                  },
                  child: Container(
                    height: 25,
                    width: 40,
                    padding: const EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 216, 219, 218),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: const Color.fromRGBO(122, 119, 119, 0.43)),
                    ),
                    alignment: Alignment.center,
                    child: const Center(
                      child: Text(
                        "筛选",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0,
                          fontFamily: 'Blinker',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //
          const SizedBox(
            height: 5,
          ),

          //标题与值
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: MediaQuery.of(context).size.width * 0.85,
            height: isExpanded ? 420 : 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 129, 127, 127),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            //alignment: Alignment.center,
            child: isExpanded
                ? SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      // getTitle("起始日期", "START DATE"),
                                      //getTitle("结束日期", "END DATE"),
                                      getTitle("日期", "DATE"),
                                      getTitle("时间", "TIME"),
                                      getTitle("收缩压", "SBP"),
                                      getTitle("舒张压", "DBP"),
                                      getTitle("心率", "PULSE"),
                                      getTitle("手臂", "ARM"),
                                      getTitle("感觉", "FEELINGS"),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 日期
                                      DateFilterWidget(
                                        startDate: widget.filterParam.startDate,
                                        endDate: widget.filterParam.endDate,
                                        updateStartDate: widget.updateStartDate,
                                        updateEndDate: widget.updateEndDate,
                                        updateGraph: widget.updateGraph,
                                      ),

                                      //
                                      const SizedBox(height: 10),

                                      //时间
                                      TimeFilterWidget(
                                        startHourController: widget
                                            .filterParam.startHourController,
                                        startMinuteController: widget
                                            .filterParam.startMinuteController,
                                        endHourController: widget
                                            .filterParam.endHourController,
                                        endMinuteController: widget
                                            .filterParam.endMinuteController,
                                      ),

                                      //
                                      const SizedBox(height: 10),

                                      // 收缩压
                                      SBPFilterWidget(
                                          minSBPController: widget
                                              .filterParam.minSBPController,
                                          maxSBPController: widget
                                              .filterParam.maxSBPController),
                                      //
                                      const SizedBox(height: 10),
                                      //舒张压
                                      DBPFilterWidget(
                                          minDBPController: widget
                                              .filterParam.minDBPController,
                                          maxDBPController: widget
                                              .filterParam.maxDBPController),
                                      const SizedBox(height: 10),
                                      //心率
                                      PulseFilterWidget(
                                        minHeartRateController: widget
                                            .filterParam.minHeartRateController,
                                        maxHeartRateController: widget
                                            .filterParam.maxHeartRateController,
                                      ),
                                      //
                                      const SizedBox(height: 10),

                                      // 手臂
                                      ArmButtonsWidget(
                                          isSelected:
                                              widget.filterParam.armsSelected),
                                      const SizedBox(height: 10),

                                      //感觉
                                      FeelingsButtonsWidget(
                                        newFilterParam: widget.filterParam,
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                ]),
                            OKCancelButtonsWidget(
                              filterParam: widget.filterParam,
                              updateGraph: widget.updateGraph,
                              prevArmsSelected: widget.prevArmsSelected,
                              prevFeelingsSelected: widget.prevFeelingsSelected,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Center(
                    // child: Text("..."),
                    child: Image.asset(
                      "assets/icons/filter.png",
                      height: 25,
                      width: 25,
                    ),
                  ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

// =============================================================================

// 血压数据详情页面
class BloodPressureMoreData extends StatefulWidget {
  const BloodPressureMoreData({super.key});

  @override
  State<BloodPressureMoreData> createState() => _BloodPressureMoreDataState();
}

class _BloodPressureMoreDataState extends State<BloodPressureMoreData> {
  //过滤器参数

  BloodPressureFilterParam filterParam = BloodPressureFilterParam(
    startDate: DateTime.now().subtract(const Duration(days: 7)),
    endDate: DateTime.now(),
    armsSelected: [false, false, false, true],
    feelingsSelected: [false, false, false, true],
    refresh: false,
    minHeartRateController: TextEditingController(),
    maxHeartRateController: TextEditingController(),
    minSBPController: TextEditingController(),
    maxSBPController: TextEditingController(),
    minDBPController: TextEditingController(),
    maxDBPController: TextEditingController(),
    startHourController: TextEditingController(),
    startMinuteController: TextEditingController(),
    endHourController: TextEditingController(),
    endMinuteController: TextEditingController(),
  );

  List<bool> prevArmsSelected = [false, false, false, true];
  List<bool> prevFeelingsSelected = [false, false, false, true];
  bool isOldParam = true;

  void updateGraph() {
    setState(() {});
  }

  void updateStartDate(DateTime newDate) {
    setState(() {
      filterParam.startDate = newDate;
      print('设置新起始日期：${filterParam.startDate}');
    });
  }

  void updateEndDate(DateTime newDate) {
    setState(() {
      filterParam.endDate = newDate;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("血压数据页面rebuild===========================");
    return PopScope(
      //canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "TriGuard",
            style: TextStyle(
                fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
          ),
          flexibleSpace: getHeader(MediaQuery.of(context).size.width,
              (MediaQuery.of(context).size.height * 0.1 + 11)),
        ),
        /* floatingActionButton: FloatingActionButton(
          onPressed: () {
            //Navigator.pop(context);
            print("哈哈");
          },
          child: Image.asset(
            "assets/icons/filter.png",
            width: 25,
            height: 25,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,  */

        body: Container(
          color: Colors.white,
          child: ListView(shrinkWrap: true, children: [
            // 标题组件
            /* UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                alignment: Alignment.centerLeft,
                child: const PageTitle(
                    title: "血压数据表", icons: "assets/icons/bloodPressure.png"),
              ),
            ),
 */

            UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const PageTitle(
                        title: "血压数据表",
                        icons: "assets/icons/bloodPressure.png"),
                    GestureDetector(
                      onTap: () {
                        print("哈哈哈哈");
                      },
                      child: Image.asset(
                        "assets/icons/filter.png",
                        height: 30,
                        width: 30,
                      ),
                    )
                  ],
                ),
              ),
            ),
            // 过滤器
            BloodPressureFilterWidget(
              filterParam: filterParam,
              prevArmsSelected: prevArmsSelected,
              prevFeelingsSelected: prevFeelingsSelected,
              updateGraph: updateGraph,
              updateStartDate: updateStartDate,
              updateEndDate: updateEndDate,
            ),

            // table数据表格
            BloodPressureRecordWidget(
              filterParam: filterParam,
              oldParam: isOldParam,
              updateGraph: updateGraph,
            ),

            UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromARGB(255, 129, 127, 127),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Name',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Age',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Role',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ],
                      rows: const <DataRow>[
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text('Sarah')),
                            DataCell(Text('19')),
                            DataCell(Text('Student')),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text('Janine')),
                            DataCell(Text('43')),
                            DataCell(Text('Professor')),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text('William')),
                            DataCell(Text('27')),
                            DataCell(Text('Associate Professor')),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text('William')),
                            DataCell(Text('27')),
                            DataCell(Text('Associate Professor')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
