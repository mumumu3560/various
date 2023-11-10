import 'package:flutter/material.dart';
import 'package:share_your_q/pages/profile_page.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_display.dart';

import 'package:share_your_q/pages/display_page_relation/display_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:timeago/timeago.dart';

import 'package:http/http.dart' as http;

//google_admob
//TODO ビルドリリースの時のみ
//import "package:share_your_q/admob/ad_mob.dart";


class ImageListDisplay extends StatefulWidget {

  final String? subject;
  final String? level;
  final String? method;
  final List<String>? tags;
  final String? title;
  final String? searchUserId;

  const ImageListDisplay({
    Key? key,
    required this.subject,
    required this.level,
    required this.method,
    required this.tags,
    required this.title,
    required this.searchUserId,
  }) :super(key: key);

  @override
  ImageListDisplayState createState() => ImageListDisplayState();

}


class ImageListDisplayState extends State<ImageListDisplay> {
  List<Map<String, dynamic>> imageData = [];
  bool isLoading = true;
  //TODO ビルドリリースの時のみ
  //final AdMob _adMob = AdMob();

  @override
  void initState() {
    super.initState();
    fetchData();
    //TODO ビルドリリースの時のみ
    //_adMob.load();
  }

  @override
  void dispose() {
    super.dispose();
    //TODO ビルドリリースの時のみ
    //_adMob.dispose();
  }

  Future<void> fetchData() async {
    try {
      final List<Map<String, dynamic>> response;

      //Conditional Chaining
      //https://supabase.com/docs/reference/dart/using-filters
      var query = supabase.from("image_data").select<List<Map<String, dynamic>>>();
      if(widget.level != "全て" && widget.level != null) query = query.eq("level", widget.level as String);
      if(widget.subject != "全て" && widget.subject != null) query = query.eq("subject", widget.subject as String);
      if(widget.method == "未発掘") query = query.eq("watched", 0);
      if(widget.searchUserId != "" && widget.searchUserId != null) query = query.eq("user_id", widget.searchUserId as String);

      List<String> tags = [];

      for (var tag in widget.tags!) {
        if(tag == "" || tag == null) continue;
        tags.add(tag);
      }

      for (var tag in tags){
        print(tag);
      }


      //ここでtagを検索する
      for (var tag in tags) {
        if(tag == "" || tag == null) continue;

        //orはその中でどれかに当てはまればいい*はワイルドパターン%と同じ
        //https://supabase.com/docs/reference/dart/or
        //https://postgrest.org/en/stable/references/api/tables_views.html#horizontal-filtering-rows

        query = query.or(
          "tag1.like.*$tag*,"
          "tag2.like.*$tag*,"
          "tag3.like.*$tag*,"
          "tag4.like.*$tag*,"
          "tag5.like.*$tag*");
        print(tag);
        //query = query.eq("tag1", tag);
      }
      print("ここまでtag");
      //query = query.eq("tag1", tags[0]);

      if(widget.method == "新着"){
        response = await query.order("created_at", ascending: false);
      }
      else if(widget.method == "いいね順"){
        response = await query.order("likes", ascending: false);
      }
      else if(widget.method == "ランダム"){
        response = await query.order("created_at", ascending: false);
        response.shuffle();
      }
      else{
        response = await query.order("created_at", ascending: false);
      }


      setState(() {
        isLoading = false;
        imageData = response;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // リストをリロードするメソッド
  void reloadList() {
    setState(() {
      isLoading = true;
    });
    fetchData(); // リロード時にデータを再取得
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title as String), // アプリバーに表示するタイトル
        actions: [
          IconButton(
            onPressed: reloadList,
            icon: const Icon(Icons.refresh), // リロードアイコン
          ),
        ],
      ),
      body: Center(
        child: Container(
          //中央寄り
          alignment: Alignment.center,
          //width: SizeConfig.blockSizeHorizontal! * 90,
          //height: SizeConfig.blockSizeVertical! * 90,
          
          child: Column(
            children: [

              if(imageData.isEmpty && !isLoading)
                //const Padding(padding: EdgeInsets.all(8.0),),
                //const Center(child: Text("データがありません。"))
                Container(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 10),
                  child: const Text(
                    "data is empty",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                )

              else 
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ListView.builder(
                          itemCount: imageData.length,
                          itemBuilder: (context, index) {

                            //6の倍数の時には広告を表示する。
                            if(index%6 == 0){
                              final item = imageData[index];
                              return Column(
                                children: [
                                  Container(
                                    height: 64,
                                    width: double.infinity,
                                    color: Colors.white,
                                    //TODO ビルドリリースの時のみ
                                    //child: _adMob.getAdBanner(),
                                  ),

                                  
                                  MyListItem(item: item),
                                ],
                              );
                            }
                            else{
                              final item = imageData[index];
                              return MyListItem(item: item);
                            }
                            
                            
                          },
                        ),
                      ),
              
            ],
          ),
        ),
      ),
    );
  }
}

//ここはsupabaseから取得したデータの内容を表示するためのウィジェット
class MyListItem extends StatelessWidget {
  final Map<String, dynamic> item;


  const MyListItem({

    Key? key,
    required this.item,
    
  }): super(key: key);

  Future<String> loadUserImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // レスポンスステータスコードが 200 の場合、画像のデータを返す
        return imageUrl;
      } else {
        // レスポンスステータスコードが 200 以外の場合、エラーメッセージを返す
        print('Error loading image: Status Code ${response.statusCode}');
        return '';
      }
    } catch (e) {
      // ネットワークエラーが発生した場合、エラーメッセージを返す
      print('Error loading image: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {

    /*
    final String imageUrlCX =
        '${item["user_id"]}XCommentXnum${item["num"].toString()}XPnum${item["P_I_count"].toString()}XCnum${item["C_I_count"].toString()}';
    final String imageUrlPX =
        '${item["user_id"]}XproblemXnum${item["num"].toString()}XPnum${item["P_I_count"].toString()}XCnum${item["C_I_count"].toString()}';
    
     */

    final String? imageUrlPX = item["problem_id"];
    final String? imageUrlCX = item["comment_id"];

    
    final String deliveryURL = dotenv.get('CLOUDFLARE_DELIVERY_URL');
    final String imageUrlC = '$deliveryURL/$imageUrlCX/public';
    final String imageUrlP = '$deliveryURL/$imageUrlPX/public';

    final String imageUrlEx = "${deliveryURL}/728235a5-f792-4f3e-e4f8-b67ec469d500/public";

    final List<String> titleLines = item['title'].toString().split("\n");
    final List<String> explainLines = item['explain'].toString().split("\n");



    return Card(
      child: ListTile(
        dense: true,

        leading: FutureBuilder(
          future: loadUserImage(imageUrlC),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // データの読み込み中はローディングインジケータなどを表示する
              return CircularProgressIndicator();
            } else if (snapshot.hasError || snapshot.data == "" || snapshot.hasError) {
              // エラーが発生した場合は代替のアイコンを表示する
              return GestureDetector(
                child: const CircleAvatar(
                  radius: 20,
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
                onTap: () {
                  print('Error occurred. Handle onTap action here.');
                  context.showErrorSnackBar(message: "プロフィールに遷移出来ません");
                  // タップした際の処理を記述する
                },
              );
            } else {
              // データが正常に読み込まれた場合に画像を表示する
              return GestureDetector(
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: Image.network(
                      snapshot.data.toString(),
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                // エラーが発生した場合の代替イメージを表示する
                return const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                );
              },
                    ),
                  ),
                ),

                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: myUserId),
                    ),
                  );
                },

              );
            }
          },
        ),

        title: Text(item['user_name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //Supabaseのtimestamptz型をDateTime型に変換して表示
            Text(format(DateTime.parse(item["created_at"]), locale: 'ja')),

            item["title"] != null
              ? titleLines.length > 3
                ?Text(
                  titleLines[0] + "\n" + titleLines[1] + "\n" + titleLines[2] + "\n" + "……",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )
                )
                :Text(
                  "[${item['title']}]",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ), 
                )
              : const Text("タイトルなし"),
            

            item["explain"] != null 
              ? explainLines.length > 3
                ? Text(
                  explainLines[0] + "\n" + explainLines[1] + "\n" + explainLines[2] + "\n" + "……",
                  style: const TextStyle(
                    fontSize: 16,
                  )
                )
                : Text(
                  item["explain"],
                  style: const TextStyle(
                    fontSize: 16,
                  )
                )
              
              : const Text("説明文なし"),
            

            item["level"] != null
              ? Text(
                  item['level'],
                )
              : const Text("レベルなし"),

            item["subject"] != null
              ? Text(
                  item['subject'],
                )
              : const Text("教科なし"),
              
            Row(
              children: [

                if (item['tag1'] != null) Text("#"+item['tag1']),
                if (item['tag2'] != null) Text("#"+item['tag2']),
                if (item['tag3'] != null) Text("#"+item['tag3']),
                if (item['tag4'] != null) Text("#"+item['tag4']),
                if (item['tag5'] != null) Text("#"+item['tag5']),                
            
            ]),

            Row(
              children: [
                const Icon(Icons.visibility,color: Colors.white,),
                Text(item["watched"].toString()),
                formSpacer,
                const Icon(Icons.favorite, color: Colors.white,),
                Text(item["likes"].toString()),
                formSpacer,
                const Icon(Icons.chat, color: Colors.white,),
                Text(item["comments"].toString()),
              ],
            ),

          ],
        ),
        onTap: () async{

          final response = await loadUserImage(imageUrlC);
          if(response == ""){
            context.showErrorSnackBar(message: "この問題は読み込めません");
            return;
          }
          
          Navigator.of(context).push(

            MaterialPageRoute(
              builder: (context) => DisplayPage(
                title: item['title'],

                image_id: item["image_data_id"],
                image_own_user_id: item["user_id"],
                tag1: item['tag1'],
                tag2: item['tag2'],
                tag3: item['tag3'],
                tag4: item['tag4'],
                tag5: item['tag5'],

                //tags: item['tags'],
                level: item['level']!,
                subject: item['subject']!,
                image1: null,
                image2: null,
                imageUrlP: imageUrlP,
                imageUrlC: imageUrlC,

                num: item['num'],

                explanation: item['explain'],

                problem_id: item["problem_id"],
                comment_id: item["comment_id"],
              ),

              /*
              builder: (context) => DisplayPage(
                title: item['title'],

                image_id: item["image_data_id"],
                image_own_user_id: item["user_id"],
                tag1: item['tag1'],
                tag2: item['tag2'],
                tag3: item['tag3'],
                tag4: item['tag4'],
                tag5: item['tag5'],

                //tags: item['tags'],
                level: item['level']!,
                subject: item['subject']!,
                image1: null,
                image2: null,
                imageUrlP: imageUrlP,
                imageUrlC: imageUrlC,

                num: item['num'],

                explanation: item['explain'],
              ),
               */

            ),


          );
        },
      ),
    );
  }
}
