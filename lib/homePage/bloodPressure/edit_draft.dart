import 'package:flutter/material.dart';
import '../../component/header/header.dart';

class BloodPressureEdit extends StatefulWidget {
  @override
  _BloodPressureEditState createState() => _BloodPressureEditState();
}

class _BloodPressureEditState extends State<BloodPressureEdit> {
  List<bool> container1States = [
    true,
    true
  ]; // Use a list to track Container1 states
  List<bool> container2States = [
    false,
    false
  ]; // Use a list to track Container2 states

  void _toggleContainer1(int index) {
    setState(() {
      // Toggle the clicked Container1
      print(index);
      container1States[index] = !container1States[index];
    });
  }

  void _toggleContainer2(int index) {
    setState(() {
      // Toggle the clicked Container2
      print(index);
      container2States[index] = !container2States[index];
    });
  }

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
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              GestureDetector(
                onTap: () => _toggleContainer1(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  height: container1States[index] ? 100.0 : 150.0,
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    //color: container1States[index] ? Colors.blue : Colors.red,
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
                  child: Text(
                      container1States[index] ? 'Container 1' : 'Container 2'),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => _toggleContainer2(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  height: container2States[index] ? 150.0 : 100.0,
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    //color: container2States[index] ? Colors.red : Colors.blue,
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
                  child: Text(
                      container2States[index] ? 'Container 2' : 'Container 1'),
                ),
              ),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}

class Container1 extends StatelessWidget {
  final VoidCallback onPressed;

  Container1({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        //color: const Color.fromARGB(255, 255, 255, 255),
        height: 100.0,
        width: MediaQuery.of(context).size.width * 0.85,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          /* boxShadow: const [
             BoxShadow(
              color: Color.fromARGB(120, 151, 151, 151),
              offset: Offset(0, 5),
              blurRadius: 5.0,
              spreadRadius: 0.0,
            ), 
          ], */
        ),
        child: Text('Container 1???'),
      ),
    );
  }
}

class Container2 extends StatelessWidget {
  final VoidCallback onPressed;

  Container2({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        height: 150.0,
        width: MediaQuery.of(context).size.width * 0.85,
        alignment: Alignment.center,
        decoration: BoxDecoration(
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
        child: Text('Container 2!!!'),
      ),
    );
  }
}
