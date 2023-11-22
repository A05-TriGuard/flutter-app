import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import '../../component/header/header.dart';
import '../../component/titleDate/titleDate.dart';
import '../../other/gradientBorder/gradient_borders.dart';
import './bpData.dart';
import './bpAllData.dart';

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
  List<bool> remarksSelected = [false, false, true];
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
    required this.remarksSelected,
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
    print('备注：${remarksSelected}');
    print('刷新：${refresh}');
    print("====================");
  }

  void tackle() {
    if (startHourController.text == "") {
      startHourController.text = "00";
    }

    if (endHourController.text == "") {
      endHourController.text = "23";
    }

    if (startMinuteController.text == "") {
      startMinuteController.text = "00";
    }

    if (endMinuteController.text == "") {
      endMinuteController.text = "59";
    }

    if (minSBPController.text == "") {
      minSBPController.text = "70";
    }

    if (maxSBPController.text == "") {
      maxSBPController.text = "140";
    }
    if (minDBPController.text == "") {
      minDBPController.text = "70";
    }

    if (maxDBPController.text == "") {
      maxDBPController.text = "140";
    }

    if (minHeartRateController.text == "") {
      minHeartRateController.text = "70";
    }

    if (maxHeartRateController.text == "") {
      maxHeartRateController.text = "150";
    }
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
  List<Map<dynamic, dynamic>> filteredData = [];
  // [最小值，最大值，平均值，偏低次数，正常次数，偏高次数，异常次数，总次数]
  /* 收缩压sbp（高压）：
    偏低： 少于90 mmHg
    正常： 90-120 mmHg
    偏高： 121-139 mmHg
    异常（高血压）： 140 mmHg及以上

    舒张压dbp（低压）：
    偏低： 少于60 mmHg
    正常： 60-80 mmHg
    偏高： 81-89 mmHg
    异常（高血压）： 90 mmHg及以上
    心率：

    偏低pulse（脉搏过缓）： 少于60 次/分钟
    正常： 60-100 次/分钟
    偏高（脉搏过快）： 101-120 次/分钟
    异常： 120 次/分钟及以上
 */
  List<int> sbpList = [1000, 0, 0, 0, 0, 0, 0, 0]; //
  List<int> dbpList = [1000, 0, 0, 0, 0, 0, 0, 0];
  List<int> heartRateList = [1000, 0, 0, 0, 0, 0, 0, 0];

  void getFilteredData() {
    filteredData = [];
    for (int i = 0; i < bpAllData.length; i++) {
      DateTime date = DateTime.parse(bpAllData[i]["date"]);
      DateTime dateTime = DateTime(date.year, date.month, date.day);
      if (!(dateTime.isAfter(widget.filterParam.startDate) &&
          dateTime.isBefore(widget.filterParam.endDate))) {
        continue;
      }

      int hour = int.parse(bpAllData[i]["time"].toString().split(":")[0]);
      int minute = int.parse(bpAllData[i]["time"].toString().split(":")[1]);
      //print(
      //    "${bpAllData[i]["time"].toString().split(":")[0]} ::: ${bpAllData[i]["time"].toString().split(":")[1]}");
      DateTime time = DateTime(2023, 06, 11, hour, minute);
      if (!(time.isAfter(DateTime(
            2023,
            06,
            11,
            int.parse(widget.filterParam.startHourController.text),
            int.parse(widget.filterParam.startMinuteController.text),
          )) &&
          time.isBefore(DateTime(
            2023,
            06,
            11,
            int.parse(widget.filterParam.endHourController.text),
            int.parse(widget.filterParam.endMinuteController.text),
          )))) {
        continue;
      }

      if (bpAllData[i]["sbp"] <
              int.parse(widget.filterParam.minSBPController.text) ||
          bpAllData[i]["sbp"] >
              int.parse(widget.filterParam.maxSBPController.text)) {
        continue;
      }

      if (bpAllData[i]["dbp"] <
              int.parse(widget.filterParam.minDBPController.text) ||
          bpAllData[i]["dbp"] >
              int.parse(widget.filterParam.maxDBPController.text)) {
        continue;
      }

      if (bpAllData[i]["heartRate"] <
              int.parse(widget.filterParam.minHeartRateController.text) ||
          bpAllData[i]["heartRate"] >
              int.parse(widget.filterParam.maxHeartRateController.text)) {
        continue;
      }

      if (widget.filterParam.armsSelected[3] == false) {
        int count = 0;
        if (widget.filterParam.armsSelected[0] == true &&
            bpAllData[i]["arm"] == 0) {
          count++;
        }
        if (widget.filterParam.armsSelected[1] == true &&
            bpAllData[i]["arm"] == 1) {
          count++;
        }
        if (widget.filterParam.armsSelected[2] == true &&
            bpAllData[i]["arm"] == 2) {
          count++;
        }

        if (count == 0) {
          continue;
        }
      }

      if (widget.filterParam.feelingsSelected[3] == false) {
        int count = 0;
        if (widget.filterParam.feelingsSelected[0] == true &&
            bpAllData[i]["feeling"] == 0) {
          count++;
        }
        if (widget.filterParam.feelingsSelected[1] == true &&
            bpAllData[i]["feeling"] == 1) {
          count++;
        }
        if (widget.filterParam.feelingsSelected[2] == true &&
            bpAllData[i]["feeling"] == 2) {
          count++;
        }

        if (count == 0) {
          continue;
        }
      }

      if (widget.filterParam.remarksSelected[2] == false) {
        int count = 0;
        if (widget.filterParam.remarksSelected[0] == true &&
            bpAllData[i]["remark"] == "") {
          count++;
        }
        if (widget.filterParam.remarksSelected[1] == true &&
            bpAllData[i]["remark"] != "") {
          count++;
        }

        if (count == 0) {
          continue;
        }
      }

      filteredData.add(bpAllData[i]);
    }

    /* print("***************************");
    //print(filteredData);
    print(filteredData.length);
    print("***************************"); */
  }

  List<DataColumn> getDataColumns() {
    //using the filteredData to generate the table
    List<DataColumn> dataColumn = [];
    List<String> columnNames = [
      "日期",
      "时间",
      "收缩压",
      "舒张压",
      "心率",
      "手臂",
      "感觉",
      "备注"
    ];

    for (int i = 0; i < columnNames.length; i++) {
      dataColumn.add(DataColumn(
        label: Expanded(
          child: i == (columnNames.length - 1)
              ? Text(
                  columnNames[i],
                  style: const TextStyle(
                      fontFamily: "BalooBhai",
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                )
              : Center(
                  child: Text(
                    columnNames[i],
                    style: const TextStyle(
                        fontFamily: "BalooBhai",
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      ));
    }

    return dataColumn;
  }

  List<DataRow> getDataRows() {
    List<String> armsText = ["左手", "右手", "不选"];
    List<String> feelingsText = ["较好", "还好", "较差"];

    List<DataRow> dataRow = [];
    for (int i = 0; i < filteredData.length; i++) {
      dataRow.add(DataRow(
        cells: <DataCell>[
          DataCell(Center(
            child: Text(filteredData[i]["date"]),
          )),
          DataCell(Center(
            child: Text(filteredData[i]["time"]),
          )),
          DataCell(Center(
            child: Text(filteredData[i]["sbp"].toString()),
          )),
          DataCell(Center(
            child: Text(filteredData[i]["dbp"].toString()),
          )),
          DataCell(Center(
            child: Text(filteredData[i]["heartRate"].toString()),
          )),
          DataCell(Center(
            child: Text(armsText[filteredData[i]["arm"]]),
          )),
          DataCell(
              Center(child: Text(feelingsText[filteredData[i]["feeling"]]))),
          DataCell(
            Text(filteredData[i]["remark"].toString()),
          ),
        ],
      ));
    }

    return dataRow;
  }

  void getFilteredStatisticsData() {
    //总和
    int sbp = 0;
    int dbp = 0;
    int pulse = 0;
    sbpList = [1000, 0, 0, 0, 0, 0, 0, 0];
    dbpList = [1000, 0, 0, 0, 0, 0, 0, 0];
    heartRateList = [1000, 0, 0, 0, 0, 0, 0, 0];

    for (int i = 0; i < filteredData.length; i++) {
      // 累加
      int temp1 = filteredData[i]["sbp"];
      int temp2 = filteredData[i]["dbp"];
      int temp3 = filteredData[i]["heartRate"];
      sbp += temp1;
      dbp += temp2;
      pulse += temp3;

      //最小值，最大值
      if (filteredData[i]["sbp"] < sbpList[0]) {
        sbpList[0] = filteredData[i]["sbp"];
      }
      if (filteredData[i]["sbp"] > sbpList[1]) {
        sbpList[1] = filteredData[i]["sbp"];
      }

      if (filteredData[i]["dbp"] < dbpList[0]) {
        dbpList[0] = filteredData[i]["dbp"];
      }
      if (filteredData[i]["dbp"] > dbpList[1]) {
        dbpList[1] = filteredData[i]["dbp"];
      }

      if (filteredData[i]["heartRate"] < heartRateList[0]) {
        heartRateList[0] = filteredData[i]["heartRate"];
      }

      if (filteredData[i]["heartRate"] > heartRateList[1]) {
        heartRateList[1] = filteredData[i]["heartRate"];
      }

      //范围
      if (filteredData[i]["sbp"] < 90) {
        sbpList[3]++;
      } else if (filteredData[i]["sbp"] >= 90 &&
          filteredData[i]["sbp"] <= 120) {
        sbpList[4]++;
      } else if (filteredData[i]["sbp"] >= 121 &&
          filteredData[i]["sbp"] <= 139) {
        sbpList[5]++;
      } else if (filteredData[i]["sbp"] >= 140) {
        sbpList[6]++;
      }

      if (filteredData[i]["dbp"] < 60) {
        dbpList[3]++;
      } else if (filteredData[i]["dbp"] >= 60 && filteredData[i]["dbp"] <= 80) {
        dbpList[4]++;
      } else if (filteredData[i]["dbp"] >= 81 && filteredData[i]["dbp"] <= 89) {
        dbpList[5]++;
      } else if (filteredData[i]["dbp"] >= 90) {
        dbpList[6]++;
      }

      if (filteredData[i]["heartRate"] < 60) {
        heartRateList[3]++;
      } else if (filteredData[i]["heartRate"] >= 60 &&
          filteredData[i]["heartRate"] <= 100) {
        heartRateList[4]++;
      } else if (filteredData[i]["heartRate"] >= 101 &&
          filteredData[i]["heartRate"] <= 120) {
        heartRateList[5]++;
      } else if (filteredData[i]["heartRate"] >= 121) {
        heartRateList[6]++;
      }

      sbpList[7]++;
      dbpList[7]++;
      heartRateList[7]++;
    }

    //平均值
    if (filteredData.length > 0) {
      sbpList[2] = sbp ~/ filteredData.length;
      dbpList[2] = dbp ~/ filteredData.length;
      heartRateList[2] = pulse ~/ filteredData.length;
    }
  }

  List<DataColumn> getStatisticsDataColumns() {
    List<DataColumn> dataColumn = [];
    List<String> columnNames = [
      "血压/心率",
      "最低值",
      "最高值",
      "平均值",
      "偏低次数",
      "正常次数",
      "偏高次数",
      "异常次数",
      "总次数",
    ];

    for (int i = 0; i < columnNames.length; i++) {
      dataColumn.add(DataColumn(
        label: Expanded(
          child: Center(
            child: Text(
              columnNames[i],
              style: const TextStyle(
                  fontFamily: "BalooBhai",
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ));
    }

    return dataColumn;
  }

  List<DataRow> getStatisticsDataRows() {
    List<DataRow> dataRow = [];
    List<String> names = ["收缩压", "舒张压", "心率"];
    List<List<int>> data = [sbpList, dbpList, heartRateList];

    for (int i = 0; i < names.length; i++) {
      dataRow.add(DataRow(
        cells: <DataCell>[
          DataCell(Center(
            child: Text(names[i]),
          )),
          DataCell(Center(
            child: Text(data[i][0].toString()),
          )),
          DataCell(Center(
            child: Text(data[i][1].toString()),
          )),
          DataCell(Center(
            child: Text(data[i][2].toString()),
          )),
          DataCell(Center(
            child: Text(data[i][3].toString()),
          )),
          DataCell(Center(
            child: Text(data[i][4].toString()),
          )),
          DataCell(Center(
            child: Text(data[i][5].toString()),
          )),
          DataCell(Center(
            child: Text(data[i][6].toString()),
          )),
          DataCell(Center(
            child: Text(data[i][7].toString()),
          )),
        ],
      ));
    }

    return dataRow;
  }

  @override
  Widget build(BuildContext context) {
    widget.filterParam.tackle();
    // 原始数据记录
    if (widget.filterParam.refresh == true) {
      print("数据表格刷新");
      getFilteredData();
      getFilteredStatisticsData();
      widget.filterParam.printFilterParams();
      widget.filterParam.refresh = false;
    } else {
      print("数据表格 (不) 刷新");
      widget.filterParam.printFilterParams();
      widget.filterParam.refresh = false;
      //return Container();
    }

    return Column(
      children: [
        UnconstrainedBox(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: filteredData.length < 6
                ? ((filteredData.length + 1) * 50) + 50
                : (50 * 6) + 50,
            /* decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(255, 129, 127, 127),
            ),
            borderRadius: BorderRadius.circular(15),
          ), */
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("数据表",
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: "BalooBhai",
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    Image.asset(
                      "assets/icons/statistics.png",
                      height: 18,
                      width: 18,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                UnconstrainedBox(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: filteredData.length < 6
                        ? (filteredData.length + 1) * 50
                        : 50 * 6,
                    //height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 129, 127, 127),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: getDataColumns(),
                          rows: getDataRows(),
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) =>
                                  const Color.fromRGBO(255, 151, 245, 0.28)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        ///const SizedBox(height: 5),

        // 统计部分
        UnconstrainedBox(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 250,
            /* decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(255, 129, 127, 127),
            ),
            borderRadius: BorderRadius.circular(15),
          ), */
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("统计表",
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: "BalooBhai",
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    Image.asset(
                      "assets/icons/statistics.png",
                      height: 18,
                      width: 18,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                UnconstrainedBox(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 200,
                    //height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 129, 127, 127),
                      ),
                      borderRadius: BorderRadius.circular(5),
                      /* boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 0.2,
                          blurRadius: 0.2,
                          offset: const Offset(0, 0.5),
                        ),
                      ], */
                    ),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: getStatisticsDataColumns(),
                          rows: getStatisticsDataRows(),
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) =>
                                  const Color.fromRGBO(34, 14, 244, 0.16)),
                        ),
                        /* child: Container(
                      color: const Color.fromARGB(255, 64, 255, 198),
                    ), */
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

// 手臂选择按钮
// ignore: must_be_immutable
class RemarksButtonsWidget extends StatefulWidget {
  //final VoidCallback onPressed;
  //final String iconPath;
  //final bool isSelected;
  List<bool> isSelected = [false, false, true];
  RemarksButtonsWidget({
    Key? key,
    //required this.onPressed,
    //required this.iconPath,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<RemarksButtonsWidget> createState() => _RemarksButtonsWidgetState();
}

class _RemarksButtonsWidgetState extends State<RemarksButtonsWidget> {
  List<String> buttonText = ["无备注", "有备注", "-"];

  Widget getButton(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == 2) {
            for (int i = 0; i < widget.isSelected.length; i++) {
              widget.isSelected[i] = false;
            }
            widget.isSelected[index] = true;
          } else {
            widget.isSelected[2] = false;
            widget.isSelected[index] = !widget.isSelected[index];
            int totalSelected = 0;
            for (int i = 0; i < 2; i++) {
              widget.isSelected[i] ? totalSelected++ : null;
            }
            if (totalSelected == 2) {
              for (int i = 0; i < 2; i++) {
                widget.isSelected[i] = false;
              }
              widget.isSelected[2] = true;
            }
          }
        });
      },
      child: Container(
        child: Row(children: [
          Container(
            height: 40,
            width: 65,
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
            widget.filterParam.remarksSelected = [false, false, true];

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
                    print("展开/收起");
                    isExpanded = !isExpanded;
                    setState(() {});
                  },
                  child: Container(
                    height: 25,
                    width: 40,
                    padding: const EdgeInsets.all(0.0),
                    /* decoration: BoxDecoration(
                      color: Color.fromARGB(255, 216, 219, 218),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: const Color.fromRGBO(122, 119, 119, 0.43),
                      ),
                    ), */
                    alignment: Alignment.center,
                    child: Center(
                      child: Text(
                        isExpanded ? "收起" : "展开",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
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
            //height: isExpanded ? 420 : 50,
            height: isExpanded ? 480 : 50,
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
                                      getTitle("备注", "REMARKS"),
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

                                      //备注
                                      RemarksButtonsWidget(
                                        isSelected:
                                            widget.filterParam.remarksSelected,
                                      ),
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
                      "assets/icons/filter1.png",
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
    refresh: true,
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
    remarksSelected: [false, false, true],
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
                    /* GestureDetector(
                      onTap: () {
                        print("哈哈哈哈");
                      },
                      child: Image.asset(
                        "assets/icons/filter.png",
                        height: 30,
                        width: 30,
                      ),
                    ) */
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
          ]),
        ),
      ),
    );
  }
}
