import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../component/header/header.dart';
import '../router/router.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  bool returnLogin = false;

  void _showBackDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Are you sure you want to leave this page?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Nevermind'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Leave'),
              onPressed: () {
                Navigator.pop(context);
                //Navigator.pop(context);
                SystemNavigator.pop();
                //exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: returnLogin,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        print("确定退出？");
        _showBackDialog();
        // TODO: 弹出确认退出的对话框
      },
      child: Scaffold(
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
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("用户"),
              //退出登录的按钮
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    returnLogin = true;
                  });
                  Navigator.pop(context);
                  //Navigator.pushNamed(context, '/');
                  //Navigator.pushReplacement(context, routes['/']!);
                },
                child: Text("退出登录"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
