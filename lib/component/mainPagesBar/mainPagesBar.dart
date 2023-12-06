import 'package:flutter/material.dart';
import '../../homePage/homePage.dart';
import '../../articles/articles.dart';
import '../../supervisor/supervisor.dart';
import '../../moment/moment.dart';
import '../../user/user.dart';
import '../icons.dart';

class MainPages extends StatefulWidget {
  final Map arguments;
  const MainPages({super.key, required this.arguments});

  @override
  State<MainPages> createState() => _MainPagesState();
}

class _MainPagesState extends State<MainPages> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    HomePage(),
    Article(),
    Supervisor(),
    Moment(),
    User()
  ];

  @override
  void initState() {
    super.initState();
    print(widget.arguments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //appBar: AppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        //被点击时

        // if index == 0, when press the icon, change the icon "home.png" to "home_.png"

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
                  child: _currentIndex == 0
                      ? MyIcons().home_()
                      : MyIcons().home()),
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
                  child: _currentIndex == 4
                      ? MyIcons().user_()
                      : MyIcons().user()),
              label: "我的"),
        ],
      ),
    );
  }
}

/* bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        height: 55,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Image.asset(
              "assets/icons/home_.png",
              width: 24,
              height: 24,
            ),
            icon: Image.asset(
              "assets/icons/home.png",
              width: 24,
              height: 24,
            ),
            label: "首页",
          ),
          NavigationDestination(
            selectedIcon: Image.asset(
              "assets/icons/articles_.png",
              width: 24,
              height: 24,
            ),
            icon: Image.asset(
              "assets/icons/articles.png",
              width: 24,
              height: 24,
            ),
            label: "资讯",
          ),
          NavigationDestination(
            selectedIcon: Image.asset(
              "assets/icons/supervisor_.png",
              width: 24,
              height: 24,
            ),
            icon: Image.asset(
              "assets/icons/supervisor.png",
              width: 24,
              height: 24,
            ),
            label: "监护",
          ),
          NavigationDestination(
            selectedIcon: Image.asset(
              "assets/icons/moment_.png",
              width: 24,
              height: 24,
            ),
            icon: Image.asset(
              "assets/icons/moment.png",
              width: 24,
              height: 24,
            ),
            label: "动态",
          ),
          NavigationDestination(
            selectedIcon: Image.asset(
              "assets/icons/user_.png",
              width: 24,
              height: 24,
            ),
            icon: Image.asset(
              "assets/icons/user.png",
              width: 24,
              height: 24,
            ),
            label: "我的",
          ),
        ],
      ), */


/*  
bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        selectedIndex: _currentIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().home_(),
            ),
            icon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().home(),
            ),
            label: "首页",
          ),
          NavigationDestination(
            selectedIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().article_(),
            ),
            icon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().article(),
            ),
            label: "资讯",
          ),
          NavigationDestination(
            selectedIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().supervisor_(),
            ),
            icon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().supervisor(),
            ),
            label: "监护",
          ),
          NavigationDestination(
            selectedIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().moment_(),
            ),
            icon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().moment(),
            ),
            label: "动态",
          ),
          NavigationDestination(
            selectedIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().user_(),
            ),
            icon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
              child: MyIcons().user(),
            ),
            label: "我的",
          ),
        ],
      ),
       */

/* bottomNavigationBar: BottomNavigationBar(
        //被点击时

        // if index == 0, when press the icon, change the icon "home.png" to "home_.png"

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        currentIndex: _currentIndex, //被选中的
        // https://blog.csdn.net/yechaoa/article/details/89852488
        type: BottomNavigationBarType.fixed,
        // iconSize: 24,
        fixedColor: Colors.black, //被选中时的颜色
        selectedFontSize: 12, // Set the font size for selected label
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
              //https://blog.csdn.net/qq_27494241/article/details/107167585?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-107167585-blog-85248876.235^v38^pc_relevant_default_base3&spm=1001.2101.3001.4242.2&utm_relevant_index=4
              // https://stackoverflow.com/questions/60151052/can-i-add-spacing-around-an-icon-in-flutter-bottom-navigation-bar
              icon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: _currentIndex == 0
                      ? MyIcons().home_()
                      : MyIcons().home()),
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
                  child: _currentIndex == 4
                      ? MyIcons().user_()
                      : MyIcons().user()),
              label: "我的"),
        ],
      ), */