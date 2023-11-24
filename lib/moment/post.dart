import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Post extends StatefulWidget {
  final double width;
  const Post({super.key, required this.width});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  String selectedClass = "高血脂";
  String selectedCategory = "饮食";
  bool canPost = false;
  final inputController = TextEditingController();
  File imageToShow = File("");
  bool showPic = false;
  var selectedImages = [];
  var imageList = <Widget>[];

  void createImageList() {
    imageList.clear();
    for (int i = 0; i < selectedImages.length; ++i) {
      imageList.add(SizedBox(
        width: 150,
        height: 150,
        child: Image.file(
          selectedImages[i],
          fit: BoxFit.cover,
        ),
      ));
      imageList.add(const SizedBox(width: 10));
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

    return SizedBox(
      width: widget.width,
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
                  onPressed: canPost ? () {} : null,
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
          // 分类 & 照片添加栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // 主题分类
                  Container(
                    color: Colors.black12,
                    height: 30,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 10),
                    child: DropdownButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 30,
                      hint: Text(selectedClass,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black)),
                      items: const [
                        DropdownMenuItem(
                            value: "高血脂",
                            child: Text(
                              "高血脂",
                              style: TextStyle(fontSize: 18),
                            )),
                        DropdownMenuItem(
                            value: "高血压",
                            child: Text(
                              "高血压",
                              style: TextStyle(fontSize: 18),
                            )),
                        DropdownMenuItem(
                            value: "高血糖",
                            child: Text(
                              "高血糖",
                              style: TextStyle(fontSize: 18),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedClass = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 话题分类
                  Container(
                    color: Colors.black12,
                    height: 30,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 10),
                    child: DropdownButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 30,
                      hint: Text(selectedCategory,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black)),
                      items: const [
                        DropdownMenuItem(
                            value: "饮食",
                            child: Text(
                              "饮食",
                              style: TextStyle(fontSize: 18),
                            )),
                        DropdownMenuItem(
                            value: "运动",
                            child: Text(
                              "运动",
                              style: TextStyle(fontSize: 18),
                            )),
                        DropdownMenuItem(
                            value: "生活",
                            child: Text(
                              "生活",
                              style: TextStyle(fontSize: 18),
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
                  )
                ],
              ),
              // 图片、视频添加按钮
              IconButton(
                onPressed: () async {
                  final image = await ImagePicker().pickMultiImage();
                  List<XFile> xFilePick = image;
                  if (xFilePick.isNotEmpty) {
                    for (var i = 0; i < xFilePick.length; i++) {
                      selectedImages.add(File(xFilePick[i].path));
                    }
                    setState(() {
                      showPic = true;
                    });
                  }
                },
                icon: const Icon(
                  Icons.image_outlined,
                  color: Colors.blue,
                  size: 25,
                ),
              ),
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
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: imageList,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ))
        ],
      ),
    );
  }
}
