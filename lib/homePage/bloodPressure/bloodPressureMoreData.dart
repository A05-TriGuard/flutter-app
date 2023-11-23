import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter/services.dart';
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
typedef UpdateFilterWidgetViewCallBack = void Function(bool showFilterWidget);

List<bool> prevArmsSelected1 = [false, false, false, true];
List<bool> prevFeelingsSelected1 = [false, false, false, true];

class BloodPressureFilterParam {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  DateTime startTime = DateTime(2023, 11, 11, 00, 00);
  DateTime endTime = DateTime(2023, 11, 11, 23, 59);
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
    required this.startTime,
    required this.endTime,
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
        '时间1： ${startHourController.text}:${startMinuteController.text} ~ ${endHourController.text}:${endMinuteController.text}');
    print(
        '时间2： ${startTime.hour}:${startTime.minute} ~ ${endTime.hour}:${endTime.minute}');

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
    // startTime and endTime pad 0

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

  void reset() {
    startDate = DateTime.now().subtract(const Duration(days: 7));
    endDate = DateTime.now();
    startTime = DateTime(2023, 11, 11, 00, 00);
    endTime = DateTime(2023, 11, 11, 23, 59);
    startHourController.text = "00";
    startMinuteController.text = "00";
    endHourController.text = "23";
    endMinuteController.text = "59";
    minSBPController.text = "70";
    maxSBPController.text = "140";
    minDBPController.text = "70";
    maxDBPController.text = "140";
    minHeartRateController.text = "70";
    maxHeartRateController.text = "150";
    armsSelected = [false, false, false, true];
    feelingsSelected = [false, false, false, true];
    remarksSelected = [false, false, true];
    refresh = false;
  }

  int checkInvalidParam() {
    DateTime time1 =
        DateTime(startDate.year, startDate.month, startDate.day, 00, 00);
    DateTime time2 = DateTime(endDate.year, endDate.month, endDate.day, 23, 59);

    if (time1.isAfter(time2)) {
      print("invalid date");
      return 1;
    }

    if (startTime.isAfter(endTime)) {
      print("invalid time");
      return 2;
    }

    if (int.parse(minSBPController.text) > int.parse(maxSBPController.text)) {
      print("invalid sbp");
      return 3;
    }

    if (int.parse(minDBPController.text) > int.parse(maxDBPController.text)) {
      print("invalid dbp");
      return 4;
    }

    if (int.parse(minHeartRateController.text) >
        int.parse(maxHeartRateController.text)) {
      print("invalid pulse");
      return 5;
    }

    return 0;
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
      DateTime dateTime = DateTime(date.year, date.month, date.day, 12, 00);
      DateTime time1 = DateTime(
          widget.filterParam.startDate.year,
          widget.filterParam.startDate.month,
          widget.filterParam.startDate.day,
          00,
          00);
      DateTime time2 = DateTime(
          widget.filterParam.endDate.year,
          widget.filterParam.endDate.month,
          widget.filterParam.endDate.day,
          23,
          59);

      if (!(dateTime.isAfter(time1) && dateTime.isBefore(time2))) {
        continue;
      }

      int hour = int.parse(bpAllData[i]["time"].toString().split(":")[0]);
      int minute = int.parse(bpAllData[i]["time"].toString().split(":")[1]);
      time1 = DateTime(2023, 06, 11, widget.filterParam.startTime.hour,
          widget.filterParam.startTime.minute, 00);
      time2 = DateTime(2023, 06, 11, widget.filterParam.endTime.hour,
          widget.filterParam.endTime.minute, 59);
      DateTime time = DateTime(2023, 06, 11, hour, minute, 30);
      if (!(time.isAfter(time1) && time.isBefore(time2))) {
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
    // 判断参数是否合法

    widget.filterParam.tackle();

    if (widget.filterParam.checkInvalidParam() > 0) {
      print("invalid param");
    }

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
            height: filteredData.length < 9
                ? ((filteredData.length + 1) * 50) + 50
                : (50 * 9) + 50,
            /* decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(255, 129, 127, 127),
            ),
            borderRadius: BorderRadius.circular(15),
          ), */
            alignment: Alignment.center,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
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

                // 数据表的表
                UnconstrainedBox(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: filteredData.length < 9
                        ? (filteredData.length + 1) * 50
                        : 50 * 9,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 196, 195, 195),
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
                        //color: Color.fromARGB(255, 129, 127, 127),
                        color: Color.fromARGB(255, 196, 195, 195),
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
            if (totalSelected == 0) {
              widget.isSelected[3] = true;
            } else if (totalSelected == 3) {
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
      alignment: Alignment.center,
      height: 41,
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
            if (totalSelected == 0) {
              widget.newFilterParam.feelingsSelected[3] = true;
            } else if (totalSelected == 3) {
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
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              color: widget.newFilterParam.feelingsSelected[index] == true
                  ? const Color.fromRGBO(253, 134, 255, 0.66)
                  : const Color.fromRGBO(218, 218, 218, 0.66),
              borderRadius: BorderRadius.circular(10.0),
              border:
                  Border.all(color: const Color.fromRGBO(122, 119, 119, 0.43)),
            ),
            alignment: Alignment.center,
            child: Center(
              child: Text(
                buttonText[index],
                style: TextStyle(
                  color: widget.newFilterParam.feelingsSelected[index] == true
                      ? const Color.fromRGBO(66, 9, 119, 0.773)
                      : const Color.fromRGBO(94, 68, 68, 100),
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
      alignment: Alignment.center,
      height: 41,
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
    return Container(
      alignment: Alignment.center,
      height: 41,
      child: Row(
        children: [
          SizedBox(
            width: 75,
            height: 40,
            child: TextFormField(
              maxLength: 3,
              controller: widget.minHeartRateController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
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
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
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
      ),
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
    return Container(
      alignment: Alignment.center,
      height: 41,
      child: Row(
        children: [
          SizedBox(
            width: 75,
            height: 40,
            child: TextFormField(
              maxLength: 3,
              controller: widget.minSBPController,
              //initialValue: widget.heartRate,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
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
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
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
      ),
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
    return Container(
      alignment: Alignment.center,
      height: 41,
      child: Row(
        children: [
          SizedBox(
            width: 75,
            height: 40,
            child: TextFormField(
              maxLength: 3,
              controller: widget.minDBPController,
              //initialValue: widget.heartRate,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
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
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
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
      ),
    );
  }
}

// 时间选择
// ignore: must_be_immutable
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

// ignore: must_be_immutable
class TimeFilterWidget2 extends StatefulWidget {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  final UpdateDateCallback updateStartTime;
  final UpdateDateCallback updateEndTime;

  TimeFilterWidget2(
      {Key? key,
      required this.startTime,
      required this.endTime,
      required this.updateStartTime,
      required this.updateEndTime})
      : super(key: key);

  @override
  State<TimeFilterWidget2> createState() => _TimeFilterWidget2State();
}

class _TimeFilterWidget2State extends State<TimeFilterWidget2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 41,
      child: Row(
        children: [
          TimePicker(
              time: widget.startTime, updateTime: widget.updateStartTime),
          const SizedBox(width: 5),
          const Text(
            "至",
            style: const TextStyle(fontSize: 16, fontFamily: "BaloonBhai"),
          ),
          const SizedBox(width: 5),
          TimePicker(time: widget.endTime, updateTime: widget.updateEndTime),
        ],
      ),
    );
  }
}

// 日期选择
// ignore: must_be_immutable
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
    return Container(
      alignment: Alignment.center,
      height: 41,
      child: Row(
        children: [
          DatePicker2(
              date: widget.startDate, updateDate: widget.updateStartDate),
          const SizedBox(width: 5),
          const Text(
            "至",
            style: TextStyle(fontSize: 16, fontFamily: "BaloonBhai"),
          ),
          const SizedBox(width: 5),
          const SizedBox(width: 10),
          DatePicker2(date: widget.endDate, updateDate: widget.updateEndDate),
        ],
      ),
    );
    /* return Container(
      alignment: Alignment.center,
      height: 41,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DatePicker2(
              date: widget.startDate, updateDate: widget.updateStartDate),
          // const SizedBox(width: 10),
          //const SizedBox(width: 10),
          DatePicker2(date: widget.endDate, updateDate: widget.updateEndDate),
        ],
      ),
    ); */
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
            if (totalSelected == 0) {
              widget.isSelected[2] = true;
            } else if (totalSelected == 2) {
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
            width: 68,
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
      alignment: Alignment.center,
      height: 41,
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
  final UpdateFilterWidgetViewCallBack updateFilterWidgetView;

  OKCancelButtonsWidget({
    Key? key,
    required this.filterParam,
    required this.updateGraph,
    required this.prevArmsSelected,
    required this.prevFeelingsSelected,
    required this.updateFilterWidgetView,
  }) : super(key: key);

  @override
  State<OKCancelButtonsWidget> createState() => _OKCancelButtonsWidgetState();
}

class _OKCancelButtonsWidgetState extends State<OKCancelButtonsWidget> {
  List<bool> _localPrevArmsSelected = [false, false, false, true];
  List<bool> _localPrevFeelingsSelected = [false, false, false, true];
  List<String> invalidParamType = [
    "",
    "日期设置有误",
    "时间设置有误",
    "收缩压设置有误",
    "舒张压设置有误",
    "心率设置有误"
  ];
  int invalidParam = 0;

  @override
  void initState() {
    super.initState();
    // resetLocalPrevSelected();
    _localPrevArmsSelected = [false, false, false, true];
    _localPrevFeelingsSelected = [false, false, false, true];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          alignment: Alignment.center,
          //child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 重置按钮
              GestureDetector(
                onTap: () {
                  print("重置");
                  widget.filterParam.reset();
                  invalidParam = 0;

                  widget.updateGraph();
                },
                child: Container(
                  height: 30,
                  width: 50,
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 209, 212, 212),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: const Color.fromRGBO(122, 119, 119, 0.43)),
                  ),
                  alignment: Alignment.center,
                  child: const Center(
                    child: Text(
                      "重置",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
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

              // 确定按钮
              GestureDetector(
                onTap: () {
                  print("确定");
                  // 进行数据表的刷新
                  widget.filterParam.refresh = true;

                  invalidParam = widget.filterParam.checkInvalidParam();
                  print("invalidParam: $invalidParam");
                  //widget.updateGraph();

                  if (invalidParam == 0) {
                    widget.updateFilterWidgetView(false);
                  } else {
                    setState(() {});
                  }
                },
                child: Container(
                  height: 30,
                  width: 50,
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: const Color.fromRGBO(122, 119, 119, 0.43)),
                  ),
                  alignment: Alignment.center,
                  child: const Center(
                    child: Text(
                      "确定",
                      style: TextStyle(
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
          //),
        ),

        // 警告信息
        Text(
          invalidParamType[invalidParam],
          style: const TextStyle(
            color: Colors.red,
            fontSize: 12.0,
            fontFamily: 'Blinker',
          ),
          //textAlign: TextAlign.center,
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
  final UpdateDateCallback updateStartTime;
  final UpdateDateCallback updateEndTime;
  final UpdateFilterWidgetViewCallBack updateFilterWidgetView;

  BloodPressureFilterWidget({
    Key? key,
    required this.filterParam,
    required this.updateGraph,
    required this.prevArmsSelected,
    required this.prevFeelingsSelected,
    required this.updateStartDate,
    required this.updateEndDate,
    required this.updateStartTime,
    required this.updateEndTime,
    required this.updateFilterWidgetView,
  }) : super(key: key);

  @override
  State<BloodPressureFilterWidget> createState() =>
      _BloodPressureFilterWidgetState();
}

class _BloodPressureFilterWidgetState extends State<BloodPressureFilterWidget> {
  bool isExpanded = true;

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
                /* GestureDetector(
                  onTap: () {
                    print("展开/收起");
                    //isExpanded = !isExpanded;
                    //setState(() {});
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
                ), */
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
            height: isExpanded ? 440 : 50,
            decoration: BoxDecoration(
              border: Border.all(
                //color: const Color.fromARGB(255, 129, 127, 127),
                color: Color.fromARGB(255, 196, 195, 195),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                      /* TimeFilterWidget(
                                        startHourController: widget
                                            .filterParam.startHourController,
                                        startMinuteController: widget
                                            .filterParam.startMinuteController,
                                        endHourController: widget
                                            .filterParam.endHourController,
                                        endMinuteController: widget
                                            .filterParam.endMinuteController,
                                      ), */
                                      TimeFilterWidget2(
                                          startTime:
                                              widget.filterParam.startTime,
                                          endTime: widget.filterParam.endTime,
                                          updateStartTime:
                                              widget.updateStartTime,
                                          updateEndTime: widget.updateEndTime),

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
                            /* OKCancelButtonsWidget(
                              filterParam: widget.filterParam,
                              updateGraph: widget.updateGraph,
                              prevArmsSelected: widget.prevArmsSelected,
                              prevFeelingsSelected: widget.prevFeelingsSelected,
                              updateFilterWidgetView:
                                  widget.updateFilterWidgetView,
                            ), */
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

          //
          const SizedBox(
            height: 10,
          ),

          // 重置与确定按钮
          OKCancelButtonsWidget(
            filterParam: widget.filterParam,
            updateGraph: widget.updateGraph,
            prevArmsSelected: widget.prevArmsSelected,
            prevFeelingsSelected: widget.prevFeelingsSelected,
            updateFilterWidgetView: widget.updateFilterWidgetView,
          ),
        ],
      ),
    );
  }
}

class ExportExcelWiget extends StatefulWidget {
  const ExportExcelWiget({super.key});

  @override
  State<ExportExcelWiget> createState() => _ExportExcelWigetState();
}

class _ExportExcelWigetState extends State<ExportExcelWiget> {
  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        //alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                print("导出excel");
              },
              child: Container(
                  height: 40,
                  width: 150,
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 148, 252, 148),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: const Color.fromRGBO(122, 119, 119, 0.43)),
                  ),
                  //alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "导出Excel文件",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontFamily: 'Blinker',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Image.asset(
                        "assets/icons/excel.png",
                        height: 25,
                        width: 25,
                      ),
                    ],
                  )),
            ),
          ],
        ),
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
    startTime: DateTime(2023, 11, 11, 00, 00),
    endTime: DateTime(2023, 11, 11, 23, 59),
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
  bool showFilterWidget = false;
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

  void updateStartTime(DateTime newTime) {
    setState(() {
      filterParam.startTime = newTime;
    });
  }

  void updateEndTime(DateTime newTime) {
    setState(() {
      filterParam.endTime = newTime;
    });
  }

  void updateFilterWidgetView(bool show) {
    setState(() {
      showFilterWidget = show;
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
        body: Container(
          color: Colors.white,
          child: ListView(shrinkWrap: true, children: [
            // 标题组件
            UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const PageTitle(
                        title: "血压详细数据",
                        icons: "assets/icons/bloodPressure.png"),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          //print("哈哈哈哈");

                          if (showFilterWidget == false) {
                            print("展开");
                          } else {
                            print("隐藏");
                          }
                          showFilterWidget = !showFilterWidget;
                          setState(() {});
                        },
                        child: Image.asset(
                          "assets/icons/filter.png",
                          height: 25,
                          width: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 过滤器
            showFilterWidget == true
                ? BloodPressureFilterWidget(
                    filterParam: filterParam,
                    prevArmsSelected: prevArmsSelected,
                    prevFeelingsSelected: prevFeelingsSelected,
                    updateGraph: updateGraph,
                    updateStartDate: updateStartDate,
                    updateEndDate: updateEndDate,
                    updateStartTime: updateStartTime,
                    updateEndTime: updateEndTime,
                    updateFilterWidgetView: updateFilterWidgetView,
                  )
                : Container(),

            // table数据表格
            BloodPressureRecordWidget(
              filterParam: filterParam,
              oldParam: isOldParam,
              updateGraph: updateGraph,
            ),

            ExportExcelWiget(),
          ]),
        ),
      ),
    );
  }
}
