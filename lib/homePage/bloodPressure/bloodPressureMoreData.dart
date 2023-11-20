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

class BloodPressureFilterParam {
  DateTime dateStart = DateTime.now().subtract(const Duration(days: 7));
  DateTime dateEnd = DateTime.now();
  int minHeartRate = 0;
  int maxHeartRate = 1000;
  List<bool> armsSelected = [false, false, false, true];
  List<bool> feelingsSelected = [false, false, false, true];
  bool refresh = false;

  BloodPressureFilterParam({
    required this.dateStart,
    required this.dateEnd,
    required this.minHeartRate,
    required this.maxHeartRate,
    required this.armsSelected,
    required this.feelingsSelected,
    required this.refresh,
  });

  void printFilterParams() {
    print(minHeartRate);
    print(maxHeartRate);
    print(armsSelected);
    print(feelingsSelected);
    print(refresh);
  }
}

// 血压表格记录
// ignore: must_be_immutable
class BloodPressureRecordWidget extends StatefulWidget {
  BloodPressureFilterParam filterParam;
  bool oldParam = false;
  BloodPressureRecordWidget(
      {Key? key, required this.filterParam, required this.oldParam})
      : super(key: key);

  @override
  State<BloodPressureRecordWidget> createState() =>
      _BloodPressureRecordWidgetState();
}

class _BloodPressureRecordWidgetState extends State<BloodPressureRecordWidget> {
  @override
  Widget build(BuildContext context) {
    // 原始数据
    if (widget.filterParam.refresh == true && widget.oldParam == true) {
      print("数据表格刷新（完全无设置过滤器）");
      widget.filterParam.printFilterParams();
      widget.oldParam = false;
    } else if (widget.filterParam.refresh == true && widget.oldParam == false) {
      print("数据表格刷新（已经设置过滤器）");
      widget.filterParam.printFilterParams();
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
  List<String> iconsPath = [
    "assets/icons/leftHand.png",
    "assets/icons/rightHand.png",
    "assets/icons/leftHand.png",
    "assets/icons/leftHand.png",
  ];
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
  //final VoidCallback onPressed;
  //final String iconPath;
  //final bool isSelected;
  List<bool> isSelected = [false, false, false, true];
  FeelingsButtonsWidget({
    Key? key,
    //required this.onPressed,
    //required this.iconPath,
    required this.isSelected,
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

// 心率区间
// ignore: must_be_immutable
class PulseFilterWidget extends StatefulWidget {
  int minHeartRate = 0;
  int maxHeartRate = 1000;
  PulseFilterWidget({Key? key}) : super(key: key);

  @override
  State<PulseFilterWidget> createState() => _PulseFilterWidgetState();
}

class _PulseFilterWidgetState extends State<PulseFilterWidget> {
  final TextEditingController minHeartRateController = TextEditingController();
  final TextEditingController maxHeartRateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          height: 40,
          child: TextFormField(
            maxLength: 3,
            controller: minHeartRateController,
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
            controller: maxHeartRateController,
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

// 确定取消按钮
// ignore: must_be_immutable
class OKCancelButtonsWidget extends StatefulWidget {
  BloodPressureFilterParam oldFilterParam;
  BloodPressureFilterParam newFilterParam;

  OKCancelButtonsWidget({
    Key? key,
    required this.oldFilterParam,
    required this.newFilterParam,
  }) : super(key: key);

  @override
  State<OKCancelButtonsWidget> createState() => _OKCancelButtonsWidgetState();
}

class _OKCancelButtonsWidgetState extends State<OKCancelButtonsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 筛选过滤器
// ignore: must_be_immutable
class BloodPressureFilterWidget extends StatefulWidget {
  // 默认展示过去一周的数据（含今天）

  BloodPressureFilterParam oldFilterParam;
  BloodPressureFilterParam newFilterParam;

  BloodPressureFilterWidget({
    Key? key,
    required this.oldFilterParam,
    required this.newFilterParam,
  }) : super(key: key);

  @override
  State<BloodPressureFilterWidget> createState() =>
      _BloodPressureFilterWidgetState();
}

class _BloodPressureFilterWidgetState extends State<BloodPressureFilterWidget> {
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
            alignment: Alignment.centerLeft,
            child: Row(
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
          ),

          //
          const SizedBox(
            height: 5,
          ),

          //标题与值
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 129, 127, 127),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            //alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                      Column(
                        children: [
                          /* Container(
                            width: 50,
                            height: 30,
                            color: Colors.blue,
                          ), */
                          PulseFilterWidget(),
                          const SizedBox(height: 10),
                          ArmButtonsWidget(
                              isSelected: widget.newFilterParam.armsSelected),
                          const SizedBox(height: 10),
                          FeelingsButtonsWidget(
                              isSelected:
                                  widget.newFilterParam.feelingsSelected),
                          const SizedBox(height: 10),
                        ],
                      )
                    ]),
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
  BloodPressureFilterParam oldParam = BloodPressureFilterParam(
    dateStart: DateTime.now().subtract(const Duration(days: 7)),
    dateEnd: DateTime.now(),
    minHeartRate: 0,
    maxHeartRate: 1000,
    armsSelected: [false, false, false, true],
    feelingsSelected: [false, false, false, true],
    refresh: true,
  );

  BloodPressureFilterParam newParam = BloodPressureFilterParam(
    dateStart: DateTime.now().subtract(const Duration(days: 7)),
    dateEnd: DateTime.now(),
    minHeartRate: 0,
    maxHeartRate: 1000,
    armsSelected: [false, false, false, true],
    feelingsSelected: [false, false, false, true],
    refresh: false,
  );

  bool isOldParam = true;
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
        body: Container(
          color: Colors.white,
          child: ListView(shrinkWrap: true, children: [
            // 标题组件
            UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                alignment: Alignment.centerLeft,
                child: const PageTitle(
                    title: "血压数据表", icons: "assets/icons/bloodPressure.png"),
              ),
            ),

            BloodPressureFilterWidget(
              oldFilterParam: oldParam,
              newFilterParam: newParam,
            ),

            BloodPressureRecordWidget(
              filterParam: oldParam,
              oldParam: isOldParam,
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
