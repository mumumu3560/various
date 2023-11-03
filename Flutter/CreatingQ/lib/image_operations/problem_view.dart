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

  final bool isCreate;

  final int? image_id;

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
    required this.image_id,
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

  late List<Map<String, dynamic>> commentList = [];

  late final TextEditingController _textController = TextEditingController();

  Future<void> fetchData() async{

    commentList = await supabase
          .from('comments')
          .select<List<Map<String, dynamic>>>()
          .eq('image_id', widget.image_id)
          .order("created_at");

    print(commentList);
  }

  @override
  void initState() {

    if(!widget.isCreate) fetchData();

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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// メッセージを送信する
  void _submitMessage() async {
    final comment = _textController.text;
    if (comment.isEmpty) {
      context.showErrorSnackBar(message: "コメントが入力されていません。");
      return;
    }
    _textController.clear();
    try {
      await supabase.from('comments').insert({
        "user_id": myUserId,
        'comments': comment,
        "image_id": widget.image_id,
      });


    } on PostgrestException catch (error) {
      // エラーが発生した場合はエラーメッセージを表示
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      // 予期せぬエラーが起きた際は予期せぬエラー用のメッセージを表示
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }

    context.showSuccessSnackBar(message: "コメントを送信しました。コメントを見たい場合にはリロードしてください");
    
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
              "${widget.title}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
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

                SizedBox(height: 5,),
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

                SizedBox(height: 5,),

                Text("ジャンル: ${widget.subject}"),

                SizedBox(height: 5,),

                Text(
                "説明:\n${widget.explanation}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          SizedBox(height: 10,),

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
                        //ここでもし画像が存在しない場合の処理を考える
                        
                      : widget.imageUrlP != null
                          ? Image.network(
                              widget.imageUrlP!,
                              fit: BoxFit.contain,
                            )
                          //TODO No imageの画像を表示する  
                          : null,
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
                  //width: SizeConfig.safeBlockHorizontal! * 80,
                  //height: SizeConfig.safeBlockVertical! * 80,
                  child: widget.image2 != null
                      ? Image.memory(
                          widget.image2!.bytes!,
                          fit: BoxFit.contain,
                        )
                        //ここでもし画像が存在しない場合を考える。
                      : widget.imageUrlC != null
                          ? Image.network(
                              widget.imageUrlC!,
                              fit: BoxFit.contain,
                            )
                            //TODO No imageの画像を表示する
                          : null,
                ),
              ),


          SizedBox(height: SizeConfig.blockSizeVertical! * 10,),

          //コメント一覧を表示する
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: const Opacity(
                            opacity: 0.5,
                            child: Text(
                                      "コメント一覧",
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,fontStyle: FontStyle.italic)
                                    ),
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: (){
                          setState(() {
                            if(widget.isCreate){
                              context.showErrorSnackBar(message: "リロードは問題を作成してから");
                            }
                            else{
                              setState(() {
                                fetchData();
                              });
                            }
                          });
                        },
                        icon: const Icon(Icons.refresh),
                      )
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: commentList.length,
                    itemBuilder: (BuildContext context, int index){
                      return ChatBubble(commentData: commentList[index]);
                    },

                  )
                ),

                Material(
                  color: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 3, // 複数行入力可能にする
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintText: 'メッセージを入力',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(8),
                            ),

                          ),
                        ),

                        TextButton(
                          //onPressed: () => _submitMessage(),
                          onPressed: () {
                            if(widget.isCreate){
                              context.showErrorSnackBar(message: "問題を作成してからコメントを送信してください。");
                            }
                            else{
                              _submitMessage();
                            }
                          },
                          child: const Text('送信'),
                        ),
                      ],
                    ),
                  )
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


