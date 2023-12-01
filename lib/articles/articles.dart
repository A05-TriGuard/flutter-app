import 'package:flutter/material.dart';
import '../component/header/header.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import '../component/icons.dart';

class Article extends StatefulWidget {
  const Article({Key? key}) : super(key: key);

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var buttonHeight = screenWidth * 0.27;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "TriGuard",
          style: TextStyle(
              fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
        ),
        flexibleSpace: getHeader(MediaQuery.of(context).size.width,
            (MediaQuery.of(context).size.height * 0.1 + 11)),
      ),

      // 主体内容
      body: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                "分类",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ArticleButton(
                      text: "用药指南",
                      icon: MyIcons().prescription(),
                      bheight: buttonHeight,
                      bwidth: buttonHeight,
                      linkPage: '/articles/medicine',
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: ArticleButton(
                      text: "食物成分",
                      icon: MyIcons().salad(),
                      bheight: buttonHeight,
                      bwidth: buttonHeight,
                      linkPage: '/articles/foodsearch',
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ArticleButton(
                      text: "疾病预防",
                      icon: MyIcons().prevention(),
                      bheight: buttonHeight,
                      bwidth: buttonHeight,
                      linkPage: '/articles/prevention',
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: ArticleButton(
                      text: "科普文章",
                      icon: MyIcons().documentation(),
                      bheight: buttonHeight,
                      bwidth: buttonHeight,
                      linkPage: '/articles/science',
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ArticleButton(
                      text: "我的收藏",
                      icon: MyIcons().stars(),
                      bheight: buttonHeight,
                      bwidth: (buttonHeight * 2) + 30,
                      linkPage: '/articles/collection',
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
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
                BorderSide(color: Color.fromRGBO(0, 0, 0, 0.2), width: 1)),
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(120, 151, 151, 151),
                  offset: Offset(0, 3),
                  spreadRadius: 0.5,
                  blurRadius: 5)
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
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              icon
            ],
          ),
        ),
      ),
    );
  }
}
