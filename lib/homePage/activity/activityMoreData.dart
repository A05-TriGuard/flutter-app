import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as ExcelPackage;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:syncfusion_flutter_xlsio/xlsio.dart'
//    hide Column, Row, Border, Stack;
import 'package:dio/dio.dart';
import 'package:triguard/account/token.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../component/header/header.dart';
import '../../component/titleDate/titleDate.dart';
import '../../other/other.dart';

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

class BloodPressureFilterParam {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  DateTime startTime = DateTime(2023, 11, 11, 00, 00);
  DateTime endTime = DateTime(2023, 11, 11, 23, 59);
  List<bool> feelingsSelected = [false, false, false, true];
  List<bool> remarksSelected = [false, false, true];
  bool refresh = false;
  TextEditingController maxDurationController = TextEditingController();
  TextEditingController minDurationController = TextEditingController();

  BloodPressureFilterParam({
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.maxDurationController,
    required this.minDurationController,
    required this.feelingsSelected,
    required this.remarksSelected,
    required this.refresh,
  });

  void tackle() {
    // startTime and endTime pad 0

    if (minDurationController.text == "") {
      minDurationController.text = "0";
    }

    if (maxDurationController.text == "") {
      maxDurationController.text = "180";
    }
  }

  void reset() {
    startDate = DateTime.now().subtract(const Duration(days: 7));
    endDate = DateTime.now();
    startTime = DateTime(2023, 11, 11, 00, 00);
    endTime = DateTime(2023, 11, 11, 23, 59);
    maxDurationController.text = "180";
    minDurationController.text = "0";

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

    if (int.parse(minDurationController.text) >
        int.parse(maxDurationController.text)) {
      print("invalid duration");
      return 3;
    }

    return 0;
  }
}

// 血压表格记录
// ignore: must_be_immutable
class BloodPressureRecordWidget extends StatefulWidget {
  final int accountId;
  BloodPressureFilterParam filterParam;
  bool oldParam = false;
  final VoidCallback updateGraph;
  BloodPressureRecordWidget(
      {Key? key,
      required this.accountId,
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

  List<int> sbpList = [0, 0, 0, 0, 0, 0, 0, 0]; //
  List<int> dbpList = [0, 0, 0, 0, 0, 0, 0, 0];
  List<int> heartRateList = [0, 0, 0, 0, 0, 0, 0, 0];
  List<dynamic> recordData = [];
  List<dynamic> recordStepData = [];
  List<dynamic> statisticData = [];

  // 更新excel表格
  Future<void> createExportFile() async {
    var status = await Permission.storage.status.isGranted;
    var status1 = await Permission.storage.request().isGranted;
    var status2 = await Permission.manageExternalStorage.status.isGranted;
    var status3 = await Permission.manageExternalStorage.request().isGranted;

    if (!status) {
      await Permission.storage.request();
    }

    // if (!await Permission.storage.request().isGranted) {
    if (!status1) {
      await Permission.manageExternalStorage.status;
    }

    if (!status2) {
      await Permission.manageExternalStorage.request();
    }

    // if (!await Permission.manageExternalStorage.request().isGranted) {
    if (!status3) {
      await Permission.manageExternalStorage.status;
    }

    // 获取文件夹路径
    var dir = await getApplicationSupportDirectory();
    var folderPath = Directory("${dir.path}/sportsActivity");

    print("folderPath: ${folderPath.path}");

    // 判断文件夹是否存在，不存在则创建
    if (await folderPath.exists() == false) {
      folderPath.create();
    }

    // 获取文件路径
    var fileNamePath = "${folderPath.path}/sportsActivity.xlsx";

    //创建文件
    var excel = ExcelPackage.Excel.createExcel();

    // **********************运动数据记录************************

    // 2. 添加工作表
    var sheet1 = excel['运动数据记录'];

    // 3. 添加数据
    List<String> columnNames = ["开始时间", "结束时间", "运动时长", "类型", "感觉", "备注"];

    // bold
    ExcelPackage.CellStyle headerCellStyle = ExcelPackage.CellStyle(
      bold: true,
      textWrapping: ExcelPackage.TextWrapping.WrapText,
      fontFamily:
          ExcelPackage.getFontFamily(ExcelPackage.FontFamily.Comic_Sans_MS),
      rotation: 0,
      bottomBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      topBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      leftBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      rightBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
    );

    sheet1.appendRow(columnNames);

    for (int i = 0; i < columnNames.length; i++) {
      var cell = sheet1.cell(
          ExcelPackage.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerCellStyle;
    }

    List<String> feelingsText = ["开心", "还好", "不好"];

    for (int i = 0; i < recordData.length; i++) {
      List<String> dataCell = [];
      dataCell.add(recordData[i]["startTime"]);
      dataCell.add(recordData[i]["endTime"]);
      dataCell.add(recordData[i]["duration"].toString());
      dataCell.add(items[recordData[i]["type"]]);
      dataCell.add(feelingsText[recordData[i]["feelings"]]);
      dataCell.add((recordData[i]["remark"].toString()) == "null"
          ? "暂无备注"
          : recordData[i]["remark"].toString());

      sheet1.appendRow(dataCell);
    }

    //sheet1.setColumnWidth(0, 15);

    ExcelPackage.CellStyle dataCellStyle = ExcelPackage.CellStyle(
      textWrapping: ExcelPackage.TextWrapping.WrapText,
      rotation: 0,
      bottomBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      topBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      leftBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      rightBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
    );

    for (int i = 1; i <= recordData.length; i++) {
      for (int j = 0; j < columnNames.length; j++) {
        var cell = sheet1.cell(ExcelPackage.CellIndex.indexByColumnRow(
            columnIndex: j, rowIndex: i));
        cell.cellStyle = dataCellStyle;
      }
    }

    // **********************步数数据记录************************

    var sheet2 = excel['步数数据记录'];

    // 3. 添加数据
    columnNames = ["日期", "步数"];

    // bold
    headerCellStyle = ExcelPackage.CellStyle(
      bold: true,
      textWrapping: ExcelPackage.TextWrapping.WrapText,
      fontFamily:
          ExcelPackage.getFontFamily(ExcelPackage.FontFamily.Comic_Sans_MS),
      rotation: 0,
      bottomBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      topBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      leftBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      rightBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
    );

    sheet2.appendRow(columnNames);

    for (int i = 0; i < columnNames.length; i++) {
      var cell = sheet2.cell(
          ExcelPackage.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerCellStyle;
    }

    for (int i = 0; i < recordStepData.length; i++) {
      List<String> dataCell = [];
      dataCell.add(recordStepData[i]["date"]);
      dataCell.add(recordStepData[i]["steps"].toString());
      sheet2.appendRow(dataCell);
    }

    dataCellStyle = ExcelPackage.CellStyle(
      textWrapping: ExcelPackage.TextWrapping.WrapText,
      rotation: 0,
      bottomBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      topBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      leftBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
      rightBorder: ExcelPackage.Border(
        borderStyle: ExcelPackage.BorderStyle.Thin,
      ),
    );

    for (int i = 1; i <= recordStepData.length; i++) {
      for (int j = 0; j < columnNames.length; j++) {
        var cell = sheet2.cell(ExcelPackage.CellIndex.indexByColumnRow(
            columnIndex: j, rowIndex: i));
        cell.cellStyle = dataCellStyle;
      }
    }

    // **********************运动统计记录************************
    var sheet3 = excel['运动统计记录'];
    List<String> columnNames2 = [
      "运动(天)",
      "少于30分钟",
      "30至60分钟",
      "60至120分钟",
      "120分钟以上",
      "总天数"
    ];

    sheet3.appendRow(columnNames2);
    for (int i = 0; i < columnNames2.length; i++) {
      var cell = sheet3.cell(
          ExcelPackage.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerCellStyle;
    }

    for (int i = 0; i < statisticData.length; i++) {
      if (statisticData[i]["name"] != "exercise") {
        continue;
      }
      int count_ = statisticData[i]["less"] +
          statisticData[i]["fewer"] +
          statisticData[i]["medium"] +
          statisticData[i]["more"];
      List<String> dataCell = [];
      dataCell.add("运动");
      dataCell.add(statisticData[i]["less"].toString());
      dataCell.add(statisticData[i]["fewer"].toString());
      dataCell.add(statisticData[i]["medium"].toString());
      dataCell.add(statisticData[i]["more"].toString());
      dataCell.add(count_.toString());
      sheet3.appendRow(dataCell);
    }

    for (int j = 0; j < columnNames2.length; j++) {
      var cell = sheet3.cell(
          ExcelPackage.CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 1));
      cell.cellStyle = dataCellStyle;
    }

    // **********************步数统计记录************************
    var sheet4 = excel['步数统计记录'];
    columnNames2 = ["步数(天)", "少于500", "500至1000", "1000至3000", "3000以上", "总天数"];

    sheet4.appendRow(columnNames2);
    for (int i = 0; i < columnNames2.length; i++) {
      var cell = sheet4.cell(
          ExcelPackage.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerCellStyle;
    }

    for (int i = 0; i < statisticData.length; i++) {
      if (statisticData[i]["name"] != "steps") {
        continue;
      }
      int count_ = statisticData[i]["less"] +
          statisticData[i]["fewer"] +
          statisticData[i]["medium"] +
          statisticData[i]["more"];
      List<String> dataCell = [];
      dataCell.add("步数");
      dataCell.add(statisticData[i]["less"].toString());
      dataCell.add(statisticData[i]["fewer"].toString());
      dataCell.add(statisticData[i]["medium"].toString());
      dataCell.add(statisticData[i]["more"].toString());
      dataCell.add(count_.toString());
      sheet4.appendRow(dataCell);
    }

    for (int j = 0; j < columnNames2.length; j++) {
      var cell = sheet4.cell(
          ExcelPackage.CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 1));
      cell.cellStyle = dataCellStyle;
    }

    excel.delete('Sheet1');
    //var downloadFolderPath = '/storage/emulated/0/Download/bp.xlsx';

    // 保存
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(join(fileNamePath))
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    //检测文件是否存在
    if (await File(fileNamePath).exists()) {
      print("excel export ok");
    }
  }

  // 从后端请求数据
  Future<void> getDataFromServer() async {
    String startDate = getFormattedDate(widget.filterParam.startDate);
    String endDate = getFormattedDate(widget.filterParam.endDate);
    String startTime = getFormattedTime(widget.filterParam.startTime);
    String endTime = getFormattedTime(widget.filterParam.endTime);
    String minDuration = widget.filterParam.minDurationController.text;
    String maxDuration = widget.filterParam.maxDurationController.text;
    String feeling = "";
    String remark = "";
    List<bool> feelingBool = widget.filterParam.feelingsSelected;
    List<bool> remarkBool = widget.filterParam.remarksSelected;

    var filterParam = {
      "startDate": startDate,
      "endDate": endDate,
      "startTime": startTime,
      "endTime": endTime,
      "minDuration": minDuration,
      "maxDuration": maxDuration,
    };

    // 代表需要过滤

    if (feelingBool[3] == false) {
      feelingBool[0] == true ? feeling += "1" : feeling += "0";
      feelingBool[1] == true ? feeling += "1" : feeling += "0";
      feelingBool[2] == true ? feeling += "1" : feeling += "0";
      filterParam["feelings"] = feeling;
    }

    //print("feeling: ${filterParam["feeling"]} ");

    if (remarkBool[2] == false) {
      remarkBool[0] == true ? remark += "1" : remark += "0";
      remarkBool[1] == true ? remark += "1" : remark += "0";
      filterParam["remark"] = remark;
    }

    if (widget.accountId >= 0) {
      filterParam["accountId"] = widget.accountId.toString();
    }

    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/sports/exercise/filter",
        data: filterParam,
      );
      if (response.data["code"] == 200) {
        //print("获取血压数据成功 按条件筛选");
        recordData = response.data["data"]["exerciseList"];
        recordStepData = response.data["data"]["stepsList"];
        statisticData = response.data["data"]["countedDataList"];
      } else {
        print(response);
        recordData = [];
        recordStepData = [];
        statisticData = [];
      }
    } catch (e) {
      print(e);
      recordData = [];
      recordStepData = [];
      statisticData = [];
    }

    await createExportFile();
    // TODO ####
  }

  // 记录表格的标题 "日期 时间 收缩压 舒张压 心率 手臂 感觉 备注"
  List<DataColumn> getDataColumns() {
    //using the filteredData to generate the table
    List<DataColumn> dataColumn = [];
    List<String> columnNames = [
      "开始时间",
      "结束时间",
      "运动时长",
      "类型",
      "感觉",
      "备注",
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

  // 记录表格的内容
  List<DataRow> getDataRows() {
    List<String> feelingsText = ["较好", "还好", "较差"];

    List<DataRow> dataRow = [];
    for (int i = 0; i < recordData.length; i++) {
      dataRow.add(DataRow(
        cells: <DataCell>[
          DataCell(Center(
            child: Text(recordData[i]["startTime"]),
          )),
          DataCell(Center(
            child: Text(recordData[i]["endTime"]),
          )),
          DataCell(Center(
            child: Text(recordData[i]["duration"].toString()),
          )),
          DataCell(Center(
            child: Text(items[recordData[i]["type"]]),
          )),
          DataCell(
              Center(child: Text(feelingsText[recordData[i]["feelings"]]))),
          DataCell(
            Text((recordData[i]["remark"].toString()) == "null"
                ? "暂无备注"
                : recordData[i]["remark"].toString()),
          ),
        ],
      ));
    }
    if (recordData.isEmpty) {
      // -
      dataRow.add(const DataRow(cells: <DataCell>[
        DataCell(Center(
          child: Text("-"),
        )),
        DataCell(Center(
          child: Text("-"),
        )),
        DataCell(Center(
          child: Text("-"),
        )),
        DataCell(Center(
          child: Text("-"),
        )),
        DataCell(Center(
          child: Text("-"),
        )),
        DataCell(Center(
          child: Text("-"),
        )),
      ]));
    }
    return dataRow;
  }

  // 统计表格的标题 "血压/心率 最低值 最高值 平均值 偏低次数 正常次数 偏高次数 异常次数 总次数"
  List<DataColumn> getStatisticsDataColumns() {
    List<DataColumn> dataColumn = [];
    List<String> columnNames = [
      "少于30分钟",
      "30至60分钟",
      "60至120分钟",
      "120分钟以上",
      "总天数",
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

  // 统计表格的内容
  List<DataRow> getStatisticsDataRows() {
    List<DataRow> dataRow = [];
    List<String> names = ["运动", "步数"];

    for (int i = 0; i < statisticData.length; i++) {
      if (statisticData[i]["name"] != "exercise") {
        continue;
      }
      int count_ = statisticData[i]["less"] +
          statisticData[i]["fewer"] +
          statisticData[i]["medium"] +
          statisticData[i]["more"];
      dataRow.add(DataRow(
        cells: <DataCell>[
          DataCell(Center(
            child: Text(statisticData[i]["less"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["fewer"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["medium"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["more"].toString()),
          )),
          DataCell(Center(
            child: Text(count_.toString()),
          )),
        ],
      ));
    }

    return dataRow;
  }

  Widget getWholeWidget(BuildContext context) {
    double recordDataHeight = 50;
    if (recordData.isEmpty) {
      recordDataHeight = 108;
    } else if (recordData.length < 9) {
      recordDataHeight = (recordData.length + 1) * 49;
    } else {
      recordDataHeight = (9 * 50);
    }

    return Column(
      children: [
        // 数据记录
        UnconstrainedBox(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            /* height: recordData.length < 9
                ? ((recordData.length + 1) * 50) + 50
                : (50 * 9) + 50, */
            // color: Colors.yellow,
            alignment: Alignment.center,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Text("运动数据表",
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
                    /* height: recordData.length < 9
                        ? ((recordData.length + 1) * 50)
                        : 50 * 9, */
                    height: recordDataHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 196, 195, 195),
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

        const SizedBox(height: 10),

        // 统计部分
        UnconstrainedBox(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 155,
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("运动统计表",
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
                    height: 105,
                    //height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        //color: Color.fromARGB(255, 129, 127, 127),
                        color: const Color.fromARGB(255, 196, 195, 195),
                      ),
                      borderRadius: BorderRadius.circular(5),
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

  @override
  Widget build(BuildContext context) {
    widget.filterParam.tackle();

    // 判断参数是否合法
    if (widget.filterParam.checkInvalidParam() > 0) {
      //print("invalid param");
      widget.filterParam.refresh = false;
      return getWholeWidget(context);
    }

    if (widget.filterParam.refresh == false) {
      //print("数据表格 (不) 刷新");
      return getWholeWidget(context);
    }

    // 原始数据记录
    //else {
    print("数据表格刷新");
    //getDataFromServer();
    widget.filterParam.refresh = false;

    return FutureBuilder(
        future: getDataFromServer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //createExportFile();
            return getWholeWidget(context);
          } else {
            //return Container();
            /* return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            ); */

            return UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text("运动数据表",
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
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.pink, size: 25),
                      ),
                    ),
                    Row(
                      children: [
                        const Text("运动统计表",
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
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.pink, size: 25),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
    //}

    //return getWholeWidget(context);
  }
}

// 血压表格记录
// ignore: must_be_immutable
class StepRecordWidget extends StatefulWidget {
  final int accountId;
  BloodPressureFilterParam filterParam;
  bool oldParam = false;
  final VoidCallback updateGraph;
  StepRecordWidget(
      {Key? key,
      required this.accountId,
      required this.filterParam,
      required this.oldParam,
      required this.updateGraph})
      : super(key: key);

  @override
  State<StepRecordWidget> createState() => _StepRecordWidgetState();
}

class _StepRecordWidgetState extends State<StepRecordWidget> {
  List<Map<dynamic, dynamic>> filteredData = [];
  // [最小值，最大值，平均值，偏低次数，正常次数，偏高次数，异常次数，总次数]

  List<int> sbpList = [0, 0, 0, 0, 0, 0, 0, 0]; //
  List<int> dbpList = [0, 0, 0, 0, 0, 0, 0, 0];
  List<int> heartRateList = [0, 0, 0, 0, 0, 0, 0, 0];
  List<dynamic> recordData = [];
  List<dynamic> statisticData = [];

  // 从后端请求数据
  Future<void> getDataFromServer() async {
    String startDate = getFormattedDate(widget.filterParam.startDate);
    String endDate = getFormattedDate(widget.filterParam.endDate);
    String startTime = getFormattedTime(widget.filterParam.startTime);
    String endTime = getFormattedTime(widget.filterParam.endTime);
    String minDuration = widget.filterParam.minDurationController.text;
    String maxDuration = widget.filterParam.maxDurationController.text;
    String feeling = "";
    String remark = "";
    List<bool> feelingBool = widget.filterParam.feelingsSelected;
    List<bool> remarkBool = widget.filterParam.remarksSelected;

    var filterParam = {
      "startDate": startDate,
      "endDate": endDate,
      "startTime": startTime,
      "endTime": endTime,
      "minDuration": minDuration,
      "maxDuration": maxDuration,
    };

    // 代表需要过滤

    if (feelingBool[3] == false) {
      feelingBool[0] == true ? feeling += "1" : feeling += "0";
      feelingBool[1] == true ? feeling += "1" : feeling += "0";
      feelingBool[2] == true ? feeling += "1" : feeling += "0";
      filterParam["feeling"] = feeling;
    }

    if (remarkBool[2] == false) {
      remarkBool[0] == true ? remark += "1" : remark += "0";
      remarkBool[1] == true ? remark += "1" : remark += "0";
      filterParam["remark"] = remark;
    }

    if (widget.accountId >= 0) {
      filterParam["accountId"] = widget.accountId.toString();
    }

    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/sports/exercise/filter",
        data: filterParam,
      );
      if (response.data["code"] == 200) {
        //print("获取血压数据成功 按条件筛选");
        recordData = response.data["data"]["stepsList"];
        statisticData = response.data["data"]["countedDataList"];

        //print(recordData);
      } else {
        print(response);
        recordData = [];
        statisticData = [];
      }
    } catch (e) {
      print(e);
      recordData = [];
      statisticData = [];
    }

    //await createExportFile();
    // TODO ####
  }

  // 记录表格的标题 "日期 步数"
  List<DataColumn> getDataColumns(double width) {
    //using the filteredData to generate the table
    List<DataColumn> dataColumn = [];
    List<String> columnNames = ["日期", "步数"];

    for (int i = 0; i < columnNames.length; i++) {
      dataColumn.add(DataColumn(
        label: Expanded(
          child: Container(
            width: width, //MediaQuery.of(context).size.width * 0.85 * 0.5,
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
        ),
      ));
    }

    return dataColumn;
  }

  // 记录表格的内容
  List<DataRow> getDataRows() {
    List<DataRow> dataRow = [];
    for (int i = 0; i < recordData.length; i++) {
      dataRow.add(DataRow(
        cells: <DataCell>[
          DataCell(Center(
            child: Text(recordData[i]["date"]),
          )),
          DataCell(Center(
            child: Text(recordData[i]["steps"].toString()),
          )),
        ],
      ));
    }
    if (recordData.isEmpty) {
      // -
      dataRow.add(const DataRow(cells: <DataCell>[
        DataCell(Center(
          child: Text("-"),
        )),
        DataCell(Center(
          child: Text("-"),
        )),
      ]));
    }
    return dataRow;
  }

  // 统计表格的标题 "血压/心率 最低值 最高值 平均值 偏低次数 正常次数 偏高次数 异常次数 总次数"
  List<DataColumn> getStatisticsDataColumns() {
    List<DataColumn> dataColumn = [];
    List<String> columnNames = [
      "0至500",
      "500至1000",
      "1000至3000",
      "3000以上",
      "总天数",
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

  // 统计表格的内容
  List<DataRow> getStatisticsDataRows() {
    List<DataRow> dataRow = [];
    List<String> names = ["运动", "步数"];

    for (int i = 0; i < statisticData.length; i++) {
      if (statisticData[i]["name"] != "steps") continue;
      int count_ = statisticData[i]["less"] +
          statisticData[i]["fewer"] +
          statisticData[i]["medium"] +
          statisticData[i]["more"];
      dataRow.add(DataRow(
        cells: <DataCell>[
          /* DataCell(Center(
            child: Text(names[i]),
          )), */
          DataCell(Center(
            child: Text(statisticData[i]["less"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["fewer"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["medium"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["more"].toString()),
          )),
          DataCell(Center(
            child: Text(count_.toString()),
          )),
        ],
      ));
    }

    return dataRow;
  }

  Widget getWholeWidget(BuildContext context) {
    double recordDataHeight = 50;
    if (recordData.isEmpty) {
      recordDataHeight = 108;
    } else if (recordData.length < 9) {
      recordDataHeight = (recordData.length + 1) * 49;
    } else {
      recordDataHeight = (9 * 50);
    }

    return Column(
      children: [
        // 数据记录
        UnconstrainedBox(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            /* height: recordData.length < 9
                ? ((recordData.length + 1) * 50) + 50
                : (50 * 9) + 50, */
            // color: Colors.yellow,
            alignment: Alignment.center,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Text("步数数据表",
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
                    /* height: recordData.length < 9
                        ? ((recordData.length + 1) * 50)
                        : 50 * 9, */
                    height: recordDataHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 196, 195, 195),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: getDataColumns(
                              MediaQuery.of(context).size.width * 0.85 * 0.4),
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

        const SizedBox(height: 10),

        // 统计部分
        UnconstrainedBox(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 155,
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("步数统计表",
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
                    height: 105,
                    //height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        //color: Color.fromARGB(255, 129, 127, 127),
                        color: const Color.fromARGB(255, 196, 195, 195),
                      ),
                      borderRadius: BorderRadius.circular(5),
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

  @override
  Widget build(BuildContext context) {
    widget.filterParam.tackle();

    // 判断参数是否合法
    if (widget.filterParam.checkInvalidParam() > 0) {
      //print("invalid param");
      widget.filterParam.refresh = false;
      return getWholeWidget(context);
    }

    /* if (widget.filterParam.refresh == false) {
      //print("数据表格 (不) 刷新");
      return getWholeWidget(context);
    } */

    // 原始数据记录
    //else {
    print("数据表格刷新");
    //getDataFromServer();
    widget.filterParam.refresh = false;

    return FutureBuilder(
        future: getDataFromServer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //createExportFile();
            return getWholeWidget(context);
          } else {
            //return Container();
            /* return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            ); */

            return UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text("步数数据表",
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
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.pink, size: 25),
                      ),
                    ),
                    Row(
                      children: [
                        const Text("步数统计表",
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
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.pink, size: 25),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
    //}

    //return getWholeWidget(context);
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

// SBP区间
// ignore: must_be_immutable
class DurationFilterWidget extends StatefulWidget {
  TextEditingController minDurationController = TextEditingController();
  TextEditingController maxDurationController = TextEditingController();
  DurationFilterWidget({
    Key? key,
    required this.minDurationController,
    required this.maxDurationController,
  }) : super(key: key);

  @override
  State<DurationFilterWidget> createState() => _DurationFilterWidgetState();
}

class _DurationFilterWidgetState extends State<DurationFilterWidget> {
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
              controller: widget.minDurationController,
              //initialValue: widget.heartRate,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                  counterText: "",
                  hintText: "-",
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            "至",
            style: TextStyle(fontSize: 16, fontFamily: "BaloonBhai"),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 75,
            height: 40,
            child: TextFormField(
              maxLength: 3,
              controller: widget.maxDurationController,
              //initialValue: widget.heartRate,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                  counterText: "",
                  hintText: "-",
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              style: const TextStyle(fontSize: 30, fontFamily: "BalooBhai"),
            ),
          ),
          const SizedBox(width: 2),
          const Text(
            "mmHg",
            style: TextStyle(fontSize: 16, fontFamily: "Blinker"),
          ),
        ],
      ),
    );
  }
}

// 时间选择
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

// 备注选择按钮
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
    "时长设置有误",
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
                  //print("invalidParam: $invalidParam");
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
            height: isExpanded ? 300 : 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 196, 195, 195),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
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
                                      getTitle("时长", "DURATION"),
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

                                      // 时长
                                      DurationFilterWidget(
                                          minDurationController: widget
                                              .filterParam
                                              .minDurationController,
                                          maxDurationController: widget
                                              .filterParam
                                              .maxDurationController),
                                      //
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
  final int accountId;
  final String nickname;
  const ExportExcelWiget(
      {Key? key, required this.accountId, required this.nickname})
      : super(key: key);

  @override
  State<ExportExcelWiget> createState() => _ExportExcelWigetState();
}

class _ExportExcelWigetState extends State<ExportExcelWiget> {
  String exportTime = "";
  String exportPath = "";
  Future<bool> createExportFile() async {
    var status = await Permission.storage.status.isGranted;
    var status1 = await Permission.storage.request().isGranted;
    var status2 = await Permission.manageExternalStorage.status.isGranted;
    var status3 = await Permission.manageExternalStorage.request().isGranted;

    if (!status) {
      await Permission.storage.request();
    }

    if (!status2) {
      await Permission.manageExternalStorage.request();
    }

    // 获取文件夹路径
    var dir = await getApplicationSupportDirectory();
    var folderPath = Directory("${dir.path}/sportsActivity");

    print("folderPath: ${folderPath.path}");

    // 判断文件夹是否存在
    if (!await folderPath.exists()) {
      return false;
    }

    // 获取文件路径
    var fileNamePath = "${folderPath.path}/sportsActivity.xlsx";
    exportTime =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}_${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}";

    String nickname = widget.accountId == -1 ? "" : widget.nickname;

    //检测文件是否存在
    if (await File(fileNamePath).exists()) {
      var downloadPath = await getDownloadsDirectory();

      await File(fileNamePath).copy(
          '${downloadPath!.path}/sportsActivity_${nickname}_${exportTime}.xlsx');
      // 检测文件是否存在
      print(
          '${downloadPath.path}/sportsActivity_${nickname}_${exportTime}.xlsx');
      if (await File(
              '${downloadPath!.path}/sportsActivity_${nickname}_${exportTime}.xlsx')
          .exists()) {
        exportPath =
            '${downloadPath.path}/sportsActivity_${nickname}_${exportTime}.xlsx';
        print("export sportsActivity.xlsx successfully");
        return true;
      }
    }

    return false;
  }

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
              onTap: () async {
                bool exportStatus = await createExportFile();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(exportStatus
                        ? '导出成功，请查看$exportPath'
                        : '导出失败，请检查文件夹权限和重试'),
                    duration: const Duration(seconds: 3),
                  ),
                );
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================

// 血压数据详情页面
class ActivityMoreData extends StatefulWidget {
  final Map arguments;
  //需要 accountId, nickname
  const ActivityMoreData({Key? key, required this.arguments}) : super(key: key);

  @override
  State<ActivityMoreData> createState() => _ActivityMoreDataState();
}

class _ActivityMoreDataState extends State<ActivityMoreData> {
  //过滤器参数

  BloodPressureFilterParam filterParam = BloodPressureFilterParam(
    startDate: DateTime.now().subtract(const Duration(days: 7)),
    endDate: DateTime.now(),
    startTime: DateTime(2023, 11, 11, 00, 00),
    endTime: DateTime(2023, 11, 11, 23, 59),
    feelingsSelected: [false, false, false, true],
    minDurationController: TextEditingController(),
    maxDurationController: TextEditingController(),
    remarksSelected: [false, false, true],
    refresh: true,
  );

  List<bool> prevArmsSelected = [false, false, false, true];
  List<bool> prevFeelingsSelected = [false, false, false, true];
  bool isOldParam = true;
  bool showFilterWidget = false;

  // 初始化
  @override
  void initState() {
    super.initState();
  }

  // 回调函数
  void updateGraph() {
    setState(() {});
  }

  // 回调函数 更新日期
  void updateStartDate(DateTime newDate) {
    setState(() {
      filterParam.startDate = newDate;
      print('设置新起始日期：${filterParam.startDate}');
    });
  }

  // 回调函数 更新日期
  void updateEndDate(DateTime newDate) {
    setState(() {
      filterParam.endDate = newDate;
    });
  }

  // 回调函数 更新时间
  void updateStartTime(DateTime newTime) {
    setState(() {
      filterParam.startTime = newTime;
    });
  }

  // 回调函数 更新时间
  void updateEndTime(DateTime newTime) {
    setState(() {
      filterParam.endTime = newTime;
    });
  }

  // 回调函数 更新过滤器视图
  void updateFilterWidgetView(bool show) {
    setState(() {
      showFilterWidget = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      //canPop: false,
      child: Scaffold(
        appBar: widget.arguments["accountId"] < 0
            ? getAppBar(0, true, "TriGuard")
            : getAppBar(1, true, widget.arguments["nickname"]),
        body: Container(
          color: Colors.white,
          child: ListView(shrinkWrap: true, children: [
            const SizedBox(height: 5),
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
                      title: "活动详细数据",
                      icons: "assets/icons/exercising.png",
                      fontSize: 22,
                    ),
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
              accountId: widget.arguments["accountId"],
              filterParam: filterParam,
              oldParam: isOldParam,
              updateGraph: updateGraph,
            ),

            StepRecordWidget(
              accountId: widget.arguments["accountId"],
              filterParam: filterParam,
              oldParam: isOldParam,
              updateGraph: updateGraph,
            ),

            ExportExcelWiget(
              accountId: widget.arguments["accountId"],
              nickname: widget.arguments["nickname"],
            ),

            const SizedBox(
              height: 50,
            ),
          ]),
        ),
      ),
    );
  }
}
