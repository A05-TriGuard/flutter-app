import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../account/token.dart';
import '../component/icons.dart';
import 'collection.dart';

class SciencePage extends StatefulWidget {
  final String title;
  final bool isPrevention;
  final int id;
  final VoidCallback updateCollection;
  const SciencePage(
      {super.key,
      required this.title,
      required this.id,
      required this.isPrevention,
      required this.updateCollection});

  @override
  State<SciencePage> createState() => _SciencePageState();
}

class _SciencePageState extends State<SciencePage> {
  bool addedCollection = false;
  Map articleInfo = {
    "title": "",
    "subtitle": "",
    "content": "",
    "isFavorite": false
  };

  // Article API
  void fetchNShowArticleInfo() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/article/get?id=${widget.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          articleInfo = response.data["data"];
          addedCollection = articleInfo["isFavorite"];
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  // Article API
  void addArticleToCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/article/favorites/add?articleId=${widget.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          addedCollection = true;
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  // Article API
  void removeArticleFromCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/article/favorites/delete?articleId=${widget.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          addedCollection = false;
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
    fetchNShowArticleInfo();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(
                fontFamily: 'BalooBhai',
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.w900),
          ),
          leading: IconButton(
              onPressed: () {
                if (widget.title == "返回文章列表") {
                  Navigator.pop(context);
                } else {
                  if (widget.isPrevention) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Collection(
                                  selectedButton: [false, false, true, false],
                                ))).then((value) {
                      widget.updateCollection();
                    });
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Collection(
                                  selectedButton: [false, false, false, true],
                                ))).then((value) {
                      widget.updateCollection();
                    });
                  }
                }
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
        body: Center(
            child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      articleInfo["title"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    IconButton(
                        onPressed: () {
                          if (!addedCollection) {
                            addArticleToCollection();
                          } else {
                            removeArticleFromCollection();
                          }
                        },
                        icon: addedCollection
                            ? MyIcons().starr()
                            : MyIcons().star()),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(15),
                        child: ListView(
                            children: [HtmlWidget(articleInfo["content"])]),
                      ),
                    ),
                  ],
                ))),
      ),
    );
  }
}
