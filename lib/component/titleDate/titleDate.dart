import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TitleDate extends StatefulWidget {
  final String title;
  final String icons;
  final DateTime date;
  const TitleDate(
      {Key? key, required this.title, required this.icons, required this.date})
      : super(key: key);

  @override
  State<TitleDate> createState() => _TitleDateState();
}

class _TitleDateState extends State<TitleDate> {
  DateTime date = DateTime(2023, 11, 11);
  DateTime oldDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

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
              // 标题icon
              Container(
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Image.asset(widget.icons, width: 20, height: 20),
                    ]),
              ),

              // 日期
              Container(
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        //"${widget.date.year}年${widget.date.month}月${widget.date.day}日",
                        '${date.year}年${date.month}月${date.day}日',
                        style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "BalooBhai",
                            color: Color.fromRGBO(48, 48, 48, 1)),
                      ),
                      const SizedBox(width: 2),

                      // 日期选择
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          icon: const Icon(Icons.calendar_month),
                          iconSize: 25,
                          /* onPressed: () {
                            print("editDate");
                          }, */

                          onPressed: () => _showDialog(Column(
                            children: [
                              Expanded(
                                //height: 220,
                                child: CupertinoDatePicker(
                                  initialDateTime: date,
                                  maximumDate: DateTime.now(),
                                  mode: CupertinoDatePickerMode.date,
                                  use24hFormat: true,
                                  // This shows day of week alongside day of month
                                  showDayOfWeek: true,
                                  // This is called when the user changes the date.
                                  onDateTimeChanged: (DateTime newDate) {
                                    // setState(() => date = newDate);
                                    date = newDate;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                width: 320,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: 120,
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            date = oldDate;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            Color.fromARGB(255, 221, 223, 223),
                                          ),
                                        ),
                                        child: const Text(
                                          '取消',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 120,
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            oldDate = date;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .all<Color>(Color.fromARGB(
                                                        255, 118, 241, 250))),
                                        child: const Text(
                                          '确定',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
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

class PageTitle extends StatefulWidget {
  final String title;
  final String icons;
  const PageTitle({Key? key, required this.title, required this.icons})
      : super(key: key);

  @override
  State<PageTitle> createState() => _PageTitleState();
}

class _PageTitleState extends State<PageTitle> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
      child: Container(
        //width: MediaQuery.of(context).size.width * 0.85,
        child: Row(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              Image.asset(widget.icons, width: 20, height: 20),
            ]),
      ),
    ));
  }
}

class DatePicker extends StatefulWidget {
  const DatePicker({super.key});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime date = DateTime(2023, 11, 11);
  DateTime oldDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              //"${widget.date.year}年${widget.date.month}月${widget.date.day}日",
              '${date.year}年${date.month}月${date.day}日',
              style: const TextStyle(
                  fontSize: 18,
                  fontFamily: "BalooBhai",
                  color: Color.fromRGBO(48, 48, 48, 1)),
            ),
            const SizedBox(width: 2),

            // 日期选择
            SizedBox(
              width: 20,
              height: 20,
              child: IconButton(
                padding: EdgeInsets.all(0),
                icon: const Icon(Icons.calendar_month),
                iconSize: 25,
                /* onPressed: () {
                            print("editDate");
                          }, */

                onPressed: () => _showDialog(Column(
                  children: [
                    Expanded(
                      //height: 220,
                      child: CupertinoDatePicker(
                        initialDateTime: date,
                        maximumDate: DateTime.now(),
                        mode: CupertinoDatePickerMode.date,
                        use24hFormat: true,
                        // This shows day of week alongside day of month
                        showDayOfWeek: true,
                        // This is called when the user changes the date.
                        onDateTimeChanged: (DateTime newDate) {
                          // setState(() => date = newDate);
                          date = newDate;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 320,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 120,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  date = oldDate;
                                });
                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 221, 223, 223),
                                ),
                              ),
                              child: const Text(
                                '取消',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            width: 120,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  oldDate = date;
                                });
                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 118, 241, 250))),
                              child: const Text(
                                '确定',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                )),
              ),
            )
          ]),
    );
  }
}

// =======================================
typedef UpdateDateCallback = void Function(DateTime newDate);

class DatePicker2 extends StatefulWidget {
  DateTime date = DateTime(2023, 11, 11);
  final UpdateDateCallback updateDate;
  DatePicker2({super.key, required this.date, required this.updateDate});

  @override
  State<DatePicker2> createState() => _DatePicker2State();
}

class _DatePicker2State extends State<DatePicker2> {
  //DateTime date = DateTime(2023, 11, 11);
  DateTime oldDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              //"${widget.date.year}年${widget.date.month}月${widget.date.day}日",
              '${widget.date.year}年${widget.date.month}月${widget.date.day}日',
              style: const TextStyle(
                  fontSize: 18,
                  fontFamily: "BalooBhai",
                  color: Color.fromRGBO(48, 48, 48, 1)),
            ),
            const SizedBox(width: 2),

            // 日期选择
            SizedBox(
              width: 30,
              height: 30,
              child: IconButton(
                padding: EdgeInsets.all(0),
                icon: const Icon(Icons.calendar_month),
                iconSize: 22,
                /* onPressed: () {
                            print("editDate");
                          }, */

                onPressed: () => _showDialog(Column(
                  children: [
                    Expanded(
                      //height: 220,
                      child: CupertinoDatePicker(
                        initialDateTime: widget.date,
                        maximumDate: DateTime.now(),
                        mode: CupertinoDatePickerMode.date,
                        use24hFormat: true,
                        // This shows day of week alongside day of month
                        showDayOfWeek: true,
                        // This is called when the user changes the date.
                        onDateTimeChanged: (DateTime newDate) {
                          // setState(() => date = newDate);
                          widget.date = newDate;
                          //print("${widget.date} => ${newDate}");
                          //widget.updateView();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 320,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //取消
                          Container(
                            width: 120,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  widget.date = oldDate;
                                  widget.updateDate(widget.date);
                                });

                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 221, 223, 223),
                                ),
                              ),
                              child: const Text(
                                '取消',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          //确定
                          Container(
                            width: 120,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  oldDate = widget.date;
                                  print("确定更改日期为 ${widget.date}");
                                  widget.updateDate(widget.date);
                                });

                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 118, 241, 250))),
                              child: const Text(
                                '确定',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    /* const SizedBox(
                      height: 5,
                    ), */
                  ],
                )),
              ),
            )
          ]),
    );
  }
}

// hour and minute picker ,must 2 digit number
class TimePicker extends StatefulWidget {
  DateTime time = DateTime(2023, 11, 11, 00, 00);
  final UpdateDateCallback updateTime;
  TimePicker({super.key, required this.time, required this.updateTime});
  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  //DateTime date = DateTime(2023, 11, 11);
  DateTime oldTime =
      DateTime(2023, 11, 11, DateTime.now().hour, DateTime.now().minute);

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              //"${widget.date.year}年${widget.date.month}月${widget.date.day}日",
              //'${widget.date.year}年${widget.date.month}月${widget.date.day}日',
              // '${widget.time.hour}:${widget.time.minute}',
              '${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  fontSize: 18,
                  fontFamily: "BalooBhai",
                  color: Color.fromRGBO(48, 48, 48, 1)),
            ),
            const SizedBox(width: 2),

            // 日期选择
            SizedBox(
              width: 30,
              height: 30,
              child: IconButton(
                padding: EdgeInsets.all(0),
                icon:
                    Image.asset("assets/icons/time.png", width: 20, height: 30),
                /* onPressed: () {
                            print("editDate");
                          }, */

                onPressed: () => _showDialog(Column(
                  children: [
                    Expanded(
                      //height: 220,
                      child: CupertinoDatePicker(
                        initialDateTime: widget.time,
                        //mode: CupertinoDatePickerMode.date,
                        mode: CupertinoDatePickerMode.time,

                        use24hFormat: true,
                        showDayOfWeek: true,
                        onDateTimeChanged: (DateTime newTime) {
                          widget.time = newTime;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 320,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //取消
                          Container(
                            width: 120,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  widget.time = oldTime;
                                  widget.updateTime(widget.time);
                                });

                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 221, 223, 223),
                                ),
                              ),
                              child: const Text(
                                '取消',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          //确定
                          Container(
                            width: 120,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  oldTime = widget.time;
                                  print("确定更改时间为 ${widget.time}");
                                  widget.updateTime(widget.time);
                                });

                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 118, 241, 250))),
                              child: const Text(
                                '确定',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                )),
              ),
            )
          ]),
    );
  }
}
