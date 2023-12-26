// 获取格式化后的日期 2023-8-1 => 2023-08-01
String getFormattedDate(DateTime date) {
  /* String formattedDate = "${date.year}-";
  if (date.month < 10) {
    formattedDate += "0";
  }
  formattedDate += "${date.month}-";
  if (date.day < 10) {
    formattedDate += "0";
  }
  formattedDate += "${date.day}";

  return formattedDate; */

  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

String getFormattedTime(DateTime time) {
  return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
}

String getStartDate(DateTime endDate, String selectedDays) {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  if (selectedDays == "最近3天") {
    startDate = endDate.subtract(const Duration(days: 3));
  } else if (selectedDays == "最近7天") {
    startDate = endDate.subtract(const Duration(days: 7));
  } else if (selectedDays == "最近1个月") {
    startDate = endDate.subtract(const Duration(days: 30));
  } else if (selectedDays == "最近3个月") {
    startDate = endDate.subtract(const Duration(days: 90));
  } else if (selectedDays == "当前的天") {
    startDate = endDate;
  } else if (selectedDays == "当前的月") {
    startDate = DateTime(endDate.year, endDate.month, 1);
    // endDate为当前月份的最后一天
    //endDate = DateTime(endDate.year, endDate.month + 1, 0);
  } else {
    startDate = endDate.subtract(const Duration(days: 7));
  }
  //print(
  //    "起始日期：$startDate， 结束日期：${date} ++++++++++++++++++++++++++++++++++");

  return getFormattedDate(startDate);
}
