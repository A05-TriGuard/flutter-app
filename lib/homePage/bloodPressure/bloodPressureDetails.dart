import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import '../../component/header/header.dart';
import '../../component/titleDate/titleDate.dart';
import '../../other/gradientBorder/gradient_borders.dart';
import './bpData.dart';

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
    //print('血压图表更新build：${widget.date}，天数：${widget.selectedDays}');
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
            //selectedDays: selectedDays2,
            selectedDays: widget.selectedDays,
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

  const BloodPressureData2({
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
// ignore: must_be_immutable
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
  int length = 1;

  @override
  void initState() {
    // TODO: 从后端请求数据

    super.initState();
  }

  void getWidgetList() {
    dataWidgetList = [];

    //TODO 要考虑到当天没有数据的情况

    // 收起时就显示一个

    if (widget.showMore == 1) {
      length = data.length;
    } else {
      length = 1;
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
    /* return Column(
      children: dataWidgetList,
    ); */

    // 收起展开的动画
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: length == 1 ? 95 : 95.0 * length,
      curve: Curves.easeInOut,
      child: SingleChildScrollView(
        child: Column(
          children: dataWidgetList,
        ),
      ),
    );
  }
}

//展示列表数据接口
// ignore: must_be_immutable
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
    // print('血压展示列表数据更新: ${widget.date}');

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
                PageTitle(title: "当日血压数据", icons: "assets/icons/list.png"),

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
    // print("血压统计饼图更新 ${widget.date} ${widget.selectedDays}");
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
class BloodPressureStaticWidget extends StatefulWidget {
  final DateTime date;
  final String selectedDays;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;

  const BloodPressureStaticWidget({
    Key? key,
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
  List<String> buttonText = ["展开", "收起"];
  List<String> buttonIcon = [
    "assets/icons/down-arrow.png",
    "assets/icons/up-arrow.png"
  ];

  List<int> bloodPressureTimes = [0, 0, 0, 0];
  List<int> heartRateTimes = [0, 0, 0, 0];
  int averageSbp = 0;
  int averageDbp = 0;
  int totalTimes = 0;
  int averageHr = 0;

  @override
  void initState() {
    // TODO: 从后端请求数据
    super.initState();
    bloodPressureTimes = [3, 13, 5, 1];
    heartRateTimes = [4, 12, 6, 0];
    totalTimes = 22;
    averageSbp = 120;
    averageDbp = 99;
    averageHr = 95;
  }

  void updateData() {
    if (widget.date == DateTime(2023, 11, 18)) {
      bloodPressureTimes = [3, 13, 5, 1];
      heartRateTimes = [4, 12, 6, 0];
      totalTimes = 22;
      averageSbp = 120;
      averageDbp = 99;
      averageHr = 95;
    } else if (widget.date == DateTime(2023, 11, 11)) {
      bloodPressureTimes = [2, 20, 5, 3];
      heartRateTimes = [4, 17, 8, 1];
      totalTimes = 30;
      averageSbp = 111;
      averageDbp = 100;
      averageHr = 88;
    } else {
      bloodPressureTimes = [1, 7, 2, 1];
      heartRateTimes = [0, 10, 1, 0];
      totalTimes = 11;
      averageSbp = 97;
      averageDbp = 88;
      averageHr = 96;
    }
  }

  void setTitle() {
    if (widget.selectedDays == "当前的天") {
      title = "${widget.date.year}年${widget.date.month}月${widget.date.day}日";
    } else if (widget.selectedDays == "当前的月") {
      title = "${widget.date.year}年${widget.date.month}月";
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pageNum == 0 ? "血压" : "心率",
                style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "BalooBhai",
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              width: 2,
            ),
            Image.asset(
              pageNum == 0
                  ? "assets/icons/bloodPressure1.png"
                  : "assets/icons/heartRate.png",
              height: 15,
              width: 15,
            ),
          ],
        ),

        // 标题
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
              '${totalTimes} ',
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
            Text(
              pageNum == 0 ? '血压平均值：' : '心率平均值：',
              style: const TextStyle(
                  fontSize: 14,
                  fontFamily: "BalooBhai",
                  fontWeight: FontWeight.bold),
            ),
            Text(
              pageNum == 0 ? '${averageSbp} / ${averageDbp} ' : '${averageHr} ',
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
                      pageNum == 0
                          ? '${bloodPressureTimes[0]} '
                          : '${heartRateTimes[0]} ',
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
                      pageNum == 0
                          ? '${bloodPressureTimes[1]} '
                          : '${heartRateTimes[1]} ',
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
                      pageNum == 0
                          ? '${bloodPressureTimes[2]} '
                          : '${heartRateTimes[2]} ',
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
                      pageNum == 0
                          ? '${bloodPressureTimes[3]} '
                          : '${heartRateTimes[3]} ',
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
        pageNum == 0
            ? BloodPressureStaticGraph(
                date: widget.date,
                selectedDays: widget.selectedDays,
                seriesName: "血压",
                dataTimes: bloodPressureTimes,
                updateDate: widget.updateDate)
            : BloodPressureStaticGraph(
                date: widget.date,
                selectedDays: widget.selectedDays,
                seriesName: "心率",
                dataTimes: heartRateTimes,
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
              color: pageNum == 0 ? Colors.grey : Colors.blue,
              borderRadius: BorderRadius.circular(5),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setTitle();
    updateData();

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          children: [
            // 标题
            PageTitle(title: "血压心率统计", icons: "assets/icons/graph.png"),

            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (details.primaryDelta! > 10) {
                      setState(() {
                        pageNum = 0;
                      });
                    } else if (details.primaryDelta! < -10) {
                      setState(() {
                        pageNum = 1;
                      });
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
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstChild: getDataStaticWidget(),
                        secondChild: getDataStaticWidget(),
                        crossFadeState: pageNum == 0
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
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
}

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
    date = widget.arguments["date"];
    bloodPressureGraphtWidget = BloodPressureGraphWidget(
      date: date,
      selectedDays: selectedDays,
      updateView: updateView,
      updateDate: updateDate,
      updateDays: updateDays,
    );
  }

  void updateView() {
    //print("血压详情页面更新");
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
        updateDays: updateDays,
      );
    });
  }

  void updateDays(String newDays) {
    //print("血压详情页面更新天数 ${newDays}");
    setState(() {
      selectedDays = newDays;
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
          // 标题组件
          UnconstrainedBox(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              alignment: Alignment.centerLeft,
              child: const PageTitle(
                  title: "血压详情", icons: "assets/icons/bloodPressure.png"),
            ),
          ),

          // 血压图表组件
          bloodPressureGraphtWidget,

          //数据列表组件
          BloodPressureDataWidget(
            date: date,
            updateView: updateView,
          ),

          //统计组件
          BloodPressureStaticWidget(
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
