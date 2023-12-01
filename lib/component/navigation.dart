import 'package:flutter/material.dart';
import '../component/icons.dart';

class MyNavigationBar extends StatefulWidget {
  final int currentIndex;
  const MyNavigationBar({super.key, required this.currentIndex});

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    _currentIndex = widget.currentIndex;

    return BottomNavigationBar(
      //被点击时
      // if index == 0, when press the icon, change the icon "home.png" to "home_.png"

      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/articles');
        }
        if (index == 3) {
          Navigator.pushNamed(context, '/moment');
        }
      },

      currentIndex: _currentIndex, //被选中的
      // https://blog.csdn.net/yechaoa/article/details/89852488
      type: BottomNavigationBarType.fixed,
      // iconSize: 24,
      fixedColor: Colors.black, //被选中时的颜色
      selectedFontSize: 12, // Set the font size for selected label
      unselectedFontSize: 10,
      items: [
        BottomNavigationBarItem(
            //https://blog.csdn.net/qq_27494241/article/details/107167585?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-107167585-blog-85248876.235^v38^pc_relevant_default_base3&spm=1001.2101.3001.4242.2&utm_relevant_index=4
            // https://stackoverflow.com/questions/60151052/can-i-add-spacing-around-an-icon-in-flutter-bottom-navigation-bar
            icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child:
                    _currentIndex == 0 ? MyIcons().home_() : MyIcons().home()),
            label: "首页"),
        BottomNavigationBarItem(
            icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: _currentIndex == 1
                    ? MyIcons().article_()
                    : MyIcons().article()),
            label: "文章"),
        BottomNavigationBarItem(
            icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: _currentIndex == 2
                    ? MyIcons().supervisor_()
                    : MyIcons().supervisor()),
            label: "监护"),
        BottomNavigationBarItem(
            icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: _currentIndex == 3
                    ? MyIcons().moment_()
                    : MyIcons().moment()),
            label: "动态"),
        BottomNavigationBarItem(
            icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child:
                    _currentIndex == 4 ? MyIcons().user_() : MyIcons().user()),
            label: "我的"),
      ],
    );
  }
}
