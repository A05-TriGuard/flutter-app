import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as ExcelPackage;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:triguard/account/token.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../component/header/header.dart';
import '../../component/titleDate/titleDate.dart';
import '../../other/other.dart';

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
      minSBPController.text = "0";
    }

    if (maxSBPController.text == "") {
      maxSBPController.text = "150";
    }
    if (minDBPController.text == "") {
      minDBPController.text = "0";
    }

    if (maxDBPController.text == "") {
      maxDBPController.text = "150";
    }

    if (minHeartRateController.text == "") {
      minHeartRateController.text = "0";
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
    minSBPController.text = "0";
    maxSBPController.text = "150";
    minDBPController.text = "0";
    maxDBPController.text = "150";
    minHeartRateController.text = "0";
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
  final int accountId;
  BloodPressureFilterParam filterParam;
  bool oldParam = false;
  final VoidCallback updateGraph;
  BloodPressureRecordWidget({
    Key? key,
    required this.accountId,
    required this.filterParam,
    required this.oldParam,
    required this.updateGraph,
  }) : super(key: key);

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
  List<int> sbpList = [0, 0, 0, 0, 0, 0, 0, 0]; //
  List<int> dbpList = [0, 0, 0, 0, 0, 0, 0, 0];
  List<int> heartRateList = [0, 0, 0, 0, 0, 0, 0, 0];
  List<dynamic> recordData = [];
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

    if (!status1) {
      await Permission.manageExternalStorage.status;
    }

    if (!status2) {
      await Permission.manageExternalStorage.request();
    }

    if (!status3) {
      await Permission.manageExternalStorage.status;
    }

    // 获取文件夹路径
    var dir = await getApplicationSupportDirectory();
    var folderPath = Directory("${dir.path}/bloodPressure");

    print("folderPath: ${folderPath.path}");

    // 判断文件夹是否存在，不存在则创建
    if (await folderPath.exists() == false) {
      folderPath.create();
    }

    // 获取文件路径
    var fileNamePath = "${folderPath.path}/bloodPressure.xlsx";

    //创建文件
    var excel = ExcelPackage.Excel.createExcel();

    // 2. 添加工作表
    var sheet1 = excel['数据记录'];

    // 3. 添加数据
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

    for (int i = 0; i < 8; i++) {
      var cell = sheet1.cell(
          ExcelPackage.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerCellStyle;
    }

    List<String> armsText = ["左手", "右手", "不选"];
    List<String> feelingsText = ["较好", "还好", "较差"];

    for (int i = 0; i < recordData.length; i++) {
      List<String> dataCell = [];
      dataCell.add(recordData[i]["date"]);
      dataCell.add(recordData[i]["time"]);
      dataCell.add(recordData[i]["sbp"].toString());
      dataCell.add(recordData[i]["dbp"].toString());
      dataCell.add(recordData[i]["heartRate"].toString());
      dataCell.add(armsText[recordData[i]["arm"]]);
      dataCell.add(feelingsText[recordData[i]["feeling"]]);
      dataCell.add((recordData[i]["remark"].toString()) == "null"
          ? "暂无备注"
          : recordData[i]["remark"].toString());

      sheet1.appendRow(dataCell);
    }

    sheet1.setColumnWidth(0, 15);

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
      for (int j = 0; j < 7; j++) {
        var cell = sheet1.cell(ExcelPackage.CellIndex.indexByColumnRow(
            columnIndex: j, rowIndex: i));
        cell.cellStyle = dataCellStyle;
      }
    }

    // Sheet2 =============================================================
    var sheet2 = excel['统计记录'];
    List<String> columnNames2 = [
      "-",
      "最低值",
      "最高值",
      "平均值",
      "偏低(次)",
      "正常(次)",
      "偏高(次)",
      "异常(次)",
      "总次数",
    ];

    sheet2.appendRow(columnNames2);
    for (int i = 0; i < 9; i++) {
      var cell = sheet2.cell(
          ExcelPackage.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerCellStyle;
    }

    List<String> names = ["收缩压", "舒张压", "心率"];
    for (int i = 0; i < statisticData.length; i++) {
      List<String> dataCell = [];
      dataCell.add(names[i]);
      dataCell.add((statisticData[i]["min"].toString()) == "null"
          ? "0"
          : statisticData[i]["min"].toString());
      dataCell.add((statisticData[i]["max"].toString()) == "null"
          ? "0"
          : statisticData[i]["max"].toString());
      dataCell.add(statisticData[i]["avg"].toString());
      dataCell.add(statisticData[i]["high"].toString());
      dataCell.add(statisticData[i]["medium"].toString());
      dataCell.add(statisticData[i]["low"].toString());
      dataCell.add(statisticData[i]["abnormal"].toString());
      dataCell.add(statisticData[i]["count"].toString());
      sheet2.appendRow(dataCell);
    }

    for (int i = 1; i <= statisticData.length; i++) {
      for (int j = 0; j < columnNames2.length; j++) {
        var cell = sheet2.cell(ExcelPackage.CellIndex.indexByColumnRow(
            columnIndex: j, rowIndex: i));
        cell.cellStyle = dataCellStyle;
      }
    }

    excel.delete('Sheet1');
    //var downloadFolderPath = '/storage/emulated/0/Download/bp.xlsx';

    // 保存
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(join(fileNamePath))
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      /*  File(join(downloadFolderPath))
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes); */
    }

    /* if (await File(downloadFolderPath).exists()) {
      print("excel export download ok");
      //打开文件
      // OpenFile.open(fileNamePath);
    } */

    //检测文件是否存在
    if (await File(fileNamePath).exists()) {
      print("excel export ok");
      //打开文件
      //OpenFile.open(fileNamePath);
      // copy the file to Downloads folder
      /* var downloadPath = await getDownloadsDirectory();
      await File(fileNamePath)
          //.copy('/storage/emulated/0/Download/bloodPressure.xlsx');
          .copy('${downloadPath!.path}/bloodPressure.xlsx');
      //.copy('/sdcard/Download/bloodPressure.xlsx');
      print("downloadPath: ${downloadPath?.path}");
      // 检测文件是否存在
      //if (await File('/storage/emulated/0/Download/bloodPressure.xlsx')
      if (await File('${downloadPath?.path}/bloodPressure.xlsx').exists()) {
        print("copy ok");
      } */
    }
  }

  // 从后端请求数据
  Future<void> getDataFromServer() async {
    String startDate = getFormattedDate(widget.filterParam.startDate);
    String endDate = getFormattedDate(widget.filterParam.endDate);
    String startTime = getFormattedTime(widget.filterParam.startTime);
    String endTime = getFormattedTime(widget.filterParam.endTime);
    String minSBP = widget.filterParam.minSBPController.text;
    String maxSBP = widget.filterParam.maxSBPController.text;
    String minDBP = widget.filterParam.minDBPController.text;
    String maxDBP = widget.filterParam.maxDBPController.text;
    String minHeartRate = widget.filterParam.minHeartRateController.text;
    String maxHeartRate = widget.filterParam.maxHeartRateController.text;
    String arm = "";
    String feeling = "";
    String remark = "";
    List<bool> armBool = widget.filterParam.armsSelected;
    List<bool> feelingBool = widget.filterParam.feelingsSelected;
    List<bool> remarkBool = widget.filterParam.remarksSelected;

    var filterParam = {
      "startDate": startDate,
      "endDate": endDate,
      "startTime": startTime,
      "endTime": endTime,
      "minSbp": minSBP,
      "maxSbp": maxSBP,
      "minDbp": minDBP,
      "maxDbp": maxDBP,
      "minHeartRate": minHeartRate,
      "maxHeartRate": maxHeartRate,
    };

    // 代表需要过滤
    if (armBool[3] == false) {
      armBool[0] == true ? arm += "1" : arm += "0";
      armBool[1] == true ? arm += "1" : arm += "0";
      armBool[2] == true ? arm += "1" : arm += "0";
      filterParam["arm"] = arm;
    }

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
        "http://43.138.75.58:8080/api/blood-pressure/get-by-filter",
        data: filterParam,
      );
      if (response.data["code"] == 200) {
        //print("获取血压数据成功 按条件筛选");
        recordData = response.data["data"]["bloodPressureList"];
        statisticData = response.data["data"]["countedDataList"];
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

    await createExportFile();
  }

  // 记录表格的标题 "日期 时间 收缩压 舒张压 心率 手臂 感觉 备注"
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

  // 记录表格的内容
  List<DataRow> getDataRows() {
    List<String> armsText = ["左手", "右手", "不选"];
    List<String> feelingsText = ["较好", "还好", "较差"];

    List<DataRow> dataRow = [];
    for (int i = 0; i < recordData.length; i++) {
      dataRow.add(DataRow(
        cells: <DataCell>[
          DataCell(Center(
            child: Text(recordData[i]["date"]),
          )),
          DataCell(Center(
            child: Text(recordData[i]["time"]),
          )),
          DataCell(Center(
            child: Text(recordData[i]["sbp"].toString()),
          )),
          DataCell(Center(
            child: Text(recordData[i]["dbp"].toString()),
          )),
          DataCell(Center(
            child: Text(recordData[i]["heartRate"].toString()),
          )),
          DataCell(Center(
            child: Text(armsText[recordData[i]["arm"]]),
          )),
          DataCell(Center(child: Text(feelingsText[recordData[i]["feeling"]]))),
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

  // 统计表格的内容
  List<DataRow> getStatisticsDataRows() {
    List<DataRow> dataRow = [];
    List<String> names = ["收缩压", "舒张压", "心率"];

    for (int i = 0; i < statisticData.length; i++) {
      dataRow.add(DataRow(
        cells: <DataCell>[
          DataCell(Center(
            child: Text(names[i]),
          )),
          DataCell(Center(
            child: Text((statisticData[i]["min"].toString()) == "null"
                ? "0"
                : statisticData[i]["min"].toString()),
          )),
          DataCell(Center(
            child: Text((statisticData[i]["max"].toString()) == "null"
                ? "0"
                : statisticData[i]["max"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["avg"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["high"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["medium"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["low"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["abnormal"].toString()),
          )),
          DataCell(Center(
            child: Text(statisticData[i]["count"].toString()),
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
            height: 250,
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
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.pink, size: 25),
                      ),
                    ),
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

// 手臂选择按钮
// ignore: must_be_immutable
class ArmButtonsWidget extends StatefulWidget {
  List<bool> isSelected = [false, false, false, true];
  ArmButtonsWidget({
    Key? key,
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
      child: Row(children: [
        Container(
          height: 40,
          width: 50,
          padding: const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            color: widget.isSelected[index] == true
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
                color: widget.isSelected[index] == true
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

// 心率区间
// ignore: must_be_immutable
class PulseFilterWidget extends StatefulWidget {
  int minHeartRate = 0;
  int maxHeartRate = 1000;
  TextEditingController minHeartRateController = TextEditingController();
  TextEditingController maxHeartRateController = TextEditingController();
  PulseFilterWidget({
    Key? key,
    required this.minHeartRateController,
    required this.maxHeartRateController,
  }) : super(key: key);

  @override
  State<PulseFilterWidget> createState() => _PulseFilterWidgetState();
}

class _PulseFilterWidgetState extends State<PulseFilterWidget> {
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
              controller: widget.maxHeartRateController,
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
            "次/分",
            style: TextStyle(fontSize: 16, fontFamily: "Blinker"),
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
              controller: widget.maxSBPController,
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
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                counterText: "",
                hintText: "-",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              ),
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
              controller: widget.maxDBPController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                counterText: "",
                hintText: "-",
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              ),
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

  TimeFilterWidget2({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.updateStartTime,
    required this.updateEndTime,
  }) : super(key: key);

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
            style: TextStyle(fontSize: 16, fontFamily: "BaloonBhai"),
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
  }
}

// 手臂选择按钮
// ignore: must_be_immutable
class RemarksButtonsWidget extends StatefulWidget {
  List<bool> isSelected = [false, false, true];
  RemarksButtonsWidget({
    Key? key,
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
      child: Row(children: [
        Container(
          height: 40,
          width: 68,
          padding: const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            color: widget.isSelected[index] == true
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
                color: widget.isSelected[index] == true
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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 重置按钮
              GestureDetector(
                onTap: () {
                  widget.filterParam.reset();
                  invalidParam = 0;

                  widget.updateGraph();
                },
                child: Container(
                  height: 30,
                  width: 50,
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 209, 212, 212),
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
                  // 进行数据表的刷新
                  widget.filterParam.refresh = true;

                  invalidParam = widget.filterParam.checkInvalidParam();

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
        ),

        // 警告信息
        Text(
          invalidParamType[invalidParam],
          style: const TextStyle(
            color: Colors.red,
            fontSize: 12.0,
            fontFamily: 'Blinker',
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
  Widget getTitle(String titleChn, String titleEng) {
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
          SizedBox(
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
            height: isExpanded ? 440 : 50,
            decoration: BoxDecoration(
              border: Border.all(
                //color: const Color.fromARGB(255, 129, 127, 127),
                color: const Color.fromARGB(255, 196, 195, 195),
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
                          ],
                        ),
                      ),
                    ),
                  )
                : Center(
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

// 导出excel文件
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
    var status2 = await Permission.manageExternalStorage.status.isGranted;

    if (!status) {
      await Permission.storage.request();
    }

    if (!status2) {
      await Permission.manageExternalStorage.request();
    }

    // 获取文件夹路径
    var dir = await getApplicationSupportDirectory();
    var folderPath = Directory("${dir.path}/bloodPressure");

    //print("folderPath: ${folderPath.path}");

    // 判断文件夹是否存在
    if (!await folderPath.exists()) {
      return false;
    }

    // 获取文件路径
    var fileNamePath = "${folderPath.path}/bloodPressure.xlsx";
    exportTime =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}_${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}";

    String nickname = widget.accountId == -1 ? "" : widget.nickname;

    //检测文件是否存在
    if (await File(fileNamePath).exists()) {
      var downloadPath = await getDownloadsDirectory();
      await File(fileNamePath).copy(
          '${downloadPath!.path}/bloodPressure_${nickname}_${exportTime}.xlsx');
      // 检测文件是否存在
      if (await File(
              '${downloadPath.path}/bloodPressure_${nickname}_${exportTime}.xlsx')
          .exists()) {
        exportPath =
            '${downloadPath.path}/bloodPressure_${nickname}_${exportTime}.xlsx';
        print(
            "export ${downloadPath.path}/bloodPressure_${nickname}_${exportTime}.xlsx successfully");
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
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
class BloodPressureMoreData extends StatefulWidget {
  final Map arguments;
  //需要 accountId, nickname
  const BloodPressureMoreData({Key? key, required this.arguments})
      : super(key: key);

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
                      title: "血压详细数据",
                      icons: "assets/icons/bloodPressure.png",
                      fontSize: 22,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
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
