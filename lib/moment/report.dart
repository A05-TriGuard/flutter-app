import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../account/token.dart';

class ConfirmReportDialog extends StatelessWidget {
  final int postId;
  const ConfirmReportDialog({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: const Text(
        "操作提示",
        style: TextStyle(fontSize: 24),
      ),
      content: const Text(
        "确认举报该帖子？",
        style: TextStyle(fontSize: 22),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                  barrierColor: Colors.black87,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: ReportDialog(
                        width: screenWidth * 0.9,
                        postId: postId,
                      ),
                    );
                  });
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

class ReportDialog extends StatefulWidget {
  final double width;
  final int postId;
  const ReportDialog({super.key, required this.width, required this.postId});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  bool canReport = false;
  final inputController = TextEditingController();

  // Moment API
  void reportPost() async {
    var token = await storage.read(key: 'token');
    var reportReason = inputController.value.text;
    print(
        'http://43.138.75.58:8080/api/moment/report?momentId=${widget.postId}&reason=$reportReason');

    try {
      final dio = Dio();
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await dio.post(
          'http://43.138.75.58:8080/api/moment/report?momentId=${widget.postId}&reason=$reportReason',
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        //print(response.data);
        showNotice();
      }
    } catch (e) {/**/}
  }

  void showNotice() {
    Navigator.pop(context);
    var screenWidth = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
                width: screenWidth * 0.8,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black87),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "非常感谢您的反馈，我们将对您的举报加以认真的研究和处理。",
                      style: TextStyle(fontSize: 18, height: 2),
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      "assets/icons/love-letter.png",
                      height: 120,
                    )
                  ],
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(fontSize: 20),
                  )),
              TextButton(
                  onPressed: canReport
                      ? () {
                          reportPost();
                        }
                      : null,
                  child: const Text(
                    "举报",
                    style: TextStyle(fontSize: 20),
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
                      canReport = true;
                    });
                  } else {
                    setState(() {
                      canReport = false;
                    });
                  }
                },
                controller: inputController,
                style: const TextStyle(height: 1.5, fontSize: 20),
                decoration: const InputDecoration(hintText: "输入举报原因"),
                maxLines: 8,
              ),
            ),
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
