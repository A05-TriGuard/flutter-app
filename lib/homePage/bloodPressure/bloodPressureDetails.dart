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
import './bpData2.dart';
import './bloodPressureEdit.dart' hide armButtonTypes, feelingButtonTypes;

const List<String> method = <String>['手机号', '邮箱'];
typedef UpdateDateCallback = void Function(DateTime newDate);
typedef UpdateDaysCallback = void Function(String newDays);

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
  DateTime date;
  final String selectedDays;
  final UpdateDateCallback updateDate;
  BloodPressureGraph(
      {Key? key,
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
    print(
        '请求日期：$requestStartDate ~~~ $requestEndDate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

    // 提取登录获取的token
    var token = await storage.read(key: 'token');
    //print(value);

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range",
        queryParameters: {
          "startDate": requestStartDate,
          "endDate": requestEndDate,
        },
      );
      if (response.data["code"] == 200) {
        print("获取血压数据成功");
        //print(response.data["data"]);
        data = response.data["data"];
        //bpdata = response.data["data"];
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
    sbpData = [];
    dbpData = [];
    heartRateData = [];

    for (int i = data.length - 1; i >= 0; i--) {
      int id_ = data[i]["id"];
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

    //print("dateData: $dateData");
    //print("valueData: $valueData");
    //setState(() {});

    /* print("dayData      : $dayData");
    print("monthData    : $monthData");
    print("sbpData      : $sbpData");
    print("dbpData      : $dbpData");
    print("heartRateData: $heartRateData"); */
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
    print('血压折线图更新build：${widget.date}，天数：${widget.selectedDays}');

    // after getDataFromServer finish then return the Echarts widget
    return FutureBuilder(
      // Replace getDataFromServer with the Future you want to wait for
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
                  /* border: GradientBoxBorder(
                    gradient: LinearGradient(colors: [
                      Color.fromARGB(146, 253, 69, 69),
                      Color.fromARGB(157, 255, 199, 223)
                    ]),
                    width: 1,
                  ), */
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
                      // width: MediaQuery.of(context).size.width * 1.5,
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
                  left: '3%',
                  right: '4%',
                  bottom: '10%',
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
  DateTime date;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  final UpdateDaysCallback updateDays;
  String selectedDays = "最近7天";
  BloodPressureGraphWidget(
      {Key? key,
      required this.date,
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
    // TODO: implement initState
    super.initState();
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('血压图表组件更新（日期与图表） ${widget.date}, ${widget.selectedDays}');

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
      child: Container(
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

  const BloodPressureData(
      {Key? key,
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
      //duration: Duration(milliseconds: 1000),
      //curve: Curves.easeInOut,
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
                Text('血压: ${widget.SBloodpressure} / ${widget.DBloodpressure}',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
                Text('心率: ${widget.heartRate} ',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('手臂: ${armButtonTypes[widget.arm]}',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
                Text('感觉: ${feelingButtonTypes[widget.feeling]}',
                    style:
                        const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  /* @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        getInfoPage(),
      ],
    );
  } */

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
      /* child: Container(
        //duration: Duration(milliseconds: 1000),
        //curve: Curves.easeIn,
        child: showRemark ? getRemarkPage() : infoPage,
      ), */

      /* child: AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        //curve: Curves.easeInOut,
        width: showRemark == true
            ? MediaQuery.of(context).size.width * 0.85
            : MediaQuery.of(context).size.width * 0.85,
        height: showRemark == true ? 160 : 80,
        curve: Curves.fastOutSlowIn,
        child: showRemark ? getRemarkPage() : infoPage,
      ), */

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
              /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BloodPressureEdit(
                    arguments: {
                      "bpDataId": widget.id,
                      "date": widget.date,
                      "prevPage": 1,
                    },
                  ),
                ),
              ); */

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BloodPressureEdit(
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
              });
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

// 当日没有数据
class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
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
            child: const Center(
              child: Text(
                "暂无数据",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "BalooBhai",
                    color: Color.fromRGBO(48, 48, 48, 1)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              print("添加数据");
              /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BloodPressureEdit(
                    arguments: {
                      "bpDataId": -1,
                      "date": DateTime.now(),
                      "prevPage": 0,
                    },
                  ),
                ),
              ).then((_) {
                //print("哈哈哈");
                widget.updateData();
              }); */
            },
            child: Container(
              height: 20,
              width: 20,
              child: Image.asset("assets/icons/add.png", width: 20, height: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// 当日没有数据 可以跳转至添加数据页面
class NoDataListWidget extends StatefulWidget {
  final DateTime date;
  final VoidCallback updateData;

  const NoDataListWidget(
      {Key? key, required this.date, required this.updateData})
      : super(key: key);

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BloodPressureEdit(
                      arguments: {
                        "bpDataId": -1,
                        "date": widget.date,
                        "prevPage": 1,
                      },
                    ),
                  ),
                ).then((_) {
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
  final VoidCallback updateData;
  DateTime date;
  int showMore;
  BloodPressureDataList(
      {Key? key,
      required this.date,
      required this.showMore,
      required this.updateData})
      : super(key: key);

  @override
  State<BloodPressureDataList> createState() => _BloodPressureDataListState();
}

class _BloodPressureDataListState extends State<BloodPressureDataList> {
  List<Map> data2 = bpdata;
  List<dynamic> data = [];
  List<Widget> dataWidget = [];
  int length = 1;

  Future<void> getDataFromServer() async {
    print(
        '请求日期：${widget.date.year}-${widget.date.month}-${widget.date.day}....................................');
    String requestDate = getFormattedDate(widget.date);

    // 提取登录获取的token
    var token = await storage.read(key: 'token');
    //print(value);

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://43.138.75.58:8080/api/blood-pressure/get-by-date-range",
        queryParameters: {
          "startDate": requestDate,
          "endDate": requestDate,
        },
      );
      if (response.data["code"] == 200) {
        //print("获取血压数据成功");
        //print(response.data["data"]);
        data = response.data["data"];
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

    //dataWidget = [];

    /* for (int i = 0; i < data.length; i++) {
      int id_ = data[i]["id"];
      DateTime date_ = DateTime.parse(data[i]["date"]);
      String timeStr = data[i]["time"];
      int hour = int.parse(timeStr.split(":")[0]);
      int minute = int.parse(timeStr.split(":")[1]);
      DateTime time_ = DateTime(2023, 01, 01, hour, minute);
      int sbp_ = data[i]["sbp"];
      int dbp_ = data[i]["dbp"];
      int heartRate_ = data[i]["heartRate"];
      int arm_ = data[i]["arm"];
      int feeling_ = data[i]["feeling"];
      String remark_ = data[i]["remark"] ?? "暂无备注";
      data[i]["isExpanded"] = 0; // 默认收起

      /* print("=====第$i条数据=====");
      print("id: $id_");
      print("date: $date_");
      print("time: $time_");
      print("sbp: $sbp_");
      print("dbp: $dbp_");
      print("heartRate: $heartRate_");
      print("arm: $arm_");
      print("feeling: $feeling_");
      print("remark: $remark_");
      print("==================="); */
    } */

    //setState(() {});
  }

  @override
  void initState() {
    // TODO: 从后端请求数据

    super.initState();
    getDataFromServer().then((_) {
      getdataWidgetList();
    });
  }

  void getWidgetList() {
    dataWidget = [];

    //TODO 要考虑到当天没有数据的情况

    // 收起时就显示一个

    if (widget.showMore == 1) {
      length = data2.length;
    } else {
      length = 1;
    }

    print("length: $length````````````````````````````````````");
    //print(data2);

    for (int i = 0; i < length; i++) {
      dataWidget.add(BloodPressureData(
        id: data2[i]["id"],
        date: widget.date,
        hour: data2[i]["hour"],
        minute: data2[i]["minute"],
        SBloodpressure: data2[i]["sbp"],
        DBloodpressure: data2[i]["dbp"],
        heartRate: data2[i]["heartRate"],
        feeling: data2[i]["feeling"],
        arm: data2[i]["arm"],
        remark: data2[i]["remark"],
        updateData: widget.updateData,
      ));
    }
  }

  void getdataWidgetList() {
    dataWidget = [];

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
      DateTime time_ = DateTime(2023, 01, 01, hour_, minute_);
      int sbp_ = data[i]["sbp"];
      int dbp_ = data[i]["dbp"];
      int heartRate_ = data[i]["heartRate"];
      int arm_ = data[i]["arm"];
      int feeling_ = data[i]["feeling"];
      String remark_ = data[i]["remark"] ?? "暂无备注";
      data[i]["isExpanded"] = 0; // 默认收起

      /* print("=====第$i条数据=====");
      print("id: $id_");
      print("date: $date_");
      print("time: $time_");
      print("sbp: $sbp_");
      print("dbp: $dbp_");
      print("heartRate: $heartRate_");
      print("arm: $arm_");
      print("feeling: $feeling_");
      print("remark: $remark_");
      print("==================="); */

      dataWidget.add(BloodPressureData(
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

    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print(
        "-----------------------------------------------------------------------");
    /* getDataFromServer().then((_) {
      getdataWidgetList();
    });

    // 收起展开的动画
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: length == 1 ? 95 : 95.0 * length,
      curve: Curves.easeInOut,
      child: SingleChildScrollView(
        child: Column(
          children: dataWidget,
        ),
      ),
    ); */

    return FutureBuilder(
      // Replace getDataFromServer with the Future you want to wait for
      future: getDataFromServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // getDataFromServer is complete, now call getdataWidgetList
          getdataWidgetList();

          // Return the AnimatedContainer here
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
          // You can return a loading indicator or placeholder here
          //return CircularProgressIndicator();
          //return Container();
          return UnconstrainedBox(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 100,
              /* child: const Center(
                child: CircularProgressIndicator(),
              ), */
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
  DateTime date;
  final VoidCallback updateView;
  final VoidCallback updateData;
  BloodPressureDataWidget(
      {Key? key,
      required this.date,
      required this.updateView,
      required this.updateData})
      : super(key: key);

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
                PageTitle(
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
    print("血压统计饼图更新 ${widget.date} ${widget.selectedDays}");

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

  BloodPressureStaticWidget({
    Key? key,
    required this.refreshData,
    required this.date,
    required this.selectedDays,
    required this.updateView,
    required this.updateDate,
  }) : super(key: key);

  @override
  State<BloodPressureStaticWidget> createState() =>
      _BloodPressureStaticWidgetState();
}

class _BloodPressureStaticWidgetState extends State<BloodPressureStaticWidget> {
  String title = "";
  int pageNum = 0;

  List<dynamic> data = [];
  List<String> seriesName = ["收缩压", "舒张压", "心率"];
  List<int> SBPTimes = [0, 0, 0, 0];
  List<int> DBPTimes = [0, 0, 0, 0];
  List<int> heartRateTimes = [0, 0, 0, 0];
  List<int> total = [0, 0, 0];
  List<int> avg = [];
  int averageSbp = 0;
  int averageDbp = 0;
  int totalTimes = 0;
  int averageHr = 0;

  Future<void> getDataFromServer() async {
    String requestStartDate = getStartDate(widget.date, widget.selectedDays);
    String requestEndDate = getFormattedDate(widget.date);
    print(
        '请求日期：$requestStartDate ~~~ $requestEndDate ??????????????????????????????????');

    // 提取登录获取的token
    var token = await storage.read(key: 'token');
    //print(value);

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/blood-pressure/get-by-filter",
        data: {
          "startDate": requestStartDate,
          "endDate": requestEndDate,
        },
      );
      if (response.data["code"] == 200) {
        print("获取血压数据成功（饼图）");
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

    print("SBPTimes: $SBPTimes");
    print("DBPTimes: $DBPTimes");
    print("heartRateTimes: $heartRateTimes");
    print("total: $total");
    print("avg: $avg");
  }

  @override
  void initState() {
    // TODO: 从后端请求数据
    super.initState();
    SBPTimes = DBPTimes = [3, 13, 5, 1];
    heartRateTimes = [4, 12, 6, 0];
    avg = [120, 99, 95];
    totalTimes = 22;
    averageSbp = 120;
    averageDbp = 99;
    averageHr = 95;
    print("饼图 initstate");
  }

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

  int getTimesData(int pageNum, int type) {
    //List<List<int>> timesData = [SBPTimes, DBPTimes, heartRateTimes];

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

  void updateData() {
    if (widget.date == DateTime(2023, 11, 18)) {
      SBPTimes = [4, 15, 7, 1];
      DBPTimes = [3, 13, 5, 1];
      heartRateTimes = [4, 12, 6, 0];
      totalTimes = 22;
      averageSbp = 120;
      averageDbp = 99;
      averageHr = 95;
      avg = [120, 99, 95];
    } else if (widget.date == DateTime(2023, 11, 11)) {
      SBPTimes = [1, 22, 5, 5];
      DBPTimes = [2, 20, 5, 3];
      heartRateTimes = [4, 17, 8, 1];
      totalTimes = 30;
      averageSbp = 111;
      averageDbp = 100;
      averageHr = 88;
      avg = [111, 100, 88];
    } else {
      SBPTimes = [1, 22, 5, 5];
      DBPTimes = [1, 7, 2, 1];
      heartRateTimes = [0, 10, 1, 0];
      totalTimes = 11;
      averageSbp = 97;
      averageDbp = 88;
      averageHr = 96;
      avg = [97, 88, 96];
    }
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
            updateDate: widget.updateDate),
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

  Widget getDataStaticWholeWidget() {
    return Center(
      child: Container(
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

                      print("右滑 页面左移动");

                      setState(() {});
                    } else if (details.primaryDelta! < -15) {
                      pageNum += 1;
                      print("左滑 页面右移动");
                      if (pageNum > 2) {
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
                          Container(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    widget.refreshData = false;
                                    pageNum -= 1;
                                    if (pageNum < 0) {
                                      pageNum = 2;
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
                                    widget.refreshData = false;
                                    pageNum += 1;
                                    if (pageNum > 2) {
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
    print('血压饼图pie更新build：${widget.date}，天数：${widget.selectedDays}');

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
    getDataFromServer();
    setTitle();
    return getDataStaticWholeWidget();
  }
}

// 更多数据按钮
class BloodPressureMoreInfoButton extends StatefulWidget {
  const BloodPressureMoreInfoButton({super.key});

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
                Navigator.pushNamed(context, 'homePage/BloodPressure/MoreData');
              },
              child: Container(
                  width: 150,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 156, 248, 243),
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

// ============================================================================

// 血压详情此页面
class BloodPressureDetails extends StatefulWidget {
  final Map arguments;
  const BloodPressureDetails({Key? key, required this.arguments});

  @override
  State<BloodPressureDetails> createState() => _BloodPressureDetailsState();
}

class _BloodPressureDetailsState extends State<BloodPressureDetails> {
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
    print("血压详情页面rebuild");
    return Scaffold(
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
          const SizedBox(
            height: 5,
          ),
          // 标题组件
          UnconstrainedBox(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              alignment: Alignment.centerLeft,
              child: const PageTitle(
                title: "血脂肪详情",
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
          ),

          //统计组件
          BloodPressureStaticWidget(
              refreshData: true,
              date: date,
              selectedDays: selectedDays,
              updateView: updateView,
              updateDate: updateDate),

          BloodPressureMoreInfoButton(),
        ]),
      ),
    );
  }
}
