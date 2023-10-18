import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart'; // 追加

Future<void> uploadImage(String uploadUrl, PlatformFile file) async {
  try {
    //final Uint8List imageBytes = await file.bytes!; // PlatformFileをUint8Listに変換
    final Uint8List imageBytes = file.bytes!; // PlatformFileをUint8Listに変換

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: file.name,
          contentType: MediaType('image', file.extension!.substring(1)),
        ),
      );

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      // アップロードが成功した場合
      print("画像アップロード成功");
    } else {
      // アップロードエラーの場合の処理
      print("画像アップロードエラー: ${response.statusCode}");
      print("エラーレスポンス: ${response.body}");
    }
  } catch (e) {
    // ネットワークエラーの場合の処理
    print("ネットワークエラー: $e");
  }
}
