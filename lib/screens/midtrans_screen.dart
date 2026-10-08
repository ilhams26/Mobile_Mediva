import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransPaymentScreen extends StatefulWidget {
  final String snapToken;
  final String orderCode;

  const MidtransPaymentScreen({
    super.key,
    required this.snapToken,
    required this.orderCode,
  });

  @override
  State<MidtransPaymentScreen> createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final String midtransUrl =
        'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Deteksi callback Midtrans
            if (request.url.contains('kelompok9.my.id') ||
                request.url.contains('ngrok') ||
                request.url.contains('finish') ||
                request.url.contains('10.0.2.2') ||
                request.url.contains('103.174.237.194')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(midtransUrl));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pembayaran ${widget.orderCode}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
             Center(child: CircularProgressIndicator(color: colorScheme.primary)),
        ],
      ),
    );
  }
}
