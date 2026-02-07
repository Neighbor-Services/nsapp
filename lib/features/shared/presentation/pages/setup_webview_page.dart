import 'package:flutter/material.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
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
      )
      ..loadRequest(Uri.parse(SuccessConnectAccountState.accountLink!.url));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
