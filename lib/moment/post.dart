import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';
import 'dart:io';

class Post extends StatefulWidget {
  final double width;
  final String curClass;
  final String curCategory;
  final String curFilter;
  final Function(List) updatePostList;
  //final Function(bool) setChange;
  const Post({
    super.key,
    required this.width,
    required this.curClass,
    required this.curCategory,
    required this.curFilter,
    required this.updatePostList,
    //required this.setChange,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  String selectedClass = "高血脂";
  String selectedCategory = "饮食";
  bool canPost = false;
  final inputController = TextEditingController();
  File? videoPreview;
  bool showPic = false;
  bool showVid = false;
  var selectedImages = [];
  var imagePreviewList = <Widget>[];
  var updatedPostList = [];
  bool isLoading = false;
  var imagePathList = [];

  // Moment API
  void postStory() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> map = {};
      map['class'] = selectedClass;
      map['category'] = selectedCategory;
      map['content'] = inputController.value.text;
      if (showVid) {
        map['video'] = await MultipartFile.fromFile(videoPreview!.path);
      }
      if (showPic) {
        var tmpImageList = [];
        for (int i = 0; i < imagePathList.length; ++i) {
          tmpImageList.add(await MultipartFile.fromFile(imagePathList[i]));
        }
        map['images'] = tmpImageList;
      }
      FormData formData = FormData.fromMap(map);
      /*
      FormData formData = FormData.fromMap({
        'class': selectedClass,
        'category': selectedCategory,
        'content': inputController.value.text
      });
      if (showVid) {
        formData.files.add(MapEntry(
            'video', await MultipartFile.fromFile(videoPreview!.path)));
      }*/
      final response = await dio.post(
        'http://43.138.75.58:8080/api/moment/create',
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (count, total) {
          print("当前进度 $count, 总进度 $total");
        },
      );

      if (response.statusCode == 200) {
        //inputController.clear();
        //fetchNShowPostList();
        delayPop();
      }
    } catch (e) {/**/}
  }

  void delayPop() {
    fetchNShowPostList();
    //widget.setChange(true);

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pop(context);
      inputController.clear();
      isLoading = false;
    });
  }

  // Moment API
  void fetchNShowPostList() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/moment/list?class=${widget.curClass}&category=${widget.curCategory}&filter=${widget.curFilter}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        updatedPostList = response.data["data"];
        widget.updatePostList(updatedPostList);
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print('Request failed: $e');
    }
  }

  void createImageList() {
    imagePreviewList.clear();
    for (int i = 0; i < selectedImages.length; ++i) {
      imagePreviewList.add(SizedBox(
        width: 150,
        height: 150,
        child: Image.file(
          selectedImages[i],
          fit: BoxFit.cover,
        ),
      ));
      imagePreviewList.add(const SizedBox(width: 10));
    }
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createImageList();

    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
            visible: isLoading, child: const CircularProgressIndicator()),
        SingleChildScrollView(
          child: SizedBox(
            //width: widget.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 功能键
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "取消",
                          style: TextStyle(fontSize: 18),
                        )),
                    TextButton(
                        onPressed: canPost
                            ? () {
                                postStory();
                                // Navigator.pop(context);
                                // widget.updatePostList(updatedPostList);
                              }
                            : null,
                        child: const Text(
                          "发布",
                          style: TextStyle(fontSize: 18),
                        ))
                  ],
                ),
                // 文本输入
                SingleChildScrollView(
                  child: SizedBox(
                    height: 150,
                    child: TextField(
                      onChanged: (value) {
                        if (value != "") {
                          setState(() {
                            canPost = true;
                          });
                        } else {
                          setState(() {
                            canPost = false;
                          });
                        }
                      },
                      controller: inputController,
                      style: const TextStyle(height: 1.5, fontSize: 20),
                      decoration: const InputDecoration(hintText: "输入发帖内容"),
                      maxLines: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // 分类
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 主题分类
                    Expanded(
                        child: Container(
                      color: Colors.black12,
                      height: 30,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 10),
                      child: DropdownButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 30,
                        hint: Text(
                          selectedClass,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: "高血脂",
                              child: Text(
                                "高血脂",
                                style: TextStyle(fontSize: 16),
                              )),
                          DropdownMenuItem(
                              value: "高血压",
                              child: Text(
                                "高血压",
                                style: TextStyle(fontSize: 16),
                              )),
                          DropdownMenuItem(
                              value: "高血糖",
                              child: Text(
                                "高血糖",
                                style: TextStyle(fontSize: 16),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value!;
                          });
                        },
                      ),
                    )),
                    const SizedBox(width: 10),
                    // 话题分类
                    Expanded(
                        child: Container(
                      color: Colors.black12,
                      height: 30,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 10),
                      child: DropdownButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 30,
                        hint: Text(selectedCategory,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black)),
                        items: const [
                          DropdownMenuItem(
                              value: "饮食",
                              child: Text(
                                "饮食",
                                style: TextStyle(fontSize: 16),
                              )),
                          DropdownMenuItem(
                              value: "运动",
                              child: Text(
                                "运动",
                                style: TextStyle(fontSize: 16),
                              )),
                          DropdownMenuItem(
                              value: "生活",
                              child: Text(
                                "生活",
                                style: TextStyle(fontSize: 16),
                              )),
                          DropdownMenuItem(
                              value: "其他",
                              child: Text(
                                "其他",
                                style: TextStyle(fontSize: 18),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    ))
                  ],
                ),
                const SizedBox(height: 15),
                // 照片添加栏
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 图片添加按钮
                    IconButton(
                      onPressed: showVid
                          ? null
                          : () async {
                              final image =
                                  await ImagePicker().pickMultiImage();
                              List<XFile> xFilePick = image;
                              if (xFilePick.isNotEmpty) {
                                for (var i = 0; i < xFilePick.length; i++) {
                                  selectedImages.add(File(xFilePick[i].path));
                                  imagePathList.add(xFilePick[i].path);
                                }
                                setState(() {
                                  showPic = true;
                                });
                              }
                            },
                      icon: Icon(
                        Icons.image_outlined,
                        color: showVid ? Colors.grey : Colors.blue,
                        size: 30,
                      ),
                    ),
                    // 视频添加按钮
                    IconButton(
                      onPressed: showPic
                          ? null
                          : () async {
                              final video = await ImagePicker()
                                  .pickVideo(source: ImageSource.gallery);
                              XFile? xFilePick = video;
                              if (xFilePick != null) {
                                videoPreview = File(xFilePick.path);

                                setState(() {
                                  showVid = true;
                                });
                              }
                            },
                      icon: Icon(
                        Icons.video_file_outlined,
                        color: showPic ? Colors.grey : Colors.blue,
                        size: 30,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                // 显示图片
                Visibility(
                  visible: showPic,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: imagePreviewList),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
                // 显示视频
                Visibility(
                  visible: showVid,
                  child: Column(
                    children: [
                      Text(
                        videoPreview != null ? videoPreview!.path : "",
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
