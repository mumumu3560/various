import 'package:flutter/material.dart';
import 'package:share_your_q/image_operations/image_list_display.dart';

import "package:share_your_q/utils/various.dart";

//TODO ここでImageListDisplayを継承して、ImageListDisplayのfetchDataをオーバーライドする
//StatefulWidgetやStateは継承したことがないので確認する

class CustomImageListDisplay extends ImageListDisplay {

  final String? level;
  final String? subject;
  final String? tag1;
  final String? tag2;
  final String? tag3;
  final String? tag4;
  final String? tag5;
  
  //titleとmethodは親クラスのImageListDisplayのものなので required thisのthisはいらない
  const CustomImageListDisplay({
    Key? key,
    required title,
    required method,
    required this.level,
    required this.subject,
    required this.tag1,
    required this.tag2,
    required this.tag3,
    required this.tag4,
    required this.tag5,
  }) : super(key: key, title: title, method: method);

  @override
  _CustomImageListDisplayState createState() => _CustomImageListDisplayState();
}

class _CustomImageListDisplayState extends ImageListDisplayState {
  @override
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

}
