# triguard

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


### Apache Echart配置
https://www.bilibili.com/video/BV1P64y147hr/?spm_id_from=333.337.search-card.all.click&vd_source=242881c2e0028b99f5965425eaeee832

```
dev_dependencies:
  flutter_test:
    sdk: flutter

  The "flutter_lints" package below contains a set of recommended lints to
  encourage good coding practices. The lint set provided by the package is
  activated in the `analysis_options.yaml` file located at the root of your
  package. See that file for information about deactivating specific lint
  rules and activating additional ones.
  flutter_lints: ^2.0.0
   flutter_echart: 
     git:
       url: git://github.com/furuiCQ/flutter_echart.git
  flutter_echarts: ^2.5.0
```

然后终端执行
flutter pub get

### FilledButton报错
可以参考这个https://stackoverflow.com/questions/74897399/how-to-use-a-filledbutton-in-flutter-material-3

终端执行
flutter channel master
flutter pub upgrade


### GradientBorder
"lib\other\gradientBorder\gradient_borders.dart"
https://stackoverflow.com/questions/55395641/outlined-transparent-button-with-gradient-border-in-flutter
https://github.com/obiwanzenobi/gradient-borders/tree/master/lib
https://pub.dev/packages/gradient_borders


### 更新echart
https://medium.com/analytics-vidhya/reactive-echarts-flutter-widget-fedab7f3c52f

#### 取消echart动画
https://blog.csdn.net/qq_30841657/article/details/111168671

#### 坐标轴对齐
https://blog.csdn.net/yuzhiqiang_1993/article/details/86496145

#### ExpansionTile button 
https://stackoverflow.com/questions/51697901/programmatically-expand-expansiontile-in-flutter

#### How to Create Image Buttons in Flutter
https://www.kindacode.com/article/ways-to-create-image-buttons-in-flutter/

#### AnimatedContainer切换瞬间overflow
https://stackoverflow.com/questions/56298325/overflow-warning-in-animatedcontainer-adjusting-height
解决：用SingleChildScrollView包裹

#### Pass a function with parameters to a VoidCallback
https://stackoverflow.com/questions/50085748/pass-a-function-with-parameters-to-a-voidcallback


#### string转int
https://stackoverflow.com/questions/56207275/how-can-i-get-int-data-from-texteditingcontroller-in-flutter
例如： `int.parse(hourController.text)`,

#### ios DateTime Picker
https://api.flutter.dev/flutter/cupertino/CupertinoDatePicker-class.html


#### 关于updateAcquireFence: Did not find frame.
https://github.com/flutter/flutter/issues/104268
The message updateAcquireFence: Did not find frame. isn't something to be worried about.
The Android team told us that this is likely a bug in HWUI and doesn't signal an error.

For the time being we should consider filtering this out from flutter run output since I agree it can be a lot of spam.

#### 关于logger包
https://pub.dev/packages/logger


### dropdown_button
https://pub.dev/packages/dropdown_button2

`dependencies: dropdown_button2: ^2.3.8`

`flutter pub get`

`import 'package:dropdown_button2/dropdown_button2.dart';`


### 无语的js


#### http请求dio库 
https://pub.dev/packages/dio
https://github.com/cfug/dio/blob/main/dio/README-ZH.md
`dependencies: dio: ^5.3.3`
`flutter pub get`

#### http库
https://stackoverflow.com/questions/62012502/how-to-post-x-www-form-urlencoded-in-flutter


### Flutter: Move to a new screen without providing navigate back to previous screen
https://stackoverflow.com/questions/50037710/flutter-move-to-a-new-screen-without-providing-navigate-back-to-previous-screen

### 返回的问题
https://api.flutter.dev/flutter/widgets/PopScope-class.html
https://www.flutterbeads.com/disable-override-back-button-in-flutter/

### 退出app
https://stackoverflow.com/questions/45109557/flutter-how-to-programmatically-exit-the-app

```
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
    
RaisedButton(
  onPressed: () {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  },
  child: Text("close app")
)
```

### how to assign future<> to widget in flutter?
https://stackoverflow.com/questions/49764905/how-to-assign-future-to-widget-in-flutter


### datatable how to add vertical border between columns
https://stackoverflow.com/questions/66895241/flutter-datatable-how-to-add-vertical-border-between-columns

#### date picker
https://pub.dev/packages/flutter_cupertino_date_picker_fork

#### Draggable FloatingActionButton in Flutter
https://stackoverflow.com/questions/55046638/draggable-floatingactionbutton-in-flutter

#### 限制键盘只输入数字
https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
`import 'package:flutter/services.dart';`

```new TextField(
              decoration: new InputDecoration(labelText: "Enter your number"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], // Only numbers can be entered
            ),
```


#### path_provider 安装问题
`flutter pub add path_provider`出现
```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings. Run
  start ms-settings:developers
to open settings.
```
https://stackoverflow.com/questions/68089177/flutter-building-with-plugins-requires-symlink-support


#### AndroidManifest.xml位置 与 添加权限
https://medium.com/@santokimaulik/flutter-location-permission-with-permission-handler-ad2c7564b596
https://stackoverflow.com/questions/76028672/flutter-exact-place-to-put-permissions-in-androidmanifest-files-for-flutter



#### setState() called after dispose():
https://medium.com/@nehatanwar.dev/setstate-called-after-dispose-b022d6a7a4a7
https://stackoverflow.com/questions/49340116/setstate-called-after-dispose

```
if (this.mounted) {
  setState(() {
    // Your state change code goes here
  });
}
```

#### 返回页面时刷新
https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter
```
Navigator.pushNamed(context, '/page2').then((_) {
  // This block runs when you have returned back to the 1st Page from 2nd.
  setState(() {
    // Call setState to refresh the page.
  });
});
```

### 加载动画
https://pub.dev/packages/loading_animation_widget

#### /data/user/0/com.example.triguard/app_flutter 在哪里？
https://stackoverflow.com/questions/67226539/how-do-i-access-data-user-0-folder-from-android

#### Android device files visible in Android Studio but not Windows Explorer! Wrong dir?
https://stackoverflow.com/questions/75542835/android-device-files-visible-in-android-studio-but-not-windows-explorer-wrong-d

#### excel
https://pub.dev/packages/excel

### 血糖标准

空腹

| 偏低  | 正常       | 偏高       | 异常  |
| ----- | ---------- | ---------- | ----- |
| < 3.9 | [3.9, 5.6] | [5.7, 7.0] | > 7.0 |



餐后2小时

| 偏低  | 正常       | 偏高        | 异常   |
| ----- | ---------- | ----------- | ------ |
| < 4.4 | [4.4, 7.8] | [7.8, 11.0] | > 11.0 |



---

### 血脂

https://www.huangpi.gov.cn/ztzl_33/ggwszsxxgk_mh/202103/t20210310_1645919.html

https://baike.baidu.com/item/%E8%A1%80%E8%84%82/1182207

血脂全套检测包括4个主要类别（脂蛋白）：总胆固醇（TC），低密度脂蛋白胆固醇（LDL-C），高密度脂蛋白胆固醇（HDL-C），和甘油三酯（TG）

##### 总胆固醇 （TC）

https://baike.baidu.com/item/%E6%80%BB%E8%83%86%E5%9B%BA%E9%86%87/8566063?fromModule=lemma_inlink

| 偏低  | 正常       | 偏高       | 异常  |
| ----- | ---------- | ---------- | ----- |
| < 2.8 | [2.8, 5.2] | [5.2, 6.5] | > 6.5 |

##### 甘油三酯（TG）

https://baike.baidu.com/item/%E7%94%98%E6%B2%B9%E4%B8%89%E9%85%AF%E5%81%8F%E9%AB%98/1808624

| 偏低  | 正常       | 偏高        | 异常  |
| ----- | ---------- | ----------- | ----- |
| < 0.5 | [0.5, 1.7] | [1.7, 2.2 ] | > 2.2 |

##### 低密度脂蛋白胆固醇（LDL-C）

https://baike.baidu.com/item/%E4%BD%8E%E5%AF%86%E5%BA%A6%E8%84%82%E8%9B%8B%E7%99%BD%E8%83%86%E5%9B%BA%E9%86%87/4857940?fromModule=lemma_inlink

| 偏低  | 正常       | 偏高       | 异常  |
| ----- | ---------- | ---------- | ----- |
| < 2.0 | [2.0, 3.3] | [3.3, 4.1] | > 4.1 |

##### 高密度脂蛋白胆固醇（HDL-C）

https://baike.baidu.com/item/%E4%BD%8E%E5%AF%86%E5%BA%A6%E8%84%82%E8%9B%8B%E7%99%BD%E8%83%86%E5%9B%BA%E9%86%87/4857940?fromModule=lemma_inlink

| 偏低  | 正常       | 偏高       | 异常  |
| ----- | ---------- | ---------- | ----- |
| < 1.0 | [1.0, 1.5] | [1.5, 3.0] | > 3.0 |