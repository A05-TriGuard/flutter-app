import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../component/icons.dart';
import '../account/token.dart';
import '../articles/medicine.dart';
import '../articles/collection.dart';

class MedicinePage extends StatefulWidget {
  final String title;
  final int id;
  final VoidCallback updateHistory;
  const MedicinePage(
      {super.key,
      required this.title,
      required this.id,
      required this.updateHistory});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  bool addedCollection = false;
  Map medicineInfo = {};

  // Medicine API
  void fetchNShowMedicineInfo() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/medicine/info?id=${widget.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          medicineInfo = response.data["data"];
          addedCollection = medicineInfo["isFavorite"];
        });
      } else {/**/}
    } catch (e) {/**/}
  }

  // Medicine API
  void addMedicineToCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/medicine/favorites/add?medicineId=${widget.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          addedCollection = true;
        });
      } else {/**/}
    } catch (e) {/**/}
  }

  // Medicine API
  void removeMedicineFromCollection() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/medicine/favorites/delete?medicineId=${widget.id}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          addedCollection = false;
        });
      } else {/**/}
    } catch (e) {/**/}
  }

  @override
  void initState() {
    super.initState();
    fetchNShowMedicineInfo();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (widget.title == "返回查询页面") {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Medicine()))
              .then((value) {
            widget.updateHistory();
          });
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Collection(
                        selectedButton: [true, false, false, false],
                      ))).then((value) {
            widget.updateHistory();
          });
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,

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
                if (widget.title == "返回查询页面") {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Medicine()))
                      .then((value) {
                    widget.updateHistory();
                  });
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Collection(
                                selectedButton: [true, false, false, false],
                              ))).then((value) {
                    widget.updateHistory();
                  });
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
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: screenWidth * 0.8,
                child: Center(
                    child: Text(
                  medicineInfo["name"] ?? "",
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ),
              const SizedBox(height: 10),
              IconButton(
                  onPressed: () {
                    if (!addedCollection) {
                      addMedicineToCollection();
                    } else {
                      removeMedicineFromCollection();
                    }
                  },
                  icon: addedCollection ? MyIcons().starr() : MyIcons().star()),
              const SizedBox(height: 20),
              Container(
                height: screenHeight * 0.7,
                width: screenWidth,
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 图片
                    medicineInfo["image"] != null
                        ? CachedNetworkImage(
                            imageUrl: medicineInfo["image"],
                            height: 150,
                          )
                        : Container(),
                    const SizedBox(height: 30),
                    // 药品名称
                    medicineInfo["name"] != null
                        ? MedicineContent(
                            title: "药品名称", content: medicineInfo["name"])
                        : Container(),
                    // 主要成分
                    medicineInfo["component"] != null
                        ? MedicineContent(
                            title: "主要成分", content: medicineInfo["component"])
                        : Container(),
                    // 用法用量
                    medicineInfo["usage"] != null
                        ? MedicineContent(
                            title: "用法用量", content: medicineInfo["usage"])
                        : Container(),
                    // 注意事项
                    medicineInfo["caution"] != null
                        ? MedicineContent(
                            title: "注意事项", content: medicineInfo["caution"])
                        : Container(),
                    // 不良反应
                    medicineInfo["sideEffect"] != null
                        ? MedicineContent(
                            title: "不良反应", content: medicineInfo["sideEffect"])
                        : Container(),
                    // 相互作用
                    medicineInfo["interaction"] != null
                        ? MedicineContent(
                            title: "相互作用", content: medicineInfo["interaction"])
                        : Container(),
                    // 有效期
                    medicineInfo["expiry"] != null
                        ? MedicineContent(
                            title: "有效期", content: medicineInfo["expiry"])
                        : Container(),
                    // 贮存条件
                    medicineInfo["condition"] != null
                        ? MedicineContent(
                            title: "贮存条件", content: medicineInfo["condition"])
                        : Container()
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          )),
        ),
      ),
    );
  }
}

class MedicineContent extends StatelessWidget {
  final String title;
  final String content;
  const MedicineContent(
      {super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 2, color: Colors.black26),
      ],
    );
  }
}
