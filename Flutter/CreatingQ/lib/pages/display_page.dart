import 'dart:html';

import 'package:flutter/material.dart';
import 'package:share_your_q/image_operations/image_display.dart'; // ImageDisplayScreenが定義されたファイルをインポート
import 'package:share_your_q/utils/various.dart';
import 'package:file_picker/file_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import "package:share_your_q/image_operations/problem_view.dart";
import 'package:supabase_flutter/supabase_flutter.dart';

//google_admob
//TODO ビルドリリースの時のみ
//import "package:share_your_q/admob/ad_mob.dart";

//リストをタップした際に遷移するページ問題が見れる
//UIはわからない

//テキストを保持する
String textKeeper = "";

class DisplayPage extends StatefulWidget {

  final String title;
  
  final int? image_id;
  final String? image_own_user_id;
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

  final int? num;
  


  const DisplayPage({
    Key? key,
    required this.title,
    required this.image_id,

    required this.image_own_user_id,

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
    required this.num,

  }) : super(key: key);

  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage>{


  final userId = supabase.auth.currentUser!.id;
  bool isLiked = false;
  bool isLoading = true; // ローディング中かどうかを示すフラグ
  //TODO ビルドリリースの時のみ
  //final AdMob _adMob = AdMob();

  @override
  void initState(){

    super.initState();
    //_insertOrUpdateDataToSupabaseTable();
    _initializeData();

    //TODO ビルドリリースの時のみ
    //_adMob.load();
  }

  @override
  void dispose() {
    super.dispose();
    //TODO ビルドリリースの時のみ
    //_adMob.dispose();
  }

  Future<void> _initializeData() async {
    try {
      // 非同期処理（データの取得やAPIコールなど）を行う
      await _insertOrUpdateDataToSupabaseTable();
    } finally {
      // ローディングが終了したことを示すフラグをセットし、ウィジェットを再構築する
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _insertTestSupabase() async{
    try {
      // `user_id`と`image_id`の組み合わせで既存のレコードを検索する
      final existingRecord = await supabase
          .from('likes')
          .select<List<Map<String, dynamic>>>()
          .eq('user_id', userId)
          .eq('image_id', widget.image_id);

      // レコードが存在する場合はアップデート、存在しない場合は挿入する
      if (existingRecord.isNotEmpty) {
        // レコードが存在する場合はアップデート
        print("ここが問題手の");
        isLiked = existingRecord[0]["add"];
        print(existingRecord[0]["add"]);

        
        print("どこだよ");

        //islikedが!isliked
        final response = await supabase
            .from('likes')
            .update({ 'add': !isLiked })
            .eq("image_id", widget.image_id)
            .eq("user_id", userId);

        //isLiked = !isLiked;
        if (response != null) {
          // エラーハンドリング
          print('Error updating data: ${response}');
        } else {
          // 成功時の処理
          print('Data updated successfully!');
        }
      } else {
        print("ここが二つ目");
        print("errorが発生しています");
        // レコードが存在しない場合は挿入
        final response = await supabase
            .from('likes')
            .insert({ 
              'add': false,
              'user_id': userId,
              'problem_num' : widget.num,
              "image_id" : widget.image_id,
              "image_own_user_id" : widget.image_own_user_id,
              });

        print("here");
        print(response);

        if (response == null) {
          // エラーハンドリング
          print('Error inserting data: ${response}');
        } else {
          // 成功時の処理
          print('Data inserted successfully!');
        }
      }
    } catch (error) {
      // 例外が発生した場合のエラーハンドリング
      print('Error: $error');
    }
  }

  Future<void> _insertOrUpdateDataToSupabaseTable() async {
    try {
      // `user_id`と`image_id`の組み合わせで既存のレコードを検索する
      final existingRecord = await supabase
          .from('likes')
          .select<List<Map<String, dynamic>>>()
          .eq('user_id', userId)
          .eq('image_id', widget.image_id);

      // レコードが存在する場合はアップデート、存在しない場合は挿入する
      if (existingRecord.isNotEmpty) {
        // レコードが存在する場合はアップデート
        print("ここが問題手の");
        isLiked = existingRecord[0]["add"];
        print(existingRecord[0]["add"]);

        print("ここが一つ目");
        final response = await supabase
            .from('likes')
            .update({ 'add': isLiked })
            .eq('user_id', userId)
            .eq('image_id', widget.image_id);

        if (response != null) {
          // エラーハンドリング
          print('Error updating data: ${response}');
        } else {
          // 成功時の処理
          print('Data updated successfully!');
        }
      } else {
        print("ここが二つ目");
        // レコードが存在しない場合は挿入
        final response = await supabase
            .from('likes')
            .insert({
              'user_id': userId,
              "image_own_user_id": widget.image_own_user_id,
              "add": false,
              "problem_num": widget.num,
              "image_id": widget.image_id,
              // 他のカラムの挿入もここで行う
            });

        
        print("here");
        print(response);

        if (response == null) {
          // エラーハンドリング
          print('Error inserting data: ${response}');
        } else {
          // 成功時の処理
          print('Data inserted successfully!');
        }
      }
    } catch (error) {
      // 例外が発生した場合のエラーハンドリング
      print('Error: $error');
    }
  }

  void _showCommentSheet(BuildContext context, int imageId) {
    showModalBottomSheet(
      context: context,
      //これがないと高さが変わらない
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: SizeConfig.blockSizeVertical! * 60,
          child: CommentListDisplay(image_id: imageId),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context){

     return Scaffold(
      appBar: AppBar(
        title: const Text('画像一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.green,),
            tooltip: "コメント",
            onPressed: (){
              _showCommentSheet(context, widget.image_id!);
            },
          ),

          SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),

          //ここで問題の評価を見る
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.blue,),
            tooltip: "評価",
            onPressed: (){
              _showCommentSheet(context, widget.image_id!);
            },
          ),

          SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),

          //ここで問題の評価を行う
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white,),
            tooltip: "評価する",
            onPressed: (){
              _showCommentSheet(context, widget.image_id!);
            },
          ),

          SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),

          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border_outlined,
              color: isLiked ? Colors.red : Colors.white,
            ),
            
            tooltip: "いいね",
            onPressed: () async{
              
              await _insertTestSupabase();

              setState(() {            
                isLiked = !isLiked;
              });
            },
          ),

          SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),


        ],
      ),

      body: SingleChildScrollView(
        
        child: Column(
          children: [
            Container(
              
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),

              alignment: Alignment.center,
              height: SizeConfig.blockSizeVertical! * 75,
      
              child: ListView(
                children: [
                  ProblemViewWidget(
                    title: widget.title,
      
                    tag1: widget.tag1,
                    tag2: widget.tag2,
                    tag3: widget.tag3,
                    tag4: widget.tag4,
                    tag5: widget.tag5,
      
                    //tags: tags,
                    level: widget.level,
                    subject: widget.subject,
                    image1: null,
                    image2: null,
                    imageUrlP: widget.imageUrlP,
                    imageUrlC: widget.imageUrlC,
      
                    explanation: widget.explanation,

                    isCreate: false,
                    image_id: widget.image_id,
      
                  ),

                  /*
                  
                  SizedBox(height: SizeConfig.blockSizeVertical! * 10,),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    height: SizeConfig.blockSizeVertical! * 60,

                    child: Column(
                      children: [
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
                      ],
                    ),
                    
                  ),
                   */

                ],
              )
      
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 2,),

            Container(
              height: SizeConfig.blockSizeVertical! * 10,
              width: double.infinity,
              color: Colors.white,
              //TODO ビルドリリースの時のみ
              //child: _adMob.getAdBanner(),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 2,),

          ],
        ),

        


      ),

      



     );


  }
}




class CommentListDisplay extends StatefulWidget{
  
    //final String? comment;
    //final String? created_at;
    final int? image_id;
  
    const CommentListDisplay({
      Key? key,
     //required this.comment,
      //required this.created_at,
      required this.image_id,
    }) : super(key: key);
  
    @override
    _CommentListDisplayState createState() => _CommentListDisplayState();
}

class _CommentListDisplayState extends State<CommentListDisplay>{

  late List<Map<String, dynamic>> _commentList = [];

  late final TextEditingController _textController = TextEditingController();

  /*
  Future<void> fetchData() async{

    _commentList = await supabase
          .from('comments')
          .select<List<Map<String, dynamic>>>()
          .eq('image_id', widget.image_id)
          .order("created_at");

    print(_commentList);
  }
   */

  Future<List<Map<String, dynamic>>> fetchData() async {
  // 非同期処理を行う（例: データの取得）
  List<Map<String, dynamic>> data = await supabase
          .from('comments')
          .select<List<Map<String, dynamic>>>()
          .eq('image_id', widget.image_id)
          .order("created_at");
  return data; // 結果をFutureで包んで返す
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

    fetchData().then((data) {
      setState(() {
        _commentList = data;
      });
    });

    //context.showSuccessSnackBar(message: "コメントを送信しました。コメントを見たい場合にはリロードしてください");
    
  }

  @override
  void initState(){
    super.initState();
    //これで非同期的
    fetchData().then((data) {
      setState(() {
        _commentList = data;
      });
    });

  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    _textController.text = textKeeper;

    //コメント一覧を表示する
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),

      //height: SizeConfig.blockSizeVertical! * 80,
      width: SizeConfig.blockSizeHorizontal! * 95,

      child: Column(
        children: [

          Container(
            child: Row(
              children: [
                const Expanded(
                  child: Center(
                    child: Opacity(
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

                    fetchData().then((data) {
                      setState(() {
                        _commentList = data;
                      });
                    });

                  },
                  //reload
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _commentList.length,
              itemBuilder: (BuildContext context, int index){
                return ChatBubble(commentData: _commentList[index]);
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

                      onChanged: (text) {
                        textKeeper = text;
                      },

                    ),
                  ),

                  TextButton(
                    //onPressed: () => _submitMessage(),
                    onPressed: () {
                      _submitMessage();
                    },
                    child: const Text('送信'),
                  ),
                ],
              ),
            )
          ),

        ],
      ),


    );
  }

}


