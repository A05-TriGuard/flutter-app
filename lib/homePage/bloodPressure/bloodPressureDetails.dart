import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import '../../component/header/header.dart';
import '../../component/titleDate/titleDate.dart';
import '../../other/gradientBorder/gradient_borders.dart';
import './bpData.dart';

const List<String> method = <String>['手机号', '邮箱'];

class GraphDayDropdownButton extends StatefulWidget {
  const GraphDayDropdownButton({super.key});

  @override
  State<GraphDayDropdownButton> createState() => _GraphDayDropdownButtonState();
}

class _GraphDayDropdownButtonState extends State<GraphDayDropdownButton> {
  final List<String> items = [
    '1天',
    '3天',
    '7天',
    '一个月',
    '3个月',
  ];
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
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
              '7天',
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
            value: selectedValue,
            onChanged: (String? value) {
              setState(() {
                selectedValue = value;
              });
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              width: 100,
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

class BloodPressureGraph extends StatefulWidget {
  DateTime date;
  final VoidCallback updateView;
  BloodPressureGraph({Key? key, required this.date, required this.updateView})
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
  Widget build(BuildContext context) {
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

class BloodPressureGraphWidget extends StatefulWidget {
  final DateTime date;
  final VoidCallback updateView;
  const BloodPressureGraphWidget(
      {Key? key, required this.date, required this.updateView})
      : super(key: key);

  @override
  State<BloodPressureGraphWidget> createState() =>
      _BloodPressureGraphWidgetState();
}

class _BloodPressureGraphWidgetState extends State<BloodPressureGraphWidget> {
  @override
  Widget build(BuildContext context) {
    print(
        'BloodPressureGraphState ================================= ${widget.date}');
    return UnconstrainedBox(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GraphDayDropdownButton(),
              DatePicker2(
                date: widget.date,
                updateView: widget.updateView,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          BloodPressureGraph(
            date: widget.date,
            updateView: widget.updateView,
          ),
        ]),
      ),
    );
  }
}

// 只展示
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

// 展示所有
class BloodPressureDataList extends StatefulWidget {
  final DateTime date;
  const BloodPressureDataList({Key? key, required this.date}) : super(key: key);

  @override
  State<BloodPressureDataList> createState() => _BloodPressureDataListState();
}

class _BloodPressureDataListState extends State<BloodPressureDataList> {
  @override
  Widget build(BuildContext context) {
    return Container();
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
  int isExpanded = 0;
  List<String> buttonText = ["展开", "收起"];
  List<String> buttonIcon = [
    "assets/icons/down-arrow.png",
    "assets/icons/up-arrow.png"
  ];

  @override
  Widget build(BuildContext context) {
    print('BloodPressureDataWidget: ${widget.date}');

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
                    print("展开");

                    if (isExpanded == 0) {
                      isExpanded = 1;
                    } else {
                      isExpanded = 0;
                    }

                    // TODO
                    if (widget.date != DateTime(2022, 1, 1)) {
                      widget.date = DateTime(2022, 1, 1);
                    }
                    /* setState(() {
                      //widget.date = DateTime(2022, 1, 1);
                    }); */
                    widget.updateView();
                  },
                  child: Container(
                    //alignment: Alignment.bottomCenter,
                    // color: Colors.yellow,
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Text(
                          buttonText[isExpanded],
                          style: const TextStyle(
                              fontSize: 15,
                              fontFamily: "BalooBhai",
                              color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Image.asset(buttonIcon[isExpanded],
                            width: 15, height: 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 血压数据（默认展示一个）
            BloodPressureData(
                id: 1,
                hour: 8,
                minute: 30,
                SBloodpressure: 120,
                DBloodpressure: 80,
                heartRate: 80,
                feeling: 0,
                arm: 0),
          ],
        ),
      ),
    );
  }
}

// 此页面
class BloodPressureDetails extends StatefulWidget {
  final Map arguments;
  const BloodPressureDetails({Key? key, required this.arguments});

  @override
  State<BloodPressureDetails> createState() => _BloodPressureDetailsState();
}

class _BloodPressureDetailsState extends State<BloodPressureDetails> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('主要：${widget.arguments}');
  }

  void updateView() {
    print("血压详情页面更新");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
              child: PageTitle(
                  title: "血压详情", icons: "assets/icons/bloodPressure.png"),
            ),
          ),
          BloodPressureGraphWidget(
            date: widget.arguments["date"],
            updateView: updateView,
          ),
          BloodPressureDataWidget(
            date: widget.arguments["date"],
            updateView: updateView,
          ),
        ]),
      ),
    );
  }
}
