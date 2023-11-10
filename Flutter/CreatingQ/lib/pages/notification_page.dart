import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_display.dart';

import 'package:share_your_q/pages/display_page_relation/display_page.dart';

import "package:share_your_q/models/radar_chart_test1.dart";

//TODO ここに通知管理
//グラフなどで自分の問題の傾向を見れるようにする

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}
class _NotificationPageState extends State<NotificationPage> {



  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return DefaultTabController(
      length: 3,
      initialIndex: 0,

      child: Scaffold(
    
        appBar: AppBar(
          title: const Text('プロフィール'),

          bottom: (
    
            const TabBar(
              tabs: <Widget>[
                Tab(text: "作問傾向", icon: Icon(Icons.create)),
                Tab(text: "解答傾向", icon: Icon(Icons.star)),
                Tab(text: "貢献度", icon: Icon(Icons.workspace_premium)),
              ]
            )
        )
          
          //title: const Text("プロフィール"),
        ),
    
        body: TabBarView(
          children: <Widget>[
              
            Center(
              
              child: SingleChildScrollView(

                child: Column(
                  children: [
                    
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 90,
                      height: SizeConfig.blockSizeVertical! * 90,
                      child: RadarChartSample(),
                    ),
                    
                    SizedBox(height: 50,),
                    
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 80,
                      height: SizeConfig.blockSizeVertical! * 80,
                      child: RadarChartSample(),
                    ),
                    
                  ]
                ),
              ),
            ),
              
            Center(
              child: Text("It's rainy here"),
            ),
              
            Center(
              child: Text("It's sunny here"),
            ),
              
          ],
              
        ),
    
      ),
    );


  }
}



