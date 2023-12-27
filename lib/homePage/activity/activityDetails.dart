import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../account/token.dart';
import '../../component/header/header.dart';
import '../../component/titleDate/titleDate.dart';
import '../../other/other.dart';
import '../bloodPressure/bloodPressureEdit.dart'
    hide armButtonTypes, feelingButtonTypes;

const List<String> method = <String>['手机号', '邮箱'];
typedef UpdateDateCallback = void Function(DateTime newDate);
typedef UpdateDaysCallback = void Function(String newDays);
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

// 图表天数选择
// ignore: must_be_immutable
class GraphDayDropdownButton extends StatefulWidget {
  //final UpdateDateCallback updateDate;
  final VoidCallback updateView;
  final UpdateDaysCallback updateDays;
  String? selectedValue = '最近7天';
  //const GraphDayDropdownButton({Key? key, required this.updateDate}):super(key: key);
  GraphDayDropdownButton(
      {Key? key,
      required this.updateView,
      required this.updateDays,
      this.selectedValue})
      : super(key: key);
  @override
  State<GraphDayDropdownButton> createState() => _GraphDayDropdownButtonState();

  String getSelectedDaysValue() {
    return selectedValue!;
  }
}

class _GraphDayDropdownButtonState extends State<GraphDayDropdownButton> {
  final List<String> items = [
    '最近3天',
    '最近7天',
    '最近1个月',
    '最近3个月',
    '当前的天',
    '当前的月',
  ];

  @override
  Widget build(BuildContext context) {
    //print("血压图表天数显示刷新 ${widget.selectedValue}");
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "显示：",
          style: TextStyle(fontSize: 15, fontFamily: "BalooBhai"),
        ),

        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text(
              '最近7天',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ))
                .toList(),
            value: widget.selectedValue,
            onChanged: (String? value) {
              setState(() {
                widget.selectedValue = value;
                //print("更改为 ${widget.selectedValue}");
                //widget.updateView();
                widget.updateDays(widget.selectedValue!);
              });
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              width: 140,
              // decoration:
              //     BoxDecoration(borderRadius: BorderRadius.circular(10)),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
          ),
        ),
        // DatePicker(),
      ],
    );
  }
}

// 血压图表
// ignore: must_be_immutable
class BloodPressureGraph extends StatefulWidget {
  final int accountId;
  DateTime date;
  final String selectedDays;
  final UpdateDateCallback updateDate;
  BloodPressureGraph(
      {Key? key,
      required this.accountId,
      required this.date,
      required this.selectedDays,
      required this.updateDate})
      : super(key: key);

  @override
  State<BloodPressureGraph> createState() => _BloodPressureGraphState();
}

class _BloodPressureGraphState extends State<BloodPressureGraph> {
  // 从后端请求得到的原始数据
  List<dynamic> data = [];
  List<dynamic> exerciseDataList = [];
  List<dynamic> stepDataList = [];

  // 显示的数据
  List<int> dayData = [];
  List<int> monthData = [];
  List<int> sbpData = [];
  List<int> dbpData = [];
  List<int> heartRateData = [];
  List<int> exercisingData = [];
  List<int> stepCountData = [];
  List<int> durationData = [];

  // 获取运动与步数数据
  Future<void> getDataListFromServer() async {
    String requestStartDate = getStartDate(widget.date, widget.selectedDays);
    String requestEndDate = getFormattedDate(widget.date);
    //String endDate = getFormattedDate(widget.date);
    if (widget.selectedDays == "当前的月") {
      requestEndDate = getFormattedDate(
          DateTime(widget.date.year, widget.date.month + 1, 0));
    }

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
      print(response);
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
      dayData.add(day_);
      monthData.add(month_);
    }

    //setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print('血压图表更新：${widget.date}');
    //widget.updateDate(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    //print('血压折线图更新build：${widget.date}，天数：${widget.selectedDays}');

    return FutureBuilder(
      future: getDataListFromServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return UnconstrainedBox(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.35,
              alignment: Alignment.centerRight,
              child: Container(
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
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
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      width: dayData.length <= 5
                          ? MediaQuery.of(context).size.width * 0.85
                          : dayData.length * 65, //325
                      height: MediaQuery.of(context).size.height * 0.45,

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
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          //return CircularProgressIndicator();
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.pink, size: 25),
          );
        }
      },
    );
  }
}

// 日期选择器 与 血压图表 组件
// ignore: must_be_immutable
class BloodPressureGraphWidget extends StatefulWidget {
  final int accountId;
  DateTime date;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  final UpdateDaysCallback updateDays;
  String selectedDays = "最近7天";
  BloodPressureGraphWidget(
      {Key? key,
      required this.date,
      required this.accountId,
      required this.selectedDays,
      required this.updateView,
      required this.updateDate,
      required this.updateDays})
      : super(key: key);

  @override
  State<BloodPressureGraphWidget> createState() =>
      _BloodPressureGraphWidgetState();
}

class _BloodPressureGraphWidgetState extends State<BloodPressureGraphWidget> {
  String selectedDays2 = "最近7天";

  @override
  void initState() {
    super.initState();
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //print('血压图表组件更新（日期与图表） ${widget.date}, ${widget.selectedDays}');

    /* BloodPressureGraph graph =  BloodPressureGraph(
      date: widget.date,
      selectedDays: widget.selectedDays,
      updateDate: widget.updateDate,
    ); */

    GraphDayDropdownButton selectDaysButton = GraphDayDropdownButton(
      updateView: widget.updateView,
      updateDays: widget.updateDays,
      //selectedValue: selectedDays2,
      selectedValue: widget.selectedDays,
    );

    return UnconstrainedBox(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(children: [
          Column(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //GraphDayDropdownButton(updateView: widget.updateView),
              const SizedBox(height: 5),
              DatePicker2(date: widget.date, updateDate: widget.updateDate),
              selectDaysButton,
              const SizedBox(height: 5),
            ],
          ),
          //graph,
          BloodPressureGraph(
            accountId: widget.accountId,
            date: widget.date,
            //selectedDays: selectedDays2,
            selectedDays: widget.selectedDays,
            updateDate: widget.updateDate,
          ),
        ]),
      ),
    );
  }
}

// 只展示 （有备注）
class BloodPressureData extends StatefulWidget {
  final int accountId;
  final String nickname;
  final int id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int duration;
  final int type;

  final int feeling;
  final String remark;

  final VoidCallback updateData;

  const BloodPressureData(
      {Key? key,
      required this.accountId,
      required this.nickname,
      required this.id,
      required this.date,
      required this.startTime,
      required this.endTime,
      required this.duration,
      required this.type,
      required this.feeling,
      required this.remark,
      required this.updateData})
      : super(key: key);

  @override
  State<BloodPressureData> createState() => _BloodPressureDataState();
}

class _BloodPressureDataState extends State<BloodPressureData> {
  List<String> armButtonTypes = ["左手", "右手", "不选"];
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
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
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

          // Edit
          GestureDetector(
            onTap: () {
              print("编辑 ${widget.id}");
              // accountId, nickname, date, activityDataId
              var args = {
                "accountId": widget.accountId,
                "nickname": widget.nickname,
                "date": widget.date,
                "activityDataId": widget.id,
              };
              Navigator.pushNamed(context, '/homePage/Activity/Edit',
                      arguments: args)
                  .then((_) {
                //print("哈哈哈");
                widget.updateData();
              });
              /*  Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Edit(
                    arguments: {
                      "bpDataId": widget.id,
                      "date": widget.date,
                      "prevPage": 1,
                    },
                  ),
                ),
              ).then((_) {
                //print("哈哈哈");
                widget.updateData();
              }); */
            },
            child: Container(
              child: Image.asset(
                "assets/icons/pencil.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 当日没有数据 可以跳转至添加数据页面
class NoDataListWidget extends StatefulWidget {
  final int accountId;
  final String nickname;
  final DateTime date;
  final VoidCallback updateData;

  const NoDataListWidget({
    Key? key,
    required this.accountId,
    required this.nickname,
    required this.date,
    required this.updateData,
  }) : super(key: key);

  @override
  State<NoDataListWidget> createState() => _NoDataListWidgetState();
}

class _NoDataListWidgetState extends State<NoDataListWidget> {
  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 195,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "暂无数据",
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: "BalooBhai",
                  color: Color.fromRGBO(48, 48, 48, 1)),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                print("添加数据");
                var args = {
                  "accountId": widget.accountId,
                  "nickname": widget.nickname,
                  "date": widget.date,
                  "activityDataId": -1,
                };
                Navigator.pushNamed(context, '/homePage/Activity/Edit',
                        arguments: args)
                    .then((_) {
                  //print("哈哈哈");
                  widget.updateData();
                });
              },
              child: Container(
                height: 20,
                width: 20,
                child:
                    Image.asset("assets/icons/add.png", width: 20, height: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 展示所有
// ignore: must_be_immutable
class BloodPressureDataList extends StatefulWidget {
  final int accountId;
  final String nickname;
  final VoidCallback updateData;
  DateTime date;
  int showMore;
  BloodPressureDataList({
    Key? key,
    required this.accountId,
    required this.nickname,
    required this.date,
    required this.showMore,
    required this.updateData,
  }) : super(key: key);

  @override
  State<BloodPressureDataList> createState() => _BloodPressureDataListState();
}

class _BloodPressureDataListState extends State<BloodPressureDataList> {
  List<Map> data2 = [];
  List<dynamic> data = [];
  List<Widget> dataWidget = [];
  int length = 1;

  Future<void> getDataFromServer() async {
    String requestDate = getFormattedDate(widget.date);

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

    if (widget.accountId >= 0) {
      arguments["accountId"] = (widget.accountId).toString();
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
      print(response);
      data = [];
    }
    // print("===============运动数据列表=====================");
    //print(data);
  }

  @override
  void initState() {
    // TODO: 从后端请求数据

    super.initState();
    /* getDataFromServer().then((_) {
      getdataWidgetList();
    }); */
  }

  void getdataWidgetList() {
    dataWidget = [];

    // 如果data[i]["endTime"] == null ，则剔除这一项
    for (int i = 0; i < data.length; i++) {
      if (data[i]["endTime"] == null) {
        data.removeAt(i);
        i--;
      }
    }

    //TODO 要考虑到当天没有数据的情况

    // 收起时就显示一个
    if (widget.showMore == 1) {
      length = data.length;
    } else {
      length = 1;
    }

    if (data.isEmpty) {
      //dataWidget.add(NoDataWidget());
      dataWidget.add(NoDataListWidget(
        accountId: widget.accountId,
        nickname: widget.nickname,
        date: widget.date,
        updateData: widget.updateData,
      ));
      length = 1;
      return;
    }

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

      dataWidget.add(UnconstrainedBox(
        child: BloodPressureData(
          accountId: widget.accountId,
          nickname: widget.nickname,
          id: id_,
          date: widget.date,
          startTime: startTime,
          endTime: endTime,
          duration: duration,
          type: type,
          feeling: feelings,
          remark: remark,
          updateData: widget.updateData,
        ),
      ));
    }

    if (data.isEmpty) {
      dataWidget.add(const NoDataWidget());
    }

    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print(
        "-----------------------------------------------------------------------");

    return FutureBuilder(
      future: getDataFromServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          getdataWidgetList();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            height: length == 1 ? 195 : 195.0 * length,
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              child: Column(
                children: dataWidget,
              ),
            ),
          );
        } else {
          return UnconstrainedBox(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 100,
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.pink, size: 25),
              ),
            ),
          );
        }
      },
    );
  }
}

//展示列表数据接口
// ignore: must_be_immutable
class BloodPressureDataWidget extends StatefulWidget {
  final int accountId;
  final String nickname;
  DateTime date;
  final VoidCallback updateView;
  final VoidCallback updateData;
  BloodPressureDataWidget({
    Key? key,
    required this.accountId,
    required this.nickname,
    required this.date,
    required this.updateView,
    required this.updateData,
  }) : super(key: key);

  @override
  State<BloodPressureDataWidget> createState() =>
      _BloodPressureDataWidgetState();
}

class _BloodPressureDataWidgetState extends State<BloodPressureDataWidget> {
  int showMore = 0;
  List<String> buttonText = ["展开", "收起"];
  List<String> buttonIcon = [
    "assets/icons/down-arrow.png",
    "assets/icons/up-arrow.png"
  ];
  late Widget dataWidgetList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //dataWidgetList = BloodPressureDataList(date: widget.date, showMore: 1);
  }

  @override
  Widget build(BuildContext context) {
    dataWidgetList = BloodPressureDataList(
      accountId: widget.accountId,
      nickname: widget.nickname,
      date: widget.date,
      showMore: showMore,
      updateData: widget.updateData,
    );
    print('血压展示列表数据更新: ${widget.date}');

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          children: [
            // 当日血压数据 与 展开收起按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PageTitle(
                  title: "当日血压数据",
                  icons: "assets/icons/list.png",
                  fontSize: 18,
                ),

                //展开按钮 -> 显示当天所有的血压数据
                GestureDetector(
                  onTap: () {
                    if (showMore == 0) {
                      //print("展开");
                      showMore = 1;
                    } else {
                      //  print("收起");
                      showMore = 0;
                    }

                    // TODO
                    /* if (widget.date != DateTime(2022, 1, 1)) {
                      widget.date = DateTime(2022, 1, 1);
                    } */
                    /* setState(() {
                      //widget.date = DateTime(2022, 1, 1);
                    }); */
                    //widget.updateView();
                    setState(() {
                      //dataWidgetList = BloodPressureDataList(
                      //date: widget.date, showMore: showMore);
                    });
                  },
                  child: Container(
                    //alignment: Alignment.bottomCenter,
                    // color: Colors.yellow,
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Text(
                          buttonText[showMore],
                          style: const TextStyle(
                              fontSize: 15,
                              fontFamily: "BalooBhai",
                              color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Image.asset(buttonIcon[showMore],
                            width: 15, height: 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            ///BloodPressureDataList(date: widget.date, showMore: showMore),
            dataWidgetList,
          ],
        ),
      ),
    );
  }
}

// 统计血压次数图表
class BloodPressureStaticGraph extends StatefulWidget {
  final DateTime date;
  final String selectedDays;
  final String seriesName;
  final UpdateDateCallback updateDate;
  final List<int> dataTimes;
  final int type;
  const BloodPressureStaticGraph({
    Key? key,
    required this.date,
    required this.selectedDays,
    required this.updateDate,
    required this.dataTimes,
    required this.seriesName,
    required this.type,
  }) : super(key: key);

  @override
  State<BloodPressureStaticGraph> createState() =>
      _BloodPressureStaticGraphState();
}

class _BloodPressureStaticGraphState extends State<BloodPressureStaticGraph> {
  List<String> labelExercising = ["少于30", "30-60", "60-120", "大于120"];
  List<String> labelSteps = ["少于500", "500-1000", "1000-3000", "大于3000"];

  Future<Widget> getEchart() async {
    List<String> label = widget.type == 0 ? labelExercising : labelSteps;
    return Echarts(option: '''
        {

          tooltip: {
            trigger: 'item'
          },
          legend: {
            orient: 'vertical',
            left: '2%',
            top: '20%'
          },
          series: [
            {
              name: '${widget.seriesName}',
              type: 'pie',
              radius: '60%',
              center: ['65%', '50%'], //第一个是左右，第二个上下
              data: [
               // { value:  ${widget.dataTimes[0]}, name: '偏高' },
              //  { value:  ${widget.dataTimes[1]}, name: '正常' },
               // { value:  ${widget.dataTimes[2]}, name: '偏低' },
               // { value:  ${widget.dataTimes[3]}, name: '异常' },
               { value:  ${widget.dataTimes[0]}, name: '${label[0]}' },
                { value:  ${widget.dataTimes[1]}, name:  '${label[1]}'  },
                { value:  ${widget.dataTimes[2]}, name:  '${label[2]}' },
                { value:  ${widget.dataTimes[3]}, name:  '${label[3]}'  },
              ],
              emphasis: {
                itemStyle: {
                  shadowBlur: 10,
                  shadowOffsetX: 0,
                  shadowColor: 'rgba(0, 0, 0, 0.5)'
                }
              },

              labelLine:{  
                normal:{  
                  length: 10, // 修改引导线第一段的长度
                  length2: 5, // 修改引导线第二段的长度
                },
              },
            }
          ]
        }
        ''');
  }

  @override
  Widget build(BuildContext context) {
    //print("血压统计饼图更新 ${widget.date} ${widget.selectedDays}");

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.25,
      alignment: Alignment.center,

      // 等待图表异步加载
      child: FutureBuilder(
          future: getEchart(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }
}

// 血压的基础统计组件
// ignore: must_be_immutable
class BloodPressureStaticWidget extends StatefulWidget {
  bool refreshData = true;
  final DateTime date;
  final String selectedDays;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  final int accountId;

  BloodPressureStaticWidget({
    Key? key,
    required this.refreshData,
    required this.date,
    required this.selectedDays,
    required this.updateView,
    required this.updateDate,
    required this.accountId,
  }) : super(key: key);

  @override
  State<BloodPressureStaticWidget> createState() =>
      _BloodPressureStaticWidgetState();
}

class _BloodPressureStaticWidgetState extends State<BloodPressureStaticWidget> {
  String title = "";
  int pageNum = 0;

  List<dynamic> data = [];
  List<String> seriesName = ["运动时长", "步数"];
  List<int> SBPTimes = [0, 0, 0, 0];
  List<int> DBPTimes = [0, 0, 0, 0];
  List<int> heartRateTimes = [0, 0, 0, 0];
  List<int> stepTimes = [0, 0, 0, 0];
  List<int> exerciseTimes = [0, 0, 0, 0];
  List<int> total = [0, 0, 0];
  List<int> avg = [];
  int averageSbp = 0;
  int averageDbp = 0;
  int totalTimes = 0;
  int averageHr = 0;

  Future<void> getDataFromServer0() async {
    String requestStartDate = getStartDate(widget.date, widget.selectedDays);
    String requestEndDate = getFormattedDate(widget.date);
    if (widget.selectedDays == "当前的月") {
      requestEndDate = getFormattedDate(
          DateTime(widget.date.year, widget.date.month + 1, 0));
    }
    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    var params = {
      "startDate": requestStartDate,
      "endDate": requestEndDate,
    };

    if (widget.accountId != -1) {
      params["accountId"] = widget.accountId.toString();
    }
    // List<dynamic> testData = [];

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/sports/exercise/filter",
          data: params);

      if (response.data["code"] == 200) {
        //print("获取血压数据成功（饼图）");
        //print(response.data["data"]);
        //data = response.data["data"]["countedDataList"];
        // print("?????????????????????????????????");
        //print(response.data["data"]["countedDataList"]);
        data = response.data["data"]["countedDataList"];
        //bpdata = response.data["data"];
      } else {
        print(response);
        data = [];
      }
    } catch (e) {
      print(e);
      data = [];
    }

    //return;

    print("================================================================");
    print(data);

    stepTimes = [];
    exerciseTimes = [];

    SBPTimes = [];
    DBPTimes = [];
    heartRateTimes = [];

    avg = [];
    total = [];
    //{name: steps, less: 7, fewer: 0, medium: 1, more: 0},
    //{name: exercise, less: 6, fewer: 1, medium: 0, more: 1}

    /* [
    {name: sbp, min: 88, max: 111, avg: 101, high: 0, medium: 8, low: 1, abnormal: 0, count: 9}, 
    {name: dbp, min: 70, max: 111, avg: 83, high: 5, medium: 3, low: 0, abnormal: 1, count: 9}, 
    {name: heart_rate, min: 72, max: 108, avg: 91, high: 1, medium: 8, low: 0, abnormal: 0, count: 9}] */

    for (int i = 0; i < data.length; i++) {
      if (data[i]["name"] == "steps") {
        stepTimes.add(data[i]["less"]);
        stepTimes.add(data[i]["fewer"]);
        stepTimes.add(data[i]["medium"]);
        stepTimes.add(data[i]["more"]);
      } else if (data[i]["name"] == "exercise") {
        exerciseTimes.add(data[i]["less"]);
        exerciseTimes.add(data[i]["fewer"]);
        exerciseTimes.add(data[i]["medium"]);
        exerciseTimes.add(data[i]["more"]);
      }
    }

    for (int i = 0; i < stepTimes.length; i++) {
      totalTimes += stepTimes[i];
    }

    /* for (int i = 0; i < exerciseTimes.length; i++) {
      totalTimes += exerciseTimes[i];
    } */

    /*  print("SBPTimes: $SBPTimes");
    print("DBPTimes: $DBPTimes");
    print("heartRateTimes: $heartRateTimes");
    print("total: $total");
    print("avg: $avg"); */
  }

  Future<void> getDataFromServer() async {
    await getDataFromServer0();

    String requestStartDate = getStartDate(widget.date, widget.selectedDays);
    String requestEndDate = getFormattedDate(widget.date);
    if (widget.selectedDays == "当前的月") {
      requestEndDate = getFormattedDate(
          DateTime(widget.date.year, widget.date.month + 1, 0));
    }
    // 提取登录获取的token
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    var params = {
      "startDate": requestStartDate,
      "endDate": requestEndDate,
    };

    if (widget.accountId != -1) {
      params["accountId"] = widget.accountId.toString();
    }

    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/blood-pressure/get-by-filter",
        /*  data: {
          "startDate": requestStartDate,
          "endDate": requestEndDate,
        }, */
        data: params,
      );
      if (response.data["code"] == 200) {
        //print("获取血压数据成功（饼图）");
        //print(response.data["data"]);
        data = response.data["data"]["countedDataList"];
        //bpdata = response.data["data"];
      } else {
        print(response);
        data = [];
      }
    } catch (e) {
      print(e);
      data = [];
    }

    //print(data);

    SBPTimes = [];
    DBPTimes = [];
    heartRateTimes = [];
    avg = [];
    total = [];

    /* [
    {name: sbp, min: 88, max: 111, avg: 101, high: 0, medium: 8, low: 1, abnormal: 0, count: 9}, 
    {name: dbp, min: 70, max: 111, avg: 83, high: 5, medium: 3, low: 0, abnormal: 1, count: 9}, 
    {name: heart_rate, min: 72, max: 108, avg: 91, high: 1, medium: 8, low: 0, abnormal: 0, count: 9}] */

    for (int i = 0; i < data.length; i++) {
      if (i == 0) {
        SBPTimes.add(data[i]["high"]);
        SBPTimes.add(data[i]["medium"]);
        SBPTimes.add(data[i]["low"]);
        SBPTimes.add(data[i]["abnormal"]);
      } else if (i == 1) {
        DBPTimes.add(data[i]["high"]);
        DBPTimes.add(data[i]["medium"]);
        DBPTimes.add(data[i]["low"]);
        DBPTimes.add(data[i]["abnormal"]);
      } else if (i == 2) {
        heartRateTimes.add(data[i]["high"]);
        heartRateTimes.add(data[i]["medium"]);
        heartRateTimes.add(data[i]["low"]);
        heartRateTimes.add(data[i]["abnormal"]);
      }
      total.add(data[i]["count"]);
      avg.add(data[i]["avg"]);
    }
  }

  @override
  void initState() {
    // TODO: 从后端请求数据
    super.initState();
    SBPTimes = DBPTimes = [0, 0, 0, 0];
    heartRateTimes = [0, 0, 0, 0];
    avg = [0, 0, 0];
    total = [0, 0, 0];
    totalTimes = 0;
    averageSbp = 0;
    averageDbp = 0;
    averageHr = 0;
  }

  List<int> getTypeData(int pageNum) {
    // SBP
    if (pageNum == 0) {
      return exerciseTimes;
    }
    // DBP
    else if (pageNum == 1) {
      return stepTimes;
    }
    return [];
  }

  int getTimesData(int pageNum, int type) {
    // SBP
    if (pageNum == 0) {
      return exerciseTimes[type];
    }
    // DBP
    else if (pageNum == 1) {
      return stepTimes[type];
    }
    return 0;
  }

  void setTitle() {
    if (widget.selectedDays == "当前的天") {
      title = "${widget.date.year}年 ${widget.date.month}月 ${widget.date.day}日";
    } else if (widget.selectedDays == "当前的月") {
      title = "${widget.date.year}年 ${widget.date.month}月";
    } else {
      title = widget.selectedDays;
    }
  }

  Widget getDataStaticWidget() {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.start,
      //crossAxisAlignment: CrossAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 标题（舒张压，收缩压，心率）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(seriesName[pageNum],
                    style: const TextStyle(
                        fontSize: 16,
                        fontFamily: "BalooBhai",
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  width: 2,
                ),
                Image.asset(
                  pageNum == 0
                      ? "assets/icons/exercising2.png"
                      : "assets/icons/footprints.png",
                  height: 15,
                  width: 15,
                ),
              ],
            ),

            const SizedBox(
              height: 5,
            ),

            // 日期
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "BalooBhai",
                  fontWeight: FontWeight.bold),
            ),

            // 总次数
            Row(
              //crossAxisAlignment: CrossAxisAlignment.,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '总次数：',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: "BalooBhai",
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  //'${totalTimes} ',
                  totalTimes.toString(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontFamily: "BalooBhai",
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  ' 次',
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: "Blinker",
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        // 分割线
        Container(
          height: 2,
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 138, 138, 138),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.center,
        ),

        const SizedBox(
          height: 10,
        ),

        // 血压平均值
        /* Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              // pageNum == 0 ? '血压平均值：' : '心率平均值：',
              //'${seriesName[pageNum]}平均值 ',
              "平均值：",
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: "BalooBhai",
                  fontWeight: FontWeight.bold),
            ),
            Text(
              //pageNum == 0 ? '${averageSbp} / ${averageDbp} ' : '${averageHr} ',
              '${avg[pageNum]} ',
              style: const TextStyle(
                  fontSize: 18,
                  fontFamily: "BalooBhai",
                  fontWeight: FontWeight.bold),
            ),
            Text(
              pageNum == 0 ? 'mmHg' : '次/分',
              style: const TextStyle(
                  fontSize: 12,
                  fontFamily: "Blinker",
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
 */
        // 次数统计
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              //mainAxisAlignment: MainAxisAlignment.centerLeft,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 偏低
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.,
                  children: [
                    const Text(
                      '偏低：',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      /* pageNum == 0
                          ? '${bloodPressureTimes[0]} '
                          : '${heartRateTimes[0]} ', */
                      '${getTimesData(pageNum, 0)} ',
                      style: const TextStyle(
                          fontSize: 18,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '次',
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Blinker",
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // 正常
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.,
                  children: [
                    const Text(
                      '正常：',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      /* pageNum == 0
                          ? '${bloodPressureTimes[1]} '
                          : '${heartRateTimes[1]} ', */
                      '${getTimesData(pageNum, 1)} ',
                      style: const TextStyle(
                          fontSize: 18,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '次',
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Blinker",
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 偏高
                Row(
                  children: [
                    const Text(
                      '偏高：',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      /* pageNum == 0
                          ? '${bloodPressureTimes[2]} '
                          : '${heartRateTimes[2]} ', */
                      '${getTimesData(pageNum, 2)} ',
                      style: const TextStyle(
                          fontSize: 18,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '次',
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Blinker",
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // 异常
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.,
                  children: [
                    const Text(
                      '异常：',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      /* pageNum == 0
                          ? '${bloodPressureTimes[3]} '
                          : '${heartRateTimes[3]} ', */
                      '${getTimesData(pageNum, 3)} ',
                      style: const TextStyle(
                          fontSize: 18,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '次',
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Blinker",
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // 血压/心率图表
        BloodPressureStaticGraph(
          date: widget.date,
          selectedDays: widget.selectedDays,
          seriesName: seriesName[pageNum],
          dataTimes: getTypeData(pageNum),
          updateDate: widget.updateDate,
          type: pageNum,
        ),
      ],
    );
  }

  Widget getPageNum() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: pageNum == 0 ? Colors.blue : Colors.grey,
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
              color: pageNum == 1 ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  Widget getDataStaticWholeWidget() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          children: [
            // 标题
            const PageTitle(
              title: "运动时长与步数统计",
              icons: "assets/icons/graph.png",
              fontSize: 18,
            ),

            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // 0 -> blood pressure
                    // 1 -> heart rate
                    // 2 ->  heart rate

                    //不用重新获取数据
                    widget.refreshData = false;

                    if (details.primaryDelta! > 15) {
                      pageNum -= 1;
                      if (pageNum < 0) {
                        pageNum = 1;
                      }

                      //print("右滑 页面左移动");

                      setState(() {});
                    } else if (details.primaryDelta! < -15) {
                      pageNum += 1;
                      // print("左滑 页面右移动");
                      if (pageNum > 1) {
                        pageNum = 0;
                      }
                      setState(() {});
                    }
                  },

                  // 血压统计图表文字
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    //height: MediaQuery.of(context).size.height * 0.55,
                    //height: 300,
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
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // left and right button
                          /* Container(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print("左！！！！！！！！！！");
                                    widget.refreshData = false;
                                    pageNum -= 1;
                                    if (pageNum < 0) {
                                      pageNum = 1;
                                    }
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset(
                                      "assets/icons/left-arrow.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print("右！！！！！！！！！！");
                                    widget.refreshData = false;
                                    pageNum += 1;
                                    if (pageNum > 1) {
                                      pageNum = 0;
                                    }
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset(
                                      "assets/icons/right-arrow.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                           */
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            firstChild: getDataStaticWidget(),
                            secondChild: getDataStaticWidget(),
                            crossFadeState: pageNum == 0
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                getPageNum(),
              ],
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //print('血压饼图pie更新build：${widget.date}，天数：${widget.selectedDays}');

    // 需要重新获取数据
    if (widget.refreshData) {
      widget.refreshData = false;
      return FutureBuilder(
          future: getDataFromServer0(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              setTitle();

              return getDataStaticWholeWidget();
            } else {
              //return CircularProgressIndicator();
              return UnconstrainedBox(
                child: Column(
                  children: [
                    //标题
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: const PageTitle(
                        title: "血压心率统计",
                        icons: "assets/icons/graph.png",
                        fontSize: 18,
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        //child: CircularProgressIndicator(),
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.pink, size: 25),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              );
            }
          });
    }

    // 左右滑动，不必重新获取数据
    /* getDataFromServer0();
    setTitle();
    return getDataStaticWholeWidget(); */

    return FutureBuilder(
        future: getDataFromServer0(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            setTitle();

            return getDataStaticWholeWidget();
          } else {
            setTitle();
            return getDataStaticWholeWidget();
          }
        });
  }
}

// 更多数据按钮
class BloodPressureMoreInfoButton extends StatefulWidget {
  final int accountId;
  final String nickname;
  const BloodPressureMoreInfoButton({
    Key? key,
    required this.accountId,
    required this.nickname,
  }) : super(key: key);

  @override
  State<BloodPressureMoreInfoButton> createState() =>
      _BloodPressureMoreInfoButtonState();
}

class _BloodPressureMoreInfoButtonState
    extends State<BloodPressureMoreInfoButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UnconstrainedBox(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                //Navigator.pushNamed(context, 'homePage/BloodPressure/MoreData');

                var args = {
                  "accountId": widget.accountId,
                  "nickname": widget.nickname,
                };

                Navigator.pushNamed(context, 'homePage/Activity/MoreData',
                    arguments: args);
              },
              child: Container(
                  width: 150,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 156, 248, 243),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "更多数据详情",
                        style: TextStyle(
                            fontFamily: 'BalooBhai',
                            fontSize: 15,
                            color: Colors.black),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        "assets/icons/doubleRightArrow.png",
                        width: 15,
                        height: 15,
                      )
                    ],
                  )),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }
}

// 步数组件
class StepCountWidget extends StatefulWidget {
  final int accountId;
  const StepCountWidget({Key? key, required this.accountId}) : super(key: key);

  @override
  State<StepCountWidget> createState() => _StepCountWidgetState();
}

class _StepCountWidgetState extends State<StepCountWidget> {
  late Stream<StepCount> _stepCountStream;
  String _steps = '0';
  int lastStepCount = 0;
  int accountId = -1;
  int offset = -1;

  // ++++++++++++++++后端API+++++++++++++++

  // 获取用户的accountId
  Future<void> getAccountId() async {
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/account/info",
      );
      if (response.data["code"] == 200) {
        accountId = response.data["data"]["id"];
        print("获取accountId成功：$accountId");
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }

    String? test = await storage.read(key: 'test');
    if (test != null) {
      print("test:$test");
    }
  }

  // 获取最近一次的步数数据
  Future<void> getStepCountFromServer() async {
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = widget.accountId >= 0
          ? await dio.get(
              "http://43.138.75.58:8080/api/sports/steps?accountId=$accountId",
            )
          : await dio.get(
              "http://43.138.75.58:8080/api/sports/steps",
            );
      if (response.data["code"] == 200) {
        //print("%%%%%%%%%%%%%%%%%%%");
        //print("获取最近一次的步数数据成功：${response.data["data"]}");
        lastStepCount = response.data["data"][0]["steps"];
        print("获取最近一次的步数数据成功：$lastStepCount");
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }

    if (widget.accountId >= 0) {
      _steps = '0';
      return;
    }

    if (widget.accountId == -1 && accountId == -1) {
      await getAccountId();
    }

    await getSteps();

    // 根据accountId存储至shared_preferences
    //await storage.write(key: 'stepData', value: stepData.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> stepData = {
      "last": lastStepCount,
      "steps": int.parse(_steps),
    };
    // 存储accountId与对应的stepData
    prefs.setString('$accountId', json.encode(stepData));
    print("存储步数数据：accountId:$accountId  last:$lastStepCount  steps:$_steps");
  }

  // 更新步数数据
  Future<void> updateStepCount(int steps) async {
    // 从shared_preferences中获取accountId对应的stepData

    // ...
    // .get('stepCount':step);
    //lastStepCount += steps;

    var token = await storage.read(key: 'token');
    //print(value);

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/sports/steps/update",
        queryParameters: {
          "steps": steps,
        },
      );
      if (response.data["code"] == 200) {
        // print("获取血压数据成功（饼图）");
        //data = response.data["data"]["countedDataList"];
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }

    // 后端的stepCount+=step
  }

  @override
  void initState() {
    super.initState();
    offset = -1;
    accountId = widget.accountId;
    // 自己的才需要更新步数
    if (widget.accountId == -1) {
      initPlatformState();
    }
  }

  // 步数初始化
  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  // 从存储中获取步数数据
  Future<void> getSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$accountId');
    if (jsonString != null) {
      Map<String, dynamic> stepData = json.decode(jsonString);
      //print("获取getSteps前:$accountId steps:$_steps");
      _steps = stepData["steps"].toString();
      // print("获取getSteps后:$accountId steps:${stepData["steps"]}");
    } else {
      _steps = '0';
    }
  }

  // 步数发生变化
  void onStepCount(StepCount event) async {
    // 监护活动页面不需要实时更新
    if (widget.accountId >= 0) {
      return;
    }
    if (widget.accountId == -1 && accountId == -1) {
      await getAccountId();
    }

    // 不是自己的账号在登录状态下不需要更新
    String? checkLoginAccount = await storage.read(key: 'accountId');
    if (checkLoginAccount != null) {
      if (checkLoginAccount != accountId.toString()) {
        return;
      }
    } else {
      return;
    }

    // 计算偏移量
    if (offset < 0 && event.steps > int.parse(_steps)) {
      offset = event.steps - int.parse(_steps);
      print("offset:$offset = ${event.steps} - $_steps");
      return;
    }
    _steps = (event.steps - offset).toString();
    print('步数更新：$_steps = ${event.steps} - $offset');
    // 距离上次更新时间内的步数
    int newSteps = int.parse(_steps);
    // 存入shared_preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$accountId');
    if (jsonString != null) {
      Map<String, dynamic> stepData = json.decode(jsonString);

      stepData["steps"] = newSteps;
      prefs.setString('$accountId', json.encode(stepData));

      print(
          "更新步数数据：accountId:$accountId  last:${stepData["last"]}  steps:${stepData["steps"]}");

      // 每500步更新一次
      if (newSteps > 50) {
        // 更新后端数据
        await updateStepCount(newSteps)
            .then((value) => getStepCountFromServer());
        offset = event.steps;
        newSteps = 0;
        // 更新lastStepCount
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  // 步数更新错误
  void onStepCountError(error) {
    // print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  Widget getStepCountWidget() {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 80,
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
        //alignment: Alignment.centerLeft,
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
                      //'$steps2',
                      _steps == "Step Count not available"
                          ? "-"
                          //: lastStepCount.toString() + _steps,
                          : (lastStepCount + int.parse(_steps)).toString(),
                      style: const TextStyle(
                        fontSize: 35,
                        //fontSize: 15,
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

  Widget getStepCountWidgetNoData() {
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 80,
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
        //alignment: Alignment.centerLeft,
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
                    child: const Text(
                      "-",
                      style: TextStyle(
                        fontSize: 35,
                        //fontSize: 15,
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

  @override
  Widget build(BuildContext context) {
    print("build offset = $offset");
    return FutureBuilder(
        future: Future.wait([
          getAccountId(),
          getStepCountFromServer(),
        ]),
        builder: (context, snapshot) {
          // 加载完成
          if (snapshot.connectionState == ConnectionState.done) {
            return getStepCountWidget();
          } else {
            return getStepCountWidgetNoData();
          }
        });
  }
}

// 今日活动
class TodayActivities extends StatefulWidget {
  final int accountId;
  const TodayActivities({Key? key, required this.accountId}) : super(key: key);

  @override
  State<TodayActivities> createState() => _TodayActivitiesState();
}

class _TodayActivitiesState extends State<TodayActivities> {
  String steps2 = '1234';
  int exercisingHours = 1;
  int exercisingMins = 55;
  bool isExercising = false;
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
  int selectedType = 0;
  bool isPause = false;
  String startTime = "2023-01-01 00:00";
  String endTime = "2023-01-01 00:00";
  OverlayEntry? overlayEntry;
  final watchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  int lastStepCount = 0;
  int accountId = -1;
  int feelings = 1;
  TextEditingController remarksController = TextEditingController();

  // ++++++++++++++++后端API+++++++++++++++
  // 获取今日已运动时长
  Future<void> getTodayExercisingDuration() async {
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        widget.accountId >= 0
            ? "http://43.138.75.58:8080/api/sports/exercise/duration?accountId=${widget.accountId}"
            : "http://43.138.75.58:8080/api/sports/exercise/duration",
      );
      if (response.data["code"] == 200) {
        //print("============今日已经运动时长===============");
        //print(response.data["data"]);
        int totalMinutes = response.data["data"];
        exercisingHours = totalMinutes ~/ 60;
        exercisingMins = totalMinutes % 60;
        // print('total:$totalMinutes  ==> $exercisingHours:$exercisingMins ');
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }
  }

  // 获取当前有没有运动，有则获取开始时间，类型，是否暂停等
  Future<void> getTodayCurrentExercising() async {
    // print("=======getTodayCurrentExercising===========");
    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        widget.accountId >= 0
            ? "http://43.138.75.58:8080/api/sports/exercise/current?accountId=${widget.accountId}"
            : "http://43.138.75.58:8080/api/sports/exercise/current",
      );
      if (response.data["code"] == 200) {
        //print("============!!!!!!===============");
        //print(response.data["data"]);
        //int totalMinutes = response.data["data"];
        //exercisingHours = totalMinutes ~/ 60;
        //exercisingMins = totalMinutes % 60;
        // print("=======getTodayCurrentExercising===========");
        //  print(response.data["data"]);
        if (response.data["data"] == null) {
          isExercising = false;
          isPause = false;
          startTime = "2023-01-01 00:00";
          selectedType = 0;
          return;
        } else {
          isExercising = response.data["data"]["isExercising"];
          isPause = response.data["data"]["isPausing"];

          startTime = response.data["data"]["startTime"];
          selectedType = response.data["data"]["type"];
        }
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
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

    if (widget.accountId >= 0) {
      arguments["accountId"] = (widget.accountId).toString();
    }

    print("=========startExercising===========");
    print(arguments);

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/sports/exercise/start",
          queryParameters: arguments);
      if (response.data["code"] == 200) {
        print("==========开始运动成功===============");
        //data = response.data["data"]["countedDataList"];
        //bpdata = response.data["data"];
        return true;
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }

    return false;
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

    if (widget.accountId >= 0) {
      arguments["accountId"] = (widget.accountId.toString());
    }

    print("=========pauseExercising===========");
    print(arguments);

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/sports/exercise/pause",
          queryParameters: arguments);
      if (response.data["code"] == 200) {
        print("==========暂停运动成功===============");
        //data = response.data["data"]["countedDataList"];
        //bpdata = response.data["data"];
        return true;
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }

    return false;
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

    if (widget.accountId >= 0) {
      arguments["accountId"] = (widget.accountId.toString());
    }

    print("=========continueExercising===========");
    print(arguments);

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/sports/exercise/continue",
          queryParameters: arguments);
      if (response.data["code"] == 200) {
        print("==========恢复运动成功===============");
        //data = response.data["data"]["countedDataList"];
        //bpdata = response.data["data"];
        return true;
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }

    return false;
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

    if (remarksController.text == "") {
      arguments.remove("remark");
    }

    if (widget.accountId >= 0) {
      arguments["accountId"] = widget.accountId;
    }

    print("=========endExercising===========");
    print(arguments);

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/sports/exercise/end",
          queryParameters: arguments);
      if (response.data["code"] == 200) {
        print("==========结束运动成功===============");
        //data = response.data["data"]["countedDataList"];
        //bpdata = response.data["data"];
        return true;
      } else {
        print(response);
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

  //=========================================
  @override
  void initState() {
    super.initState();
    accountId = widget.accountId;
  }

  void updateType() {
    setState(() {});
  }

  // 运动类型选择弹窗
  void exercisingTypeOverlay(BuildContext context) async {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            //color: const Color.fromARGB(156, 255, 255, 255),
            //child: getTypeSelector2(),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color.fromARGB(217, 131, 131, 131)),
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
                /* isExercising = false;
                isPause = false;
                watchTimer.onStopTimer();
                print(
                    "结束运动 类型:${items[selectedType]}  开始/结束：${startTime} ~ ${DateTime.now()}");

                setState(() {});
                Navigator.pop(context); */

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

  // 运动类型枚举选择
  Widget exercisingTypeSelector2() {
    //网格布局，将items中的数据放入网格中
    return Container(
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
              print(items[selectedType]);
              /* setState(() {
                // 更新被选中的运动类型

                //
              }); */
              overlayEntry?.markNeedsBuild();
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item == items[selectedType]
                    ? Color.fromARGB(255, 253, 184, 255)
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

  // 运动类型选择界面 (运动类型标题+选项+确定/取消)
  Widget getTypeSelector2() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
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
                    //setState(() {});
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
                    /* isExpanded = false;
                    isExercising = true;
                    setState(() {});
                    overlayEntry?.markNeedsBuild();
                    overlayEntry?.remove();
                    return; */
                    // 开始timer
                    //startTime = DateTime.now();
                    //watchTimer.onStartTimer();

                    bool status = await startExercising();
                    if (status) {
                      //print("开始运动成功");
                      isExercising = true;
                      setState(() {});
                      overlayEntry?.markNeedsBuild();
                      overlayEntry?.remove();
                    } else {
                      print("开始运动失败");
                      overlayEntry?.remove();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent),
                  ),
                  child: Text('开始'),
                ),
              ],
            ),
          ],
          //),
        ),
      ),
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
            //color: const Color.fromARGB(156, 255, 255, 255),
            //child: getTypeSelector2(),
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

  // 运动感受与备注
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
                          print("开心");
                          feelings = 0;
                          //setState(() {});
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
                          print("还好");
                          feelings = 1;
                          // setState(() {});
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
                          print("不好");
                          feelings = 2;
                          // setState(() {});
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
                      //initialValue: widget.SBloodpressure,
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
                      //setState(() {});
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
                      /* setState(() {});
                        overlayEntry?.markNeedsBuild();
                        overlayEntry?.remove();
                        Navigator.pop(context); */

                      /* isExercising = false;
                      isPause = false;
                      watchTimer.onStopTimer();
                      print(
                          "结束运动 类型:${items[selectedType]}  开始/结束：${startTime} ~ ${DateTime.now()}");

                      overlayEntry?.remove();
                      setState(() {});
                      Navigator.pop(context);
                      return; */

                      bool status = await endExercising();
                      if (status) {
                        isExercising = false;
                        isPause = false;
                        overlayEntry?.remove();
                        setState(() {});
                        Navigator.pop(context);
                      } else {
                        print("结束运动失败");
                        overlayEntry?.remove();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.greenAccent),
                    ),
                    child: Text('确定'),
                  ),
                ],
              ),
            ]),
      ),
    );
  }

  // 获取步数运动权限
  Future<void> getActivityRecognitionPermission() async {
    var permissionStatus =
        await Permission.activityRecognition.request().isGranted;

    if (!permissionStatus) {
      await Permission.activityRecognition.request();
    }
  }

  // 运动时长组件
  Widget exercisingWidget() {
    double height1 = 50;
    return Stack(
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
                  // 今日运动 + 运动时长
                  Container(
                    height: 50,
                    //color: Colors.indigo,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 标题
                        Container(
                          height: height1,
                          alignment: Alignment.topCenter,
                          child: const PageTitle(
                            title: "今日运动",
                            icons: "assets/icons/exercising2.png",
                            fontSize: 20,
                          ),
                        ),

                        // 运动时长 x小时 y分钟
                        Row(
                          children: [
                            Container(
                              height: height1,
                              alignment: Alignment.center,
                              child: Text(
                                '$exercisingHours',
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontFamily: "BalooBhai",
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 104, 200, 255),
                                ),
                              ),
                            ),
                            Container(
                              height: height1,
                              alignment: Alignment.center,
                              child: const Text(
                                ' 小时 ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "BalooBhai",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              height: height1,
                              alignment: Alignment.center,
                              child: Text(
                                '$exercisingMins',
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontFamily: "BalooBhai",
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 104, 200, 255),
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: const Text(
                                ' 分钟',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "BalooBhai",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ], // 运动中或开始运动
                    ),
                  ),
                  // 运动中或开始运动
                  isExercising == false
                      // 不在运动时
                      ? // 开始/结束运动按钮
                      Container(
                          height: 50,
                          alignment: Alignment.center,
                          //color: Colors.amber,
                          child: GestureDetector(
                            onTap: () {
                              /* setState(() {
                                    isExpanded = !isExpanded;
                                  }); */
                              exercisingTypeOverlay(context);
                            },
                            child: Container(
                              width: 100,
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 104, 200, 255),
                                border: Border.all(
                                  color: const Color.fromRGBO(0, 0, 0, 0.2),
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                '开始运动',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "BalooBhai",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      //运动时
                      : Column(
                          children: [
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.black45,
                            ),
                            // 计时器
                            Container(
                              // color: Colors.greenAccent,
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
                                    //color: Colors.greenAccent,
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
                              //color: Colors.yellowAccent,
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
                            Container(
                              //color: Colors.deepPurpleAccent,
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
                                        setState(() {});
                                        /*  setState(() {
                                          /* if (isPause == false) {
                                            isPause = true;
                                            //watchTimer.onStopTimer();
                                            print("暂停运动");
                                          } else {
                                            isPause = false;
                                            //watchTimer.onStartTimer();
                                            print("继续运动");
                                          } */
                                        }); */
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
                                          borderRadius:
                                              BorderRadius.circular(15),
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

                                        if (isExercising == false) {
                                          setState(() {});
                                        }

                                        /* setState(() {
                                              isExercising = false;
                                              watchTimer.onStopTimer();
                                              final displayTime =
                                                  StopWatchTimer.getDisplayTime(
                                                      watchTimer.rawTime.value,
                                                      hours: true,
                                                      minute: true,
                                                      second: true,
                                                      milliSecond: false);

                                              watchTimer.onResetTimer();
                                              print(
                                                  "结束运动 类型:${items[selectedType]}  开始/结束：${startTime} ~ ${DateTime.now()} 时长：${displayTime}");
                                            }); */
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
                                          borderRadius:
                                              BorderRadius.circular(15),
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
        isExercising
            ? Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: isPause ? Colors.blueAccent : Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  //Future<void>
  @override
  Widget build(BuildContext context) {
    // var permissionStatus = await Permission.activityRecognition.request().isGranted;

    return FutureBuilder(
        future: Future.wait([
          getActivityRecognitionPermission(),
          getTodayExercisingDuration(),
          getTodayCurrentExercising(),
        ]),
        builder: (context, snapshot) {
          // 加载完成
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                UnconstrainedBox(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: const PageTitle(
                      title: "今日活动",
                      icons: "assets/icons/exercising.png",
                      fontSize: 18,
                    ),
                  ),
                ),

                // 步数统计
                StepCountWidget(
                  accountId: widget.accountId,
                ),

                //
                const SizedBox(
                  height: 15,
                ),

                // 运动时长统计
                exercisingWidget(),
              ],
            );
          }
          // 加载中
          else {
            return Column(children: [
              UnconstrainedBox(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: const PageTitle(
                    title: "今日活动",
                    icons: "assets/icons/exercising.png",
                    fontSize: 18,
                  ),
                ),
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

    //
  }
}
// ============================================================================

// 活动详情此页面
class ActivityDetails extends StatefulWidget {
  final Map arguments;
  const ActivityDetails({Key? key, required this.arguments}) : super(key: key);

  @override
  State<ActivityDetails> createState() => _ActivityDetailsState();
}

class _ActivityDetailsState extends State<ActivityDetails> {
  DateTime date = DateTime.now();
  String selectedDays = "最近7天";
  late Widget bloodPressureGraphtWidget;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print('主要：${widget.arguments}');
    if (widget.arguments["date"] == null) {
      date = DateTime.now();
    } else {
      date = widget.arguments["date"];
    }
    bloodPressureGraphtWidget = BloodPressureGraphWidget(
      accountId: widget.arguments["accountId"],
      date: date,
      selectedDays: selectedDays,
      updateView: updateView,
      updateDate: updateDate,
      updateDays: updateDays,
    );
  }

  // 更新数据
  void updateData() {
    setState(() {
      bloodPressureGraphtWidget = BloodPressureGraphWidget(
        accountId: widget.arguments["accountId"],
        date: date,
        selectedDays: selectedDays,
        updateView: updateView,
        updateDate: updateDate,
        updateDays: updateDays,
      );
    });
  }

  void updateView() {
    //print("血压详情页面更新");
    setState(() {});
  }

  void updateDate(DateTime newDate) {
    if (newDate == date) {
      return;
    }
    setState(() {
      date = newDate;
      bloodPressureGraphtWidget = BloodPressureGraphWidget(
        accountId: widget.arguments["accountId"],
        date: date,
        selectedDays: selectedDays,
        updateView: updateView,
        updateDate: updateDate,
        updateDays: updateDays,
      );
    });
  }

  void updateDays(String newDays) {
    //print("血压详情页面更新天数 ${newDays}");
    if (newDays == selectedDays) {
      return;
    }
    setState(() {
      selectedDays = newDays;
      bloodPressureGraphtWidget = BloodPressureGraphWidget(
        accountId: widget.arguments["accountId"],
        date: date,
        selectedDays: selectedDays,
        updateView: updateView,
        updateDate: updateDate,
        updateDays: updateDays,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("活动详情页面rebuild");
    return Scaffold(
      appBar: widget.arguments["accountId"] < 0
          ? getAppBar(0, true, "TriGuard")
          : getAppBar(1, true, widget.arguments["nickname"]),
      body: Container(
        color: Colors.white,
        child: ListView(shrinkWrap: true, children: [
          const SizedBox(
            height: 5,
          ),
          // 标题组件
          UnconstrainedBox(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              alignment: Alignment.centerLeft,
              child: const PageTitle(
                title: "活动详情",
                icons: "assets/icons/exercising.png",
                fontSize: 22,
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          TodayActivities(
            accountId: widget.arguments["accountId"],
          ),

          const SizedBox(
            height: 10,
          ),

          // 步数与运动时长数据图
          bloodPressureGraphtWidget,

          // 血压图表组件
          const SizedBox(
            height: 10,
          ),

          //数据列表组件
          BloodPressureDataWidget(
            accountId: widget.arguments["accountId"],
            nickname: widget.arguments["nickname"],
            date: date,
            updateView: updateView,
            updateData: updateData,
          ),

          const SizedBox(
            height: 10,
          ),

          //统计组件
          BloodPressureStaticWidget(
              accountId: widget.arguments["accountId"],
              refreshData: true,
              date: date,
              selectedDays: selectedDays,
              updateView: updateView,
              updateDate: updateDate),

          BloodPressureMoreInfoButton(
            accountId: widget.arguments["accountId"],
            nickname: widget.arguments["nickname"],
          ),

          /* bloodPressureGraphtWidget,

          const SizedBox(
            height: 10,
          ),

          //数据列表组件
          BloodPressureDataWidget(
            date: date,
            updateView: updateView,
            updateData: updateData,
          ),

          //统计组件
          BloodPressureStaticWidget(
              refreshData: true,
              date: date,
              selectedDays: selectedDays,
              updateView: updateView,
              updateDate: updateDate),

          BloodPressureMoreInfoButton(), */
        ]),
      ),
    );
  }
}
