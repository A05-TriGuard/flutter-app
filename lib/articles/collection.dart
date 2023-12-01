import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../articles/medicinepage.dart';
import '../articles/foodsearchpage.dart';
import '../component/header/header.dart';

// TOINTERACT: 增加var列表，用来保存内容页面需要展示的内容（图片、文字等）
// TOINTERACT: 增加bool变量记录文章是否被收藏
class ArticleInfo {
  final String title;
  final String content;
  final String imagePath;
  ArticleInfo(
      {required this.title, required this.content, required this.imagePath});
}

// TOIMPROVE: 返回收藏页面的时候保持在上次选的模块
class Collection extends StatefulWidget {
  const Collection({super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  var token =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiYWRtaW4iLCJpZCI6MywiZXhwIjoxNzAxMzUwNDMyLCJpYXQiOjE3MDEwOTEyMzIsImp0aSI6IjU0YmY3YWY3LWI3ZDMtNDcxMC1hMzhhLTY3ZDE1ZmM4MTQ1YyIsImF1dGhvcml0aWVzIjpbIlJPTEVfdXNlciJdfQ.E6b_y9olNKiKJAsxWuOhgM0y4ifWZT2taQ9CQJD4SH4';
  var classSelected = <bool>[true, false, false, false];
  int curSelected = 0;
  int curItemCount = 0;
  var medicineArticleList = [];
  var foodArticleList = [];
  var preventionArticleList = <ArticleInfo>[
    ArticleInfo(
        title: "Title 5",
        content: "This is the fifth content...",
        imagePath:
            "https://images.nintendolife.com/3e199ccf1141f/doraemon-nobitars-little-star-wars-2021.large.jpg"),
    ArticleInfo(
        title: "Title 9",
        content: "This is the ninth content...",
        imagePath:
            "https://www.billboard.com/wp-content/uploads/2023/06/Oreo-x-Nintendo-billboard-1548.jpg?w=942&h=623&crop=1"),
  ];
  var scienceArticleList = <ArticleInfo>[
    ArticleInfo(
        title: "Title 7",
        content: "This is the seventh content...",
        imagePath:
            "https://news.cgtn.com/news/3049544e7751544f776b7a4e3249444f776b7a4e31457a6333566d54/img/dbc2bed8083940c4a70ca53dc7e784a2/dbc2bed8083940c4a70ca53dc7e784a2.jpg"),
    ArticleInfo(
        title: "Title 3",
        content: "This is the third content...",
        imagePath:
            "https://images.unsplash.com/photo-1576622085773-4eb399076362?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8bWVycnklMjBnbyUyMHJvdW5kfGVufDB8fDB8fHww"),
    ArticleInfo(
        title: "Title 2",
        content: "This is the second content...",
        imagePath:
            "https://assets-global.website-files.com/61eaa3470cc7de3ef77364b3/651430a63005ee02c2bab489_istockphoto-1270902491-170667a.jpg"),
  ];
  var medicineTileList = <NonArticleTile>[];
  var foodTileList = <NonArticleTile>[];
  var preventionTileList = <ArticleTile>[];
  var scienceTileList = <ArticleTile>[];

  void createMedicineTileList() {
    medicineTileList.clear();

    for (int i = 0; i < medicineArticleList.length; ++i) {
      medicineTileList.add(NonArticleTile(
        articleInfo: medicineArticleList[i],
        linkpath: '/articles/collection/medicinepage',
        isMed: true,
      ));
    }
  }

  void createFoodTileList() {
    foodTileList.clear();

    for (int i = 0; i < foodArticleList.length; ++i) {
      foodTileList.add(NonArticleTile(
        articleInfo: foodArticleList[i],
        linkpath: '/articles/collection/foodsearchpage',
        isMed: false,
      ));
    }
  }

  void createScienceTileList() {
    scienceTileList.clear();

    for (int i = 0; i < scienceArticleList.length; ++i) {
      scienceTileList.add(ArticleTile(articleList: scienceArticleList[i]));
    }
  }

  void createPreventionTileList() {
    preventionTileList.clear();

    for (int i = 0; i < preventionArticleList.length; ++i) {
      preventionTileList
          .add(ArticleTile(articleList: preventionArticleList[i]));
    }
  }

  // Medicine API
  void fetchNShowMedicineCollection() async {
    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/medicine/favorites/list',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          medicineArticleList = response.data["data"];
          curItemCount = medicineArticleList.length;
          classSelected[curSelected] = false;
          classSelected[0] = true;
          curSelected = 0;
          //print(medicineArticleList);
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ///print('Request failed: $e');
    }
  }

  // Food API
  void fetchNShowFoodCollection() async {
    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/food/favorites/list',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          foodArticleList = response.data["data"];
          curItemCount = foodArticleList.length;
          classSelected[curSelected] = false;
          classSelected[1] = true;
          curSelected = 1;
          //print(medicineArticleList);
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ///print('Request failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNShowMedicineCollection();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    createMedicineTileList();
    createFoodTileList();
    createScienceTileList();
    createPreventionTileList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "我的收藏",
          style: TextStyle(
              fontFamily: 'BalooBhai',
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w900),
        ),
        flexibleSpace: getHeader(MediaQuery.of(context).size.width,
            (MediaQuery.of(context).size.height * 0.1 + 11)),
      ),

      // 主体内容
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ToggleButtons(
              fillColor: const Color.fromARGB(255, 250, 209, 252),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              color: Colors.black38,
              selectedColor: Colors.black,
              borderRadius: BorderRadius.circular(15),
              constraints: BoxConstraints.expand(
                  width: screenWidth * 0.85 * 0.25,
                  height: screenHeight * 0.06),
              isSelected: classSelected,
              children: const [
                Text("用药指南"),
                Text("食物参数"),
                Text("疾病预防"),
                Text("科普文章"),
              ],
              onPressed: (index) {
                if (index == 0) {
                  fetchNShowMedicineCollection();
                } else if (index == 1) {
                  fetchNShowFoodCollection();
                } else {
                  setState(() {
                    classSelected[curSelected] = false;
                    classSelected[index] = true;
                    curSelected = index;
                    curItemCount = 0;
                  });
                }
              },
            ),
            SizedBox(
                height: screenHeight * 0.65,
                width: screenWidth * 0.88,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: curItemCount,
                  itemBuilder: (BuildContext context, index) {
                    if (classSelected[0]) {
                      return medicineTileList[index];
                    } else if (classSelected[1]) {
                      return foodTileList[index];
                    } else if (classSelected[2]) {
                      return preventionTileList[index];
                    } else {
                      return scienceTileList[index];
                    }
                  },
                ))
          ],
        ),
      ),
    );
  }
}

// TOINTERACT: 在跳转去内容页面时，先设置好要展示的内容
class ArticleTile extends StatelessWidget {
  final ArticleInfo articleList;

  const ArticleTile({super.key, required this.articleList});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      shadowColor: Colors.black87,
      elevation: 6,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/articles/collection/articlepage');
        },
        child: ListTile(
          minVerticalPadding: 15,
          title: Text(articleList.title, maxLines: 1),
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w900, color: Colors.black, fontSize: 20),
          subtitle: Text(articleList.content, maxLines: 1),
          leading: Container(
            height: 55,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: AspectRatio(
              aspectRatio: 1.6,
              child: Image.network(articleList.imagePath, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

// TOINTERACT: 在跳转去内容页面时，先设置好要展示的内容
class NonArticleTile extends StatelessWidget {
  final Map articleInfo;
  final String linkpath;
  final bool isMed;

  const NonArticleTile(
      {super.key,
      required this.articleInfo,
      required this.linkpath,
      required this.isMed});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      shadowColor: Colors.black87,
      elevation: 6,
      child: InkWell(
        onTap: () {
          if (isMed) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MedicinePage(title: "返回收藏列表", id: articleInfo["id"])));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FoodsearchPage(
                        title: "返回收藏列表", id: articleInfo["id"])));
          }
        },
        child: ListTile(
          minVerticalPadding: 15,
          title: Text(articleInfo["name"], maxLines: 1),
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w900, color: Colors.black, fontSize: 20),
        ),
      ),
    );
  }
}
