import 'package:flutter/material.dart';
//import '../component/mainPagesBar/mainPagesBar.dart';
import '../component/header/header.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import '../other/gradientBorder/gradient_borders.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? selectedDate;

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
    final formattedDate = selectedDate != null
        ? "${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日"
        : "${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日";

    return Scaffold(
        appBar: AppBar(
          /* leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ), */

          /* title: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: const Text(
            "TriGuard",
            style: TextStyle(
                fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
          ),
        ), */

          title: const Text(
            "TriGuard",
            style: TextStyle(
                fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
          ),
          /* actions: [
            IconButton(
              icon: Icon(
                Icons.search,
              ),
              onPressed: () {
                print("搜索");
              },
              color: Colors.black,
            )
          ], */
          //flexibleSpace: header,
          //toolbarHeight: 45,
          //toolbarHeight: MediaQuery.of(context).size.height * 0.1,
          flexibleSpace: getHeader(MediaQuery.of(context).size.width,
              (MediaQuery.of(context).size.height * 0.1 + 11)),

          //toolbarHeight: 45,
        ),
        /* body: const Center(
        child: Text("首页"),
      ), */

        body: Container(
          // white background
          color: Colors.white,
          child: ListView(
            shrinkWrap: true,
            children: [
              /* Container(
            height: 1,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 169, 171, 179),
            ),
          ), */
              // 日期选择
              Container(
                child: Container(
                  alignment: Alignment.center,
                  //width: 300,
                  //color: const Color.fromARGB(255, 255, 255, 255),
                  color: Colors.transparent,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 20, fontFamily: "BalooBhai"),
                        ),
                        //const SizedBox(height: 5),
                        //ElevatedButton(
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
              /*    const SizedBox(
            height: 5,
          ), */

              // 今日血压
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "今日血压",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                              Image.asset("assets/icons/bloodPressure.png",
                                  width: 25, height: 25),
                            ]),
                      ),
                      Container(
                        child: const Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "112/95",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(165, 51, 51, 1)),
                              ),
                              SizedBox(width: 5),
                              Text("mmHg",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.edit),
                            ]),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              // 血压图表
              UnconstrainedBox(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.25,
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
                  alignment: Alignment.centerRight,
                  child: Echarts(
                    option: '''
              {
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
                  min: 80,
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

              // -----------------------------------------------------------------------------------------
              // -----------------------------------------------------------------------------------------
              // -----------------------------------------------------------------------------------------
              // -----------------------------------------------------------------------------------------
              // -----------------------------------------------------------------------------------------

              const SizedBox(
                height: 15,
              ),

              /*    const SizedBox(
            height: 5,
          ), */

              // 今日血糖
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "今日血糖",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                              Image.asset("assets/icons/sugar-blood-level.png",
                                  width: 25, height: 25),
                            ]),
                      ),
                      Container(
                        child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "8.8",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(165, 51, 51, 1)),
                              ),
                              const SizedBox(width: 5),
                              const Text("mmol/L",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.edit),
                            ]),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              // 血糖图表
              UnconstrainedBox(
                child: Container(
                  child: Echarts(
                    option: '''
              {
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
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 95, 95, 95),
                        offset: Offset(0, 0),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  alignment: Alignment.centerRight,
                ),
              ),

              // -----------------------------------------------------------------------------------------
              // -----------------------------------------------------------------------------------------
              // -----------------------------------------------------------------------------------------
              // -----------------------------------------------------------------------------------------
              // -----------------------------------------------------------------------------------------

              const SizedBox(
                height: 15,
              ),

              /*    const SizedBox(
            height: 5,
          ), */

              // 今日血糖
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "今日血脂",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                              Image.asset("assets/icons/blood-count-test.png",
                                  width: 25, height: 25),
                            ]),
                      ),
                      Container(
                        child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "3.4",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(165, 51, 51, 1)),
                              ),
                              const SizedBox(width: 5),
                              const Text("mmol/L",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.edit),
                            ]),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              // 血脂图表
              UnconstrainedBox(
                child: Container(
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 95, 95, 95),
                        offset: Offset(0, 0),
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

              // 运动
              const SizedBox(
                height: 15,
              ),

              /*    const SizedBox(
            height: 5,
          ), */

              // 今日血糖
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "今日运动",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                              Image.asset("assets/icons/blood-count-test.png",
                                  width: 25, height: 25),
                            ]),
                      ),
                      Container(
                        child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "3.4",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(165, 51, 51, 1)),
                              ),
                              const SizedBox(width: 5),
                              const Text("mmol/L",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.edit),
                            ]),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              // 血脂图表
              UnconstrainedBox(
                child: Container(
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 95, 95, 95),
                        offset: Offset(0, 0),
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
      axisLabel: {
        formatter: '{value}'
      }
    },
    {
      type: 'value',
      name: '运动时长',
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

              // 饮食
              const SizedBox(
                height: 15,
              ),

              /*    const SizedBox(
            height: 5,
          ), */

              // 今日血糖
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "今日饮食",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                              Image.asset("assets/icons/blood-count-test.png",
                                  width: 25, height: 25),
                            ]),
                      ),
                      Container(
                        child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "3.4",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(165, 51, 51, 1)),
                              ),
                              const SizedBox(width: 5),
                              const Text("mmol/L",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.edit),
                            ]),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              // 血脂图表
              UnconstrainedBox(
                child: Container(
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 95, 95, 95),
                        offset: Offset(0, 0),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: Echarts(
                    option: '''
             {
            title:{
text: '饮食',
    top:'5%',
    left:'2%',
            },
  tooltip: {
    trigger: 'item'
  },

  grid: {
                left: '3%',
                right: '4%',
                bottom: '5%',
                containLabel: true
              },
  legend: {
    top: '5%',
    left: '40%',
    // doesn't perfectly work with our tricks, disable it
    selectedMode: false
  },
  series: [
    {
      name: 'Meal Calories',
      type: 'pie',
      radius: ['40%', '70%'],
      center: ['50%', '70%'],
      // adjust the start angle
      startAngle: 180,
      label: {
        show: true,
        formatter(param) {
          // correct the percentage
          return param.value+'千卡';
        }
      },
      data: [
        { value: 400, name: '早餐' },
        { value: 600, name: '午餐' },
        { value: 500, name: '晚餐' },
        { value: 300, name: '其他' },
        {
          // make a record to fill the bottom 50%
          value: 400 + 600 + 500 + 300,
          itemStyle: {
            // stop the chart from rendering this piece
            color: 'none',
            decal: {
              symbol: 'none'
            }
          },
          label: {
            show: false
          }
        }
      ]
    }
  ]
}
            ''',
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
