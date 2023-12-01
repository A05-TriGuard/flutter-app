import 'package:flutter/material.dart';

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
  const CommentDialog({super.key, required this.height, required this.width});

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  bool canComment = false;
  bool showTextField = false;
  String hintText = "输入评论";
  final inputController = TextEditingController();
  var commentList = [
    CommentInfo(
        comment: "评论加好奇，这是一个很长很长的评论哈哈哈哈应该够长了吗",
        username: "这个是第一个用户名",
        profilepic:
            "https://media.nbclosangeles.com/2021/07/106882821-1620931316186-gettyimages-1232614603-DISNEYLAND_REOPENING.jpeg?quality=85&strip=all&crop=0px%2C4px%2C4000px%2C2250px&resize=1200%2C675",
        hasQuote: false,
        quoteComment: "",
        quoteUsername: "",
        commentTime: "2023-12-01   11:01"),
    CommentInfo(
        comment: "一些评论加回应。。。",
        username: "用户名2",
        profilepic:
            "https://media.nbclosangeles.com/2021/07/106882821-1620931316186-gettyimages-1232614603-DISNEYLAND_REOPENING.jpeg?quality=85&strip=all&crop=0px%2C4px%2C4000px%2C2250px&resize=1200%2C675",
        hasQuote: true,
        quoteComment: "评论加好奇，这是一个很长很长的评论哈哈哈哈应该够长了吗",
        quoteUsername: "这个是第一个用户名",
        commentTime: "2023-12-01   13:21"),
  ];
  var commentTileList = [];

  void createCommentTileList(double width) {
    var commentWidth = width * 0.64;
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
                              hintText = "回复${commentList[i].username}：";
                              showTextField = true;
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
                    backgroundImage: NetworkImage(commentList[i].profilepic),
                  ),
                ),
                // 评论主体
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 评论用户名
                    Text(
                      commentList[i].username,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    // 评论内容
                    SizedBox(
                      width: commentWidth,
                      child: Text(
                        commentList[i].comment,
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
                      commentList[i].commentTime,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    // 引用的评论
                    Visibility(
                      visible: commentList[i].hasQuote,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 3,
                          ),
                          Container(
                            width: commentWidth,
                            padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(3)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  commentList[i].quoteUsername,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Container(
                                  child: Text(
                                    commentList[i].quoteComment,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
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
              mainAxisSize: MainAxisSize.min,
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
                        style: const TextStyle(height: 1.5, fontSize: 20),
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
                                setState(() {
                                  showTextField = false;
                                  inputController.clear();
                                  canComment = false;
                                });
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
