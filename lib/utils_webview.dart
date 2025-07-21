import 'package:flutter/material.dart';
/*
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter_android/webview_flutter_android.dart';
*/
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'utils.dart';

InAppWebViewController? webViewController;
GlobalKey webViewKey = GlobalKey();

Widget uWebview() {
  return InAppWebView(
    key: webViewKey,
    initialFile: "assets/index.html",
    onWebViewCreated: (controller) {
      webViewController = controller;
    },
  );
}

/*
WebViewController uInitWebview() {
  var controller =
      WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);

  //var params = WebKitWebViewControllerCreationParams();

  if (controller.platform is AndroidWebViewController) {
    AndroidWebViewController.enableDebugging(true);
    (controller.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
  }

  return controller;
}

Future<void> uLoadWebview(WebViewController controller) async {
  final htmlContent = await rootBundle.loadString('assets/index.html');
  controller.loadHtmlString(htmlContent);
}

Widget uWebview(WebViewController controller) {
  return WebViewWidget(controller: controller);
}
*/
