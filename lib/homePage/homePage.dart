import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pie_chart/pie_chart.dart';

import '../component/header/header.dart';
import '../other/other.dart';
import '../account/token.dart';
import '../component/titleDate/titleDate.dart';
import '../fooddiary/fooddiary.dart';

// 标题抽象类
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
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(children: [
              // 标题+图标
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              Image.asset(widget.icon, width: 25, height: 25),
            ]),
            // 今日的值
            Row(children: [
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(165, 51, 51, 1),
                ),
              ),
              const SizedBox(width: 5),

              // 单位
              Text(
                widget.unit,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              // 编辑按钮
              SizedBox(
                width: 20,
                height: 20,
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.edit),
                  iconSize: 25,
                  onPressed: () {
                    if (widget.arguments != null) {
                      // 有参数的跳转
                      Navigator.pushNamed(context, widget.route,
                              arguments: widget.arguments)
                          .then((value) => widget.refreshData());
                      setState(() {});
                    } else {
                      // 无参数的跳转
                      Navigator.pushNamed(context, widget.route)
                          .then((value) => widget.refreshData());
                      setState(() {});
                    }
                  },
                ),
              )
            ])
          ],
        ),
      ),
    );
  }
}

// 血压模块
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

    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(widget.accountId >= 0
          ? "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range?startDate=$requestDate&endDate=$requestDate&accountId=${widget.accountId}"
          : "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range?startDate=$requestDate&endDate=$requestDate");
      if (response.data["code"] == 200) {
        //print("获取血压数据成功");
        data = response.data["data"];
      } else {
        data = [];
      }
    } catch (e) {
      data = [];
    }

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
    return FutureBuilder(
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
                      child: SizedBox(
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
                  // 更多详情跳转按钮
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

// 血糖模块
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
        data = [];
      }
    } catch (e) {
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
                    child: SizedBox(
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

                // 更多详情跳转按钮
                GestureDetector(
                  onTap: () {
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

// 血脂模块
class MyBloodFat extends StatefulWidget {
  final int accountId;
  final String nickname;
  final String value;
  final DateTime date;
  const MyBloodFat({
    Key? key,
    required this.accountId,
    required this.nickname,
    required this.value,
    required this.date,
  }) : super(key: key);

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
        data = [];
      }
    } catch (e) {
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
                    SizedBox(
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

// 活动模块
class MyActivities extends StatefulWidget {
  final DateTime date;
  final int accountId;
  final String nickname;
  final String value;
  const MyActivities({
    Key? key,
    required this.accountId,
    required this.value,
    required this.date,
    required this.nickname,
  }) : super(key: key);

  @override
  State<MyActivities> createState() => _MyActivitiesState();
}

class _MyActivitiesState extends State<MyActivities> {
  List<dynamic> data = [];
  // 显示的数据
  List<int> dayData = [];
  List<int> monthData = [];
  List<int> exercisingData = [];
  List<int> stepCountData = [];
  List<int> durationData = [];
  int exercisingMins = 0;

  // 获取运动与步数数据
  Future<void> getDataFromServer() async {
    String requestStartDate = getFormattedDate(widget.date);
    String requestEndDate = getFormattedDate(widget.date);
    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";
    var arguments = {
      "startDate": requestStartDate,
      "endDate": requestEndDate,
    };

    if (widget.accountId >= 0) {
      arguments["accountId"] = (widget.accountId).toString();
    }

    response = await dio.get(
      "http://43.138.75.58:8080/api/sports/info",
      queryParameters: arguments,
    );
    if (response.data["code"] == 200) {
      data = response.data["data"];
    } else {
      data = [];
    }

    //print("======================图表数据=====================");
    //print(data);

    stepCountData = [];
    exercisingData = [];
    dayData = [];
    monthData = [];

    for (int i = 0; i < data.length; i++) {
      String date_ = data[i]["date"];
      int month_ = int.parse(date_.split("-")[1]);
      int day_ = int.parse(date_.split("-")[2]);

      stepCountData.add(data[i]["steps"]);
      exercisingData.add(data[i]["duration"]);
      exercisingMins = data[i]["duration"];
      dayData.add(day_);
      monthData.add(month_);
    }
  }

  void refreshData() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getDataFromServer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(children: [
              MyTitle(
                title: "今日活动",
                icon: "assets/icons/exercising.png",
                value: exercisingMins.toString(),
                unit: "分钟",
                route: "/homePage/Activity/Edit",
                arguments: {
                  "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                  "nickname":
                      widget.accountId >= 0 ? widget.nickname : "TriGuard",
                  "date": widget.date,
                  "activityDataId": -1,
                },
                refreshData: refreshData,
              ),

              const SizedBox(
                height: 5,
              ),

              // 活动图表
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
                    child: Echarts(
                      extraScript: '''
                  var month = $monthData;
                  var day = $dayData;
                  
''',
                      option: '''
              {
                animation:false,

                title: {
                  text: '活动',
                  top:'5%',
                  left:'10',
                },

                legend: {
                  data: ['步数', '运动时长'],
                  top:'6%',
                  left:'70',
                },

                  grid: {
                  left: '3%',
                  right: '4%',
                  bottom: '5%',
                  top: '30%',
                  containLabel: true,
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

                yAxis:[
                  { 
                    type: 'value',
                    name: '运动时长',
                    axisLabel:{
                      textStyle: {
                          color: '#000000'
                      },
                    },
                    splitLine:{       //y轴刻度线
                      show:false
                    }, 
                  },

                  {
                    type: 'value',
                    name: '步数',
                    
                    axisLabel:{
                      textStyle: {
                          color: '#000000'
                      },
                    },
                  },
                ],

                series: [{
                  name: '步数',
                  data: $stepCountData,
                  type: 'bar',
                  //barWidth: '25%',
                  barWidth: ${stepCountData.length} < 4? 50 : '60%',
                  //barGap: '20%',
                  yAxisIndex: 1,
                  smooth: true,
                  tooltip: {
                    valueFormatter: function (value) {
                      return value + ' 步';
                    }
                  },
                },
                {
                  name: '运动时长',
                  data: $exercisingData,
                  type: 'line',
                 
                  yAxisIndex: 0,
                  tooltip: {
                    valueFormatter: function (value) {
                      return value + ' 分钟';
                    }
                  },
                  smooth: true
                },
                ]
              }
            ''',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    //Navigator.pushNamed(context, "/homePage/Activity/Details");

                    var args = {
                      "accountId": widget.accountId,
                      "nickname": widget.nickname,
                      "date": widget.date,
                    };
                    Navigator.pushNamed(context, "/homePage/Activity/Details",
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
            return Column(children: [
              MyTitle(
                title: "今日活动",
                icon: "assets/icons/exercising.png",
                value: "-",
                unit: "分钟",
                route: "/homePage/Activity/Edit",
                arguments: {
                  "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                  "nickname":
                      widget.accountId >= 0 ? widget.nickname : "TriGuard",
                  "date": widget.date,
                  "activityDataId": -1,
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
        });
  }
}

class MyDiet extends StatefulWidget {
  final DateTime date;
  final int accountId;
  final String value;
  final String nickname;
  const MyDiet(
      {Key? key,
      required this.accountId,
      required this.value,
      required this.nickname,
      required this.date})
      : super(key: key);

  @override
  State<MyDiet> createState() => _MyDietState();
}

class _MyDietState extends State<MyDiet> {
  Map<String, double> dataMap = {"早餐": 100, "午餐": 100, "晚餐": 100, "其他": 100};
  int totalCalories = 0;
  var categoryName = ["全部", "早餐", "午餐", "晚餐", "其他"];
  int curUserId = -1;

  void refreshData() {
    setState(() {});
  }

  // 获取格式化后的日期 2023-8-1 => 2023-08-01
  String getFormattedDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Meal API
  void getAccountId() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/account/info',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        curUserId = response.data["data"]["id"];
      }
    } catch (e) {/**/}
  }

  // Meal API
  void getSpecificMealInfo(int ind) async {
    var token = await storage.read(key: 'token');
    var curDate = getFormattedDate(widget.date);
    var category = categoryName[ind];

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          widget.accountId == -1
              ? 'http://43.138.75.58:8080/api/meal/get?date=$curDate&category=$category'
              : 'http://43.138.75.58:8080/api/meal/get?date=$curDate&category=$category&accountId=${widget.accountId}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        if (ind == 0) {
          setState(() {
            totalCalories = response.data["data"]["calories"];
          });
        } else {
          setState(() {
            dataMap[category] =
                double.parse(response.data["data"]["calories"].toString());
          });
        }
      } else {
        if (ind == 0) {
          setState(() {
            totalCalories = 0;
          });
        } else {
          setState(() {
            dataMap[category] = 0;
          });
        }
      }
    } catch (e) {/**/}
  }

  @override
  void initState() {
    super.initState();
    getAccountId();
    getSpecificMealInfo(0);
    getSpecificMealInfo(1);
    getSpecificMealInfo(2);
    getSpecificMealInfo(3);
    getSpecificMealInfo(4);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MyTitle(
        title: "今日饮食",
        icon: "assets/icons/meal.png",
        value: totalCalories.toString(),
        unit: "千卡",
        route: "/homePage/BloodPressure/Edit",
        refreshData: refreshData,
      ),
      const SizedBox(
        height: 5,
      ),
      Stack(alignment: Alignment.centerRight, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(45, 30, 45, 30),
          width: MediaQuery.of(context).size.width * 0.85,
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
          child: PieChart(
            dataMap: dataMap,
            initialAngleInDegree: 290,
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: false,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            var passId = widget.accountId == -1 ? curUserId : widget.accountId;
            var arguments = {
              "accountId": passId,
              "isOwner": widget.accountId == -1,
              "date": widget.date,
              "nickname": widget.nickname,
            };
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FoodDiary(
                          arguments: arguments,
                        ))).then((value) {
              refreshData();
            });
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
        wardInfos = [];
      }
    } catch (e) {
      wardInfos = [];
    }

    allWardInfo.clear();

    // 生成监护人列表
    for (int i = 0; i < wardInfos.length; i++) {
      allWardInfo.add(WardInfo(
          accountId: wardInfos[i]["id"],
          nickname: wardInfos[i]["nickname"],
          image: wardInfos[i]["image"] ??
              "https://www.renwu.org.cn/wp-content/uploads/2020/12/image-33.png"));
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(
                  'http://43.138.75.58:8080/static/${allWardInfo[i].image}'),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: const Color.fromARGB(74, 104, 103, 103),
              width: 1,
            ),
          ),
        ),
        title: Text(allWardInfo[i].nickname),
        onTap: () {
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
                alignment: Alignment.center,
                color: Colors.transparent,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    formattedDate,
                    style:
                        const TextStyle(fontSize: 20, fontFamily: "BalooBhai"),
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
                  nickname: widget.arguments["nickname"],
                  date: selectedDate,
                  value: "45"),

              const SizedBox(
                height: 15,
              ),

              // 饮食
              MyDiet(
                  accountId: widget.arguments["accountId"],
                  nickname: widget.arguments["nickname"],
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
