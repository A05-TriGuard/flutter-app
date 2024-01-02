import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';
import 'sciencepage.dart';
import '../component/mainPagesBar/mainPagesBar.dart';

class Prevention extends StatefulWidget {
  const Prevention({super.key});

  @override
  State<Prevention> createState() => _PreventionState();
}

class _PreventionState extends State<Prevention> {
  int pageCount = 1;
  int batchCount = 10;
  int increaseNum = 5;
  var articleList = [];
  var articleTileList = <ArticleTile>[];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void createArticleList() {
    articleTileList.clear();

    for (int i = 0; i < articleList.length; ++i) {
      articleTileList.add(ArticleTile(article: articleList[i]));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
          batchCount += increaseNum;
          fetchNShowArticles();
        });
      }
    }
  }

  // Prevention API
  void fetchNShowArticles() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/article/disease/list?page=$pageCount&size=$batchCount',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          //showResult = true;
          articleList = response.data["data"];
          _isLoading = false;
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchNShowArticles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createArticleList();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MainPages(
                      arguments: {"setToArticlePage": true},
                    )));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "疾病预防",
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
        body: Container(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              itemCount: articleTileList.length,
              itemBuilder: (context, index) {
                return articleTileList[index];
              },
            )),
      ),
    );
  }
}

class ArticleTile extends StatelessWidget {
  final Map article;

  const ArticleTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      elevation: 6,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SciencePage(
                        title: "返回文章列表",
                        id: article["id"],
                        isPrevention: true,
                        updateCollection: () {},
                      )));
        },
        child: ListTile(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          tileColor: Colors.white,
          title: Text(
            article["title"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w900, color: Colors.black, fontSize: 20),
          subtitle: Text(
            article["subtitle"] ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // leading: Container(
          //   clipBehavior: Clip.hardEdge,
          //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          //   child: AspectRatio(
          //     aspectRatio: 1.6,
          //     child: Image.network(
          //         (article["cover"] != "" && article["cover"] != null)
          //             ? article["cover"]
          //             : "https://static.vecteezy.com/system/resources/thumbnails/008/034/405/small/loading-bar-doodle-element-hand-drawn-vector.jpg",
          //         fit: BoxFit.cover),
          //   ),
          // ),
        ),
      ),
    );
  }
}
