

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;



WebViewController uInitWebview() {
  var controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

  return controller;
}

Future<void> uLoadWebview(WebViewController controller) async {

  final htmlContent = await rootBundle.loadString('assets/index.html');
  controller.loadHtmlString(htmlContent);
}

Widget uWebview(WebViewController controller) {
  return WebViewWidget(controller: controller);
}
