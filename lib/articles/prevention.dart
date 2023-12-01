import 'package:flutter/material.dart';
import '../component/icons.dart';

// TOINTERACT: 增加var列表，用来保存内容页面需要展示的内容（图片、文字等）
// TOINTERACT: 增加bool变量记录文章是否被收藏
class ArticleInfo {
  final String title;
  final String content;
  final String imagePath;
  ArticleInfo(
      {required this.title, required this.content, required this.imagePath});
}

class Prevention extends StatefulWidget {
  const Prevention({super.key});

  @override
  State<Prevention> createState() => _PreventionState();
}

class _PreventionState extends State<Prevention> {
  int _currentIndex = 0;
  var articleList = <ArticleInfo>[
    ArticleInfo(
        title: "Title 1",
        content: "This is the first content...",
        imagePath:
            "https://climate.copernicus.eu/sites/default/files/styles/hero_image_extra_large_2x/public/2023-07/iStock-1267333118.jpg?itok=1udeNtwZ"),
    ArticleInfo(
        title: "Title 2",
        content: "This is the second content...",
        imagePath:
            "https://assets-global.website-files.com/61eaa3470cc7de3ef77364b3/651430a63005ee02c2bab489_istockphoto-1270902491-170667a.jpg"),
    ArticleInfo(
        title: "Title 3",
        content: "This is the third content...",
        imagePath:
            "https://images.unsplash.com/photo-1576622085773-4eb399076362?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8bWVycnklMjBnbyUyMHJvdW5kfGVufDB8fDB8fHww"),
    ArticleInfo(
        title: "Title 4",
        content: "This is the forth content...",
        imagePath:
            "https://www.danceinforma.com/wp-content/uploads/2019/08/Ailey-.jpg"),
    ArticleInfo(
        title: "Title 5",
        content: "This is the fifth content...",
        imagePath:
            "https://images.nintendolife.com/3e199ccf1141f/doraemon-nobitars-little-star-wars-2021.large.jpg"),
    ArticleInfo(
        title: "Title 6",
        content: "This is the sixth content...",
        imagePath:
            "https://i.guim.co.uk/img/media/d13a335be378fd1d5360d34a88faefe2b6e38ca9/0_156_3500_2100/master/3500.jpg?width=700&quality=85&auto=format&fit=max&s=092c5fc37ff9a1f56faae91550b1d035"),
    ArticleInfo(
        title: "Title 7",
        content: "This is the seventh content...",
        imagePath:
            "https://news.cgtn.com/news/3049544e7751544f776b7a4e3249444f776b7a4e31457a6333566d54/img/dbc2bed8083940c4a70ca53dc7e784a2/dbc2bed8083940c4a70ca53dc7e784a2.jpg"),
    ArticleInfo(
        title: "Title 8",
        content: "This is the eighth content...",
        imagePath:
            "https://wollens.co.uk/wp-content/uploads/2019/10/Halloween--e1668260910131.jpg"),
    ArticleInfo(
        title: "Title 9",
        content: "This is the ninth content...",
        imagePath:
            "https://www.billboard.com/wp-content/uploads/2023/06/Oreo-x-Nintendo-billboard-1548.jpg?w=942&h=623&crop=1"),
    ArticleInfo(
        title: "Title 10",
        content: "This is the tenth content...",
        imagePath:
            "https://sramedia.s3.amazonaws.com/media/images/News/21b8762b-7506-421d-9d27-22c15eaea828.jpg?v=447381432"),
  ];

  var articleTileList = <ArticleTile>[];

  void createArticleList() {
    for (int i = 0; i < articleList.length; ++i) {
      articleTileList.add(ArticleTile(articleList: articleList[i]));
    }
  }

  @override
  Widget build(BuildContext context) {
    articleTileList.clear();
    createArticleList();

    return Scaffold(
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
              Navigator.pushNamed(context, '/articles');
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
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: articleTileList,
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
          Navigator.pushNamed(context, '/articles/science/page');
        },
        child: ListTile(
          minVerticalPadding: 15,
          title: Text(
            articleList.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
