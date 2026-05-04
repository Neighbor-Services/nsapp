import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SetupWebviewPage extends StatefulWidget {
  const SetupWebviewPage({super.key});

  @override
  State<SetupWebviewPage> createState() => _SetupWebviewPageState();
}

class _SetupWebviewPageState extends State<SetupWebviewPage> {
  
  late WebViewController controller;
  
  @override
  void initState() {
    super.initState();
    // URL is passed as a route argument when navigating to this page.
    // e.g., Get.toNamed('/stripe-account', arguments: accountLink.url)
    final String? url = Get.arguments as String?;
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    
    if (url != null && url.isNotEmpty) {
      controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}


