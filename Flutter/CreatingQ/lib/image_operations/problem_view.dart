import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import "package:share_your_q/utils/various.dart";

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

  final bool? isCreate;

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

    required this.isCreate,
  }) : super(key: key);

  @override
  _ProblemViewWidgetState createState() => _ProblemViewWidgetState();
}

class _ProblemViewWidgetState extends State<ProblemViewWidget> {
  late ImageStream _imageStream1;
  late ImageStream _imageStream2;

  bool showProblemImage = false;
  bool showExplanationImage = false;

  bool isLoadingImage1 = true; // 1つ目の画像の読み込み状態を管理
  bool isLoadingImage2 = true; // 2つ目の画像の読み込み状態を管理

  @override
  void initState() {
    super.initState();

    if(widget.image1 != null || widget.image2 != null){
      isLoadingImage1 = false;
      isLoadingImage2 = false;
    }
    else{

      // 1つ目の画像の読み込み状態を監視
      _imageStream1 = Image.network(widget.imageUrlP!).image.resolve(ImageConfiguration.empty);
      _imageStream1.addListener(ImageStreamListener((info, call) {
        if (mounted) {
          setState(() {
            // 1つ目の画像が読み込まれたらisLoadingImage1をfalseに設定
            isLoadingImage1 = false;
          });
        }
      }));

      // 2つ目の画像の読み込み状態を監視
      _imageStream2 = Image.network(widget.imageUrlC!).image.resolve(ImageConfiguration.empty);
      _imageStream2.addListener(ImageStreamListener((info, call) {
        if (mounted) {
          setState(() {
            // 2つ目の画像が読み込まれたらisLoadingImage2をfalseに設定
            isLoadingImage2 = false;
          });
        }
      }));

    }
    


  }

  

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

                Text("説明:\n${widget.explanation}" ),
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
            if (isLoadingImage1)
              preloader
            else
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
            if (isLoadingImage2)
              preloader
            else
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


          SizedBox(height: SizeConfig.blockSizeVertical! * 10,),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(10),
            ),

            height: SizeConfig.blockSizeVertical! * 60,
            width: SizeConfig.blockSizeHorizontal! * 95,

            child: Column(
              children: [

                Container(
                  child: const Opacity(
                    opacity: 0.5,
                    child: Text(
                              "コメント一覧",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                            ),
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile(
                              title: Text("コメント"),
                            );
                    },

                  )
                ),

                Container(

                  child: Text("aaaa"),

                ),




              ],
            ),


          ),

          SizedBox(height: SizeConfig.blockSizeHorizontal,),




        ],
      ),
    );
  }
}