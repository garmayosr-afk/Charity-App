import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/konnect_services.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String paymentRef;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.paymentRef,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            // Detect success or fail redirect
            if (request.url.contains('success')) {
              _verifyAndNavigate(success: true);
              return NavigationDecision.prevent;
            } else if (request.url.contains('fail')) {
              _verifyAndNavigate(success: false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _verifyAndNavigate({required bool success}) async {
    if (success) {
      // Double-check with the API
      try {
        final status = await KonnectService.getPaymentStatus(widget.paymentRef);
        final paymentStatus = status['payment']['status'];

        if (!mounted) return;

        if (paymentStatus == 'completed') {
          Navigator.pushReplacementNamed(context, '/payment-success');
        } else {
          Navigator.pushReplacementNamed(context, '/payment-fail');
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/payment-fail');
      }
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/payment-fail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
