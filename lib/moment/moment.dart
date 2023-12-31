import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../component/icons.dart';
import '../account/token.dart';
import 'media.dart';
import 'post.dart';
import 'report.dart';
import 'comment.dart';

class Moment extends StatefulWidget {
  const Moment({super.key});

  @override
  State<Moment> createState() => _MomentState();
}

class _MomentState extends State<Moment> {
  var classSelected = <bool>[true, false, false];
  var iconSelected = <Image>[
    MyIcons().bloodLipidBig(),
    MyIcons().bloodPressure2Big(),
    MyIcons().bloodSugarBig()
  ];
  var className = <String>["高血脂", "高血压", "高血糖"];
  var categoryName = <String>["饮食", "运动", "生活", "其他"];
  bool showHeader = true;
  int curSelClassInd = 0;
  int curSelCatInd = 0;
  String selectedFilter = "最新发布";
  var curPostList = [];
  var postTileList = [];
  var userFollowMap = {};
  var curUserId = 0;
  bool isLoading = true;
  double lastPosition = 0;
  late ScrollController listViewController;
  final searchController = TextEditingController();
  String keyword = "";
  int pageCount = 1;
  int batchCount = 5;
  bool _isLoading = false;
  bool refreshPage = false;

  void _onScroll() {
    if (listViewController.position.pixels ==
        listViewController.position.maxScrollExtent) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
          pageCount += 1;
          refreshPage = false;
          lastPosition = listViewController.offset;
        });
        fetchNShowPostList();
      }
    }
  }

  // Moment API
  void getAccountId() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/account/info',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        curUserId = response.data["data"]["id"];
        pageCount = 1;
        refreshPage = false;
        fetchNShowPostList();
      }
    } catch (e) {/**/}
  }

  // Moment API
  void fetchNShowPostList() async {
    curPostList.clear();

    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          keyword != ""
              ? 'http://43.138.75.58:8080/api/moment/list?class=${className[curSelClassInd]}&category=${categoryName[curSelCatInd]}&filter=$selectedFilter&keyword=$keyword&page=$pageCount&size=$batchCount'
              : 'http://43.138.75.58:8080/api/moment/list?class=${className[curSelClassInd]}&category=${categoryName[curSelCatInd]}&filter=$selectedFilter&page=$pageCount&size=$batchCount',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        if (keyword != "") {
          setState(() {
            curPostList = response.data["data"];
            isLoading = false;
            keyword = "";
            searchController.clear();
            _isLoading = false;
          });
        } else {
          setState(() {
            curPostList = response.data["data"];
            isLoading = false;
            _isLoading = false;
          });
        }
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  void addUserFollowPair(int userId, bool isFollow) {
    var postCount = pageCount * 5;
    setState(() {
      userFollowMap[userId.toString()] = isFollow;
      isLoading = true;
      //remainPosition = true;
      lastPosition = listViewController.offset;
      pageCount = 1;
      batchCount = postCount;
      refreshPage = true;
    });
    fetchNShowPostList();
  }

  bool getUserFollowCond(int userId) {
    return userFollowMap[userId.toString()];
  }

  void updatePostList(List newPostList) {
    setState(() {
      curPostList = newPostList;
      refreshPage = true;
    });
  }

  void createPostTileList(double width) {
    if (refreshPage) {
      postTileList.clear();
    }

    for (int i = 0; i < curPostList.length; ++i) {
      var tmp = curPostList[i]["accountId"].toString();
      if (!userFollowMap.containsKey(tmp)) {
        userFollowMap[tmp] = curPostList[i]["isFollow"];
      }

      postTileList.add(PostTile(
        key: UniqueKey(),
        width: width,
        curPost: curPostList[i],
        curUserId: curUserId,
        updatePostList: updatePostList,
        getSelectedProperty: getSelectedProperty,
        updateUserFollowMap: addUserFollowPair,
        getFollowCond: getUserFollowCond,
      ));
    }
  }

  String getSelectedProperty(int index) {
    if (index == 0) {
      return className[curSelClassInd];
    }
    if (index == 1) {
      return categoryName[curSelCatInd];
    }
    if (index == 2) {
      return selectedFilter;
    }
    return pageCount.toString();
  }

  void headerButtonAction(int curIndex) {
    if (curSelClassInd == curIndex) {
      setState(() {
        showHeader = !showHeader;
        lastPosition = listViewController.offset;
      });
    } else {
      setState(() {
        classSelected[curSelClassInd] = false;
        classSelected[curIndex] = true;
        curSelClassInd = curIndex;
        showHeader = true;
        isLoading = true;
        lastPosition = 0.0;
        pageCount = 1;
        refreshPage = true;
      });
      fetchNShowPostList();
    }
  }

  @override
  void initState() {
    super.initState();
    getAccountId();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    listViewController = ScrollController(initialScrollOffset: lastPosition);
    listViewController.addListener(_onScroll);

    createPostTileList(screenWidth - 80);

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "TriGuard",
          style: TextStyle(
              fontFamily: 'BalooBhai', fontSize: 26, color: Colors.black),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(169, 171, 179, 1),
                  width: 1,
                ),
              ),
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 20),
                // 主题按钮
                SizedBox(
                  width: screenWidth * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            headerButtonAction(0);
                          },
                          child: ClassButton(
                            title: className[0],
                            icon: MyIcons().bloodLipidOutlined(),
                            selected: classSelected[0],
                            buttonWidth: screenWidth * 0.85 * 0.31,
                          )),
                      InkWell(
                          onTap: () {
                            headerButtonAction(1);
                          },
                          child: ClassButton(
                            title: className[1],
                            icon: MyIcons().bloodPressure2(),
                            selected: classSelected[1],
                            buttonWidth: screenWidth * 0.85 * 0.31,
                          )),
                      InkWell(
                          onTap: () {
                            headerButtonAction(2);
                          },
                          child: ClassButton(
                            title: className[2],
                            icon: MyIcons().bloodSugar(),
                            selected: classSelected[2],
                            buttonWidth: screenWidth * 0.85 * 0.31,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // 主要内容 & 发帖按钮
                Stack(
                  children: [
                    // 主要内容
                    SizedBox(
                      height: screenHeight * 0.75,
                      child: Column(children: [
                        Visibility(
                            visible: showHeader,
                            child: Column(
                              children: [
                                // 主题 Header
                                Stack(children: [
                                  // 打底
                                  Container(
                                    height: 80,
                                    color: Colors.transparent,
                                  ),
                                  // 后面白色阴影
                                  Positioned(
                                    top: 40,
                                    child: Container(
                                      width: screenWidth,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black26,
                                                offset: Offset(0, 3),
                                                blurRadius: 3)
                                          ]),
                                    ),
                                  ),
                                  // 标题那栏
                                  Positioned(
                                    left: 30,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 主题图标
                                        Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black38,
                                                    offset: Offset(3, 3),
                                                    blurRadius: 5)
                                              ]),
                                          child: iconSelected[curSelClassInd],
                                        ),
                                        // 主题名称 & 分类
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 40),
                                          width: screenWidth - 100,
                                          height: 70,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              // 主题名称
                                              Text(
                                                className[curSelClassInd],
                                                style: const TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2),
                                              ),
                                              // 话题分类
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            curSelCatInd = 0;
                                                            lastPosition = 0.0;
                                                            pageCount = 1;
                                                            refreshPage = true;
                                                          });
                                                          fetchNShowPostList();
                                                        },
                                                        child: CategoryButton(
                                                            curInd:
                                                                curSelCatInd,
                                                            catInd: 0,
                                                            title: "饮食")),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            curSelCatInd = 1;
                                                            lastPosition = 0.0;
                                                            pageCount = 1;
                                                            refreshPage = true;
                                                          });
                                                          fetchNShowPostList();
                                                        },
                                                        child: CategoryButton(
                                                            curInd:
                                                                curSelCatInd,
                                                            catInd: 1,
                                                            title: "运动")),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            curSelCatInd = 2;
                                                            lastPosition = 0.0;
                                                            pageCount = 1;
                                                            refreshPage = true;
                                                          });
                                                          fetchNShowPostList();
                                                        },
                                                        child: CategoryButton(
                                                            curInd:
                                                                curSelCatInd,
                                                            catInd: 2,
                                                            title: "生活")),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            curSelCatInd = 3;
                                                            lastPosition = 0.0;
                                                            pageCount = 1;
                                                            refreshPage = true;
                                                          });
                                                          fetchNShowPostList();
                                                        },
                                                        child: CategoryButton(
                                                            curInd:
                                                                curSelCatInd,
                                                            catInd: 3,
                                                            title: "其他")),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                                // 筛选框 & 搜索框
                                Container(
                                  height: 50,
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 0),
                                            blurRadius: 3)
                                      ]),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        // 筛选框
                                        Container(
                                          height: 30,
                                          padding: const EdgeInsets.only(
                                              left: 10, bottom: 5),
                                          color: Colors.black12,
                                          child: DropdownButton(
                                            icon: const Icon(
                                                Icons.arrow_drop_down),
                                            iconSize: 30,
                                            hint: Text(selectedFilter,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                            items: const [
                                              DropdownMenuItem(
                                                  value: "最新发布",
                                                  child: Text("最新发布")),
                                              DropdownMenuItem(
                                                  value: "最受欢迎",
                                                  child: Text("最受欢迎")),
                                              DropdownMenuItem(
                                                  value: "我的帖子",
                                                  child: Text("我的帖子")),
                                              DropdownMenuItem(
                                                  value: "我的点赞",
                                                  child: Text("我的点赞")),
                                              DropdownMenuItem(
                                                  value: "我的收藏",
                                                  child: Text("我的收藏")),
                                              DropdownMenuItem(
                                                  value: "我的关注",
                                                  child: Text("我的关注")),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                selectedFilter = value!;
                                                lastPosition = 0.0;
                                                isLoading = true;
                                                pageCount = 1;
                                                refreshPage = true;
                                              });
                                              fetchNShowPostList();
                                            },
                                          ),
                                        ),
                                        // 搜索框
                                        Expanded(
                                          child: SizedBox(
                                            width: screenWidth * 0.5,
                                            height: 30,
                                            child: TextField(
                                              controller: searchController,
                                              onTap: () {},
                                              decoration: InputDecoration(
                                                  hintText: "关键词搜索",
                                                  hintStyle: const TextStyle(
                                                      color: Colors.black26,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 16),
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black),
                                                  ),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          250,
                                                                          209,
                                                                          252),
                                                                  width: 2)),
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      keyword =
                                                          searchController.text;
                                                      pageCount = 1;
                                                      refreshPage = true;
                                                      fetchNShowPostList();
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              FocusNode());
                                                    },
                                                    icon: Image.asset(
                                                        "assets/icons/searchWhite.png",
                                                        width: 10),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 0),
                                                  )),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        )
                                      ]),
                                )
                              ],
                            )),
                        // 灰边
                        Container(
                          height: 7,
                          decoration:
                              const BoxDecoration(color: Colors.black12),
                        ),
                        // 帖子列表
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.black12),
                                  child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      controller: listViewController,
                                      shrinkWrap: true,
                                      itemCount: postTileList.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        return postTileList[index];
                                      }),
                                ),
                        )
                      ]),
                    ),
                    // 发帖按钮
                    Positioned(
                      top: screenHeight * 0.55,
                      left: screenWidth * 0.81,
                      child: FloatingActionButton(
                        onPressed: () {
                          showDialog(
                              barrierColor: Colors.black87,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Post(
                                    width: screenWidth * 0.4,
                                    updatePostList: updatePostList,
                                    getSelectedProperty: getSelectedProperty,
                                  ),
                                );
                              });
                        },
                        foregroundColor:
                            const Color.fromARGB(255, 250, 209, 252),
                        backgroundColor: Colors.white,
                        splashColor: const Color.fromARGB(255, 250, 209, 252),
                        elevation: 10,
                        tooltip: "发布帖子",
                        child: const Icon(
                          Icons.add,
                          size: 50,
                        ),
                      ),
                    )
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}

class ClassButton extends StatelessWidget {
  final String title;
  final Image icon;
  final bool selected;
  final double buttonWidth;
  const ClassButton(
      {super.key,
      required this.title,
      required this.icon,
      required this.selected,
      required this.buttonWidth});

  @override
  Widget build(BuildContext context) {
    return Ink(
      //padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
      width: buttonWidth,
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          color: selected
              ? const Color.fromARGB(255, 249, 227, 251)
              : Colors.transparent,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(13)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        icon,
        SizedBox(
          child: AutoSizeText(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        )
      ]),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final int curInd;
  final int catInd;
  final String title;
  const CategoryButton(
      {super.key,
      required this.curInd,
      required this.catInd,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        decoration: BoxDecoration(
            color: curInd == catInd ? Colors.black : Colors.black12,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: AutoSizeText(
          title,
          maxLines: 1,
          minFontSize: 5,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: curInd == catInd ? FontWeight.w900 : FontWeight.normal,
            color: curInd == catInd ? Colors.white : Colors.black,
          ),
        ));
  }
}

class PostTile extends StatefulWidget {
  final Map curPost;
  final double width;
  final int curUserId;
  final Function(List) updatePostList;
  final Function(int) getSelectedProperty;
  final Function(int, bool) updateUserFollowMap;
  final Function(int) getFollowCond;
  const PostTile(
      {super.key,
      required this.width,
      required this.curPost,
      required this.curUserId,
      required this.updatePostList,
      required this.getSelectedProperty,
      required this.updateUserFollowMap,
      required this.getFollowCond});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  bool isFollow = false;
  bool isFavorite = false;
  bool isLike = false;
  int likeCount = 0;
  int commentCount = 0;
  int favoriteCount = 0;
  var imageContainerList = <Widget>[];
  var commentList = [];
  var updatedPostList = [];
  var curClass = "";
  var curCategory = "";
  var curFilter = "";
  int curPageCount = 0;
  bool isLoadingFollow = false;

  void getProperty() {
    curClass = widget.getSelectedProperty(0);
    curCategory = widget.getSelectedProperty(1);
    curFilter = widget.getSelectedProperty(2);
    curPageCount = int.parse(widget.getSelectedProperty(3));
  }

  // Moment API
  void fetchPostList() async {
    updatedPostList.clear();
    getProperty();
    var postCount = curPageCount * 5;

    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/moment/list?class=$curClass&category=$curCategory&filter=$curFilter&page=1&size=$postCount',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        updatedPostList = response.data["data"];
        widget.updatePostList(updatedPostList);
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  // Moment API
  void addPostToCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/moment/favorite?momentId=${widget.curPost["id"]}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          isFavorite = true;
          favoriteCount += 1;
        });
      }
    } catch (e) {/**/}
  }

  // Moment API
  void removePostFromCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/moment/unfavorite?momentId=${widget.curPost["id"]}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          isFavorite = false;
          favoriteCount -= 1;
        });
      }
    } catch (e) {/**/}
  }

  // Moment API
  void likePost() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/moment/like?momentId=${widget.curPost["id"]}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          isLike = true;
          likeCount += 1;
        });
      }
    } catch (e) {/**/}
  }

  // Moment API
  void unlikePost() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/moment/unlike?momentId=${widget.curPost["id"]}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          isLike = false;
          likeCount -= 1;
        });
      }
    } catch (e) {/**/}
  }

  // Moment API
  void followUser() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/moment/follow?momentAccountId=${widget.curPost["accountId"]}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        widget.updateUserFollowMap(widget.curPost["accountId"], true);
      }
    } catch (e) {/**/}
  }

  // Moment API
  void unfollowUser() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/moment/unfollow?momentAccountId=${widget.curPost["accountId"]}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        widget.updateUserFollowMap(widget.curPost["accountId"], false);
      }
    } catch (e) {/**/}
  }

  void createImageConList(
      BuildContext context, List imageList, double imageSize) {
    imageContainerList.clear();
    var loopLen = imageList.length;
    var needCount = false;
    int count = 0;
    if (loopLen > 3) {
      count = loopLen - 3;
      loopLen = 3;
      needCount = true;
    }
    for (int i = 0; i < loopLen; ++i) {
      imageContainerList.add(
        // 图片方块
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Gallery(
                    images: imageList,
                    curIndex: i,
                  );
                });
          },
          child: (needCount && i == 2)
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black45,
                                offset: Offset(1, 1),
                                blurRadius: 3)
                          ]),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl:
                            "http://43.138.75.58:8080/static/${imageList[i]}",
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),

                      // Image.network(
                      //   imageList[i],
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    Container(
                      width: imageSize,
                      height: imageSize,
                      color: Colors.black26,
                      child: Center(
                        child: Text(
                          "+$count",
                          style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  ],
                )
              : Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black45,
                            offset: Offset(1, 1),
                            blurRadius: 3)
                      ]),
                  child:
                      // Image.network(
                      //   //imageList[i],
                      //   //"https://cdn.mos.cms.futurecdn.net/iC7HBvohbJqExqvbKcV3pP.jpg",
                      //   "http://43.138.75.58:8080/static/1702984086797IMG_20231216_004005.jpg",
                      //   fit: BoxFit.cover,
                      // ),
                      CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: "http://43.138.75.58:8080/static/${imageList[i]}",
                    //"http://43.138.75.58:8080/static/1702984086797IMG_20231216_004005.jpg",
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
        ),
      );
    }
    for (int i = 0; i < 3 - loopLen; ++i) {
      imageContainerList.add(SizedBox(width: imageSize));
    }
  }

  List<String> separateString(String input) {
    if (input.endsWith(';')) {
      input = input.substring(0, input.length - 1);
    }
    List<String> result = input.split(';');
    result.removeWhere((element) => element.isEmpty);
    return result;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isFollow = widget.getFollowCond(widget.curPost["accountId"]);
      isFavorite = widget.curPost["isFavorite"];
      isLike = widget.curPost["isLike"];
      likeCount = widget.curPost["likeCount"];
      commentCount = widget.curPost["commentCount"];
      favoriteCount = widget.curPost["favoriteCount"];
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    if (widget.curPost["images"] != "") {
      createImageConList(context, separateString(widget.curPost["images"]),
          widget.width * 0.33);
    } else {
      createImageConList(context, [], widget.width * 0.33);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
          decoration: const BoxDecoration(color: Colors.white),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 帖子 header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户头像
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.black45,
                  child: CircleAvatar(
                    radius: 21,
                    backgroundColor: Colors.white,
                    backgroundImage: widget.curPost["profile"] != null
                        ? CachedNetworkImageProvider(
                            "http://43.138.75.58:8080/static/${widget.curPost["profile"]}")
                        : const CachedNetworkImageProvider(
                            "https://static.vecteezy.com/system/resources/previews/020/765/399/non_2x/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg"),
                  ),
                ),
                // 用户名 & 发布日期
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            widget.curPost["username"],
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.curPost["date"],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          )
                        ]),
                  ),
                ),
                // 功能按键
                Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        // 关注按键
                        Visibility(
                          visible:
                              widget.curPost["accountId"] != widget.curUserId,
                          child: isLoadingFollow
                              ? const CircularProgressIndicator()
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isFollow) {
                                        unfollowUser();
                                      } else {
                                        followUser();
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 7, 0),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.orange),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isFollow ? null : Icons.add,
                                          size: isFollow ? 3 : 15,
                                          color: Colors.orange,
                                        ),
                                        Text(
                                          isFollow ? "取消关注" : "关注",
                                          style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        // 更多功能按键
                        InkWell(
                          onTap: () {
                            showDialog(
                                barrierColor: Colors.black87,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      insetPadding: EdgeInsets.zero,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          widget.curPost["accountId"] ==
                                                  widget.curUserId
                                              ?
                                              // 删除按钮
                                              Row(
                                                  children: [
                                                    Expanded(
                                                        child: TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              showDialog(
                                                                  barrierColor:
                                                                      Colors
                                                                          .black87,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return DeleteDialog(
                                                                        curPostId:
                                                                            widget.curPost[
                                                                                "id"],
                                                                        getSelectedProperty:
                                                                            widget
                                                                                .getSelectedProperty,
                                                                        updatePostList:
                                                                            widget.updatePostList);
                                                                  });
                                                            },
                                                            child: const Text(
                                                              "删除",
                                                              style: TextStyle(
                                                                  fontSize: 18),
                                                            )))
                                                  ],
                                                )
                                              :
                                              // 举报按钮
                                              Row(
                                                  children: [
                                                    Expanded(
                                                        child: TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              showDialog(
                                                                  barrierColor:
                                                                      Colors
                                                                          .black87,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return ConfirmReportDialog(
                                                                      postId: widget
                                                                              .curPost[
                                                                          "id"],
                                                                    );
                                                                  });
                                                            },
                                                            child: const Text(
                                                              "举报",
                                                              style: TextStyle(
                                                                  fontSize: 18),
                                                            )))
                                                  ],
                                                ),
                                        ],
                                      ));
                                });
                          },
                          child: const Text(
                            "○○○",
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.curPost["content"],
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: widget.curPost["images"] != "",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: imageContainerList,
              ),
            ),
            // 视频 media = video
            widget.curPost["video"] != ""
                ? VideoPlayerScreen(
                    enlarge: false,
                    videolink: widget.curPost["video"],
                    fullscreen: false,
                  )
                : Container(),
            const SizedBox(height: 10),
            Container(
              color: Colors.black12,
              height: 1,
            ),
            const SizedBox(height: 10),
            // 互动栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      if (isFavorite) {
                        removePostFromCollection();
                      } else {
                        addPostToCollection();
                      }
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isFavorite
                              ? MyIcons().collectionAdded()
                              : MyIcons().collection(),
                          const SizedBox(width: 5),
                          Text(
                            favoriteCount <= 0
                                ? "收藏"
                                : favoriteCount.toString(),
                            style: const TextStyle(fontSize: 16),
                          )
                        ]),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          barrierColor: Colors.black87,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              insetPadding: EdgeInsets.zero,
                              content: CommentDialog(
                                width: screenWidth * 0.65,
                                height: screenHeight * 0.5,
                                postId: widget.curPost["id"],
                              ),
                            );
                          }).then((value) {
                        fetchPostList();
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyIcons().comment(),
                          const SizedBox(width: 5),
                          Text(
                            commentCount <= 0 ? "评论" : commentCount.toString(),
                            style: const TextStyle(fontSize: 16),
                          )
                        ]),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isLike) {
                          unlikePost();
                        } else {
                          likePost();
                        }
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isLike ? MyIcons().liked() : MyIcons().like(),
                          const SizedBox(width: 5),
                          Text(
                            likeCount <= 0 ? "点赞" : likeCount.toString(),
                            style: const TextStyle(fontSize: 16),
                          )
                        ]),
                  ),
                ),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 7),
      ],
    );
  }
}

class DeleteDialog extends StatefulWidget {
  final int curPostId;
  final Function(int) getSelectedProperty;
  final Function(List) updatePostList;
  const DeleteDialog(
      {super.key,
      required this.curPostId,
      required this.getSelectedProperty,
      required this.updatePostList});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  bool isLoading = false;
  var updatedPostList = [];
  var curClass = "";
  var curCategory = "";
  var curFilter = "";
  int curPageCount = 0;

  void getProperty() {
    curClass = widget.getSelectedProperty(0);
    curCategory = widget.getSelectedProperty(1);
    curFilter = widget.getSelectedProperty(2);
    curPageCount = int.parse(widget.getSelectedProperty(3));
  }

  // Moment API
  void deletePost() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/moment/delete?momentId=${widget.curPostId}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        refreshPost();
      }
    } catch (e) {/**/}
  }

  // Moment API
  void fetchNShowPostList() async {
    getProperty();
    var postCount = curPageCount * 5;

    var token = await storage.read(key: 'token');

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/moment/list?class=$curClass&category=$curCategory&filter=$curFilter&page=1&size=$postCount',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        updatedPostList = response.data["data"];
        widget.updatePostList(updatedPostList);
      } else {/**/}
    } catch (e) {/**/}
  }

  void refreshPost() {
    fetchNShowPostList();

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pop(context);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "操作提示",
        style: TextStyle(fontSize: 24),
      ),
      content: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: isLoading,
            child: const CircularProgressIndicator(),
          ),
          const Text(
            "确认删除该帖子？",
            style: TextStyle(fontSize: 22),
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              deletePost();
            },
            child: const Text(
              "确认",
              style: TextStyle(fontSize: 20),
            )),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "取消",
              style: TextStyle(fontSize: 20),
            ))
      ],
    );
  }
}
