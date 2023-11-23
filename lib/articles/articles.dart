import 'package:flutter/material.dart';
import '../component/icons.dart';

class Article extends StatefulWidget {
  const Article({Key? key}) : super(key: key);

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var buttonHeight = screenWidth * 0.3;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "TriGuard",
          style: TextStyle(
              fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 209, 252),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
        ),
      ),

      // 主体内容
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "分类",
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ArticleButton(
                  text: "用药指南",
                  icon: MyIcons().prescription(),
                  bheight: buttonHeight,
                  bwidth: buttonHeight,
                  linkPage: '/articles/medicine',
                ),
                const SizedBox(width: 30),
                ArticleButton(
                  text: "食物成分",
                  icon: MyIcons().salad(),
                  bheight: buttonHeight,
                  bwidth: buttonHeight,
                  linkPage: '/articles/foodsearch',
                )
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ArticleButton(
                  text: "疾病预防",
                  icon: MyIcons().prevention(),
                  bheight: buttonHeight,
                  bwidth: buttonHeight,
                  linkPage: '/articles/prevention',
                ),
                const SizedBox(width: 30),
                ArticleButton(
                  text: "科普文章",
                  icon: MyIcons().documentation(),
                  bheight: buttonHeight,
                  bwidth: buttonHeight,
                  linkPage: '/articles/science',
                )
              ],
            ),
            const SizedBox(height: 30),
            ArticleButton(
              text: "我的收藏",
              icon: MyIcons().stars(),
              bheight: buttonHeight,
              bwidth: (buttonHeight * 2) + 30,
              linkPage: '/articles/collection',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // 下方导航栏
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

class ArticleButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final double bheight;
  final double bwidth;
  final String linkPage;
  const ArticleButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.bheight,
      required this.bwidth,
      required this.linkPage});

  @override
  Widget build(BuildContext context) {
    var buttonPadding = (bheight - 16 - 55) * 0.3;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, linkPage);
      },
      child: Ink(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.fromBorderSide(
                BorderSide(color: Colors.black, width: 1)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black54,
                  offset: Offset(1, 1),
                  spreadRadius: 0.5,
                  blurRadius: 4)
            ],
            color: Colors.white),
        height: bheight,
        width: bwidth,
        padding: EdgeInsets.all(buttonPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              icon
            ],
          ),
        ),
      ),
    );
  }
}
