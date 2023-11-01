import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_display.dart';

import "package:share_your_q/pages/display_page.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//google_admob
//TODO ビルドリリースの時のみ
import 'package:google_mobile_ads/google_mobile_ads.dart';
import "package:share_your_q/admob/ad_helper.dart";
import "package:share_your_q/admob/ad_mob.dart";


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
  final AdMob _adMob = AdMob();

  @override
  void initState() {
    super.initState();
    fetchData();
    //TODO ビルドリリースの時のみ
    _adMob.load();
  }

  @override
  void dispose() {
    super.dispose();
    //TODO ビルドリリースの時のみ
    _adMob.dispose();
  }

  Future<void> fetchData() async {
    try {
      //items: <String>['新着', '未発掘', 'いいね順', "ランダム"]

      /*

      response = await supabase
            .from("image_data")
            .select<List<Map<String, dynamic>>>()
            .like("subject", widget.subject as String)
            .like("level", widget.level as String)
            .eq("watched", 0)
            .order('created_at');
       */

      final List<Map<String, dynamic>> response;

      //Conditional Chaining
      //https://supabase.com/docs/reference/dart/using-filters
      var query = supabase.from("image_data").select<List<Map<String, dynamic>>>();
      if(widget.level != "全て" && widget.level != null) query = query.eq("level", widget.level as String);
      if(widget.subject != "全て" && widget.subject != null) query = query.eq("subject", widget.subject as String);
      if(widget.method == "未発掘") query = query.eq("watched", 0);
      if(widget.searchUserId != "" && widget.searchUserId != null) query = query.eq("user_id", widget.searchUserId as String);

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
          width: SizeConfig.blockSizeHorizontal! * 90,
          //height: SizeConfig.blockSizeVertical! * 90,
          
          child: Column(
            children: [

              if(imageData.isEmpty && !isLoading)
                const Center(child: Text("データがありません。"))
              else 
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ListView.builder(
                          itemCount: imageData.length,
                          itemBuilder: (context, index) {

                            if(index%6 == 0){
                              return Container(
                                height: 64,
                                width: double.infinity,
                                color: Colors.white,
                                //TODO ビルドリリースの時のみ
                                child: _adMob.getAdBanner(),
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

  @override
  Widget build(BuildContext context) {
    final String imageUrlCX =
        '${item["user_id"]}XCommentXnum${item["num"].toString()}XPnum${item["P_I_count"].toString()}XCnum${item["C_I_count"].toString()}';
    final String imageUrlPX =
        '${item["user_id"]}XproblemXnum${item["num"].toString()}XPnum${item["P_I_count"].toString()}XCnum${item["C_I_count"].toString()}';
    
    final String deliveryURL = dotenv.get('CLOUDFLARE_DELIVERY_URL');
    final String imageUrlC = '$deliveryURL/$imageUrlCX/public';
    final String imageUrlP = '$deliveryURL/$imageUrlPX/public';

    final String imageUrlEx = "${deliveryURL}/728235a5-f792-4f3e-e4f8-b67ec469d500/public";

    final List<String> titleLines = item['title'].toString().split("\n");
    final List<String> explainLines = item['explain'].toString().split("\n");


    return Card(
      child: ListTile(
        dense: true,

        leading: GestureDetector(
          child: CircleAvatar(
            radius: 20, // アイコン
            backgroundImage: NetworkImage(imageUrlC), // ユーザーアイコンのURLを設定
          ),
          onTap: () {
            print("タップされました");
          }),

        title: Text(item['user_name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


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
                Text(item["likes"].toString()),
              ],
            ),

          ],
        ),
        onTap: () {

          print(item["tag1"]);
          print(item["tag2"]);
          print(item["tag3"]);
          print(item["tag4"]);
          print(item["tag5"]);
          print(item["level"]);
          print(item["subject"]);
          print(item["image_data_id"]);
          print(item["user_id"]);
          print(item["num"]);
          print(item["explain"]);

          
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
              ),

            ),


          );
        },
      ),
    );
  }
}
