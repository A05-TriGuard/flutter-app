//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../account/token.dart';
import '../../component/header/header.dart';
import '../../component/titleDate/titleDate.dart';
import '../../other/other.dart';

const List<String> method = <String>['手机号', '邮箱'];
typedef UpdateDateCallback = void Function(DateTime newDate);
typedef UpdateDaysCallback = void Function(String newDays);

// 图表天数选择
// ignore: must_be_immutable
class GraphDayDropdownButton extends StatefulWidget {
  final VoidCallback updateView;
  final UpdateDaysCallback updateDays;
  String? selectedValue = '最近7天';
  GraphDayDropdownButton({
    Key? key,
    required this.updateView,
    required this.updateDays,
    this.selectedValue,
  }) : super(key: key);
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
    return Row(
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
                .map(
                  (String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
                .toList(),
            value: widget.selectedValue,
            onChanged: (String? value) {
              setState(() {
                widget.selectedValue = value;
                widget.updateDays(widget.selectedValue!);
              });
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              width: 140,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
          ),
        ),
      ],
    );
  }
}

// 血压图表
// ignore: must_be_immutable
class BloodPressureGraph extends StatefulWidget {
  DateTime date;
  final String selectedDays;
  final UpdateDateCallback updateDate;
  final int accountId;
  BloodPressureGraph({
    Key? key,
    required this.date,
    required this.selectedDays,
    required this.updateDate,
    required this.accountId,
  }) : super(key: key);

  @override
  State<BloodPressureGraph> createState() => _BloodPressureGraphState();
}

class _BloodPressureGraphState extends State<BloodPressureGraph> {
  // 从后端请求得到的原始数据
  List<dynamic> data = [];

  // 显示的数据
  List<int> dayData = [];
  List<int> monthData = [];
  List<int> sbpData = [];
  List<int> dbpData = [];
  List<int> heartRateData = [];

  // 从后端请求数据
  Future<void> getDataFromServer() async {
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
      response = await dio.get(
        "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range",
        queryParameters: params,
      );
      if (response.data["code"] == 200) {
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

    if (data.isEmpty) {
      dayData.add(widget.date.day);
      monthData.add(widget.date.month);
      sbpData.add(0);
      dbpData.add(0);
      heartRateData.add(0);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDataFromServer(),
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
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: dayData.length <= 5 ? 325 : dayData.length * 65,
                      height: MediaQuery.of(context).size.height * 0.35,
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
                          left: '20', // 3%
                          right: '20', // 4%
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
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
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
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  final UpdateDaysCallback updateDays;
  String selectedDays = "最近7天";
  DateTime date;
  BloodPressureGraphWidget({
    Key? key,
    required this.date,
    required this.selectedDays,
    required this.updateView,
    required this.updateDate,
    required this.updateDays,
    required this.accountId,
  }) : super(key: key);

  @override
  State<BloodPressureGraphWidget> createState() =>
      _BloodPressureGraphWidgetState();
}

class _BloodPressureGraphWidgetState extends State<BloodPressureGraphWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GraphDayDropdownButton selectDaysButton = GraphDayDropdownButton(
      updateView: widget.updateView,
      updateDays: widget.updateDays,
      selectedValue: widget.selectedDays,
    );

    return UnconstrainedBox(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(children: [
          // 日期选择器
          Column(
            children: [
              const SizedBox(height: 5),
              DatePicker2(date: widget.date, updateDate: widget.updateDate),
              selectDaysButton,
              const SizedBox(height: 5),
            ],
          ),
          // 血压图表
          BloodPressureGraph(
            date: widget.date,
            selectedDays: widget.selectedDays,
            updateDate: widget.updateDate,
            accountId: widget.accountId,
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
  final int hour;
  final int minute;
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int arm;
  final int feeling;
  final String remark;
  final VoidCallback updateData;

  const BloodPressureData({
    Key? key,
    required this.accountId,
    required this.nickname,
    required this.id,
    required this.date,
    required this.hour,
    required this.minute,
    required this.SBloodpressure,
    required this.DBloodpressure,
    required this.heartRate,
    required this.feeling,
    required this.arm,
    required this.remark,
    required this.updateData,
  }) : super(key: key);

  @override
  State<BloodPressureData> createState() => _BloodPressureDataState();
}

class _BloodPressureDataState extends State<BloodPressureData> {
  List<String> armButtonTypes = ["左手", "右手", "不选"];
  List<String> feelingButtonTypes = ["开心", "还好", "不好"];
  bool showRemark = false;
  PageController pageController = PageController();

  // 展示血压数据
  Widget getInfoPage() {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.2),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
                '${widget.hour < 10 ? "0${widget.hour}" : widget.hour}:${widget.minute < 10 ? "0${widget.minute}" : widget.minute}',
                style: const TextStyle(fontSize: 20, fontFamily: "BalooBhai")),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '血压: ${widget.SBloodpressure} / ${widget.DBloodpressure}',
                  style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Text(
                  '心率: ${widget.heartRate} ',
                  style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '手臂: ${armButtonTypes[widget.arm]}',
                  style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Text(
                  '感觉: ${feelingButtonTypes[widget.feeling]}',
                  style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 展示备注
  Widget getRemarkPage() {
    return Container(
      height: 80,
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

  // 展示页码
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
              var args = {
                "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                "nickname": widget.nickname,
                "bpDataId": widget.id, //表示跳转后展开这个id的血压数据
                "date": widget.date,
              };

              Navigator.pushNamed(context, "/homePage/BloodPressure/Edit",
                      arguments: args)
                  .then((_) {
                widget.updateData();
              });
            },
            child: Image.asset(
              "assets/icons/pencil.png",
              width: 20,
              height: 20,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 暂无数据
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
            // 今日没有数据，点击跳转至添加数据页面
            GestureDetector(
              onTap: () {
                var args = {
                  "accountId": widget.accountId >= 0 ? widget.accountId : -1,
                  "bpDataId": -1,
                  "nickname": widget.nickname,
                  "date": widget.date,
                };

                Navigator.pushNamed(context, "/homePage/BloodPressure/Edit",
                        arguments: args)
                    .then((_) {
                  widget.updateData();
                });
              },
              child: SizedBox(
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
  List<dynamic> data = [];
  List<Widget> dataWidget = [];
  int length = 1;

  // 从后端请求数据
  Future<void> getDataFromServer() async {
    String requestDate = getFormattedDate(widget.date);

    var token = await storage.read(key: 'token');

    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    var params = {
      "startDate": requestDate,
      "endDate": requestDate,
    };

    if (widget.accountId != -1) {
      params["accountId"] = widget.accountId.toString();
    }

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range",
        queryParameters: params,
      );
      if (response.data["code"] == 200) {
        data = response.data["data"];
      } else {
        data = [];
      }
    } catch (e) {
      data = [];
    }
  }

  @override
  void initState() {
    super.initState();
    getDataFromServer().then((_) {
      getdataWidgetList();
    });
  }

  // 获取展示的数据
  void getdataWidgetList() {
    dataWidget = [];

    // 收起时就显示一个
    if (widget.showMore == 1) {
      length = data.length;
    } else {
      length = 1;
    }

    if (data.isEmpty) {
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
      int id_ = data[i]["id"];
      DateTime date_ = DateTime.parse(data[i]["date"]);
      String timeStr = data[i]["time"];
      int hour_ = int.parse(timeStr.split(":")[0]);
      int minute_ = int.parse(timeStr.split(":")[1]);
      int sbp_ = data[i]["sbp"];
      int dbp_ = data[i]["dbp"];
      int heartRate_ = data[i]["heartRate"];
      int arm_ = data[i]["arm"];
      int feeling_ = data[i]["feeling"];
      String remark_ = data[i]["remark"] ?? "暂无备注";
      data[i]["isExpanded"] = 0; // 默认收起

      dataWidget.add(BloodPressureData(
        accountId: widget.accountId,
        nickname: widget.nickname,
        id: id_,
        date: date_,
        hour: hour_,
        minute: minute_,
        SBloodpressure: sbp_,
        DBloodpressure: dbp_,
        heartRate: heartRate_,
        feeling: feeling_,
        arm: arm_,
        remark: remark_,
        updateData: widget.updateData,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDataFromServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          getdataWidgetList();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            height: length == 1 ? 95 : 95.0 * length,
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              child: Column(
                children: dataWidget,
              ),
            ),
          );
        } else {
          return UnconstrainedBox(
            child: SizedBox(
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
    super.initState();
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

    return Center(
      child: SizedBox(
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
                      showMore = 1;
                    } else {
                      showMore = 0;
                    }

                    setState(() {});
                  },
                  child: Container(
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
  const BloodPressureStaticGraph({
    Key? key,
    required this.date,
    required this.selectedDays,
    required this.updateDate,
    required this.dataTimes,
    required this.seriesName,
  }) : super(key: key);

  @override
  State<BloodPressureStaticGraph> createState() =>
      _BloodPressureStaticGraphState();
}

class _BloodPressureStaticGraphState extends State<BloodPressureStaticGraph> {
  Future<Widget> getEchart() async {
    return Echarts(option: '''
        {

          tooltip: {
            trigger: 'item'
          },
          legend: {
            orient: 'vertical',
            left: '10%',
            top: '20%'
          },
          series: [
            {
              name: '${widget.seriesName}',
              type: 'pie',
              radius: '60%',
              center: ['65%', '50%'], //第一个是左右，第二个上下
              data: [
                { value:  ${widget.dataTimes[0]}, name: '偏高' },
                { value:  ${widget.dataTimes[1]}, name: '正常' },
                { value:  ${widget.dataTimes[2]}, name: '偏低' },
                { value:  ${widget.dataTimes[3]}, name: '异常' },
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
  List<dynamic> data = [];
  List<String> seriesName = ["收缩压", "舒张压", "心率"];
  List<int> SBPTimes = [0, 0, 0, 0];
  List<int> DBPTimes = [0, 0, 0, 0];
  List<int> heartRateTimes = [0, 0, 0, 0];
  List<int> total = [0, 0, 0];
  List<int> avg = [];
  String title = "";
  int averageSbp = 0;
  int averageDbp = 0;
  int totalTimes = 0;
  int averageHr = 0;
  int pageNum = 0;

  // 从后端请求数据
  Future<void> getDataFromServer() async {
    String requestStartDate = getStartDate(widget.date, widget.selectedDays);
    String requestEndDate = getFormattedDate(widget.date);
    if (widget.selectedDays == "当前的月") {
      requestEndDate = getFormattedDate(
          DateTime(widget.date.year, widget.date.month + 1, 0));
    }

    var token = await storage.read(key: 'token');
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
        data: params,
      );
      if (response.data["code"] == 200) {
        data = response.data["data"]["countedDataList"];
      } else {
        data = [];
      }
    } catch (e) {
      data = [];
    }

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
    super.initState();
    SBPTimes = DBPTimes = [3, 13, 5, 1];
    heartRateTimes = [4, 12, 6, 0];
    avg = [120, 99, 95];
    totalTimes = 22;
    averageSbp = 120;
    averageDbp = 99;
    averageHr = 95;
  }

  // 获取展示的数据
  List<int> getTypeData(int pageNum) {
    // SBP
    if (pageNum == 0) {
      return SBPTimes;
    }
    // DBP
    else if (pageNum == 1) {
      return DBPTimes;
    }
    // HR
    else if (pageNum == 2) {
      return heartRateTimes;
    }
    return [];
  }

  // 获取展示的数据
  int getTimesData(int pageNum, int type) {
    // SBP
    if (pageNum == 0) {
      return SBPTimes[type];
    }
    // DBP
    else if (pageNum == 1) {
      return DBPTimes[type];
    }
    // HR
    else if (pageNum == 2) {
      return heartRateTimes[type];
    }
    return 0;
  }

  // 设置标题
  void setTitle() {
    if (widget.selectedDays == "当前的天") {
      title = "${widget.date.year}年 ${widget.date.month}月 ${widget.date.day}日";
    } else if (widget.selectedDays == "当前的月") {
      title = "${widget.date.year}年 ${widget.date.month}月";
    } else {
      title = widget.selectedDays;
    }
  }

  // 获取展示的数据
  Widget getDataStaticWidget() {
    return Column(
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
                  pageNum <= 1
                      ? "assets/icons/bloodPressure1.png"
                      : "assets/icons/heartRate.png",
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
                  total[pageNum].toString(),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "平均值：",
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: "BalooBhai",
                  fontWeight: FontWeight.bold),
            ),
            Text(
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

        // 次数统计
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 偏低
                Row(
                  children: [
                    const Text(
                      '偏低：',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
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
                  children: [
                    const Text(
                      '正常：',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
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
                  children: [
                    const Text(
                      '异常：',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "BalooBhai",
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
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
            updateDate: widget.updateDate),
      ],
    );
  }

  // 展示页码
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
          const SizedBox(
            width: 5,
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: pageNum == 2 ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
          )
        ],
      ),
    );
  }

  // 展示所有
  Widget getDataStaticWholeWidget() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          children: [
            // 标题
            const PageTitle(
              title: "血压心率统计",
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
                        pageNum = 2;
                      }

                      setState(() {});
                    } else if (details.primaryDelta! < -15) {
                      pageNum += 1;
                      if (pageNum > 2) {
                        pageNum = 0;
                      }
                      setState(() {});
                    }
                  },

                  // 血压统计图表文字
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
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
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
    // 需要重新获取数据
    if (widget.refreshData) {
      widget.refreshData = false;
      return FutureBuilder(
          future: getDataFromServer(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              setTitle();
              return getDataStaticWholeWidget();
            } else {
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
    getDataFromServer();
    setTitle();
    return getDataStaticWholeWidget();
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
                var args = {
                  "accountId": widget.accountId,
                  "nickname": widget.nickname,
                };

                Navigator.pushNamed(context, 'homePage/BloodPressure/MoreData',
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
                      "更多血压详情",
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
                ),
              ),
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

// ============================================================================

// 血压详情此页面
class BloodPressureDetails extends StatefulWidget {
  final Map arguments;
  // 需要 accountId ， nickname，date 如果是自己的数据，accountId = -1
  const BloodPressureDetails({Key? key, required this.arguments})
      : super(key: key);

  @override
  State<BloodPressureDetails> createState() => _BloodPressureDetailsState();
}

class _BloodPressureDetailsState extends State<BloodPressureDetails> {
  DateTime date = DateTime.now();
  String selectedDays = "最近7天";
  late Widget bloodPressureGraphtWidget;

  @override
  void initState() {
    super.initState();
    if (widget.arguments["date"] == null) {
      date = DateTime.now();
    } else {
      date = widget.arguments["date"];
    }
    bloodPressureGraphtWidget = BloodPressureGraphWidget(
      date: date,
      selectedDays: selectedDays,
      updateView: updateView,
      updateDate: updateDate,
      updateDays: updateDays,
      accountId: widget.arguments["accountId"],
    );
  }

  // 更新数据
  void updateData() {
    setState(() {
      bloodPressureGraphtWidget = BloodPressureGraphWidget(
        date: date,
        selectedDays: selectedDays,
        updateView: updateView,
        updateDate: updateDate,
        updateDays: updateDays,
        accountId: widget.arguments["accountId"],
      );
    });
  }

  // 更新页面
  void updateView() {
    setState(() {});
  }

  // 更新日期
  void updateDate(DateTime newDate) {
    if (newDate == date) {
      return;
    }
    setState(() {
      date = newDate;
      bloodPressureGraphtWidget = BloodPressureGraphWidget(
        date: date,
        selectedDays: selectedDays,
        updateView: updateView,
        updateDate: updateDate,
        updateDays: updateDays,
        accountId: widget.arguments["accountId"],
      );
    });
  }

  // 更新天数
  void updateDays(String newDays) {
    if (newDays == selectedDays) {
      return;
    }
    setState(() {
      selectedDays = newDays;
      bloodPressureGraphtWidget = BloodPressureGraphWidget(
        date: date,
        selectedDays: selectedDays,
        updateView: updateView,
        updateDate: updateDate,
        updateDays: updateDays,
        accountId: widget.arguments["accountId"],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                title: "血压详情",
                icons: "assets/icons/bloodPressure.png",
                fontSize: 22,
              ),
            ),
          ),

          // 血压图表组件
          bloodPressureGraphtWidget,

          const SizedBox(
            height: 10,
          ),

          //数据列表组件
          BloodPressureDataWidget(
            date: date,
            updateView: updateView,
            updateData: updateData,
            accountId: widget.arguments["accountId"],
            nickname: widget.arguments["accountId"] >= 0
                ? widget.arguments["nickname"]
                : "TriGuard",
          ),

          //统计组件
          BloodPressureStaticWidget(
            refreshData: true,
            date: date,
            selectedDays: selectedDays,
            updateView: updateView,
            updateDate: updateDate,
            accountId: widget.arguments["accountId"],
          ),

          BloodPressureMoreInfoButton(
            accountId: widget.arguments["accountId"],
            nickname: widget.arguments["accountId"] >= 0
                ? widget.arguments["nickname"]
                : "TriGuard",
          ),
        ]),
      ),
    );
  }
}
