import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_display.dart';

import "package:share_your_q/pages/display_page.dart";

import "package:share_your_q/models/radar_chart_test1.dart";

//TODO ここにプロフィールページを作成する
//グラフなどで自分の問題の傾向を見れるようにする

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
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

  void loadNextPage() {
    currentPage++;
    fetchData(currentPage);
  }

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
        title: const Text("プロフィール"),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 25),

          child: Container(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeVertical! * 80,

            child: SingleChildScrollView(

              child: Column(
                children: [

                  Container(
                    width: SizeConfig.blockSizeHorizontal! * 80,
                    height: SizeConfig.blockSizeVertical! * 80,
                    child: RadarChartSample(),
                  ),

                  SizedBox(height: 50,),

                  Container(
                    width: SizeConfig.blockSizeHorizontal! * 80,
                    height: SizeConfig.blockSizeVertical! * 80,
                    child: RadarChartSample(),
                  ),

                ]
              )
              
            )
          ),
        )
      ),

    );


  }
}



