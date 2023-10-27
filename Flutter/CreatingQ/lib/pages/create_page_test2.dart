import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'package:share_your_q/cloudflare_relations/server_request.dart';
import 'package:share_your_q/image_operations/image_select.dart';
import 'package:share_your_q/image_operations/image_upload.dart';
import 'package:share_your_q/utils/various.dart';


//問題を作るページ

//TODO textformfieldの長さの制限を考える。
//Supabaseではtext型だがこれはvarchar(10)になおす。
//textは最大で2GBまで入るので問題がある(flutterのtextformfieldの制限変えられる)

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {

  //現在作っている問題が何問目か(制限を考える)
  int problemNum = 1;

  //問題文の画像と解説の画像の数を表す。
  int problemIcount = 1;
  int commentIcount = 1;


  final userId = supabase.auth.currentUser!.id;

  //cloudflare imagesのURLにつかうcustomId
  String? customId1;
  String? customId2;

  //PlatformFileはwebでもandroidでも使える。
  PlatformFile? selectedImage1;
  PlatformFile? selectedImage2;

  //supabaseに送るもの。
  String? problemTitle = '';
  TextEditingController _titleController = TextEditingController();
  //教科、数学など
  String? subject;
  //小学校、中学校などいつ習ったものか
  String? level;
  //タグ
  List<String> tags = [];

  //tagの入力コントローラー
  TextEditingController _tagController = TextEditingController();

  //説明文の入力コントローラー
  TextEditingController _explainController = TextEditingController();

  String? explainText = '';


  // タグの入力値
  String tagInput = '';

  //cloudflare imagesのURLにつかうdirectUploadUrl
  String? directUploadUrl1;
  String? directUploadUrl2;

  // 確認画面を表示するかどうか
  bool isConfirmationMode = false;

  String? userName = "";

  // サーバーレスポンスからcustomIdとdirectUploadUrlを受け取る関数
  void onServerResponseReceived(String customId, String directUploadUrl, bool isProblem) {
    setState(() {
      if (isProblem) {
        customId1 = customId;
        directUploadUrl1 = directUploadUrl;
      } else {
        customId2 = customId;
        directUploadUrl2 = directUploadUrl;
      }
    });
  }

  // 選択した画像をアップロードする関数
  void uploadSelectedImage(PlatformFile? selectedImage, String customId, String? directUploadUrl) {
    if (selectedImage != null && directUploadUrl != null) {
      print("ここはどうですか？");
      final uploadUrl = directUploadUrl;
      uploadImage(uploadUrl, selectedImage);
    }
  }

  //ここにproblemNumを決める関数を書く。
  //supabaseからuser_idをもとに、その人が今までどれだけの問題を投稿しているかを取得する。
  //その数をproblemNumに代入する。
  //supabaseに問題を投稿するときに、numにproblemNumを代入する。
  //TODOこれ必要かわからない
  Future<void> fetchProblemNum() async{
    print(userId);
    final response = await supabase.from("profiles").select().eq("id", userId);
    print(response);
    problemNum = response[0]["problem_num"];
    problemNum++;
    userName = response[0]["username"];
  }

  // Supabaseに情報を送信する関数（未実装）
  Future<void> sendInfoToSupabase() async {
    // TODO: Supabaseに情報を送信するロジックを実装

    
    try{
      //ここでは、問題の情報をsupabaseに送る。
      //P_I_CountとC_I_Countは、問題文の画像と解説の画像の数を表す。今は1にしておく。
      await supabase.from("image_data").insert({
        "num": problemNum,
        "title": problemTitle,
        "subject": subject,
        "PorC": 1,
        "level": level,
        //"tags": tags,
        "tag1": tags.length > 0 ? tags[0] : null,
        "tag2": tags.length > 1 ? tags[1] : null,
        "tag3": tags.length > 2 ? tags[2] : null,
        "tag4": tags.length > 3 ? tags[3] : null,
        "tag5": tags.length > 4 ? tags[4] : null,
        "user_id": userId,
        "P_I_count": 1,
        "C_I_count": 1,
        "user_name" : userName,
        "explain": explainText,
      });

      //ここでは、ユーザーの問題の投稿数を増やす。
      await supabase.from("profiles").update({
        "problem_num": problemNum,
      }).eq("id", userId);


    } on PostgrestException catch (error){
      context.showErrorSnackBar(message: error.message);
    } catch(_){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }



  }

  // クラウドフレアのImageサービスからアップロード用のURLを取得する関数
  Future<void> getImageUploadUrls() async {

    //TODO今は1つの問題につき2つの画像をアップロードするようにしているが、
    //これからは問題、解答複数枚に対応するようにする。

    //送る情報は、画像の名前(これはcloudflareの方)
    //problemNumは、それが何回目に作られた問題化を示す。(一意)
    //userId+"?"+"problemORComment"+problemNum.toString()+"?"+"number"
    // 1つ目の画像用のリクエスト
    //09004426-6a8d-4633-9cda-fae9bd2ee46cXcommentX4X1Xaxbcd12333333
    //09004426-6a8d-4633-9cda-fae9bd2ee46c?Comment?num=10?Pnum=1?Cnum=1

    print("ここは？");
    final response1 = await ImageSelectionAndRequest(
      knownUserInfo: '${userId}XproblemXnum${problemNum.toString()}XPnum${problemIcount.toString()}XCnum${commentIcount.toString()}',
      //knownUserInfo: userId+"?"+"problem"+"?"+problemNum.toString()+"?"+problemIcount.toString(),
      onServerResponseReceived: (customId, directUploadUrl) {
        onServerResponseReceived(customId, directUploadUrl, true);
      },
    ).sendRequest();

    print("レスポンス確認");

    //TODO: responseがエラーを起こした場合の処理を書く

    // customId1, customId2, directUploadUrl1, directUploadUrl2 を使用して画像をアップロード
    print("ここが問題1");
    uploadSelectedImage(selectedImage1, customId1!, directUploadUrl1);
    print("ここが問題2");
    // 2つ目の画像用のリクエスト

    //09004426-6a8d-4633-9cda-fae9bd2ee46cXCommentXnum=6XPnum=1XCnum=1
    //URLエンコードでは?が%3Fになるので違う文字を使う
    final response2 = await ImageSelectionAndRequest(
      knownUserInfo: '${userId}XCommentXnum${problemNum.toString()}XPnum${problemIcount.toString()}XCnum${commentIcount.toString()}',
      //knownUserInfo: '${userId}XcommentX${problemNum.toString()}X${commentIcount.toString()}X',
      //knownUserInfo: userId+"?"+"Comment"+"?"+problemNum.toString()+commentIcount.toString(),
      onServerResponseReceived: (customId, directUploadUrl) {
        onServerResponseReceived(customId, directUploadUrl, false);
      },
    ).sendRequest();

    // customId1, customId2, directUploadUrl1, directUploadUrl2 を使用して画像をアップロード
    uploadSelectedImage(selectedImage2, customId2!, directUploadUrl2);

    print("できたかどうかの確認");

  }


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

    //SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('作成ページ'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!isConfirmationMode)
                Column(

                  children: [
                    // タイトルの入力フォーム
                    TextFormField(
                      maxLength: 30,
                      initialValue: problemTitle,
                      onChanged: (value) {
                        setState(() {
                          problemTitle = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '問題のタイトル',
                      ),
                    ),

                    
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
                        labelText: 'タグを入力',
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

                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 90,
                      child: TextFormField(
                        //大きさを変えたい
                        
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        maxLength: 100,
                        controller: _explainController,
                        onChanged: (value) {
                          setState(() {
                            explainText = value;
                          });
                        },
                    
                        decoration: const InputDecoration(
                          labelText: '簡単な説明',
                        ),
                    
                      ),
                    ),



                    SizedBox(height: SizeConfig.blockSizeVertical! * 20),
                    
                    // 画像1の選択ウィジェット
                    Column(
                      children: [
                        if (selectedImage1 == null)
                          Column(
                            children: [
                              const Text(
                                "問題文の画像を選択してください",
                                style: TextStyle(color: Colors.red),
                              ),
                              ImageSelectionWidget(
                                onImageSelected: (image) {
                                  setState(() {
                                    selectedImage1 = image;
                                  });
                                },
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Image.memory(
                                selectedImage1!.bytes!,
                                height: 150,
                              ),
                              SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImage1 = null;
                                  });
                                },
                                child: const Text(
                                  "画像を削除",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    
                    SizedBox(height: SizeConfig.blockSizeVertical! * 20), // 適宜間隔を設定
                    
                    // 画像2の選択ウィジェット
                    Column(
                      children: [
                        if (selectedImage2 == null)
                          Column(
                            children: [
                              const Text(
                                "解説の画像を選択してください",
                                style: TextStyle(color: Colors.red),
                              ),
                              ImageSelectionWidget(
                                onImageSelected: (image) {
                                  setState(() {
                                    selectedImage2 = image;
                                  });
                                },
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Image.memory(
                                selectedImage2!.bytes!,
                                height: 150,
                              ),
                              SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImage2 = null;
                                  });
                                },
                                child: const Text(
                                  "画像を削除",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    SizedBox(height: SizeConfig.blockSizeVertical! * 20),

                    ElevatedButton(
                      onPressed: () async{
                        print("now");
                        await fetchProblemNum();
                        print("isOK");

                        if (selectedImage1 == null ||
                            selectedImage2 == null ||
                            problemTitle == null ||
                            subject == null ||
                            level == null ||
                            tags.isEmpty) {
                          // エラーがある場合の処理
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('全ての情報を入力してください。'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          //print(selectedImage1!.bytes!);
                          //fetchProblemNum();
                          setState(() {
                            
                            isConfirmationMode = true;
                          });
                        }
                      },
                      child: Text("問題を投稿"),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              if (isConfirmationMode)
                buildConfirmationView(),

            ],
          ),
        ),
      ),
    );
  }

  // 問題投稿の確認画面を表示する関数
  Widget buildConfirmationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /*       
        */
        ProblemViewWidget(
          title: problemTitle!,

          tag1: tags.length > 0 ? tags[0] : null,
          tag2: tags.length > 1 ? tags[1] : null,
          tag3: tags.length > 2 ? tags[2] : null,
          tag4: tags.length > 3 ? tags[3] : null,
          tag5: tags.length > 4 ? tags[4] : null,

          //tags: tags,
          level: level!,
          subject: subject!,
          image1: selectedImage1,
          image2: selectedImage2,
          imageUrlP: null,
          imageUrlC: null,

          explanation: explainText!,
        ),

        /*
        Text("タイトル: $problemTitle"),
        Text("タグ: ${tags.join(', ')}"),
        Text("レベル: $level"),
        Text("ジャンル: $subject"),
        Image.memory(
          selectedImage1!.bytes!,
          height: 150,
        ),
        Image.memory(
          selectedImage2!.bytes!,
          height: 150,
        ),
        */

        


        ElevatedButton(
          onPressed: () async {

            showLoadingDialog(context,"処理中...");
            
            await sendInfoToSupabase();

            // 画像をアップロード
            await getImageUploadUrls();

            // ダイアログを閉じる
            Navigator.of(context).pop();

            showFinisheDialog(context, "Great!", "投稿が完了しました！！");

            setState(() {
              isConfirmationMode = false;
            });
          },
          child: const Text("確認して投稿"),
        ),

        ElevatedButton(
          onPressed: () {
            setState(() {
              isConfirmationMode = false;
            });
          },
          child: const Text("編集"),
        ),
      ],
    );
  }
}
