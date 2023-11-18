import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import '../../component/header/header.dart';
import '../../component/titleDate/titleDate.dart';
import '../../other/gradientBorder/gradient_borders.dart';
import './bpData.dart';

const List<String> method = <String>['手机号', '邮箱'];
typedef UpdateDateCallback = void Function(DateTime newDate);

// 图表天数选择
class GraphDayDropdownButton extends StatefulWidget {
  //final UpdateDateCallback updateDate;
  final VoidCallback updateView;
  final Function(String) updateDays;
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
    print("血压图表天数显示刷新 ${widget.selectedValue}");
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "显示：",
          style: const TextStyle(fontSize: 15, fontFamily: "BalooBhai"),
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
  List<String> dateData = [
    '8-11',
    '9-11',
    '10-11',
    '11-11',
    '12-11',
    '13-11',
    '14-11',
    '15-11',
    '16-11'
  ];
  List<int> day = [8, 9, 10, 11, 12, 13, 14, 15, 16];
  List<int> month = [11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11];
  //List<int> dateData = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  List<int> sbpData = [102, 120, 112, 123, 106, 105, 105, 105, 106];
  List<int> dbpData = [86, 82, 95, 80, 83, 85, 85, 85, 86];
  List<int> heartRateData = [97, 93, 92, 97, 100, 95, 95, 95, 93];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print('血压图表更新：${widget.date}');
    //widget.updateDate(widget.date);
  }

  // 从后端请求当天的数据
  void updateGraph() {
    List<int> heartRateData1 = [97, 93, 92, 97, 100, 95, 95, 95, 93];
    List<int> heartRateData2 = [88, 87, 88, 88, 111, 87, 100, 88, 100];
    List<int> heartRateData3 = [77, 77, 77, 77, 60, 69, 60, 60, 60];
    List<int> heartRateData4 = [100, 110, 120, 110, 100, 90, 80, 70, 60];
    if (widget.date == DateTime(2023, 11, 17)) {
      heartRateData = heartRateData1;
    } else if (widget.date == DateTime(2023, 11, 11)) {
      heartRateData = heartRateData2;
    } else if (widget.date == DateTime(2023, 11, 18)) {
      heartRateData = heartRateData3;
    } else {
      heartRateData = heartRateData4;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('血压图表更新build：${widget.date}，天数：${widget.selectedDays}');
    updateGraph();
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.35,
        alignment: Alignment.centerRight,
        child: Container(
          //width: MediaQuery.of(context).size.width * 0.85,
          //height: MediaQuery.of(context).size.height * 0.35,
          alignment: Alignment.centerRight,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: GradientBoxBorder(
              gradient: LinearGradient(colors: [
                Color.fromARGB(146, 253, 69, 69),
                Color.fromARGB(157, 255, 199, 223)
              ]),
              width: 1,
            ),
            boxShadow: [
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
                width: dateData.length * 65,
                height: MediaQuery.of(context).size.height * 0.35,
                child: Echarts(
                  extraScript: '''
                  var month = $month;
                  var day = $day;
                  
''',
                  option: '''
              {
                animation:false,

                title: {
                  text: '血压',
                  top:'5%',
                  left:'2%',
                },

                legend: {
                  data: ['收缩压', '舒张压', '心率'],
                  top:'6%',
                  left:'10%',
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
                   formatter: function(index) {
                        // 自定义显示格式
                         return day[index] + '/' + month[index]; // 取日期的第一部分
                   }
                  },


                  //data: $dateData // 我想要的是这样['8/11', '9/11', '10/11','11/11','12/11','13/11','14/11','15/11','16/11'],
                },

                yAxis: {
                  type: 'value',
                  //min: 80,
                  //max: 130,
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
  }
}

// 日期选择器 与 血压图表 组件
class BloodPressureGraphWidget extends StatefulWidget {
  DateTime date;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  String selectedDays = "最近7天";
  BloodPressureGraphWidget(
      {Key? key,
      required this.date,
      required this.selectedDays,
      required this.updateView,
      required this.updateDate})
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

  void updateDays(String newDays) {
    print("更新天数 ${newDays}");
    setState(() {
      selectedDays2 = newDays;
      widget.selectedDays = newDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('血压图表组件更新（日期与图表） ${widget.date}, ${selectedDays2}');

    /* BloodPressureGraph graph =  BloodPressureGraph(
      date: widget.date,
      selectedDays: widget.selectedDays,
      updateDate: widget.updateDate,
    ); */

    GraphDayDropdownButton selectDaysButton = GraphDayDropdownButton(
      updateView: widget.updateView,
      updateDays: updateDays,
      selectedValue: selectedDays2,
      //selectedValue: widget.selectedDays,
    );

    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //GraphDayDropdownButton(updateView: widget.updateView),
              selectDaysButton,
              DatePicker2(date: widget.date, updateDate: widget.updateDate),
            ],
          ),
          //graph,
          BloodPressureGraph(
            date: widget.date,
            selectedDays: selectedDays2,
            //selectedDays: widget.selectedDays,
            updateDate: widget.updateDate,
          ),
        ]),
      ),
    );
  }
}

// 只展示 （没有备注）
class BloodPressureData extends StatefulWidget {
  final int id;
  final int hour;
  final int minute;
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int arm;
  final int feeling;

  const BloodPressureData(
      {Key? key,
      required this.id,
      required this.hour,
      required this.minute,
      required this.SBloodpressure,
      required this.DBloodpressure,
      required this.heartRate,
      required this.feeling,
      required this.arm})
      : super(key: key);

  @override
  State<BloodPressureData> createState() => _BloodPressureDataState();
}

class _BloodPressureDataState extends State<BloodPressureData> {
  List<String> armButtonTypes = ["左手", "右手", "不选"];
  List<String> feelingButtonTypes = ["开心", "还好", "不好"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color.fromRGBO(0, 0, 0, 0.2),
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  offset: Offset(0, 5),
                  blurRadius: 5.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                      '${widget.hour < 10 ? "0${widget.hour}" : widget.hour}:${widget.minute < 10 ? "0${widget.minute}" : widget.minute}',
                      style: const TextStyle(
                          fontSize: 16, fontFamily: "BalooBhai")),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '血压: ${widget.SBloodpressure} / ${widget.DBloodpressure}',
                          style: const TextStyle(
                              fontSize: 16, fontFamily: "BalooBhai")),
                      Text('心率: ${widget.heartRate} ',
                          style: const TextStyle(
                              fontSize: 16, fontFamily: "BalooBhai")),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('手臂: ${armButtonTypes[widget.arm]}',
                          style: const TextStyle(
                              fontSize: 16, fontFamily: "BalooBhai")),
                      Text('感觉: ${feelingButtonTypes[widget.feeling]}',
                          style: const TextStyle(
                              fontSize: 16, fontFamily: "BalooBhai")),
                    ],
                  ),
                ],
              ),
            ))
      ],
    );
  }
}

// 只展示 （有备注）
class BloodPressureData2 extends StatefulWidget {
  final int id;
  final int hour;
  final int minute;
  final int SBloodpressure;
  final int DBloodpressure;
  final int heartRate;
  final int arm;
  final int feeling;
  final String remark;

  BloodPressureData2({
    Key? key,
    required this.id,
    required this.hour,
    required this.minute,
    required this.SBloodpressure,
    required this.DBloodpressure,
    required this.heartRate,
    required this.feeling,
    required this.arm,
    required this.remark,
  }) : super(key: key);

  @override
  State<BloodPressureData2> createState() => _BloodPressureData2State();
}

class _BloodPressureData2State extends State<BloodPressureData2> {
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
        /* boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            offset: Offset(0, 5),
            blurRadius: 5.0,
            spreadRadius: 0.0,
          ),
        ], */
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
                '${widget.hour < 10 ? "0${widget.hour}" : widget.hour}:${widget.minute < 10 ? "0${widget.minute}" : widget.minute}',
                style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai")),
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
        /* boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            offset: Offset(0, 5),
            blurRadius: 5.0,
            spreadRadius: 0.0,
          ),
        ], */
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Text(
                "备注",
                style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "BalooBhai",
                    fontWeight: FontWeight.bold),
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

      child: Column(
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
    );
  }
}

// 展示所有
class BloodPressureDataList extends StatefulWidget {
  DateTime date;
  int showMore;
  BloodPressureDataList({Key? key, required this.date, required this.showMore})
      : super(key: key);

  @override
  State<BloodPressureDataList> createState() => _BloodPressureDataListState();
}

class _BloodPressureDataListState extends State<BloodPressureDataList> {
  List<Map> data = bpdata;
  List<Widget> dataWidgetList = [];

  @override
  void initState() {
    // TODO: 从后端请求数据

    super.initState();
  }

  void getWidgetList() {
    dataWidgetList = [];

    // 收起时就显示一个
    int length = 1;
    if (widget.showMore == 1) {
      length = data.length;
    }

    for (int i = 0; i < length; i++) {
      dataWidgetList.add(BloodPressureData2(
        id: data[i]["id"],
        hour: data[i]["hour"],
        minute: data[i]["minute"],
        SBloodpressure: data[i]["sbp"],
        DBloodpressure: data[i]["dbp"],
        heartRate: data[i]["heartRate"],
        feeling: data[i]["feeling"],
        arm: data[i]["arm"],
        remark: data[i]["remark"],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    getWidgetList();
    return Column(
      children: dataWidgetList,
    );
  }
}

//展示列表数据接口
class BloodPressureDataWidget extends StatefulWidget {
  DateTime date;
  final VoidCallback updateView;
  BloodPressureDataWidget(
      {Key? key, required this.date, required this.updateView})
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
    dataWidgetList = BloodPressureDataList(date: widget.date, showMore: 0);
  }

  @override
  Widget build(BuildContext context) {
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
                PageTitle(title: "当日血压数据", icons: "assets/icons/graph.png"),

                //展开按钮 -> 显示当天所有的血压数据
                GestureDetector(
                  onTap: () {
                    if (showMore == 0) {
                      print("展开");
                      showMore = 1;
                    } else {
                      print("收起");
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
                      dataWidgetList = BloodPressureDataList(
                          date: widget.date, showMore: showMore);
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

            // 血压数据（默认展示一个）
            /*  BloodPressureData2(
              id: 1,
              hour: 8,
              minute: 30,
              SBloodpressure: 120,
              DBloodpressure: 80,
              heartRate: 80,
              feeling: 0,
              arm: 0,
              remark:
                  "测试备注哈哈哈哈哈哈！山东黄金卡的健身卡的克里斯多夫打扫房间看对方ksfkls3劳务费3监控方式罗斯福2犯得上发生访问二分",
            ), */

            //BloodPressureDataList(date: widget.date, showMore: showMore),
            dataWidgetList,
          ],
        ),
      ),
    );
  }
}

class BloodPressureStaticGraph extends StatefulWidget {
  final DateTime date;
  //final String selectedDays;
  final UpdateDateCallback updateDate;
  const BloodPressureStaticGraph(
      {Key? key,
      required this.date,
      //required this.selectedDays,
      required this.updateDate})
      : super(key: key);

  @override
  State<BloodPressureStaticGraph> createState() =>
      _BloodPressureStaticGraphState();
}

class _BloodPressureStaticGraphState extends State<BloodPressureStaticGraph> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Text(widget.date.toString()), /* Text(widget.selectedDays) */
      ]),
    );
  }
}

// 血压的基础统计组件
class BloodPressureStaticWidget extends StatefulWidget {
  final DateTime date;
  //final String selectedDays;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  const BloodPressureStaticWidget(
      {Key? key,
      required this.date,
      // required this.selectedDays,
      required this.updateView,
      required this.updateDate})
      : super(key: key);

  @override
  State<BloodPressureStaticWidget> createState() =>
      _BloodPressureStaticWidgetState();
}

class _BloodPressureStaticWidgetState extends State<BloodPressureStaticWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(widget.date.toString()),
          //Text(widget.selectedDays),
          BloodPressureStaticGraph(
              date: widget.date,
              //selectedDays: widget.selectedDays,
              updateDate: widget.updateDate)
        ],
      ),
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
    print('主要：${widget.arguments}');
    date = widget.arguments["date"];
    bloodPressureGraphtWidget = BloodPressureGraphWidget(
      date: date,
      selectedDays: selectedDays,
      updateView: updateView,
      updateDate: updateDate,
    );
  }

  void updateView() {
    print("血压详情页面更新");
    setState(() {});
  }

  void updateDate(DateTime newDate) {
    setState(() {
      date = newDate;
      bloodPressureGraphtWidget = BloodPressureGraphWidget(
        date: date,
        selectedDays: selectedDays,
        updateView: updateView,
        updateDate: updateDate,
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
        // white background
        color: Colors.white,
        child: ListView(shrinkWrap: true, children: [
          /* TitleDate(
              title: "血压详情",
              icons: "assets/icons/bloodPressure.png",
              date: DateTime.now()), */
          UnconstrainedBox(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              alignment: Alignment.centerLeft,
              child: const PageTitle(
                  title: "血压详情", icons: "assets/icons/bloodPressure.png"),
            ),
          ),

          /* BloodPressureGraphWidget(
            date: date,
            updateView: updateView,
            updateDate: updateDate,
          ), */
          bloodPressureGraphtWidget,
          BloodPressureDataWidget(
            date: date,
            updateView: updateView,
          ),
          BloodPressureStaticWidget(
              date: date, updateView: updateView, updateDate: updateDate)
        ]),
      ),
    );
  }
}
