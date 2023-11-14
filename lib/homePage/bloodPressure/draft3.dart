/* import 'package:flutter/material.dart';
import '../../component/header/header.dart';

//https://stackoverflow.com/questions/51697901/programmatically-expand-expansiontile-in-flutter
class MyListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  List<bool> _isExpandedList = [];

  @override
  void initState() {
    super.initState();
    // Initialize the list of ExpansionTile states to all false (collapsed).
    _isExpandedList = List.generate(5, (index) => false);
  }

  void _updateExpansionState(int index) {
    // Set the tapped ExpansionTile to expanded (true) and others to collapsed (false).
    setState(() {
      /* for (int i = 0; i < _isExpandedList.length; i++) {
        _isExpandedList[i] = i == index;
      } */
      _isExpandedList[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            ExpansionTile(
              onExpansionChanged: (isExpanded) {
                // When an ExpansionTile is expanded, update the expansion states.
                //if (isExpanded) {
                _updateExpansionState(index);
                //}
                print(index);
              },
              /* trailing: IgnorePointer(
                child: Switch(
                  value: isExpanded,
                  onChanged: (_) {},
                ),
              ), */
              trailing: const SizedBox(),
              /* trailing: Visibility(
                //child: Text("Invisible"),
                child: SizedBox(),
                maintainSize: false,
                maintainAnimation: true,
                maintainState: true,
                visible: false,
              ), */
              title: Container(
                //transform: Matrix4.translationValues(32, 0, 0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text("时间:"),
                  Text("09:32"),
                ]),
              ),
              //subtitle: Text('血压: 110/95 心率: 90 感觉: 还好'),
              subtitle: Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("血压:"),
                  Text(
                    "110/95",
                    style: TextStyle(fontFamily: "BalooBhai"),
                  ),
                  Text("心率:"),
                  Text(
                    "90",
                    style: TextStyle(fontFamily: "BalooBhai"),
                  ),
                  Text("感觉:"),
                  Text("还好"),
                ],
              )),
              children: <Widget>[
                // The content of each ExpansionTile.
                SizedBox(
                  height: _isExpandedList[index]
                      ? 100.0
                      : 0.0, // Set the height based on the expansion state.
                  child: Center(
                    child: Text('Expanded content'),
                  ),
                ),
              ],
            ),
            Divider(
              height: 1.0,
              color: Colors.grey,
            ),
          ],
        );
      },
    );
  }
}

//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------

class bloodPressureEdit extends StatefulWidget {
  const bloodPressureEdit({super.key});

  @override
  State<bloodPressureEdit> createState() => _bloodPressureEditState();
}

class _bloodPressureEditState extends State<bloodPressureEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          /* title: const Text(
          "返回",
          style: TextStyle(
              fontFamily: 'Blinker', fontSize: 22, color: Colors.black),
        ), */
          // flexibleSpace: header,
          //toolbarHeight: MediaQuery.of(context).size.height * 0.1 + 11,

          flexibleSpace: getHeader(MediaQuery.of(context).size.width,
              (MediaQuery.of(context).size.height * 0.1 + 11)),
        ),
        /* body: const Center(
        child: Text("修改血压"),
      ), */
        body: MyListView());
  }
}
 */

import 'package:flutter/material.dart';
import '../../component/header/header.dart';

class BloodPressureEdit extends StatefulWidget {
  @override
  _BloodPressureEditState createState() => _BloodPressureEditState();
}

class _BloodPressureEditState extends State<BloodPressureEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TriGuard",
          style: TextStyle(
            fontFamily: 'BalooBhai',
            fontSize: 26,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          UnconstrainedBox(
            child: BloodPressureEditWidget(
                time: "09:32",
                SBloodpressure: "111",
                DBloodpressure: "95",
                heartRate: "90",
                arm: "LEFT",
                feeling: "还好"),
          ),
          const SizedBox(height: 10),
          UnconstrainedBox(
            child: BloodPressureEditWidget(
                time: "09:32",
                SBloodpressure: "111",
                DBloodpressure: "95",
                heartRate: "90",
                arm: "LEFT",
                feeling: "还好"),
          ),
          const SizedBox(height: 10),
          UnconstrainedBox(
            child: BloodPressureEditWidget(
                time: "09:32",
                SBloodpressure: "111",
                DBloodpressure: "95",
                heartRate: "90",
                arm: "LEFT",
                feeling: "还好"),
          ),
        ],
      ),
    );
  }
}

class BloodPressureEditWidget extends StatefulWidget {
  final String time;
  final String SBloodpressure;
  final String DBloodpressure;
  final String heartRate;
  final String feeling;
  final String arm;

  const BloodPressureEditWidget(
      {Key? key,
      required this.time,
      required this.SBloodpressure,
      required this.DBloodpressure,
      required this.heartRate,
      required this.feeling,
      required this.arm})
      : super(key: key);

  @override
  State<BloodPressureEditWidget> createState() =>
      _BloodPressureEditWidgetState();
}

class _BloodPressureEditWidgetState extends State<BloodPressureEditWidget> {
  bool isExpanded = false;
  Widget? BPEditWidget;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      //child: BPEditWidget,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeIn,
          height: isExpanded
              ? MediaQuery.of(context).size.height * 0.2
              : MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            //color: Colors.white,
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
          alignment: Alignment.center,
          child: isExpanded
              ? BloodPressureEditWidgetMore(
                  time: "09:35",
                  SBloodpressure: "111",
                  DBloodpressure: "95",
                  heartRate: "90",
                  arm: "LEFT",
                  feeling: "还好")
              : BloodPressureEditWidgetLess(
                  time: "09:35",
                  SBloodpressure: "111",
                  DBloodpressure: "95",
                  heartRate: "90",
                  feeling: "还好")),
    );
  }
}

// 只展示
class BloodPressureEditWidgetLess extends StatefulWidget {
  final String time;
  final String SBloodpressure;
  final String DBloodpressure;
  final String heartRate;
  final String feeling;

  const BloodPressureEditWidgetLess(
      {Key? key,
      required this.time,
      required this.SBloodpressure,
      required this.DBloodpressure,
      required this.heartRate,
      required this.feeling})
      : super(key: key);

  @override
  State<BloodPressureEditWidgetLess> createState() =>
      _BloodPressureEditWidgetLessState();
}

class _BloodPressureEditWidgetLessState
    extends State<BloodPressureEditWidgetLess> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
            'Time: ${widget.time}, Pressure: ${widget.SBloodpressure + '/' + widget.DBloodpressure}, Heart Rate: ${widget.heartRate}, Feeling: ${widget.feeling}'),
      ),
    );
  }
}

// 可编辑
class BloodPressureEditWidgetMore extends StatefulWidget {
  final String time;
  final String SBloodpressure;
  final String DBloodpressure;
  final String heartRate;
  final String feeling;
  final String arm;

  const BloodPressureEditWidgetMore(
      {Key? key,
      required this.time,
      required this.SBloodpressure,
      required this.DBloodpressure,
      required this.heartRate,
      required this.feeling,
      required this.arm})
      : super(key: key);

  @override
  State<BloodPressureEditWidgetMore> createState() =>
      _BloodPressureEditWidgetMoreState();
}

class _BloodPressureEditWidgetMoreState
    extends State<BloodPressureEditWidgetMore> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
            'Time: ${widget.time}, Pressure: ${widget.SBloodpressure + '/' + widget.DBloodpressure}, Heart Rate: ${widget.heartRate}, Feeling: ${widget.feeling}, Arm: ${widget.arm}'),
      ),
    );
  }
}
