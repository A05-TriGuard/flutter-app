import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../component/header/header.dart';
import '../other/other.dart';
import '../account/token.dart';
import '../component/titleDate/titleDate.dart';

class MyTitle extends StatefulWidget {
  final String title;
  final String icon;
  final String value;
  final String unit;
  final String route;
  final Object? arguments;
  final VoidCallback refreshData;

  const MyTitle({
    Key? key,
    required this.title,
    required this.icon,
    required this.value,
    required this.unit,
    required this.route,
    this.arguments,
    required this.refreshData,
  }) : super(key: key);

  @override
  State<MyTitle> createState() => _MyTitleState();
}

class _MyTitleState extends State<MyTitle> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 5),
                    Image.asset(widget.icon, width: 25, height: 25),
                  ]),
            ),
            Container(
              child: Row(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.value,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(165, 51, 51, 1)),
                    ),
                    const SizedBox(width: 5),
                    Text(widget.unit,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        icon: const Icon(Icons.edit),
                        iconSize: 25,
                        onPressed: () {
                          // print(widget.arguments);
                          /*  if (widget.arguments != null) {
                            Navigator.pushNamed(context, widget.route,
                                arguments: widget.arguments);
                          } else {
                            Navigator.pushNamed(context, widget.route);
                          } */

                          if (widget.arguments != null) {
                            Navigator.pushNamed(context, widget.route,
                                    arguments: widget.arguments)
                                .then((value) => widget.refreshData());
                            setState(() {});
                          } else {
                            Navigator.pushNamed(context, widget.route)
                                .then((value) => widget.refreshData());
                            setState(() {});
                          }
                        },
                      ),
                    )
                  ]),
            )
          ],
        ),
      ),
    );
  }
}

class MyBloodPressure extends StatefulWidget {
  final int accountId;
  final String nickname;
  final DateTime date;
  final String value;
  const MyBloodPressure({
    Key? key,
    required this.accountId,
    required this.nickname,
    required this.value,
    required this.date,
  }) : super(key: key);

  @override
  State<MyBloodPressure> createState() => _MyBloodPressureState();
}

class _MyBloodPressureState extends State<MyBloodPressure> {
  // 从后端请求得到的原始数据
  List<dynamic> data = [];

  // 显示的数据
  List<int> dayData = [];
  List<int> monthData = [];
  List<int> sbpData = [];
  List<int> dbpData = [];
  List<int> heartRateData = [];

  int todaySBP = -1;
  int todayDBP = -1;

  // 从后端请求数据
  Future<void> getDataFromServer() async {
    String requestDate = getFormattedDate(widget.date);
    // print('请求日期： $requestDate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

    // 提取登录获取的token
    var token = await storage.read(key: 'token');
    //print(value);

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
          /* "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range",
        queryParameters: {
          "startDate": requestDate,
          "endDate": requestDate,
          "accountId": widget.accountId,
        }, */
          widget.accountId >= 0
              ? "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range?startDate=$requestDate&endDate=$requestDate&accountId=${widget.accountId}"
              : "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range?startDate=$requestDate&endDate=$requestDate");
      if (response.data["code"] == 200) {
        //print("获取血压数据成功");
        data = response.data["data"];
      } else {
        print(response);
        data = [];
      }
    } catch (e) {
      print(e);
      data = [];
    }

    //print("血压数据： $data");

    dayData = [];
    monthData = [];
    sbpData = [];
    dbpData = [];
    heartRateData = [];

    for (int i = data.length - 1; i >= 0; i--) {
      String date_ = data[i]["date"];
      int month_ = int.parse(date_.split("-")[1]);
      int day_ = int.parse(date_.split("-")[2]);
      int sbp_ = data[i]["sbp"];
      int dbp_ = data[i]["dbp"];
      int heartRate_ = data[i]["heartRate"];

      dayData.add(day_);
      monthData.add(month_);
      sbpData.add(sbp_);
      dbpData.add(dbp_);
      heartRateData.add(heartRate_);
    }

    if (data.isNotEmpty) {
      todaySBP = data[0]["sbp"];
      todayDBP = data[0]["dbp"];
    }

    if (data.isEmpty) {
      dayData.add(widget.date.day);
      monthData.add(widget.date.month);
      sbpData.add(0);
      dbpData.add(0);
      heartRateData.add(0);
    }
  }

  void refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    todaySBP = -1;
    todayDBP = -1;
    //print("血压 ${widget.date}");
    //getDataFromServer();
    return FutureBuilder(
      // Replace getDataFromServer with the Future you want to wait for
      future: getDataFromServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //获取数据后
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyTitle(
                title: "今日血压",
                icon: "assets/icons/bloodPressure.png",
                value:
                    "${todaySBP < 0 ? '-' : todaySBP}/${todayDBP < 0 ? '-' : todayDBP}",
                unit: "mmHg",
                route: "/homePage/BloodPressure/Edit",
                arguments: {
                  "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                  "nickname":
                      widget.accountId >= 0 ? widget.nickname : "TriGuard",
                  "date": widget.date,
                  "bpDataId": -1,
                },
                refreshData: refreshData,
              ),

              const SizedBox(
                height: 5,
              ),

              // 血压图表
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  UnconstrainedBox(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.30,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
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
                      alignment: Alignment.centerRight,
                      child: Container(
                        // width: MediaQuery.of(context).size.width * 1.5,
                        //width: dayData.length <= 5 ? 325 : dayData.length * 65,
                        width: MediaQuery.of(context).size.width * 0.85, //345
                        height: MediaQuery.of(context).size.height * 0.30,
                        child: Echarts(
                          extraScript: '''
                          var month = $monthData;
                          var day = $dayData;
                        ''',
                          option: '''
              {
                animation:false,

                title: {
                  text: '血压',
                  top:'5%',
                  left:'10',
                },

                legend: {
                  data: ['收缩压', '舒张压', '心率'],
                  top:'6%',
                  left:'70',
                },

                  grid: {
                  left: '10', // 3%
                  right: '20', // 4%
                  //top: '45',
                  bottom: '5%',
                  containLabel: true,
                },
                tooltip: {
                  trigger: 'axis'
                },

                xAxis: {
                  type: 'category',
                  boundaryGap: true,
                  axisLabel: {
                   interval: 0,
                   textStyle: {
                      color: '#000000'
                  },
                   formatter: function(index) {
                        // 自定义显示格式
                         return day[index] + '/' + month[index]; // 取日期的第一部分
                   }
                  },

                },

                yAxis: {
                  type: 'value',
                  //min: 80,
                  //max: 130,
                  ${data.isEmpty ? "min: 0, max: 120," : ""}
                  axisLabel:{
                    textStyle: {
                        color: '#000000'
                    },
                  },
                },
                series: [{
                  name: '收缩压',
                  data: $sbpData,
                  type: 'line',
                  smooth: true
                },
                {
                  name: '舒张压',
                  data: $dbpData,
                  type: 'line',
                  smooth: true
                },

                 {
                  name: '心率',
                  data: $heartRateData,
                  type: 'line',
                  smooth: true
                }
                ]
              }
            ''',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      var arguments = {
                        "accountId": widget.accountId,
                        "date": widget.date,
                        "nickname": widget.nickname,
                      };
                      Navigator.pushNamed(
                              context, "/homePage/BloodPressure/Details",
                              arguments: arguments)
                          .then((value) => refreshData());
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 225, 225),
                        borderRadius: BorderRadius.circular(5),
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
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        } else {
          // 未获取到数据时显示的内容
          return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyTitle(
                  title: "今日血压",
                  icon: "assets/icons/bloodPressure.png",
                  value: "-/-",
                  unit: "mmHg",
                  route: "/homePage/BloodPressure/Edit",
                  arguments: {
                    "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                    "nickname":
                        widget.accountId >= 0 ? widget.nickname : "TriGuard",
                    "date": widget.date,
                    "bpDataId": -1,
                  },
                  refreshData: refreshData,
                ),
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.pink, size: 25),
                )
              ]);
        }
      },
    );
  }
}

class MyBloodSugar extends StatefulWidget {
  final int accountId;
  final String value;
  final String nickname;
  final DateTime date;
  const MyBloodSugar(
      {Key? key,
      required this.accountId,
      required this.nickname,
      required this.value,
      required this.date})
      : super(key: key);

  @override
  State<MyBloodSugar> createState() => _MyBloodSugarState();
}

class _MyBloodSugarState extends State<MyBloodSugar> {
  // 从后端请求得到的原始数据
  List<dynamic> data = [];

  // 显示的数据
  List<int> dayData = [];
  List<int> monthData = [];
  List<double> bloodSugarData = [];
  double todayBS = -1;

  // 从后端请求数据
  Future<void> getDataFromServer() async {
    String requestDate = getFormattedDate(widget.date);
    //print('请求日期：$requestDate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(widget.accountId >= 0
          ? "http://43.138.75.58:8080/api/blood-sugar/get-by-date?date=$requestDate&accountId=${widget.accountId}"
          : "http://43.138.75.58:8080/api/blood-sugar/get-by-date?date=$requestDate");
      if (response.data["code"] == 200) {
        //print("获取血糖数据成功");
        data = response.data["data"];
      } else {
        print(response);
        data = [];
      }
    } catch (e) {
      print(e);
      data = [];
    }

    dayData = [];
    monthData = [];
    bloodSugarData = [];

    for (int i = data.length - 1; i >= 0; i--) {
      String date_ = data[i]["date"];
      int month_ = int.parse(date_.split("-")[1]);
      int day_ = int.parse(date_.split("-")[2]);
      double bs_ = data[i]["bs"];

      dayData.add(day_);
      monthData.add(month_);
      bloodSugarData.add(bs_);
    }

    if (data.isNotEmpty) {
      todayBS = data[0]["bs"];
    }

    if (data.isEmpty) {
      dayData.add(widget.date.day);
      monthData.add(widget.date.month);
      bloodSugarData.add(0);
    }

    //print("bloodSugarData: $bloodSugarData");
  }

  void refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    todayBS = -1;
    return FutureBuilder(
      future: getDataFromServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              MyTitle(
                title: "今日血糖",
                icon: "assets/icons/bloodSugar.png",
                value: todayBS < 0 ? '-' : todayBS.toStringAsFixed(1),
                unit: "mmol/L",
                route: "/homePage/BloodSugar/Edit",
                arguments: {
                  "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                  "nickname":
                      widget.accountId >= 0 ? widget.nickname : "TriGuard",
                  "date": widget.date,
                  "bsDataId": -1,
                },
                refreshData: refreshData,
              ),

              const SizedBox(
                height: 5,
              ),

              // 血糖图表
              Stack(alignment: Alignment.centerRight, children: [
                UnconstrainedBox(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.30,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.30,
                      child: Echarts(
                        extraScript: '''
                  var month = $monthData;
                  var day = $dayData;
                  
                  ''',
                        option: '''
              {
                animation:false,

                title: {
                  text: '血糖',
                  top:'5%',
                  left:'10',
                },

                legend: {
                  data: ['血糖'],
                  top:'6%',
                  left:'70',
                },

                  grid: {
                  left: '3%',
                  right: '4%',
                  bottom: '5%',
                  containLabel: true,
                },
                tooltip: {
                  trigger: 'axis'
                },

                xAxis: {
                  type: 'category',
                  boundaryGap: true,
                  axisLabel: {
                   interval: 0,
                   textStyle: {
                      color: '#000000'
                  },
                   formatter: function(index) {
                        // 自定义显示格式
                         return day[index] + '/' + month[index]; // 取日期的第一部分
                   }
                  },

                },

                yAxis: {
                  type: 'value',
                  axisLabel:{
                    textStyle: {
                        color: '#000000'
                    },
                  },
                  ${data.isEmpty ? "min: 0, max: 120," : ""}
                },
                series: [{
                  name: '血糖',
                  data: $bloodSugarData,
                  type: 'line',
                  smooth: true,
                  itemStyle: {
                      normal: {
                          color: "#E437B4",
                          lineStyle: {
                              color: "#F87CE4"
                          }
                      }
                  },
                },
                ]
                }
            ''',
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    /* Navigator.pushNamed(
                        context, "/homePage/BloodSugar/Details"); */

                    var arguments = {
                      "accountId": widget.accountId,
                      "date": widget.date,
                      "nickname": widget.nickname,
                    };
                    Navigator.pushNamed(context, "/homePage/BloodSugar/Details",
                            arguments: arguments)
                        .then((value) => refreshData());
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 225, 225),
                      borderRadius: BorderRadius.circular(5),
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
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                    ),
                  ),
                ),
              ]),
            ],
          );
        } else {
          // 未获取到数据时显示的内容
          return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyTitle(
                  title: "今日血糖",
                  icon: "assets/icons/bloodSugar.png",
                  value: "-",
                  unit: "mmol/L",
                  route: "/homePage/BloodSugar/Edit",
                  arguments: {
                    "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                    "nickname":
                        widget.accountId >= 0 ? widget.nickname : "TriGuard",
                    "date": widget.date,
                    "bpDataId": -1,
                  },
                  refreshData: refreshData,
                ),
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.pink, size: 25),
                )
              ]);
        }
      },
    );
  }
}

class MyBloodFat extends StatefulWidget {
  final int accountId;
  final String nickname;
  final String value;
  final DateTime date;
  const MyBloodFat(
      {Key? key,
      required this.accountId,
      required this.nickname,
      required this.value,
      required this.date})
      : super(key: key);

  @override
  State<MyBloodFat> createState() => _MyBloodFatState();
}

class _MyBloodFatState extends State<MyBloodFat> {
  // 从后端请求得到的原始数据
  List<dynamic> data = [];

  // 显示的数据
  List<int> dayData = [];
  List<int> monthData = [];
  List<double> tcData = [];
  List<double> tgData = [];
  List<double> ldlData = [];
  List<double> hdlData = [];
  double todayTC = -1;

  // 从后端请求数据
  Future<void> getDataFromServer() async {
    String requestDate = getFormattedDate(widget.date);
    //print('请求日期： $requestDate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        widget.accountId >= 0
            ? "http://43.138.75.58:8080/api/blood-lipids/get-by-date?date=$requestDate&accountId=${widget.accountId}"
            : "http://43.138.75.58:8080/api/blood-lipids/get-by-date?date=$requestDate",
      );
      if (response.data["code"] == 200) {
        //print("获取血脂数据成功");
        data = response.data["data"];
      } else {
        print(response);
        data = [];
      }
    } catch (e) {
      print(e);
      data = [];
    }

    dayData = [];
    monthData = [];
    tcData = [];
    tgData = [];
    ldlData = [];
    hdlData = [];

    for (int i = data.length - 1; i >= 0; i--) {
      String date_ = data[i]["date"];
      int month_ = int.parse(date_.split("-")[1]);
      int day_ = int.parse(date_.split("-")[2]);
      double tc = data[i]["tc"];
      double tg = data[i]["tg"];
      double ldl = data[i]["ldl"];
      double hdl = data[i]["hdl"];

      dayData.add(day_);
      monthData.add(month_);

      tcData.add(tc);
      tgData.add(tg);
      ldlData.add(ldl);
      hdlData.add(hdl);
    }

    if (data.isNotEmpty) {
      todayTC = data[0]["tc"];
    }

    if (data.isEmpty) {
      dayData.add(0);
      monthData.add(0);
      tcData.add(0);
      tgData.add(0);
      ldlData.add(0);
      hdlData.add(0);
    }
  }

  void refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    todayTC = -1;
    return FutureBuilder(
      future: getDataFromServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(children: [
            MyTitle(
              title: "今日血脂",
              icon: "assets/icons/bloodFat.png",
              value: todayTC < 0 ? '-' : todayTC.toStringAsFixed(1),
              unit: "mmol/L",
              route: "/homePage/BloodFat/Edit",
              arguments: {
                "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                "nickname":
                    widget.accountId >= 0 ? widget.nickname : "TriGuard",
                "date": widget.date,
                "bfDataId": -1,
              },
              refreshData: refreshData,
            ),
            const SizedBox(
              height: 5,
            ),
            Stack(alignment: Alignment.centerRight, children: [
              UnconstrainedBox(
                child: Container(
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    Container(
                      // width: MediaQuery.of(context).size.width * 1.5,
                      width: dayData.length * 65 <= 550
                          ? 550
                          : dayData.length * 65,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Echarts(
                        extraScript: '''
                  var month = $monthData;
                  var day = $dayData;
                  
''',
                        option: '''
              {
                animation:false,

                title: {
                  text: '血脂',
                  top:'5%',
                  left:'10',
                },

                legend: {
                  data: ['总胆固醇', '甘油三酯', '低密度脂蛋白胆固醇', '高密度脂蛋白胆固醇'],
                  top:'6%',
                  left:'70',
                },

                  grid: {
                  left: '3%',
                  right: '4%',
                  bottom: '5%',
                  containLabel: true,
                },
                tooltip: {
                  trigger: 'axis'
                },

                xAxis: {
                  type: 'category',
                  boundaryGap: true,
                  axisLabel: {
                   interval: 0,
                   textStyle: {
                      color: '#000000'
                  },
                   formatter: function(index) {
                        // 自定义显示格式
                         return day[index] + '/' + month[index]; // 取日期的第一部分
                   }
                  },

                },

                yAxis: {
                  type: 'value',
                  axisLabel:{
                    textStyle: {
                        color: '#000000'
                    },
                  },
                  ${data.isEmpty ? "min: 0, max: 5," : ""}
                },
                series: [{
                  name: '总胆固醇',
                  data: $tcData,
                  type: 'line',
                  smooth: true
                },
                {
                  name: '甘油三酯',
                  data: $tgData,
                  type: 'line',
                  smooth: true
                },

                 {
                  name: '低密度脂蛋白胆固醇',
                  data: $ldlData,
                  type: 'line',
                  smooth: true
                },

                {
                  name: '高密度脂蛋白胆固醇',
                  data: $hdlData,
                  type: 'line',
                  smooth: true
                }
                ]
              }
            ''',
                      ),
                    ),
                  ]),
                ),
              ),
              GestureDetector(
                onTap: () {
                  //Navigator.pushNamed(context, "/homePage/BloodFat/Details");
                  var args = {
                    "accountId": widget.accountId,
                    "nickname": widget.nickname,
                    "date": widget.date,
                  };
                  Navigator.pushNamed(context, "/homePage/BloodFat/Details",
                          arguments: args)
                      .then((value) => refreshData());
                },
                child: Container(
                  height: 30,
                  width: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 225, 225),
                    borderRadius: BorderRadius.circular(5),
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
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                  ),
                ),
              ),
            ]),
          ]);
        } else {
          //return CircularProgressIndicator();
          return Column(children: [
            MyTitle(
              title: "今日血脂",
              icon: "assets/icons/bloodFat.png",
              value: "-",
              unit: "mmol/L",
              route: "/homePage/BloodFat/Edit",
              arguments: {
                "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                "nickname":
                    widget.accountId >= 0 ? widget.nickname : "TriGuard",
                "date": widget.date,
                "bfDataId": -1,
              },
              refreshData: refreshData,
            ),
            const SizedBox(
              height: 5,
            ),
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.pink, size: 25),
            ),
          ]);
        }
      },
    );
  }
}

class MyActivities extends StatefulWidget {
  final DateTime date;
  final int accountId;
  final String value;
  const MyActivities(
      {Key? key,
      required this.accountId,
      required this.value,
      required this.date})
      : super(key: key);

  @override
  State<MyActivities> createState() => _MyActivitiesState();
}

class _MyActivitiesState extends State<MyActivities> {
  void refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MyTitle(
        title: "今日活动",
        icon: "assets/icons/exercising.png",
        value: widget.value,
        unit: "分钟",
        route: "/homePage/BloodPressure/Edit",
        refreshData: refreshData,
      ), //TODO

      const SizedBox(
        height: 5,
      ),

      // 活动图表
      Stack(alignment: Alignment.centerRight, children: [
        UnconstrainedBox(
          child: Container(
            alignment: Alignment.centerRight,
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
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
            child: Echarts(
              option: '''
             {

   title: {
    text: '活动',
    top:'5%',
    left:'2%',
  },

  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'cross',
      crossStyle: {
        color: '#999'
      }
    }
  },

  legend: {
    data: ['步数', '运动时长'],
    top : '5%',
    //left: '20%',
  },

  grid: {
                //top: '15%',
                left: '3%',
                right: '4%',
                bottom: '5%',
                containLabel: true
              },
  xAxis: [
    {
      type: 'category',
      data: ['8/11', '9/11', '10/11','11/11'],
      axisPointer: {
        type: 'shadow'
      }
    }
  ],
  yAxis: [
    {
      type: 'value',
      name: '步数',
      nameGap: 10, 
      axisLabel: {
        formatter: '{value}'
      }
    },
    {
      type: 'value',
      name: '运动时长',
      nameGap: 10,
      axisLabel: {
        formatter: '{value}'
      },

      splitLine:{       //y轴刻度线
          show:false
        },
    }
  ],
  series: [
    {
      name: '步数',
      type: 'bar',
      tooltip: {
        valueFormatter: function (value) {
          return value + ' 步';
        }
      },
      data: [837, 1063, 1543, 1400]
    },
    {
      name: '运动时长',
      type: 'line',
      yAxisIndex: 1,
      tooltip: {
        valueFormatter: function (value) {
          return value + ' 分钟';
        }
      },
      data: [30,  70,120,45  ]
    }
  ]
}
            ''',
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/homePage/Activity/Details");
          },
          child: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 225, 225),
              borderRadius: BorderRadius.circular(5),
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
              Icons.arrow_forward_ios_rounded,
              size: 20,
            ),
          ),
        ),
      ]),
    ]);
  }
}

class MyDiet extends StatefulWidget {
  final DateTime date;
  final int accountId;
  final String value;
  const MyDiet(
      {Key? key,
      required this.accountId,
      required this.value,
      required this.date})
      : super(key: key);

  @override
  State<MyDiet> createState() => _MyDietState();
}

class _MyDietState extends State<MyDiet> {
  void refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MyTitle(
        title: "今日饮食",
        icon: "assets/icons/meal.png",
        value: widget.value,
        unit: "千卡",
        route: "/homePage/BloodPressure/Edit",
        refreshData: refreshData,
      ), //TODO

      const SizedBox(
        height: 5,
      ),
      Stack(alignment: Alignment.centerRight, children: [
        UnconstrainedBox(
          child: Container(
            alignment: Alignment.centerRight,
            width: MediaQuery.of(context).size.width * 0.85,
            // height: MediaQuery.of(context).size.height * 0.25,
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
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
            child: Echarts(
              extraScript: '''
chart.on('updateAxisPointer', function (event) {
    const xAxisInfo = event.axesInfo[0];
    if (xAxisInfo) {
      const dimension = xAxisInfo.value + 1;
      chart.setOption({
        series: {
          id: 'pie',
          label: {
            formatter: '{b} {@[' + dimension + ']}'
          },
          encode: {
            value: dimension,
            tooltip: dimension
          }
        }
      });
    }
  });
''',
              option: '''

 {
  animation:false,

   // title:'饮食',
     title: {
    text: '饮食',
    top:'5%',
    left:'2%',
  },
    legend: {data:['早餐','午餐','晚餐','其他','卡路里总和'],
     orient: 'vertical',
    top:'15%',
      left:'5%'
    },
    tooltip: {
      trigger: 'axis',
      showContent: true
    },
    dataset: {
      source: [
        ['product', '8/11', '9/11', '10/11','11/11'],
        ['早餐', 400, 500, 550, 480],
        ['午餐', 600, 620, 650, 580],
        ['晚餐', 300, 350, 380, 360],
        ['其他', 200, 180, 160, 190],
      //  ['卡路里总和', 1500, 1650, 1740, 1610, 1740, 1700]
      ]
    },
    xAxis: { type: 'category',data: ['8/11', '9/11', '10/11','11/11']},
    yAxis: { gridIndex: 0 },
    grid: { 
      top: '55%',
      left:'3',
      right: '4%', 
      bottom: '5%',
      containLabel: true
    },
    series: [
      {
        type: 'line',
        //name: '早餐',
        smooth: true,
        seriesLayoutBy: 'row',
        //emphasis: { focus: 'series' }
      },
      {
        type: 'line',
        //name: '午餐',
        smooth: true,
        seriesLayoutBy: 'row',
        //emphasis: { focus: 'series' }
      },
      {
        type: 'line',
        //name: '晚餐',
        smooth: true,
        seriesLayoutBy: 'row',
        //emphasis: { focus: 'series' }
      },
      {
        type: 'line',
        //name: '其他',
        smooth: true,
        seriesLayoutBy: 'row',
       //emphasis: { focus: 'series' }
      },
      {
        type: 'pie',
        id: 'pie',
        radius: '30%',
        center: ['62%', '30%'],
        emphasis: {
          focus: 'self'
        },
        label: {
          formatter: '{b} {@11/11}'
        },
        encode: {
          itemName: 'product', // 修改为卡路里总和的对应项
          value: '11/11',
          tooltip: '11/11'
        },
        labelLine:{  
        normal:{  
          length: 5, // 修改引导线第一段的长度
          length2: 2, // 修改引导线第二段的长度
          //lineStyle: {
          //  color: "red" // 修改引导线的颜色
          //}
        },
        },

       
       
        
      },
      {
        type: 'line', // 柱状图显示总卡路里数据
        name: '卡路里总和',
        smooth: true,
        data: [1500, 1650, 1740, 1610],
        emphasis: { focus: 'series' }
      },
    ]
  }
            ''',
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/homePage/fooddiary/Details");
          },
          child: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 225, 225),
              borderRadius: BorderRadius.circular(5),
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
              Icons.arrow_forward_ios_rounded,
              size: 20,
            ),
          ),
        ),
      ]),
    ]);
  }
}

//
class WardInfo {
  final int accountId;
  final String nickname;
  final String image;

  WardInfo(
      {required this.accountId, required this.nickname, required this.image});
}

// ==============此页面=====================
// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  /*  int accountId;
  final int groupId; // -1表示不是群组
  String nickname;
  final String groupName;
 */
  final Map arguments;
  const HomePage({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  List<WardInfo> allWardInfo = [];
  List<Widget> allWardInfoWidgets = [];
  bool refreshWardList = true;

  // 获取群内成员列表
  Future<void> getGroupMemberListFromServer() async {
    if (!refreshWardList) {
      return;
    }
    List<dynamic> wardInfos = [];

    var token = await storage.read(key: 'token');
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
          "http://43.138.75.58:8080/api/guard-group/activity?groupId=${widget.arguments["groupId"]}");
      if (response.data["code"] == 200) {
        wardInfos = response.data["data"]["wardInfos"];
      } else {
        print(response);
        wardInfos = [];
      }
    } catch (e) {
      print(e);
      wardInfos = [];
    }

    //print("监护人成员列表：$wardInfos");

    allWardInfo.clear();

    // 生成监护人列表
    for (int i = 0; i < wardInfos.length; i++) {
      allWardInfo.add(WardInfo(
          accountId: wardInfos[i]["id"],
          nickname: wardInfos[i]["nickname"],
          image: wardInfos[i]["image"] ??
              "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png"));
      //print("监护人列表：${allWardInfo[i].nickname} ${allWardInfo[i].accountId}");
    }

    getWardInfoWidgets();
    refreshWardList = false;
  }

  // 选择日期弹窗
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      // https://stackoverflow.com/questions/50321182/how-to-customize-a-date-picker
      // 自定义日期选择的主题
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary:
                  Color.fromARGB(178, 250, 151, 205), // header background color
              onPrimary: Colors.black, // header text color
              onSurface: Color.fromARGB(255, 43, 43, 43), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color.fromARGB(255, 58, 58, 58), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        //print(selectedDate);
      });
    }
  }

  // 切换监护对象的抽屉
  void getWardInfoWidgets() {
    // 清空
    allWardInfoWidgets.clear();
    //
    allWardInfoWidgets.add(
      const SizedBox(
        height: 10,
      ),
    );
    // 群名
    allWardInfoWidgets.add(
      Text(
        widget.arguments["groupName"],
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontFamily: 'BalooBhai',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black),
      ),
    );

    // 群内成员
    for (int i = 0; i < allWardInfo.length; i++) {
      allWardInfoWidgets.add(ListTile(
        leading: Container(
          constraints: const BoxConstraints(
            maxHeight: 30,
            maxWidth: 40,
          ),
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
            ),
          ),
          child: Image.network(
            allWardInfo[i].image,
            //width: 40,
            //height: 30,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(allWardInfo[i].nickname),
        onTap: () {
          print("切换成员：${allWardInfo[i].nickname} ${allWardInfo[i].accountId}");
          Navigator.pop(context);
          setState(() {
            widget.arguments["nickname"] = allWardInfo[i].nickname;
            widget.arguments["accountId"] = allWardInfo[i].accountId;
          });
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日 ${getWeekDay(selectedDate)}";

    if (widget.arguments["groupId"] >= 0) {
      getGroupMemberListFromServer();
    }
    // print(
    //    "监护的首页rebuild: 个人：${widget.arguments["accountId"]} 群组：${widget.arguments["groupId"]}");

    return PopScope(
      canPop: widget.arguments["accountId"] == -1 ? false : true,
      child: Scaffold(
        // appbar
        appBar: getAppBar(
            widget.arguments["accountId"] == -1 ? 0 : 1,
            widget.arguments["accountId"] == -1 ? false : true,
            widget.arguments["groupName"].isEmpty
                ? widget.arguments["nickname"]
                : widget.arguments["groupName"]),

        // 切换监护对象
        endDrawer: widget.arguments["groupId"] >= 0
            ? Drawer(child: ListView(children: allWardInfoWidgets))
            : null,

        // 此页面
        body: Container(
          // white background
          color: Colors.white,
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(
                height: 10,
              ),

              // 监护对象
              widget.arguments["accountId"] >= 0
                  ? Text(
                      widget.arguments["nickname"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'BalooBhai',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )
                  : const SizedBox(),

              // 日期选择
              Container(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          //getFormattedDate(selectedDate),
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 20, fontFamily: "BalooBhai"),
                        ),
                        SizedBox(
                          width: 40,
                          child: TextButton(
                            onPressed: () => _selectDate(context),
                            child: const Icon(
                              Icons.calendar_month,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),

              // 今日血压
              MyBloodPressure(
                  accountId: widget.arguments["accountId"],
                  nickname: widget.arguments["nickname"],
                  date: selectedDate,
                  value: "112/95"),

              const SizedBox(
                height: 15,
              ),

              // 今日血糖
              MyBloodSugar(
                  accountId: widget.arguments["accountId"],
                  nickname: widget.arguments["nickname"],
                  date: selectedDate,
                  value: "8.8"),

              const SizedBox(
                height: 15,
              ),

              // 今日血脂
              MyBloodFat(
                  accountId: widget.arguments["accountId"],
                  nickname: widget.arguments["nickname"],
                  date: selectedDate,
                  value: "3.4"),

              const SizedBox(
                height: 15,
              ),

              // 运动
              MyActivities(
                  accountId: widget.arguments["accountId"],
                  date: selectedDate,
                  value: "45"),

              const SizedBox(
                height: 15,
              ),

              // 饮食
              MyDiet(
                  accountId: widget.arguments["accountId"],
                  date: selectedDate,
                  value: "1723"),

              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
