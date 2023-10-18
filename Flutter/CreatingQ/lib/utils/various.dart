import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

//https://zenn.dev/dshukertjr/books/flutter-supabase-chat/viewer/page1

final supabase = Supabase.instance.client;

//プリローダー
const preloader = Center(child: CircularProgressIndicator(color: Colors.orange));

const formSpacer = SizedBox(width: 16, height: 16);

//フォームのパディング
const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

//予期せぬエラーが起きた際のエラーメッセージ
const unexpectedErrorMessage = '予期せぬエラーが起きました';


extension ShowSnackBar on BuildContext {
  /// 標準的なSnackbarを表示
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.black,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  /// エラーが起きた際のSnackbarを表示
  void showErrorSnackBar({required String message}) {
    showSnackBar(
      message: message,
      backgroundColor: Theme.of(this).colorScheme.error,
    );
  }

  /// 成功した際のSnackbarを表示
  void showSuccessSnackBar({required String message}) {
    showSnackBar(
      message: message,
      backgroundColor: Theme.of(this).colorScheme.secondary,
    );
  }
}


//ユーザーの問題を表示するヴィジェット
class ProblemViewWidget extends StatefulWidget {
  final String title;
  //final List<String> tags;
  //tagは最大5つまでそれぞれをカンマで区切って表示する
  final String? tag1;
  final String? tag2;
  final String? tag3;
  final String? tag4;
  final String? tag5;

  final String level;
  final String subject;

  final PlatformFile? image1;
  final PlatformFile? image2;
  final String? imageUrlP;
  final String? imageUrlC;

  final String? explanation;

  const ProblemViewWidget({
    Key? key,
    required this.title,

    //required this.tags,
    required this.tag1,
    required this.tag2,
    required this.tag3,
    required this.tag4,
    required this.tag5,

    required this.level,
    required this.subject,
    required this.image1,
    required this.image2,
    required this.imageUrlP,
    required this.imageUrlC,

    required this.explanation,
  }) : super(key: key);

  @override
  _ProblemViewWidgetState createState() => _ProblemViewWidgetState();
}

class _ProblemViewWidgetState extends State<ProblemViewWidget> {
  bool showProblemImage = false;
  bool showExplanationImage = false;

  @override
  Widget build(BuildContext context) {
    
    SizeConfig().init(context);

    return SingleChildScrollView(

      child: Column(

        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,

        children: <Widget>[

          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            //decoration: BoxDecoration(border: Border.all(), ),
            child: Text(
              "タイトル: ${widget.title}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          Container(
            //alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft, 
            //decoration: BoxDecoration(border: Border.all(), color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("レベル: ${widget.level}"),
                // tagは最大5つまでそれぞれをカンマで区切って表示する

                //タグを横並びにする
                
                Row(

                  children: [
                    if (widget.tag1 != null) Text("タグ: #${widget.tag1}"),
                    if (widget.tag2 != null) Text("#${widget.tag2}"),
                    if (widget.tag3 != null) Text("#${widget.tag3}"),
                    if (widget.tag4 != null) Text("#${widget.tag4}"),
                    if (widget.tag5 != null) Text("#${widget.tag5}"),
                  ],
                ),

                Text("ジャンル: ${widget.subject}"),

                Text("説明: ${widget.explanation}" ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              setState(() {
                showProblemImage = !showProblemImage;
              });
            },
            child: Text("問題を表示する"),
          ),

          SizedBox(height: 10,),

          

          if (showProblemImage && (widget.image1 != null || widget.imageUrlP != null))
            Container(
              width: SizeConfig.blockSizeHorizontal! * 90,
              height: SizeConfig.blockSizeVertical! * 90,
              
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(8.0),
              //decoration: BoxDecoration(border: Border.all(), color: Colors.black),
              child: SizedBox(
                //width: SizeConfig.safeBlockHorizontal! * 80,
                //height: SizeConfig.safeBlockVertical! * 30,

                child: widget.image1 != null
                    ? Image.memory(
                        widget.image1!.bytes!,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        widget.imageUrlP!,
                        fit: BoxFit.contain,
                      ),
              ),

            ),

          ElevatedButton(
            onPressed: () {
              setState(() {
                showExplanationImage = !showExplanationImage;
              });
            },
            child: Text("解説を表示する"),
          ),
          
          if (showExplanationImage && (widget.image2 != null || widget.imageUrlC != null))
            Container(
              width: SizeConfig.blockSizeHorizontal! * 90,
              height: SizeConfig.blockSizeVertical! * 90,

              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(8.0),
              //decoration: BoxDecoration(border: Border.all(), color: Colors.black),
              child: SizedBox(
                width: SizeConfig.safeBlockHorizontal! * 80,
                height: SizeConfig.safeBlockVertical! * 80,
                child: widget.image2 != null
                    ? Image.memory(
                        widget.image2!.bytes!,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        widget.imageUrlC!,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}




//https://qiita.com/kokogento/items/87aaf0a0fbc192e51504

//ここは機種に依らないサイズを決めるclass
class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth! / 100;
    blockSizeVertical = screenHeight! / 100;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;

    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
        
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal!) / 100;
    safeBlockVertical = (screenHeight! - _safeAreaVertical!) / 100;
  }
}
