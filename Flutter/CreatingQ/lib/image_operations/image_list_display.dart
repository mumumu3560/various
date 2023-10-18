import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_display.dart';

import "package:share_your_q/pages/display_page.dart";

class ImageListDisplay extends StatefulWidget {
  @override
  _ImageListDisplayState createState() => _ImageListDisplayState();
}
class _ImageListDisplayState extends State<ImageListDisplay> {
  List<Map<String, dynamic>> imageData = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  bool isLoading = true;
  int maxPage = 1;

  @override
  void initState() {
    super.initState();
    fetchData(currentPage);
  }

  Future<void> fetchData(int page) async {
    try {
      final response = await supabase
          .from("image_data")
          .select<List<Map<String, dynamic>>>()
          .order('created_at');

      setState(() {
        maxPage = (response.length / itemsPerPage).ceil();
        isLoading = false;
        imageData = response;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  //TODO これは使うかがわからない。今のところlistをスクロールするので完了しているため
  void loadNextPage() {
    currentPage++;
    fetchData(currentPage);
  }

  //TODO これは使うかがわからない。今のところlistをスクロールするので完了しているため
  void loadPreviousPage() {
    if (currentPage > 1) {
      currentPage--;
      fetchData(currentPage);
    }
  }

  // リストをリロードするメソッド
  void reloadList() {
    setState(() {
      isLoading = true;
    });
    fetchData(currentPage); // リロード時にデータを再取得
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('新着'), // アプリバーに表示するタイトル
        actions: [
          IconButton(
            onPressed: reloadList,
            icon: Icon(Icons.refresh), // リロードアイコン
          ),
        ],
      ),
      body: Container(
        width: SizeConfig.blockSizeHorizontal! * 98,
        //height: SizeConfig.blockSizeVertical! * 90,
        
        child: Column(
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: imageData.length,
                      itemBuilder: (context, index) {
                        final item = imageData[index];
                        return MyListItem(item: item);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}


class MyListItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const MyListItem({

    Key? key,
    required this.item
    
  }): super(key: key);

  @override
  Widget build(BuildContext context) {

    //imageUrlC_pre、imageUrlCを分けたのは長すぎるから
    final String imageUrlC_pre =
              '${item["user_id"]}XCommentXnum${item["num"].toString()}XPnum${item["P_I_count"].toString()}XCnum${item["C_I_count"].toString()}';
    final String imageUrlP_pre =
              '${item["user_id"]}XproblemXnum${item["num"].toString()}XPnum${item["P_I_count"].toString()}XCnum${item["C_I_count"].toString()}';

          final String imageUrlC = '<解説の画像のURL>';
          final String imageUrlP = '<問題の画像のURL>';

          final String imageUrlEx = "<画像が読み込まれなかった場合>";
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
            Text(item['title']),
            Text(item['level']),
            Text(item['subject']),
            Row(
              children: [

                if (item['tag1'] != null) Text("#" + item['tag1'] ),
                if (item['tag2'] != null) Text("#" +item['tag2']),
                if (item['tag3'] != null) Text("#" +item['tag3']),
                if (item['tag4'] != null) Text("#" +item['tag4']),
                if (item['tag5'] != null) Text("#" +item['tag5']),                
            
            ]),

            if (item['explain'] != null) Text(item['explain'])
            else Text("説明文なし"),


          ],
        ),
        onTap: () {
          
          Navigator.of(context).push(

            /*
            MaterialPageRoute(
              builder: (context) => ImageDisplayScreen(
                imageUrl: imageUrl,
              ),
            ),
            */

            /*
            
             */
            MaterialPageRoute(
              builder: (context) => DisplayPage(
                title: item['title'],

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

                explanation: item['explain'],
              ),

              /*
              
              builder: (context) => ProblemViewWidget(
                title: item['title']!,

                tag1: item['tag1']!,
                tag2: item['tag2']!,
                tag3: item['tag3']!,
                tag4: item['tag4']!,
                tag5: item['tag5']!,

                //tags: item['tags'],
                level: item['level']!,
                subject: item['subject']!,
                image1: null,
                image2: null,
                imageUrlP: imageUrlP,
                imageUrlC: imageUrlC,
              ),
               */
            ),


          );
        },
      ),
    );
  }
}
