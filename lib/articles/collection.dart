import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';
import '../articles/medicinepage.dart';
import '../articles/foodsearchpage.dart';
import '../articles/sciencepage.dart';
import '../component/mainPagesBar/mainPagesBar.dart';

class Collection extends StatefulWidget {
  final List<bool> selectedButton;
  const Collection({super.key, required this.selectedButton});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  var classSelected = <bool>[false, false, false, false];
  int curSelected = 0;
  int curItemCount = 0;
  var medicineArticleList = [];
  var foodArticleList = [];
  var preventionArticleList = [];
  var scienceArticleList = [];
  var medicineTileList = <NonArticleTile>[];
  var foodTileList = <NonArticleTile>[];
  var preventionTileList = <ArticleTile>[];
  var scienceTileList = <ArticleTile>[];
  int pageCount = 1;
  int batchCount = 10;
  int increaseNum = 5;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        if (curSelected == 2) {
          setState(() {
            _isLoading = true;
            batchCount += increaseNum;
            fetchNShowDiseaseCollection();
          });
        } else if (curSelected == 3) {
          setState(() {
            _isLoading = true;
            batchCount += increaseNum;
            fetchNShowScienceCollection();
          });
        }
      }
    }
  }

  void createMedicineTileList() {
    medicineTileList.clear();

    for (int i = 0; i < medicineArticleList.length; ++i) {
      medicineTileList.add(NonArticleTile(
        articleInfo: medicineArticleList[i],
        linkpath: '/articles/collection/medicinepage',
        isMed: true,
        updateCollection: fetchNShowMedicineCollection,
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
        updateCollection: fetchNShowFoodCollection,
      ));
    }
  }

  void createScienceTileList() {
    scienceTileList.clear();

    for (int i = scienceArticleList.length - 1; i >= 0; --i) {
      scienceTileList.add(ArticleTile(
        article: scienceArticleList[i],
        isPrevention: false,
        updateCollection: fetchNShowScienceCollection,
      ));
    }
  }

  void createPreventionTileList() {
    preventionTileList.clear();

    for (int i = preventionArticleList.length - 1; i >= 0; --i) {
      preventionTileList.add(ArticleTile(
        article: preventionArticleList[i],
        isPrevention: true,
        updateCollection: fetchNShowDiseaseCollection,
      ));
    }
  }

  // Medicine API
  void fetchNShowMedicineCollection() async {
    var token = await storage.read(key: 'token');

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
    var token = await storage.read(key: 'token');

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

  // Disease API
  void fetchNShowDiseaseCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/article/favorites/disease/list?page=$pageCount&size=$batchCount',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          preventionArticleList = response.data["data"];
          curItemCount = preventionArticleList.length;
          classSelected[curSelected] = false;
          classSelected[2] = true;
          curSelected = 2;
          _isLoading = false;
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ///print('Request failed: $e');
    }
  }

  // Science API
  void fetchNShowScienceCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/article/favorites/science/list?page=$pageCount&size=$batchCount',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          scienceArticleList = response.data["data"];
          curItemCount = scienceArticleList.length;
          classSelected[curSelected] = false;
          classSelected[3] = true;
          curSelected = 3;
          _isLoading = false;
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
    _scrollController.addListener(_onScroll);
    if (widget.selectedButton[0]) {
      fetchNShowMedicineCollection();
    } else if (widget.selectedButton[1]) {
      fetchNShowFoodCollection();
    } else if (widget.selectedButton[2]) {
      fetchNShowDiseaseCollection();
    } else {
      fetchNShowScienceCollection();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    createMedicineTileList();
    createFoodTileList();
    createScienceTileList();
    createPreventionTileList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MainPages(
                      arguments: {"setToArticlePage": true},
                    )));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "我的收藏",
            style: TextStyle(
                fontFamily: 'BalooBhai',
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.w900),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainPages(
                              arguments: {"setToArticlePage": true},
                            )));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 30,
              )),
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
                  AutoSizeText("用药指南"),
                  //Text("用药指南"),
                  Text("食物参数"),
                  Text("疾病预防"),
                  Text("科普文章"),
                ],
                onPressed: (index) {
                  if (index == 0) {
                    fetchNShowMedicineCollection();
                  } else if (index == 1) {
                    fetchNShowFoodCollection();
                  } else if (index == 2) {
                    fetchNShowDiseaseCollection();
                  } else {
                    fetchNShowScienceCollection();
                  }
                },
              ),
              SizedBox(
                  height: screenHeight * 0.7,
                  width: screenWidth * 0.88,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollController,
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
      ),
    );
  }
}

class ArticleTile extends StatelessWidget {
  final Map article;
  final bool isPrevention;
  final VoidCallback updateCollection;

  const ArticleTile(
      {super.key,
      required this.article,
      required this.isPrevention,
      required this.updateCollection});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      shadowColor: Colors.black87,
      elevation: 6,
      child: InkWell(
        onTap: () {
          if (isPrevention) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SciencePage(
                          title: "返回收藏列表",
                          id: article["id"],
                          isPrevention: isPrevention,
                          updateCollection: updateCollection,
                        )));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SciencePage(
                          title: "返回收藏列表",
                          id: article["id"],
                          isPrevention: isPrevention,
                          updateCollection: updateCollection,
                        )));
          }
        },
        child: ListTile(
          minVerticalPadding: 15,
          title: Text(
            article["title"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w900, color: Colors.black, fontSize: 20),
          subtitle: Text(
            article["subtitle"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Container(
            height: 55,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: AspectRatio(
              aspectRatio: 1.6,
              child: Image.network(
                  article["cover"] != ""
                      ? article["cover"]
                      : "https://static.vecteezy.com/system/resources/thumbnails/008/034/405/small/loading-bar-doodle-element-hand-drawn-vector.jpg",
                  fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

class NonArticleTile extends StatelessWidget {
  final Map articleInfo;
  final String linkpath;
  final bool isMed;
  final VoidCallback updateCollection;

  const NonArticleTile(
      {super.key,
      required this.articleInfo,
      required this.linkpath,
      required this.isMed,
      required this.updateCollection});

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
                    builder: (context) => MedicinePage(
                          title: "返回收藏列表",
                          id: articleInfo["id"],
                          updateHistory: updateCollection,
                        )));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FoodsearchPage(
                          title: "返回收藏列表",
                          id: articleInfo["id"],
                          updateHistory: updateCollection,
                        )));
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
