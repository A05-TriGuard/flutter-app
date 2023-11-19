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