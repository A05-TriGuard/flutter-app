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

// 删除 取消 确定

class OtherButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const OtherButton(
      {required this.onPressed, required this.text, required this.color});

  @override
  State<OtherButton> createState() => _OtherButtonState();
}

class _OtherButtonState extends State<OtherButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        height: 25,
        width: 40,
        padding: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color.fromRGBO(122, 119, 119, 0.43)),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.0,
              fontFamily: 'Blinker',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// 手臂的按钮
class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSelected;

  const CustomButton(
      {required this.onPressed, required this.text, required this.isSelected});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        height: 40,
        width: 50,
        padding: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color.fromRGBO(253, 134, 255, 0.66)
              : Color.fromRGBO(218, 218, 218, 0.66),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color.fromRGBO(122, 119, 119, 0.43)),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.isSelected
                  ? Color.fromRGBO(66, 9, 119, 0.773)
                  : Color.fromRGBO(94, 68, 68, 100),
              fontSize: 16.0,
              fontFamily: 'Blinker',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final bool isSelected;

  const CustomIconButton({
    required this.onPressed,
    required this.iconPath,
    required this.isSelected,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        height: 40,
        width: 60,
        padding: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color.fromRGBO(253, 134, 255, 0.66)
              : Color.fromRGBO(218, 218, 218, 0.66),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Color.fromRGBO(122, 119, 119, 0.43)),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 25,
          width: 25,
          // color: widget.isSelected
          //     ? Color.fromRGBO(66, 9, 119, 0.773)
          //     : Color.fromRGBO(94, 68, 68, 100),
          child: Image.asset(
            widget.iconPath,
          ),
        ),
      ),
    );
  }
}

class CustomButtonRow extends StatefulWidget {
  final int initialSelectedIndex;

  const CustomButtonRow({required this.initialSelectedIndex});

  @override
  _CustomButtonRowState createState() => _CustomButtonRowState();
}

class _CustomButtonRowState extends State<CustomButtonRow> {
  late int selectedButtonIndex;

  @override
  void initState() {
    super.initState();
    selectedButtonIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomButton(
          onPressed: () {
            setState(() {
              selectedButtonIndex = 0;
            });
            print("左手按钮被点击了！");
          },
          text: "左手",
          isSelected: selectedButtonIndex == 0,
        ),
        const SizedBox(width: 5),
        CustomButton(
          onPressed: () {
            setState(() {
              selectedButtonIndex = 1;
            });
            print("右手按钮被点击了！");
          },
          text: "右手",
          isSelected: selectedButtonIndex == 1,
        ),
        const SizedBox(width: 5),
        CustomButton(
          onPressed: () {
            setState(() {
              selectedButtonIndex = 2;
            });
            print("不选按钮被点击了！");
          },
          text: "不选",
          isSelected: selectedButtonIndex == 2,
        ),
      ],
    );
  }
}

class CustomIconButtonRow extends StatefulWidget {
  final int initialSelectedIndex;

  const CustomIconButtonRow({required this.initialSelectedIndex});

  @override
  _CustomIconButtonRowState createState() => _CustomIconButtonRowState();
}

class _CustomIconButtonRowState extends State<CustomIconButtonRow> {
  late int selectedButtonIndex;

  @override
  void initState() {
    super.initState();
    selectedButtonIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomIconButton(
          onPressed: () {
            setState(() {
              selectedButtonIndex = 0;
            });
            print("左手按钮被点击了！");
          },
          iconPath: "assets/icons/emoji-nice.png",
          isSelected: selectedButtonIndex == 0,
        ),
        const SizedBox(width: 5),
        CustomIconButton(
          onPressed: () {
            setState(() {
              selectedButtonIndex = 1;
            });
            print("右手按钮被点击了！");
          },
          iconPath: "assets/icons/emoji-ok.png",
          isSelected: selectedButtonIndex == 1,
        ),
        const SizedBox(width: 5),
        CustomIconButton(
          onPressed: () {
            setState(() {
              selectedButtonIndex = 2;
            });
            print("不选按钮被点击了！");
          },
          iconPath: "assets/icons/emoji-bad.png",
          isSelected: selectedButtonIndex == 2,
        ),
      ],
    );
  }
}

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
          TitleDate(date: DateTime.now()),
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
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class TitleDate extends StatefulWidget {
  final DateTime date;
  const TitleDate({Key? key, required this.date}) : super(key: key);

  @override
  State<TitleDate> createState() => _TitleDateState();
}

class _TitleDateState extends State<TitleDate> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                        "修改血压",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Image.asset("assets/icons/edit.png",
                          width: 20, height: 20),
                    ]),
              ),
              Container(
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.date.year}年${widget.date.month}月${widget.date.day}日",
                        style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "BalooBhai",
                            color: Color.fromRGBO(48, 48, 48, 1)),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          icon: const Icon(Icons.calendar_month),
                          iconSize: 25,
                          onPressed: () {
                            print("editDate");
                          },
                        ),
                      )
                    ]),
              )
            ],
          ),
        ),
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
            if (!isExpanded) isExpanded = !isExpanded;
          });
        },
        //child: BPEditWidget,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeIn,
          height: isExpanded
              ? MediaQuery.of(context).size.height * 0.55
              : MediaQuery.of(context).size.height * 0.15,
          // height: MediaQuery.of(context).size.height * 0.15,
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
          //https://stackoverflow.com/questions/56298325/overflow-warning-in-animatedcontainer-adjusting-height
          //切换的一瞬间会overflow，用SingleChildScrollView包裹一下解决
          child: isExpanded
              ? SingleChildScrollView(
                  child: BloodPressureEditWidgetMore(
                  time: DateTime.now(),
                  SBloodpressure: "111",
                  DBloodpressure: "95",
                  heartRate: "90",
                  arm: "左",
                  feeling: "还好",
                  onCollapse: () {
                    setState(() {
                      isExpanded = false;
                    });
                  },
                ))
              : SingleChildScrollView(
                  child: BloodPressureEditWidgetLess(
                      time: DateTime.now(),
                      SBloodpressure: "111",
                      DBloodpressure: "95",
                      heartRate: "90",
                      arm: "左",
                      feeling: "还好")),
        ));
  }
}

// 只展示
class BloodPressureEditWidgetLess extends StatefulWidget {
  final DateTime time;
  final String SBloodpressure;
  final String DBloodpressure;
  final String heartRate;
  final String feeling;
  final String arm;

  const BloodPressureEditWidgetLess(
      {Key? key,
      required this.time,
      required this.SBloodpressure,
      required this.DBloodpressure,
      required this.heartRate,
      required this.feeling,
      required this.arm})
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
      /* child: Center(
        child: Text(
            'Time: ${widget.time}, Pressure: ${widget.SBloodpressure + '/' + widget.DBloodpressure}, Heart Rate: ${widget.heartRate}, Feeling: ${widget.feeling}'),
      ), */
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '时间: ${widget.time.hour}:${widget.time.minute}',
              style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
            ),
            Text(
              '血压: ${widget.SBloodpressure + '/' + widget.DBloodpressure}    心率: ${widget.heartRate} ',
              style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
            ),
            Text(
              '手臂: ${widget.arm}            感觉: ${widget.feeling}',
              style: const TextStyle(fontSize: 16, fontFamily: "BalooBhai"),
            ),
          ]),
    );
  }
}

// 可编辑
class BloodPressureEditWidgetMore extends StatefulWidget {
  final DateTime time;
  final String SBloodpressure;
  final String DBloodpressure;
  final String heartRate;
  final String feeling;
  final String arm;
  final VoidCallback onCollapse;

  const BloodPressureEditWidgetMore({
    Key? key,
    required this.time,
    required this.SBloodpressure,
    required this.DBloodpressure,
    required this.heartRate,
    required this.feeling,
    required this.arm,
    required this.onCollapse,
  }) : super(key: key);

  @override
  State<BloodPressureEditWidgetMore> createState() =>
      _BloodPressureEditWidgetMoreState();
}

class _BloodPressureEditWidgetMoreState
    extends State<BloodPressureEditWidgetMore> {
  Widget getTitle(String TitleChn, String TitleEng) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.center,
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${TitleChn}",
          style: const TextStyle(fontSize: 18, fontFamily: "BalooBhai"),
        ),
        Text(
          "${TitleEng}",
          style: const TextStyle(
              fontSize: 14,
              fontFamily: "Blinker",
              color: Color.fromARGB(255, 109, 109, 109)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    /* return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              'Time: ${widget.time}, Pressure: ${widget.SBloodpressure + '/' + widget.DBloodpressure}, Heart Rate: ${widget.heartRate}, Feeling: ${widget.feeling}, Arm: ${widget.arm}'),
          ElevatedButton(
            onPressed: widget.onCollapse,
            child: Text('Collapse'),
          ),
        ],
      ),
    ); */

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 修改时间
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //修改时间
              Row(
                children: [
                  getTitle("时间", "TIME"),
                  /* TextField(
                  decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '时',
              )), */
                  SizedBox(
                    width: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          maxLength: 2,
                          decoration: InputDecoration(
                              counterText: "",
                              hintText: "${widget.time.hour}",
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 2)),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: const TextStyle(
                              fontSize: 30, fontFamily: "BalooBhai"),
                        ),
                      ),
                      SizedBox(width: 2),
                      const Text(
                        "时",
                        style: const TextStyle(
                            fontSize: 16, fontFamily: "BalooBhai"),
                      ),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          maxLength: 2,
                          decoration: InputDecoration(
                              counterText: "",
                              hintText: "${widget.time.minute}",
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 2)),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: const TextStyle(
                              fontSize: 30, fontFamily: "BalooBhai"),
                        ),
                      ),
                      const Text(
                        "分",
                        style: const TextStyle(
                            fontSize: 16, fontFamily: "BalooBhai"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //修改时间
              Row(
                children: [
                  getTitle("收缩压", "SBP"),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 75,
                        height: 40,
                        child: TextField(
                          maxLength: 3,
                          decoration: InputDecoration(
                              counterText: "",
                              hintText: "${widget.SBloodpressure}",
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: const TextStyle(
                              fontSize: 30, fontFamily: "BalooBhai"),
                        ),
                      ),
                      SizedBox(width: 2),
                      const Text(
                        "mmHg",
                        style: const TextStyle(
                            fontSize: 16, fontFamily: "Blinker"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //修改时间
              Row(
                children: [
                  getTitle("舒张压", "DBP"),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 75,
                        height: 40,
                        child: TextField(
                          maxLength: 3,
                          decoration: InputDecoration(
                              counterText: "",
                              hintText: "${widget.DBloodpressure}",
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: const TextStyle(
                              fontSize: 30, fontFamily: "BalooBhai"),
                        ),
                      ),
                      SizedBox(width: 2),
                      const Text(
                        "mmHg",
                        style: const TextStyle(
                            fontSize: 16, fontFamily: "Blinker"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //修改时间
              Row(
                children: [
                  getTitle("心率", "PULSE"),
                  SizedBox(
                    width: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 75,
                        height: 40,
                        child: TextField(
                          maxLength: 3,
                          decoration: InputDecoration(
                              counterText: "",
                              hintText: "${widget.heartRate}",
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: const TextStyle(
                              fontSize: 30, fontFamily: "BalooBhai"),
                        ),
                      ),
                      SizedBox(width: 2),
                      const Text(
                        "次/分",
                        style: const TextStyle(
                            fontSize: 16, fontFamily: "Blinker"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //修改时间
              Row(
                children: [
                  getTitle("手臂", "ARM"),
                  SizedBox(
                    width: 20,
                  ),
                  CustomButtonRow(
                    initialSelectedIndex: 2,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //修改时间
              Row(
                children: [
                  getTitle("感觉", "FEELINGS"),
                  SizedBox(
                    width: 20,
                  ),
                  CustomIconButtonRow(
                    initialSelectedIndex: 2,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //修改时间
              Row(
                children: [
                  OtherButton(
                      onPressed: () {
                        print("删除");
                      },
                      text: "删除",
                      color: Color.fromRGBO(253, 108, 108, 1)),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OtherButton(
                            onPressed: () {
                              print("取消");
                            },
                            text: "取消",
                            color: Color.fromRGBO(144, 235, 235, 1)),
                        const SizedBox(width: 5),
                        OtherButton(
                            onPressed: () {
                              print("确定");
                            },
                            text: "确定",
                            color: Color.fromRGBO(173, 255, 144, 1)),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),

          ElevatedButton(
            onPressed: widget.onCollapse,
            child: Text('收起'),
          ),
        ],
      ),
    );
  }
}
