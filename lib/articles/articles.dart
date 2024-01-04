import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import '../component/icons.dart';

class Article extends StatefulWidget {
  const Article({Key? key}) : super(key: key);

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  bool isShortDevice = false;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var buttonHeight = screenWidth * 0.35;
    if (buttonHeight > screenHeight * 0.18) {
      buttonHeight = screenHeight * 0.18;
      isShortDevice = true;
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          //退出app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
              ),
              border: Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(169, 171, 179, 1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),

        // 主体内容
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // 标题
                  const Text(
                    "分类",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3),
                  ),
                  // 用药指南 & 食物成分
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ArticleButton(
                        text: "用药指南",
                        icon: MyIcons().prescription(),
                        bheight: buttonHeight,
                        bwidth: buttonHeight,
                        linkPage: '/articles/medicine',
                        shortDevice: isShortDevice,
                      ),
                      const SizedBox(width: 30),
                      ArticleButton(
                        text: "食物成分",
                        icon: MyIcons().salad(),
                        bheight: buttonHeight,
                        bwidth: buttonHeight,
                        linkPage: '/articles/foodsearch',
                        shortDevice: isShortDevice,
                      )
                    ],
                  ),
                  // 疾病预防 & 科普文章
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ArticleButton(
                        text: "疾病预防",
                        icon: MyIcons().prevention(),
                        bheight: buttonHeight,
                        bwidth: buttonHeight,
                        linkPage: '/articles/prevention',
                        shortDevice: isShortDevice,
                      ),
                      const SizedBox(width: 30),
                      ArticleButton(
                        text: "科普文章",
                        icon: MyIcons().documentation(),
                        bheight: buttonHeight,
                        bwidth: buttonHeight,
                        linkPage: '/articles/science',
                        shortDevice: isShortDevice,
                      )
                    ],
                  ),
                  // 我的收藏
                  ArticleButton(
                    text: "我的收藏",
                    icon: MyIcons().stars(),
                    bheight: buttonHeight,
                    bwidth: (buttonHeight * 2) + 30,
                    linkPage: '/articles/collection',
                    shortDevice: isShortDevice,
                  ),
                ],
              ),
            ],
          ),
        ),
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
  final bool shortDevice;
  const ArticleButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.bheight,
      required this.bwidth,
      required this.linkPage,
      required this.shortDevice});

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
              shortDevice
                  ? AutoSizeText(
                      text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
              icon
            ],
          ),
        ),
      ),
    );
  }
}
