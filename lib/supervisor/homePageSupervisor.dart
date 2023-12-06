import 'package:flutter/material.dart';
//import '../component/mainPagesBar/mainPagesBar.dart';
import '../component/header/header.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
//import '../other/gradientBorder/gradient_borders.dart';
import '../component/titleDate/titleDate.dart';

class MyTitle extends StatefulWidget {
  final String title;
  final String icon;
  final String value;
  final String unit;
  final String route;

  const MyTitle(
      {Key? key,
      required this.title,
      required this.icon,
      required this.value,
      required this.unit,
      required this.route})
      : super(key: key);

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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    SizedBox(width: 5),
                    Text(widget.unit,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.edit),
                        iconSize: 25,
                        onPressed: () {
                          Navigator.pushNamed(context, widget.route);
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
  final String value;
  int accountId = 0;
  MyBloodPressure({Key? key, required this.value, required this.accountId})
      : super(key: key);

  @override
  State<MyBloodPressure> createState() => _MyBloodPressureState();
}

class _MyBloodPressureState extends State<MyBloodPressure> {
  @override
  Widget build(BuildContext context) {
    print("血压rebuild 值：${widget.value}");
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MyTitle(
            title: "今日血压",
            icon: "assets/icons/bloodPressure.png",
            value: widget.value,
            unit: "mmHg",
            route: "/homePage/BloodPressure/Edit"),

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
                height: MediaQuery.of(context).size.height * 0.25,
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
                child: Echarts(
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
                top:'5%',
                left:'20%',
              },
            
                grid: {
                left: '3%',
                right: '4%',
                bottom: '5%',
                containLabel: true
              },
              tooltip: {
                trigger: 'axis'
              },
                xAxis: {
                  
                  type: 'category',
                  boundaryGap: true,
                  data: ['8/11', '9/11', '10/11','11/11']
                },
                yAxis: {
                  type: 'value',
                  min: 70,
                  max: 130,
                },
                series: [{
                  name: '收缩压',
                  data: [102, 120, 112,123],
                  type: 'line',
                  smooth: true,
                  // itemStyle: {
                  //     normal: {
                  //         color: "#FD3F61",
                  //         lineStyle: {
                  //             color: "#FF8C4B"
                  //         }
                  //     }
                  // },
                },
                {
                  name: '舒张压',
                  data: [86, 82, 95,80],
                  type: 'line',
                  smooth: true
                },

                 {
                  name: '心率',
                  data: [97, 93, 92,97],
                  type: 'line',
                  smooth: true
                }
                ]
              }
            ''',
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/homePage/BloodPressure/Details");
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
        ),
      ],
    );
  }
}

class MyBloodSugar extends StatefulWidget {
  final String value;
  int accountId = 0;
  MyBloodSugar({Key? key, required this.value, required this.accountId})
      : super(key: key);

  @override
  State<MyBloodSugar> createState() => _MyBloodSugarState();
}

class _MyBloodSugarState extends State<MyBloodSugar> {
  @override
  Widget build(BuildContext context) {
    print("血糖rebuild");
    return Column(
      children: [
        MyTitle(
            title: "今日血糖",
            icon: "assets/icons/bloodSugar.png",
            value: widget.value,
            unit: "mmol/L",
            route: "/homePage/BloodSugar/Edit"), //TODO

        const SizedBox(
          height: 5,
        ),

        // 血糖图表
        Stack(alignment: Alignment.centerRight, children: [
          UnconstrainedBox(
            child: Container(
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
              alignment: Alignment.centerRight,
              child: Echarts(
                option: '''
              {
                animation:false,
                title: {
    text: '血糖',
    top:'5%',
    left:'2%',
  },
                legend: {
    data: ['血糖'],
    top:'5%',
    //left:'20%',
  },
 
    grid: {
    left: '3%',
    right: '4%',
    bottom: '5%',
    containLabel: true
  },
  tooltip: {
    trigger: 'axis'
  },
                xAxis: {
                  
                  type: 'category',
                  //boundaryGap: false,
                  data: ['8/11', '9/11', '10/11','11/11']
                },
                yAxis: {
                  type: 'value',
                },
                series: [{
                  name: '血糖',
                  data: [5.3, 6.8, 5.9,8.8],
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
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/homePage/BloodSugar/Details");
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
  }
}

class MyBloodFat extends StatefulWidget {
  final String value;
  int accountId = 0;
  MyBloodFat({Key? key, required this.value, required this.accountId})
      : super(key: key);

  @override
  State<MyBloodFat> createState() => _MyBloodFatState();
}

class _MyBloodFatState extends State<MyBloodFat> {
  @override
  Widget build(BuildContext context) {
    print("血脂rebuild");
    return Column(children: [
      MyTitle(
          title: "今日血脂",
          icon: "assets/icons/bloodFat.png",
          value: widget.value,
          unit: "mmol/L",
          route: "/homePage/BloodFat/Edit"),
      const SizedBox(
        height: 5,
      ),
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
                text: '血脂',
                top:'5%',
                left:'2%',
              },
                            legend: {
                data: ['总胆固醇' , '高密度脂蛋白脂','甘油三酯','低密度脂蛋白脂'],
                top:'5%',
                left:'20%',
              },
            
                grid: {
                left: '3%',
                right: '4%',
                bottom: '5%',
                containLabel: true
              },
              tooltip: {
                trigger: 'axis'
              },
                xAxis: {
                  
                  type: 'category',
                  boundaryGap: true,
                  data: ['8/11', '9/11', '10/11','11/11']
                },
                yAxis: {
                  type: 'value',
                },
                series: [{
                  name: '总胆固醇',
                  data: [3.1,4.2,5.2,4.6],
                  type: 'line',
                  smooth: true
                },
                {
                  name: '甘油三酯',
                  data: [4.6,2.6,5.6,2.7],
                  type: 'line',
                  smooth: true
                },

                 {
                  name: '高密度脂蛋白脂',
                  data: [3.0,6.3,5.3,5.6],
                  type: 'line',
                  smooth: true
                },
                 {
                  name: '低密度脂蛋白脂',
                  data: [4.7,4.98,4.3,3.4],
                  type: 'line',
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
            Navigator.pushNamed(context, "/homePage/BloodFat/Details");
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

class MyActivities extends StatefulWidget {
  final String value;
  int accountId = 0;
  MyActivities({Key? key, required this.value, required this.accountId})
      : super(key: key);

  @override
  State<MyActivities> createState() => _MyActivitiesState();
}

class _MyActivitiesState extends State<MyActivities> {
  @override
  Widget build(BuildContext context) {
    print("活动rebuild");
    return Column(children: [
      MyTitle(
          title: "今日活动",
          icon: "assets/icons/exercising.png",
          value: widget.value,
          unit: "分钟",
          route: "/homePage/BloodPressure/Edit"), //TODO

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
  final String value;
  int accountId = 0;
  MyDiet({Key? key, required this.value, required this.accountId})
      : super(key: key);

  @override
  State<MyDiet> createState() => _MyDietState();
}

class _MyDietState extends State<MyDiet> {
  @override
  Widget build(BuildContext context) {
    print("饮食rebuild");
    return Column(children: [
      MyTitle(
          title: "今日饮食",
          icon: "assets/icons/meal.png",
          value: widget.value,
          unit: "千卡",
          route: "/homePage/BloodPressure/Edit"), //TODO

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
            Navigator.pushNamed(context, "/homePage/BloodPressure/Details");
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? selectedDate;
  String guardian = "妈妈";
  int accountId = 0;

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

  @override
  Widget build(BuildContext context) {
    print("监护的首页rebuild");
    final formattedDate = selectedDate != null
        ? "${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日 ${getWeekDay(selectedDate!)}"
        : "${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日 ${getWeekDay(DateTime.now())}";

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "TriGuard",
            style: TextStyle(
                fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
          ),
          flexibleSpace: getHeader(MediaQuery.of(context).size.width,
              (MediaQuery.of(context).size.height * 0.1 + 11),
              color: 1),

          automaticallyImplyLeading: true, //toolbarHeight: 45, 不显示 ← 按钮
          actions: [
            //back button
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        drawer: Drawer(
            child: ListView(children: [
          // 监护对象列表：妈妈，爸爸，爷爷，奶奶，外公，外婆
          const SizedBox(
            height: 10,
          ),
          const Text("监护对象",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'BalooBhai',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            title: const Text("妈妈"),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                guardian = "妈妈";
                accountId = 0;
              });
            },
          ),
          ListTile(
            title: const Text("爸爸"),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                guardian = "爸爸";
                accountId = 1;
              });
            },
          ),
          ListTile(
            title: const Text("爷爷"),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                guardian = "爷爷";
                accountId = 2;
              });
            },
          ),
        ])),
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
              Text(guardian,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'BalooBhai',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),

              // 日期选择
              Container(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
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
              MyBloodPressure(accountId: accountId, value: "112/95"),

              const SizedBox(
                height: 15,
              ),

              // 今日血糖
              MyBloodSugar(accountId: accountId, value: "8.8"),

              const SizedBox(
                height: 15,
              ),

              // 今日血脂
              MyBloodFat(accountId: accountId, value: "3.4"),

              const SizedBox(
                height: 15,
              ),

              MyActivities(accountId: accountId, value: "45"),

              // 运动
              const SizedBox(
                height: 15,
              ),

              // 饮食
              const SizedBox(
                height: 15,
              ),

              MyDiet(accountId: accountId, value: "1723"),

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
