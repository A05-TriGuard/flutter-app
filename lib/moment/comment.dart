import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';

class CommentInfo {
  final String username;
  final String profilepic;
  final String comment;
  final String commentTime;
  final bool hasQuote;
  final String quoteUsername;
  final String quoteComment;
  CommentInfo(
      {required this.username,
      required this.profilepic,
      required this.comment,
      required this.commentTime,
      required this.hasQuote,
      required this.quoteUsername,
      required this.quoteComment});
}

class CommentDialog extends StatefulWidget {
  final double height;
  final double width;
  final int postId;
  const CommentDialog(
      {super.key,
      required this.height,
      required this.width,
      required this.postId});

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  bool canComment = false;
  bool showTextField = false;
  bool hasQuote = false;
  int curQuoteCommentId = -1;
  String hintText = "输入评论";
  final inputController = TextEditingController();
  var commentList = [];
  var commentTileList = [];

  // Moment API
  void fetchNShowCommentList() async {
    commentList.clear();

    var token = await storage.read(key: 'token');

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.get(
          'http://43.138.75.58:8080/api/moment/comment/list?momentId=${widget.postId}',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          commentList = response.data["data"];
        });
      }
    } catch (e) {/**/}
  }

  // Moment API
  void postComment() async {
    var token = await storage.read(key: 'token');

    try {
      final dio = Dio(); // Create Dio instance
      final headers = {
        'Authorization': 'Bearer $token',
      };
      FormData formData = FormData.fromMap(hasQuote
          ? {
              'momentId': widget.postId,
              'content': inputController.value.text,
              'quoteCommentId': curQuoteCommentId
            }
          : {'momentId': widget.postId, 'content': inputController.value.text});
      final response = await dio.post(
          'http://43.138.75.58:8080/api/moment/comment',
          data: formData,
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        setState(() {
          showTextField = false;
          canComment = false;
          hasQuote = false;
          inputController.clear();
        });
        fetchNShowCommentList();
      }
    } catch (e) {/**/}
  }

  void createCommentTileList(double width) {
    commentTileList.clear();

    for (int i = 0; i < commentList.length; ++i) {
      commentTileList.add(Column(
        children: [
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      children: [
                        SimpleDialogOption(
                          child: const Text("回复评论"),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              hintText = "回复${commentList[i]["username"]}：";
                              showTextField = true;
                              hasQuote = true;
                              curQuoteCommentId = commentList[i]["id"];
                            });
                          },
                        )
                      ],
                    );
                  });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 用户头像
                CircleAvatar(
                  radius: 21,
                  backgroundColor: Colors.black45,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: commentList[i]["profile"] != null
                        ? CachedNetworkImageProvider(
                            "http://43.138.75.58:8080/static/${commentList[i]["profile"]}")
                        : const CachedNetworkImageProvider(
                            "https://static.vecteezy.com/system/resources/previews/020/765/399/non_2x/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg"),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                // 评论主体
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 评论用户名
                        Text(
                          commentList[i]["username"],
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        // 评论
                        SizedBox(
                          child: Text(
                            commentList[i]["content"],
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        // 评论日期、时间
                        Text(
                          commentList[i]["createTime"],
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        // 引用的评论
                        Visibility(
                          visible: commentList[i]["quoteCommentId"] != null,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 3,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                    decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 引用评论用户名
                                        Text(
                                          commentList[i]
                                                  ["quoteCommentUsername"] ??
                                              "",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        // 引用评论内容
                                        Text(
                                          commentList[i]
                                                  ["quoteCommentContent"] ??
                                              "",
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 1,
            color: Colors.black26,
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNShowCommentList();
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    createCommentTileList(widget.width);

    return Scrollbar(
        thickness: 10,
        scrollbarOrientation: ScrollbarOrientation.right,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: widget.width,
            child: Column(
              //mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "评论列表",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 15),
                // 评论
                SizedBox(
                  height: widget.height,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: commentTileList.length,
                      itemBuilder: (BuildContext context, index) {
                        return commentTileList[index];
                      }),
                ),
                // 评论输入框
                Visibility(
                  visible: showTextField,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      child: TextField(
                        onChanged: (value) {
                          if (value != "") {
                            setState(() {
                              canComment = true;
                            });
                          } else {
                            setState(() {
                              canComment = false;
                            });
                          }
                        },
                        controller: inputController,
                        style: const TextStyle(
                          height: 1.5,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(hintText: hintText),
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
                // 评论按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            showTextField = true;
                          });
                        },
                        child: const Text(
                          "评论",
                          style: TextStyle(fontSize: 20),
                        )),
                    TextButton(
                        onPressed: canComment
                            ? () {
                                postComment();
                              }
                            : null,
                        child: const Text(
                          "发布评论",
                          style: TextStyle(fontSize: 20),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
