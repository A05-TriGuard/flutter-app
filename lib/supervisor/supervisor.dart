import 'package:flutter/material.dart';
import '../component/header/header.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

class Supervisor extends StatefulWidget {
  const Supervisor({super.key});

  @override
  State<Supervisor> createState() => _SupervisorState();
}

class _SupervisorState extends State<Supervisor> {
  List<int> systolicPressureData = [
    102,
    120,
    112,
    123,
    106,
    105,
    105,
    105,
    106
  ];
  List<int> diastolicPressureData = [86, 82, 95, 80, 83, 85, 85, 85, 86];
  List<int> heartRateData = [97, 93, 92, 97, 100, 95, 95, 95, 93];

  void _updateChartData() {
    setState(() {
      systolicPressureData =
          systolicPressureData.map((value) => value + 1).toList();
      diastolicPressureData =
          diastolicPressureData.map((value) => value + 1).toList();
      heartRateData = heartRateData.map((value) => value + 1).toList();
    });
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
        // flexibleSpace: header,
        // toolbarHeight: 45,
        flexibleSpace: getHeader(MediaQuery.of(context).size.width,
            (MediaQuery.of(context).size.height * 0.1 + 11)),
      ),
      /* body: const Center(
        child: Text("文章/资讯"),
      ), */

      body: Column(children: [
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: _updateChartData,
          child: Text('更新数据'),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.35,
          alignment: Alignment.centerRight,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 95, 95, 95),
                offset: Offset(0, 0),
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
                width: 9 * 65,
                height: MediaQuery.of(context).size.height * 0.35,
                child: Echarts(
                  option: '''
              {
                legend: {
                  data: ['收缩压', '舒张压', '心率'],
                  top:'10%',
                  left:'5%',
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
                  },
                  data: ['8/11', '9/11', '10/11','11/11','12/11','13/11','14/11','15/11','16/11']
                },
                yAxis: {
                  type: 'value',
                  //min: 80,
                  //max: 130,
                },
                series: [{
                  name: '收缩压',
                  data: $systolicPressureData,
                  type: 'line',
                  smooth: true
                },
                {
                  name: '舒张压',
                  data: $diastolicPressureData,
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
      ]),
    );
  }
}
