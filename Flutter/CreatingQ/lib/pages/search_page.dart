import 'package:flutter/material.dart';
import 'package:share_your_q/image_operations/image_display.dart'; // ImageDisplayScreenをインポート
import "package:share_your_q/utils/various.dart";

import "package:share_your_q/pages/display_page.dart";

import "package:share_your_q/image_operations/test_override.dart";

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {


  //教科、数学など
  String? subject;
  //小学校、中学校などいつ習ったものか
  String? level;
  //タグ
  List<String> tags = [];

  //tagの入力コントローラー
  TextEditingController _tagController = TextEditingController();

  // タグの入力値
  String tagInput = '';

  // タグを追加する関数
  void addTag() {

    bool jad = false;

    if (tagInput.isNotEmpty && tags.length < 5) {

      print(tags);
      print(tagInput);

      if (!tags.contains(tagInput)) {
        print("this is a test");
        setState(() {
          tags.add(tagInput);
          tagInput = '';
          _tagController.clear(); // 入力フォームを空にする
        });

      } else {
        jad = true;
        context.showErrorSnackBar(message: '同じタグは追加できません');
      }

    } else {
      if(!jad){
        context.showErrorSnackBar(message: 'タグは5つまでしか追加できません');
      }
      
    }

    print(jad);
    print(tags);
  }

  // タグを削除する関数
  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('検索'),
      ),
      body: SingleChildScrollView(


        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                Column(

                  children: [
                    
                    // レベルとジャンルの横並び
                    DropdownButton<String>(
                      value: level,
                      onChanged: (value) {
                        setState(() {
                          level = value;
                        });
                      },
                      items: <String>['小学校', '中学校', '高校', '大学', 'その他']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: const Text('レベルを選択してください'),
                    ),

                    
                    DropdownButton<String>(
                      value: subject,
                      onChanged: (value) {
                        setState(() {
                          subject = value;
                        });
                      },
                      items: <String>['数学', '物理', '化学', 'その他']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: const Text('ジャンルを選択してください'),
                    ),


                    // タグの入力フォーム
                    TextFormField(
                      maxLength: 10,
                      controller: _tagController,
                      onChanged: (value) {
                        
                        setState(() {
                          tagInput = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '検索したいタグを入力',
                      ),
                    ),


                    ElevatedButton(
                      onPressed: addTag,
                      child: Text("タグを追加"),
                    ),

                    Wrap(
                      children: tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          onDeleted: () {
                            removeTag(tag);
                          },
                        ),
                      )
                    .toList(),
                    ),


                  ],
                ),

                formSpacer,

                Container(
                  height: SizeConfig.blockSizeVertical! * 90, // 任意の高さを設定
                  child: CustomImageListDisplay(
                    level: level,
                    subject: subject,
                    tag1: "0",
                    tag2: "0",
                    tag3: "0",
                    tag4: "0",
                    tag5: "0",
                    title: "検索結果",
                    method: "search",
                  )

                ),


            ],

          ),

          
        ),

        
      ),
    );
  }
}
