import 'package:flutter/material.dart';
import '../component/navigation.dart';
import '../component/icons.dart';
import 'media.dart';
import 'post.dart';
import 'report.dart';
import 'comment.dart';

class PostInfo {
  final String username;
  final String profilepic;
  final String date;
  final String content;
  final List<String> images;
  final String video;
  bool addfriend;
  bool star;
  bool like;
  PostInfo(
      {required this.username,
      required this.profilepic,
      required this.date,
      required this.content,
      required this.images,
      required this.video,
      required this.addfriend,
      required this.star,
      required this.like});
}

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
  bool showHeader = true;
  int curSelClassInd = 0;
  int curSelCatInd = 0;
  String selectedFilter = "最新发布";
  var testPost = PostInfo(
      username: "山野都有雾灯kk",
      //profilepic: "assets/images/testUser.png",
      profilepic:
          "https://media.nbclosangeles.com/2021/07/106882821-1620931316186-gettyimages-1232614603-DISNEYLAND_REOPENING.jpeg?quality=85&strip=all&crop=0px%2C4px%2C4000px%2C2250px&resize=1200%2C675",
      date: "2023-10-25",
      content: "最近才了解到高血糖要少吃四种蔬菜耶 土豆、南瓜、酸菜和芋头 以后都要少吃啦~",
      images: [
        "https://cdn.mos.cms.futurecdn.net/iC7HBvohbJqExqvbKcV3pP.jpg",
        "https://www.thespruce.com/thmb/1snRSslsAIBo4KFg3ip3wU-KP5Q=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-to-choose-carving-pumpkins-1403449-03-b29896bd3fa04574937cfde004e45dd5.jpg"
      ],
      video: "",
      addfriend: false,
      star: false,
      like: false);
  var testPost2 = PostInfo(
      username: "山野都有雾灯kk",
      //profilepic: "assets/images/testUser.png",
      profilepic:
          "https://media.nbclosangeles.com/2021/07/106882821-1620931316186-gettyimages-1232614603-DISNEYLAND_REOPENING.jpeg?quality=85&strip=all&crop=0px%2C4px%2C4000px%2C2250px&resize=1200%2C675",
      date: "2023-10-25",
      content: "最近才了解到高血糖要少吃四种蔬菜耶 土豆、南瓜、酸菜和芋头 以后都要少吃啦~",
      images: [],
      video:
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      addfriend: false,
      star: false,
      like: false);
  var testPost3 = PostInfo(
      username: "山野都有雾灯kk",
      profilepic:
          "https://media.nbclosangeles.com/2021/07/106882821-1620931316186-gettyimages-1232614603-DISNEYLAND_REOPENING.jpeg?quality=85&strip=all&crop=0px%2C4px%2C4000px%2C2250px&resize=1200%2C675",
      date: "2023-10-25",
      content: "最近才了解到高血糖要少吃四种蔬菜耶 土豆、南瓜、酸菜和芋头 以后都要少吃啦~",
      images: [
        "https://38jiejie.com/wp-content/uploads/2019/10/Netizens-Criticize-Karry-Wang-Junkais-Style-and-Body-in-Non-Photoshopped-Pictures-Weibo_10.13.19.jpg",
        "https://www.cpophome.com/wp-content/uploads/2021/01/Karry-Wang3.jpg",
        "https://kingchoice.me/media/CACHE/images/4b7b853875653f368e9b0876beb4c176_kXZLhcG/9b9b24e321536feddc7d7b84a11b6dc7.jpg",
        "https://i.mydramalist.com/2qXE2f.jpg",
        "https://overseasidol.com/wp-content/uploads/2022/05/karry-wang-junkai.jpg",
      ],
      video: "",
      addfriend: false,
      star: false,
      like: false);

  void headerButtonAction(int curIndex) {
    if (curSelClassInd == curIndex) {
      setState(() {
        classSelected[curSelClassInd] = false;
        classSelected[curIndex] = true;
        curSelClassInd = curIndex;
        showHeader = !showHeader;
      });
    } else {
      setState(() {
        classSelected[curSelClassInd] = false;
        classSelected[curIndex] = true;
        curSelClassInd = curIndex;
        showHeader = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

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
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // 主题按钮
          SizedBox(
            width: screenWidth * 0.85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                      onTap: () {
                        headerButtonAction(0);
                      },
                      child: ClassButton(
                          title: className[0],
                          icon: MyIcons().bloodLipid(),
                          selected: classSelected[0])),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                      onTap: () {
                        headerButtonAction(1);
                      },
                      child: ClassButton(
                          title: className[1],
                          icon: MyIcons().bloodPressure2(),
                          selected: classSelected[1])),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                      onTap: () {
                        headerButtonAction(2);
                      },
                      child: ClassButton(
                          title: className[2],
                          icon: MyIcons().bloodSugar(),
                          selected: classSelected[2])),
                )
              ],
            ),
          ),
          // 主要内容 & 发帖按钮
          Stack(
            children: [
              // 主要内容
              SizedBox(
                height: screenHeight * 0.7,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 主题图标
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      curSelCatInd = 0;
                                                    });
                                                  },
                                                  child: CategoryButton(
                                                      curInd: curSelCatInd,
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
                                                    });
                                                  },
                                                  child: CategoryButton(
                                                      curInd: curSelCatInd,
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
                                                    });
                                                  },
                                                  child: CategoryButton(
                                                      curInd: curSelCatInd,
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
                                                    });
                                                  },
                                                  child: CategoryButton(
                                                      curInd: curSelCatInd,
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
                            padding: const EdgeInsets.only(left: 30, right: 30),
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
                                      icon: const Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      hint: Text(selectedFilter,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.black),
                                      items: const [
                                        DropdownMenuItem(
                                            value: "最新发布", child: Text("最新发布")),
                                        DropdownMenuItem(
                                            value: "最受欢迎", child: Text("最受欢迎")),
                                        DropdownMenuItem(
                                            value: "我的帖子", child: Text("我的帖子")),
                                        DropdownMenuItem(
                                            value: "我的点赞", child: Text("我的点赞")),
                                        DropdownMenuItem(
                                            value: "我的收藏", child: Text("我的收藏")),
                                        DropdownMenuItem(
                                            value: "我的关注", child: Text("我的关注")),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedFilter = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  // 搜索框
                                  Expanded(
                                    child: Container(
                                      width: screenWidth * 0.5,
                                      height: 30,
                                      child: TextField(
                                        onTap: () {},
                                        decoration: InputDecoration(
                                            hintText: "关键词搜索",
                                            hintStyle: const TextStyle(
                                                color: Colors.black26,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16),
                                            contentPadding:
                                                const EdgeInsets.only(left: 10),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Color.fromARGB(
                                                            255, 250, 209, 252),
                                                        width: 2)),
                                            suffixIcon: IconButton(
                                              onPressed: () {},
                                              icon: Image.asset(
                                                  "assets/icons/searchWhite.png",
                                                  width: 10),
                                              padding: const EdgeInsets.only(
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
                    decoration: const BoxDecoration(color: Colors.black12),
                  ),
                  // 帖子
                  // Container(
                  //   height: screenHeight * 0.7 - 137,
                  //   decoration: const BoxDecoration(color: Colors.black12),
                  //   child: ListView(
                  //     shrinkWrap: true,
                  //     children: [
                  //       PostTile(width: screenWidth - 80, curPost: testPost),
                  //       PostTile(width: screenWidth - 80, curPost: testPost2),
                  //       PostTile(width: screenWidth - 80, curPost: testPost3),
                  //     ],
                  //   ),
                  // ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.black12),
                      child: Column(
                        children: [
                          PostTile(width: screenWidth - 80, curPost: testPost),
                          PostTile(width: screenWidth - 80, curPost: testPost2),
                          PostTile(width: screenWidth - 80, curPost: testPost3),
                        ],
                      ),
                    ),
                  ))
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
                            content: Post(width: screenWidth * 0.9),
                          );
                        });
                  },
                  foregroundColor: const Color.fromARGB(255, 250, 209, 252),
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

      // 下方导航栏
      bottomNavigationBar: const MyNavigationBar(currentIndex: 3),
    );
  }
}

class ClassButton extends StatelessWidget {
  final String title;
  final Image icon;
  final bool selected;
  const ClassButton(
      {super.key,
      required this.title,
      required this.icon,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
          color: selected
              ? const Color.fromARGB(255, 249, 227, 251)
              : Colors.transparent,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(13)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        icon,
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.fromLTRB(11, 0, 11, 0),
      decoration: BoxDecoration(
          color: curInd == catInd ? Colors.black : Colors.black12,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: curInd == catInd ? FontWeight.w900 : FontWeight.normal,
            color: curInd == catInd ? Colors.white : Colors.black,
            fontSize: 16),
      ),
    );
  }
}

class PostTile extends StatefulWidget {
  final PostInfo curPost;
  final double width;
  const PostTile({super.key, required this.width, required this.curPost});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  bool addfriend = false;
  var imageContainerList = <Widget>[];

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
                      child: Image.network(
                        imageList[i],
                        fit: BoxFit.cover,
                      ),
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
                  child: Image.network(
                    imageList[i],
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      );
    }
    for (int i = 0; i < 3 - loopLen; ++i) {
      imageContainerList.add(SizedBox(width: imageSize));
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      addfriend = widget.curPost.addfriend;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    createImageConList(context, widget.curPost.images, widget.width * 0.33);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(children: [
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
                    backgroundImage: NetworkImage(widget.curPost.profilepic),
                  ),
                ),
                // 用户名 & 发布日期
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.fromLTRB(12, 3, 0, 3),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.curPost.username,
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.curPost.date,
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
                        InkWell(
                          onTap: () {
                            setState(() {
                              addfriend = !addfriend;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 0, 7, 0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Icon(
                                  addfriend ? null : Icons.add,
                                  size: addfriend ? 3 : 15,
                                  color: Colors.orange,
                                ),
                                Text(
                                  addfriend ? "取消关注" : "关注",
                                  style: const TextStyle(
                                      color: Colors.orange, fontSize: 14),
                                )
                              ],
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
                                  return const ConfirmReportDialog();
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
              widget.curPost.content,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            // 照片栏 media = image
            Visibility(
              visible: widget.curPost.video == "",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: imageContainerList,
              ),
            ),
            // 视频 media = video
            Visibility(
              visible: widget.curPost.video != "",
              child: VideoPlayerScreen(
                enlarge: false,
                videolink: widget.curPost.video,
                fullscreen: false,
              ),
            ),
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
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyIcons().share(),
                        const SizedBox(width: 5),
                        const Text(
                          "分享",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        widget.curPost.star = !widget.curPost.star;
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.curPost.star
                              ? MyIcons().collectionAdded()
                              : MyIcons().collection(),
                          const SizedBox(width: 5),
                          const Text(
                            "收藏",
                            style: TextStyle(fontSize: 16),
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
                              content: CommentDialog(
                                  width: screenWidth * 0.9,
                                  height: screenHeight * 0.5),
                            );
                          });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyIcons().comment(),
                          const SizedBox(width: 5),
                          const Text(
                            "评论",
                            style: TextStyle(fontSize: 16),
                          )
                        ]),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        widget.curPost.like = !widget.curPost.like;
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.curPost.like
                              ? MyIcons().liked()
                              : MyIcons().like(),
                          const SizedBox(width: 5),
                          const Text(
                            "点赞",
                            style: TextStyle(fontSize: 16),
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
