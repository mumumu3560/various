import 'package:flutter/material.dart';
import 'package:share_your_q/image_operations/image_display.dart'; // ImageDisplayScreenが定義されたファイルをインポート
import 'package:share_your_q/utils/various.dart';
import 'package:file_picker/file_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

//リストをタップした際に遷移するページ問題が見れる
//UIはわからない

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

  @override
  void initState(){

    super.initState();
    //_insertOrUpdateDataToSupabaseTable();
    _initializeData();
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


  @override
  Widget build(BuildContext context){

     return Scaffold(
      appBar: AppBar(
        title: const Text('画像一覧'),
      ),

      body: SingleChildScrollView(
        
        child: Container(
          alignment: Alignment.center,
          height: SizeConfig.blockSizeVertical! * 90,
      
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
      
              ),
            ],
          )
      
        ),
      ),

      //ここでいいね評価を行う
      floatingActionButton: FloatingActionButton(
        onPressed: () async { 
          final String External_id = supabase.auth.currentUser!.id.toString();
          print(External_id);
          //OneSignal.login(External_id);
          //context.showSuccessSnackBar(message: supabase.auth.currentUser!.id.toString());

          await _insertTestSupabase();

          setState(() {            
            isLiked = !isLiked;
          });

          print(isLiked);
          print("isliked?");
          
        },
        //もしisLikedがtrueならばアイコンは黄色、falseならば白
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border_outlined,
          color: isLiked ? Colors.red : Colors.white,
        ),
      )



     );


  }
}
