//import 'dart:html';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter/material.dart';
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
class BloodFatGraph extends StatefulWidget {
  final int accountId;
  DateTime date;
  final String selectedDays;
  final UpdateDateCallback updateDate;
  BloodFatGraph({
    Key? key,
    required this.accountId,
    required this.date,
    required this.selectedDays,
    required this.updateDate,
  }) : super(key: key);

  @override
  State<BloodFatGraph> createState() => _BloodFatGraphState();
}

class _BloodFatGraphState extends State<BloodFatGraph> {
  // 从后端请求得到的原始数据
  List<dynamic> data = [];

  // 显示的数据
  List<int> dayData = [];
  List<int> monthData = [];
  List<double> tcData = [];
  List<double> tgData = [];
  List<double> ldlData = [];
  List<double> hdlData = [];

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

    if (widget.accountId >= 0) {
      params["accountId"] = widget.accountId.toString();
    }

    try {
      response = await dio.get(
          "http://43.138.75.58:8080/api/blood-lipids/get-by-date-range",
          queryParameters: params);
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

    if (data.isEmpty) {
      dayData.add(0);
      monthData.add(0);
      tcData.add(0);
      tgData.add(0);
      ldlData.add(0);
      hdlData.add(0);
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
                      width: dayData.length * 65 <= 550
                          ? 550
                          : dayData.length * 65,
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
class BloodFatGraphWidget extends StatefulWidget {
  final int accountId;
  DateTime date;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;
  final UpdateDaysCallback updateDays;
  String selectedDays = "最近7天";
  BloodFatGraphWidget(
      {Key? key,
      required this.accountId,
      required this.date,
      required this.selectedDays,
      required this.updateView,
      required this.updateDate,
      required this.updateDays})
      : super(key: key);

  @override
  State<BloodFatGraphWidget> createState() => _BloodFatGraphWidgetState();
}

class _BloodFatGraphWidgetState extends State<BloodFatGraphWidget> {
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
          BloodFatGraph(
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

// 只展示 （血脂）
class BloodFatData extends StatefulWidget {
  final int accountId;
  final String nickname;
  final int id;
  final DateTime date;
  final int hour;
  final int minute;
  final double tc;
  final double tg;
  final double ldl;
  final double hdl;
  final int feeling;
  final String remark;
  final VoidCallback updateData;

  const BloodFatData({
    Key? key,
    required this.accountId,
    required this.nickname,
    required this.id,
    required this.date,
    required this.hour,
    required this.minute,
    required this.tc,
    required this.tg,
    required this.ldl,
    required this.hdl,
    required this.feeling,
    required this.remark,
    required this.updateData,
  }) : super(key: key);

  @override
  State<BloodFatData> createState() => _BloodFatDataState();
}

class _BloodFatDataState extends State<BloodFatData> {
  List<String> mealButtonTypes = ["空腹", "餐后", "不选"];
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
                Row(
                  children: [
                    const Text(
                      '总胆固醇: ',
                      style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                    ),
                    Text(
                      '${widget.tc}',
                      style: const TextStyle(
                          fontSize: 20, fontFamily: "BalooBhai"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      '甘油三酯: ',
                      style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                    ),
                    Text(
                      '${widget.tg}',
                      style: const TextStyle(
                          fontSize: 20, fontFamily: "BalooBhai"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      '低密度脂蛋白胆固醇: ',
                      style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                    ),
                    Text(
                      '${widget.ldl}',
                      style: const TextStyle(
                          fontSize: 20, fontFamily: "BalooBhai"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      '高密度脂蛋白胆固醇: ',
                      style: TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
                    ),
                    Text(
                      '${widget.hdl}',
                      style: const TextStyle(
                          fontSize: 20, fontFamily: "BalooBhai"),
                    ),
                  ],
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
      child: Stack(alignment: Alignment.topRight, children: [
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
              "accountId": widget.accountId,
              "nickname": widget.nickname,
              "bfDataId": widget.id,
              "date": widget.date,
            };

            Navigator.pushNamed(context, '/homePage/BloodFat/Edit',
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
      ]),
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
                color: Color.fromRGBO(48, 48, 48, 1),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                var args = {
                  "accountId": widget.accountId,
                  "nickname": widget.nickname,
                  "bfDataId": -1,
                  "date": widget.date,
                };

                Navigator.pushNamed(context, '/homePage/BloodFat/Edit',
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
class BloodFatDataList extends StatefulWidget {
  final int accountId;
  final String nickname;
  final VoidCallback updateData;
  DateTime date;
  int showMore;
  BloodFatDataList(
      {Key? key,
      required this.accountId,
      required this.nickname,
      required this.date,
      required this.showMore,
      required this.updateData})
      : super(key: key);

  @override
  State<BloodFatDataList> createState() => _BloodFatDataListState();
}

class _BloodFatDataListState extends State<BloodFatDataList> {
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
            ? "http://43.138.75.58:8080/api/blood-lipids/get-by-date?date=$requestDate&accountId=${widget.accountId}"
            : "http://43.138.75.58:8080/api/blood-lipids/get-by-date?date=$requestDate",
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
      double tc_ = data[i]["tc"];
      double tg_ = data[i]["tg"];
      double ldl_ = data[i]["ldl"];
      double hdl_ = data[i]["hdl"];
      int feeling_ = data[i]["feeling"];
      String remark_ = data[i]["remark"] ?? "暂无备注";
      data[i]["isExpanded"] = 0; // 默认收起

      dataWidget.add(BloodFatData(
        accountId: widget.accountId,
        nickname: widget.nickname,
        id: id_,
        date: date_,
        hour: hour_,
        minute: minute_,
        tc: tc_,
        tg: tg_,
        ldl: ldl_,
        hdl: hdl_,
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
          double height = length * 190.0;
          if (data.isEmpty) {
            height = 90;
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            height: height,
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
class BloodFatDataWidget extends StatefulWidget {
  final int accountId;
  final String nickname;
  DateTime date;
  final VoidCallback updateView;
  final VoidCallback updateData;
  BloodFatDataWidget(
      {Key? key,
      required this.accountId,
      required this.nickname,
      required this.date,
      required this.updateView,
      required this.updateData})
      : super(key: key);

  @override
  State<BloodFatDataWidget> createState() => _BloodFatDataWidgetState();
}

class _BloodFatDataWidgetState extends State<BloodFatDataWidget> {
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
    dataWidgetList = BloodFatDataList(
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
            // 当日血脂数据 与 展开收起按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PageTitle(
                  title: "当日血脂数据",
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
class BloodFatStaticGraph extends StatefulWidget {
  final DateTime date;
  final String selectedDays;
  final String seriesName;
  final UpdateDateCallback updateDate;
  final List<int> dataTimes;
  const BloodFatStaticGraph({
    Key? key,
    required this.date,
    required this.selectedDays,
    required this.updateDate,
    required this.dataTimes,
    required this.seriesName,
  }) : super(key: key);

  @override
  State<BloodFatStaticGraph> createState() => _BloodFatStaticGraphState();
}

class _BloodFatStaticGraphState extends State<BloodFatStaticGraph> {
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
class BloodFatStaticWidget extends StatefulWidget {
  final int accountId;
  bool refreshData = true;
  final DateTime date;
  final String selectedDays;
  final VoidCallback updateView;
  final UpdateDateCallback updateDate;

  BloodFatStaticWidget({
    Key? key,
    required this.accountId,
    required this.refreshData,
    required this.date,
    required this.selectedDays,
    required this.updateView,
    required this.updateDate,
  }) : super(key: key);

  @override
  State<BloodFatStaticWidget> createState() => _BloodFatStaticWidgetState();
}

class _BloodFatStaticWidgetState extends State<BloodFatStaticWidget> {
  String title = "";
  int pageNum = 0;

  List<dynamic> data = [];
  List<String> seriesName = ["总胆固醇", "甘油三酯", "低密度脂蛋白胆固醇", "高密度脂蛋白胆固醇"];
  List<int> tcTimes = [0, 0, 0, 0];
  List<int> tgTimes = [0, 0, 0, 0];
  List<int> ldlTimes = [0, 0, 0, 0];
  List<int> hdlTimes = [0, 0, 0, 0];
  List<int> total = [0, 0, 0, 0];
  List<double> avg = [0, 0, 0, 0];

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
    var args = {
      "startDate": requestStartDate,
      "endDate": requestEndDate,
    };
    if (widget.accountId >= 0) {
      args["accountId"] = widget.accountId.toString();
    }

    try {
      response = await dio.post(
          "http://43.138.75.58:8080/api/blood-lipids/get-by-filter",
          data: args);
      if (response.data["code"] == 200) {
        data = response.data["data"]["countedDataList"];
      } else {
        data = [];
      }
    } catch (e) {
      data = [];
    }

    tcTimes = [];
    tgTimes = [];
    ldlTimes = [];
    hdlTimes = [];
    avg = [];
    total = [];

    for (int i = 0; i < data.length; i++) {
      if (i == 0) {
        tcTimes.add(data[i]["high"]);
        tcTimes.add(data[i]["medium"]);
        tcTimes.add(data[i]["low"]);
        tcTimes.add(data[i]["abnormal"]);
      } else if (i == 1) {
        tgTimes.add(data[i]["high"]);
        tgTimes.add(data[i]["medium"]);
        tgTimes.add(data[i]["low"]);
        tgTimes.add(data[i]["abnormal"]);
      } else if (i == 2) {
        ldlTimes.add(data[i]["high"]);
        ldlTimes.add(data[i]["medium"]);
        ldlTimes.add(data[i]["low"]);
        ldlTimes.add(data[i]["abnormal"]);
      }
      // HDL
      else if (i == 3) {
        hdlTimes.add(data[i]["high"]);
        hdlTimes.add(data[i]["medium"]);
        hdlTimes.add(data[i]["low"]);
        hdlTimes.add(data[i]["abnormal"]);
      }
      total.add(data[i]["count"]);
      avg.add(data[i]["avg"]);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  List<int> getTypeData(int pageNum) {
    // TC
    if (pageNum == 0) {
      return tcTimes;
    }
    // TG
    else if (pageNum == 1) {
      return tgTimes;
    }
    // LDL
    else if (pageNum == 2) {
      return ldlTimes;
    }
    // HDL
    else if (pageNum == 3) {
      return hdlTimes;
    }
    return [];
  }

  int getTimesData(int pageNum, int type) {
    // SBP
    if (pageNum == 0) {
      return tcTimes[type];
    }
    // DBP
    else if (pageNum == 1) {
      return tgTimes[type];
    }
    // HR
    else if (pageNum == 2) {
      return ldlTimes[type];
    } else if (pageNum == 3) {
      return hdlTimes[type];
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  seriesName[pageNum],
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "BalooBhai",
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 2,
                ),
                Image.asset(
                  "assets/icons/bloodLipid.png",
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
              '${(avg[pageNum]).toStringAsFixed(2)} ',
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

        // 总胆固醇，甘油三酯，低密度脂蛋白，高密度脂蛋白 饼图pie
        BloodFatStaticGraph(
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
          ),
          const SizedBox(
            width: 5,
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: pageNum == 3 ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
          )
        ],
      ),
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
              title: "血压心率统计",
              icons: "assets/icons/graph.png",
              fontSize: 18,
            ),

            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    //不用重新获取数据
                    widget.refreshData = false;

                    if (details.primaryDelta! > 15) {
                      pageNum -= 1;
                      if (pageNum < 0) {
                        pageNum = 3;
                      }

                      setState(() {});
                    } else if (details.primaryDelta! < -15) {
                      pageNum += 1;
                      if (pageNum > 3) {
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
    //print('血压饼图pie更新build：${widget.date}，天数：${widget.selectedDays}');

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
class BloodFatMoreInfoButton extends StatefulWidget {
  final int accountId;
  final String nickname;
  const BloodFatMoreInfoButton(
      {Key? key, required this.accountId, required this.nickname})
      : super(key: key);

  @override
  State<BloodFatMoreInfoButton> createState() => _BloodFatMoreInfoButtonState();
}

class _BloodFatMoreInfoButtonState extends State<BloodFatMoreInfoButton> {
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
                Navigator.pushNamed(context, 'homePage/BloodFat/MoreData',
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
                        "更多血脂详情",
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
class BloodFatDetails extends StatefulWidget {
  final Map arguments;
  // 需要 accountId ， nickname，date 如果是自己的数据，accountId = -1
  const BloodFatDetails({Key? key, required this.arguments}) : super(key: key);

  @override
  State<BloodFatDetails> createState() => _BloodFatDetailsState();
}

class _BloodFatDetailsState extends State<BloodFatDetails> {
  DateTime date = DateTime.now();
  String selectedDays = "最近7天";
  late Widget bloodFatGraphtWidget;

  @override
  void initState() {
    super.initState();
    if (widget.arguments["date"] == null) {
      date = DateTime.now();
    } else {
      date = widget.arguments["date"];
    }
    bloodFatGraphtWidget = BloodFatGraphWidget(
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
      bloodFatGraphtWidget = BloodFatGraphWidget(
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
      bloodFatGraphtWidget = BloodFatGraphWidget(
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
      bloodFatGraphtWidget = BloodFatGraphWidget(
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
                title: "血脂详情",
                icons: "assets/icons/bloodFat.png",
                fontSize: 22,
              ),
            ),
          ),

          // 血压图表组件
          bloodFatGraphtWidget,

          const SizedBox(
            height: 10,
          ),

          //数据列表组件
          BloodFatDataWidget(
            accountId: widget.arguments["accountId"],
            nickname: widget.arguments["nickname"],
            date: date,
            updateView: updateView,
            updateData: updateData,
          ),

          //统计组件
          BloodFatStaticWidget(
              accountId: widget.arguments["accountId"],
              refreshData: true,
              date: date,
              selectedDays: selectedDays,
              updateView: updateView,
              updateDate: updateDate),

          BloodFatMoreInfoButton(
            accountId: widget.arguments["accountId"],
            nickname: widget.arguments["nickname"],
          ),
        ]),
      ),
    );
  }
}
