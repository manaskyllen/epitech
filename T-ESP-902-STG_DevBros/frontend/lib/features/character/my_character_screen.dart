import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyCharacterScreen extends StatefulWidget {
  const MyCharacterScreen({super.key});

  @override
  State<MyCharacterScreen> createState() => _MyCharacterScreenState();
}

class _MyCharacterScreenState extends State<MyCharacterScreen> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (WebResourceError error) {
                debugPrint('Web Error: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse('https://api.inspiria.cloud/character'));
  }

  @override
  Widget build(BuildContext context) {
    // Clip the WebView to only show a portion of its height.
    const double visiblePortion = 1;

    return Scaffold(
      body: SafeArea(
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: visiblePortion,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: WebViewWidget(controller: controller),
            ),
          ),
        ),
      ),
    );
  }
}
