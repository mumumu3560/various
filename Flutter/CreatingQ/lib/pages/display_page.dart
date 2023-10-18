import 'package:flutter/material.dart';
import 'package:share_your_q/image_operations/image_display.dart'; // ImageDisplayScreenが定義されたファイルをインポート
import 'package:share_your_q/utils/various.dart';
import 'package:file_picker/file_picker.dart';


//リストをタップした際に遷移するページ問題が見れる
//UIはわからない

class DisplayPage extends StatefulWidget {

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

  const DisplayPage({
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
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage>{

  final userId = supabase.auth.currentUser!.id;
  
  @override
  Widget build(BuildContext context){

    print(widget.title);
    print(widget.tag1);
    print(widget.tag2);
    print(widget.tag3);
    print(widget.tag4);
    print(widget.tag5);
    print(widget.level);
    print(widget.subject);
    print(widget.imageUrlP);
    print(widget.imageUrlC);


     return Scaffold(
      appBar: AppBar(
        title: const Text('画像一覧'),
      ),

      body: Container(
        alignment: Alignment.center,

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
     );
  }
}
