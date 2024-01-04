//import 'dart:html';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../account/token.dart';
import './bloodSugarEdit.dart';
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
class BloodSugarGraph extends StatefulWidget {
  final int accountId;
  DateTime date;

  final String selectedDays;
  final UpdateDateCallback updateDate;
  BloodSugarGraph({
    Key? key,
    required this.accountId,
    required this.date,
    required this.selectedDays,
    required this.updateDate,
  }) : super(key: key);

  @override
  State<BloodSugarGraph> createState() => _BloodSugarGraphState();
}

class _BloodSugarGraphState extends State<BloodSugarGraph> {
  // 从后端请求得到的原始数据
  List<dynamic> data = [];

  // 显示的数据
  List<int> dayData = [];
  List<int> monthData = [];
  List<double> bloodSugarData = [];

  // 从后端请求数据
  Future<void> getDataFromServer() async {
    String requestStartDate = getStartDate(widget.date, widget.selectedDays);
    String requestEndDate = getFormattedDate(widget.date);

    if (widget.selectedDays == "当前的月") {
      requestEndDate = getFormattedDate(
          DateTime(widget.date.year, widget.date.month + 1, 0));
    }

    var token = await storage.read(key: 'token');

    //从后端获取数据
    final dio = Dio();
    Response response;
    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        widget.accountId >= 0
            ? "http://43.138.75.58:8080/api/blood-sugar/get-by-date-range?startDate=$requestStartDate&endDate=$requestEndDate&accountId=${widget.accountId}"
            : "http://43.138.75.58:8080/api/blood-sugar/get-by-date-range?startDate=$requestStartDate&endDate=$requestEndDate",
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

    if (data.isEmpty) {
      dayData.add(widget.date.day);
      monthData.add(widget.date.month);
      bloodSugarData.add(0);
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
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
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
class BloodSugarGraphWidget extends StatefulWidget {
  final int accountId;
  DateTime date;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  final UpdateDaysCallback updateDays;
  String selectedDays = "最近7天";
  BloodSugarGraphWidget({
    Key? key,
    required this.accountId,
    required this.date,
    required this.selectedDays,
    required this.updateView,
    required this.updateDate,
    required this.updateDays,
  }) : super(key: key);

  @override
  State<BloodSugarGraphWidget> createState() => _BloodSugarGraphWidgetState();
}

class _BloodSugarGraphWidgetState extends State<BloodSugarGraphWidget> {
  String selectedDays2 = "最近7天";

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
          Column(
            children: [
              const SizedBox(height: 5),
              DatePicker2(date: widget.date, updateDate: widget.updateDate),
              selectDaysButton,
              const SizedBox(height: 5),
            ],
          ),
          //graph,
          BloodSugarGraph(
            accountId: widget.accountId,
            date: widget.date,
            selectedDays: widget.selectedDays,
            updateDate: widget.updateDate,
          ),
        ]),
      ),
    );
  }
}

// 只展示 （有备注）
class BloodSugarData extends StatefulWidget {
  final int accountId;
  final String nickname;
  final int id;
  final DateTime date;
  final int hour;
  final int minute;
  final double bloodSugar;
  final int meal;
  final int feeling;
  final String remark;
  final VoidCallback updateData;

  const BloodSugarData({
    Key? key,
    required this.accountId,
    required this.nickname,
    required this.id,
    required this.date,
    required this.hour,
    required this.minute,
    required this.bloodSugar,
    required this.meal,
    required this.feeling,
    required this.remark,
    required this.updateData,
  }) : super(key: key);

  @override
  State<BloodSugarData> createState() => _BloodSugarDataState();
}

class _BloodSugarDataState extends State<BloodSugarData> {
  List<String> mealButtonTypes = ["空腹", "餐后", "不选"];
  List<String> feelingButtonTypes = ["开心", "还好", "不好"];
  bool showRemark = false;
  PageController pageController = PageController();

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
              style: const TextStyle(fontSize: 20, fontFamily: "BalooBhai"),
            ),
            Row(
              children: [
                const Text(
                  '血糖: ',
                  style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                ),
                Text(
                  '${widget.bloodSugar}',
                  style: const TextStyle(fontSize: 20, fontFamily: "BalooBhai"),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '进食: ${mealButtonTypes[widget.meal]}',
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BloodSugarEdit(
                    arguments: {
                      "accountId": widget.accountId,
                      "nickname": widget.nickname,
                      "bsDataId": widget.id,
                      "date": widget.date,
                    },
                  ),
                ),
              ).then((_) {
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
                  color: Color.fromRGBO(48, 48, 48, 1),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: SizedBox(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BloodSugarEdit(
                      arguments: {
                        "accountId": widget.accountId,
                        "nickname": widget.nickname,
                        "bsDataId": -1,
                        "date": widget.date,
                        "prevPage": 1,
                      },
                    ),
                  ),
                ).then((_) {
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
class BloodSugarDataList extends StatefulWidget {
  final int accountId;
  final String nickname;
  DateTime date;
  int showMore;
  final VoidCallback updateData;
  BloodSugarDataList({
    Key? key,
    required this.accountId,
    required this.nickname,
    required this.date,
    required this.showMore,
    required this.updateData,
  }) : super(key: key);

  @override
  State<BloodSugarDataList> createState() => _BloodSugarDataListState();
}

class _BloodSugarDataListState extends State<BloodSugarDataList> {
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

    try {
      response = await dio.get(
        widget.accountId >= 0
            ? "http://43.138.75.58:8080/api/blood-sugar/get-by-date?date=$requestDate&accountId=${widget.accountId}"
            : "http://43.138.75.58:8080/api/blood-sugar/get-by-date?date=$requestDate",
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
        nickname: widget.accountId >= 0 ? widget.nickname : "TriGuard",
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
      double bloodSugar_ = data[i]["bs"];
      int meal_ = data[i]["meal"];
      int feeling_ = data[i]["feeling"];
      String remark_ = data[i]["remark"] ?? "暂无备注";
      data[i]["isExpanded"] = 0; // 默认收起

      dataWidget.add(BloodSugarData(
        accountId: widget.accountId,
        nickname: widget.accountId >= 0 ? widget.nickname : "TriGuard",
        id: id_,
        date: date_,
        hour: hour_,
        minute: minute_,
        bloodSugar: bloodSugar_,
        meal: meal_,
        feeling: feeling_,
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
class BloodSugarDataWidget extends StatefulWidget {
  final int accountId;
  final String nickname;
  DateTime date;
  final VoidCallback updateView;
  final VoidCallback updateData;
  BloodSugarDataWidget(
      {Key? key,
      required this.accountId,
      required this.nickname,
      required this.date,
      required this.updateView,
      required this.updateData})
      : super(key: key);

  @override
  State<BloodSugarDataWidget> createState() => _BloodSugarDataWidgetState();
}

class _BloodSugarDataWidgetState extends State<BloodSugarDataWidget> {
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
    dataWidgetList = BloodSugarDataList(
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
            // 当日血糖数据 与 展开收起按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PageTitle(
                  title: "当日血糖数据",
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
class BloodSugarStaticGraph extends StatefulWidget {
  final DateTime date;
  final String selectedDays;
  final String seriesName;
  final UpdateDateCallback updateDate;
  final List<int> dataTimes;
  const BloodSugarStaticGraph({
    Key? key,
    required this.date,
    required this.selectedDays,
    required this.updateDate,
    required this.dataTimes,
    required this.seriesName,
  }) : super(key: key);

  @override
  State<BloodSugarStaticGraph> createState() => _BloodSugarStaticGraphState();
}

class _BloodSugarStaticGraphState extends State<BloodSugarStaticGraph> {
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
    //   print("血压统计饼图更新 ${widget.date} ${widget.selectedDays}");

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
class BloodSugarStaticWidget extends StatefulWidget {
  final int accountId;
  final DateTime date;
  final String selectedDays;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  bool refreshData = true;

  BloodSugarStaticWidget({
    Key? key,
    required this.accountId,
    required this.date,
    required this.selectedDays,
    required this.updateView,
    required this.updateDate,
    required this.refreshData,
  }) : super(key: key);

  @override
  State<BloodSugarStaticWidget> createState() => _BloodSugarStaticWidgetState();
}

class _BloodSugarStaticWidgetState extends State<BloodSugarStaticWidget> {
  String title = "";
  int pageNum = 0;

  List<dynamic> data = [];
  List<String> seriesName = ["收缩压", "舒张压", "心率"];
  List<int> bloodSugarTimes = [0, 0, 0, 0];
  int total = 0;
  double avg = 0;

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

    if (widget.accountId >= 0) {
      params["accountId"] = widget.accountId.toString();
    }

    try {
      response = await dio.post(
        "http://43.138.75.58:8080/api/blood-sugar/get-by-filter",
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

    avg = 0;
    total = 0;
    bloodSugarTimes = [];

    bloodSugarTimes.add(data[0]["high"]);
    bloodSugarTimes.add(data[0]["medium"]);
    bloodSugarTimes.add(data[0]["low"]);
    bloodSugarTimes.add(data[0]["abnormal"]);
    total = data[0]["count"];
    // 保留两位小数
    avg = data[0]["avg"];
  }

  @override
  void initState() {
    super.initState();
    bloodSugarTimes = [0, 0, 0, 0];
    total = 0;
    avg = 0;
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("血糖",
                    style: TextStyle(
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
                  total.toString(),
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
              // 4.2378942 => 4.24
              (double.parse(avg.toStringAsFixed(2))).toString(),
              style: const TextStyle(
                  fontSize: 18,
                  fontFamily: "BalooBhai",
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              'mmol/L',
              style: TextStyle(
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
                      '${bloodSugarTimes[0]} ',
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
                      '${bloodSugarTimes[1]} ',
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
                      '${bloodSugarTimes[2]} ',
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
                      '${bloodSugarTimes[3]} ',
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

        // 图表
        BloodSugarStaticGraph(
            date: widget.date,
            selectedDays: widget.selectedDays,
            seriesName: "血糖",
            dataTimes: bloodSugarTimes,
            updateDate: widget.updateDate),
      ],
    );
  }

  Widget getDataStaticWholeWidget() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          children: [
            // 标题
            const PageTitle(
              title: "血糖统计",
              icons: "assets/icons/graph.png",
              fontSize: 18,
            ),

            // 血压统计图表文字
            Container(
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
                child: getDataStaticWidget(),
              ),
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
class BloodSugarMoreInfoButton extends StatefulWidget {
  final int accountId;
  final String nickname;
  const BloodSugarMoreInfoButton(
      {Key? key, required this.accountId, required this.nickname})
      : super(key: key);

  @override
  State<BloodSugarMoreInfoButton> createState() =>
      _BloodSugarMoreInfoButtonState();
}

class _BloodSugarMoreInfoButtonState extends State<BloodSugarMoreInfoButton> {
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
                Navigator.pushNamed(context, 'homePage/BloodSugar/MoreData',
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
                        "更多血糖详情",
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
class BloodSugarDetails extends StatefulWidget {
  final Map arguments; // 需要 accountId ， nickname，date 如果是自己的数据，accountId = -1
  const BloodSugarDetails({Key? key, required this.arguments})
      : super(key: key);

  @override
  State<BloodSugarDetails> createState() => _BloodSugarDetailsState();
}

class _BloodSugarDetailsState extends State<BloodSugarDetails> {
  DateTime date = DateTime.now();
  String selectedDays = "最近7天";
  late Widget bloodSugarGraphtWidget;

  @override
  void initState() {
    super.initState();
    if (widget.arguments["date"] == null) {
      date = DateTime.now();
    } else {
      date = widget.arguments["date"];
    }
    bloodSugarGraphtWidget = BloodSugarGraphWidget(
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
      bloodSugarGraphtWidget = BloodSugarGraphWidget(
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
    setState(() {});
  }

  void updateDate(DateTime newDate) {
    if (newDate == date) {
      return;
    }
    setState(() {
      date = newDate;
      bloodSugarGraphtWidget = BloodSugarGraphWidget(
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
    if (newDays == selectedDays) {
      return;
    }
    setState(() {
      selectedDays = newDays;
      bloodSugarGraphtWidget = BloodSugarGraphWidget(
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
    return Scaffold(
      appBar: widget.arguments["accountId"] < 0
          ? getAppBar(0, true, "TriGuard")
          : getAppBar(1, true, widget.arguments["nickname"]),

      //
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
                title: "血糖详情",
                icons: "assets/icons/bloodSugar.png",
                fontSize: 22,
              ),
            ),
          ),

          // 图表组件
          bloodSugarGraphtWidget,

          const SizedBox(
            height: 10,
          ),

          //数据列表组件
          BloodSugarDataWidget(
            accountId: widget.arguments["accountId"],
            nickname: widget.arguments["accountId"] >= 0
                ? widget.arguments["nickname"]
                : "TriGuard",
            date: date,
            updateView: updateView,
            updateData: updateData,
          ),

          //统计组件
          BloodSugarStaticWidget(
              accountId: widget.arguments["accountId"],
              refreshData: true,
              date: date,
              selectedDays: selectedDays,
              updateView: updateView,
              updateDate: updateDate),

          const SizedBox(
            height: 20,
          ),

          BloodSugarMoreInfoButton(
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
