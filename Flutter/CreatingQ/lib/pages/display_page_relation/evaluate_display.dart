import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

//ここでeval_pointやdiff_pointは状態管理でめんどいと思ったので
//riverpodで管理することにした

int eval_point = 0;
int diff_point = 0;

class EvaluateDisplay extends StatefulWidget{
  
  final int? image_id;

  const EvaluateDisplay({
    Key? key,
    required this.image_id,
  }) : super(key: key);

  @override
  _EvaluateDisplayState createState() => _EvaluateDisplayState();
}

class _EvaluateDisplayState extends State<EvaluateDisplay>{

  late List<Map<String, dynamic>> _imageData = [];

  late final TextEditingController _textController = TextEditingController();

  

  Future<List<Map<String, dynamic>>> fetchData() async {
    try{
      List<Map<String, dynamic>> data = await supabase
        .from('image_data')
        .select<List<Map<String, dynamic>>>()
        .eq('image_data_id', widget.image_id!);
      return data; 

    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
      return [];
    }
    catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      return [];
    }
  }

  void setEvalKind(int eval){
    setState(() {
      eval_point = eval;
    });
  }

  void setDiff(int diff){
    setState(() {
      diff_point = diff;
    });
  }

  void judPoints(){
    print("eval、diffの順番");
    print(eval_point);
    print(diff_point);
  }


  /// 評価の更新
  void _submitEvaluation() async {

    if (eval_point == 0 || diff_point == 0) {
      context.showErrorSnackBar(message: "評価が入力されていません。");
      return;
    }

    try {
      await supabase.from('likes')
        .update({
          "difficulty": diff_point,
          "eval": eval_point,
        })
        .eq("image_id", widget.image_id)
        .eq("user_id", myUserId);

    } on PostgrestException catch (error) {
      // エラーが発生した場合はエラーメッセージを表示
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      // 予期せぬエラーが起きた際は予期せぬエラー用のメッセージを表示
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }

    fetchData().then((data) {
      setState(() {
        _imageData = data;
      });
    });
    
  }

  @override
  void initState(){
    super.initState();
    //これで非同期的
    fetchData().then((data) {
      setState(() {
        _imageData = data;
      });
    });

  }


  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),

      //height: SizeConfig.blockSizeVertical! * 80,
      width: SizeConfig.blockSizeHorizontal! * 95,

      child: Column(
        children: [
          _ratingBar(setEvalKind, eval_point),

          Text("評価: $eval_point"),

          _ratingBar(setDiff, diff_point),

          Text("難易度: $diff_point"),

          ElevatedButton(
            onPressed: () async{
              _submitEvaluation();
              judPoints();
            },
            child: Text("ここが評価"),
          )

        ],
      ),


    );


  }

}



Widget _ratingBar(Function function, int point){
  return RatingBar.builder(

    initialRating: point as double,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: false,
    itemCount: 5,
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, _) => Icon(
      Icons.star,
      color: Colors.amber,
    ),
    onRatingUpdate: (rating) {
      function(rating);
    },
  );

}