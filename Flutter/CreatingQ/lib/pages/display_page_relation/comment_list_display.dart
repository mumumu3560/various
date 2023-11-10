import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


String textKeeper = "";
class CommentListDisplay extends StatefulWidget{
  
  final int? image_id;

  const CommentListDisplay({
    Key? key,
    required this.image_id,
  }) : super(key: key);

  @override
  _CommentListDisplayState createState() => _CommentListDisplayState();
}

class _CommentListDisplayState extends State<CommentListDisplay>{

  late List<Map<String, dynamic>> _commentList = [];

  late final TextEditingController _textController = TextEditingController();


  Future<List<Map<String, dynamic>>> fetchData() async {
    List<Map<String, dynamic>> data = await supabase
            .from('comments')
            .select<List<Map<String, dynamic>>>()
            .eq('image_id', widget.image_id)
            .order("created_at");
    return data; 
}


  /// メッセージを送信する
  void _submitMessage() async {
    final comment = _textController.text;
    textKeeper = "";
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
    textKeeper = _textController.text;
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
                      maxLines: 3, // 複数行入力可能。3行まで表示。
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



