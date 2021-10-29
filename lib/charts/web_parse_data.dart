import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as webHtml;


/// read file data from your computer
Future<List<String>> getChannelData() async {
  Completer<List<String>> completer = Completer();
  List<String> result = [];

  webHtml.FileUploadInputElement uploadInput =
  webHtml.FileUploadInputElement()..multiple = true;
  uploadInput.click();
  uploadInput.onChange.listen((e) {
    var allFiles = uploadInput.files ?? [];
    allFiles.asMap().forEach((index, file) {
      final reader = new webHtml.FileReader();
      reader.onLoadEnd.listen((e) {
        result.addAll(reader.result.toString().split("\n"));
        if (index == allFiles.length - 1) {
          print("web onLoadEnd: $result ");
          completer.complete(result);
        }
      });
      reader.readAsText(file);
    });
  });
  return completer.future;
}