import 'package:flutter/material.dart';

class ConfirmReportDialog extends StatelessWidget {
  const ConfirmReportDialog({super.key});

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
                      content: ReportDialog(width: screenWidth * 0.9),
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
  const ReportDialog({super.key, required this.width});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  bool canReport = false;
  final inputController = TextEditingController();

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
                  onPressed: canReport ? () {} : null,
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
