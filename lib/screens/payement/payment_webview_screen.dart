import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../services/konnect_services.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String paymentRef;
  
  // 📍 THESE ARE THE MISSING VARIABLES FIXING YOUR RED ERRORS
  final double amount; 
  final String? orphanageId;
  final String? campaignId;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.paymentRef,
    required this.amount, 
    this.orphanageId,
    this.campaignId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isSavingToDatabase = false; 

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
      setState(() => _isSavingToDatabase = true); 
      
      try {
        final status = await KonnectService.getPaymentStatus(widget.paymentRef);
        final paymentStatus = status['payment']['status'];

        if (!mounted) return;

        if (paymentStatus == 'completed') {
          
          final user = FirebaseAuth.instance.currentUser;
          final donorId = user?.uid;

          await FirebaseFirestore.instance.collection('donations').add({
            'amount': widget.amount,
            'date': FieldValue.serverTimestamp(),
            'donor_id': donorId,
            'orphanage_id': widget.orphanageId,
            'campaign_id': widget.campaignId, 
          });

          if (widget.orphanageId != null && donorId != null) {
            await FirebaseFirestore.instance
                .collection('orphanages')
                .doc(widget.orphanageId)
                .update({
              'unique_donors': FieldValue.arrayUnion([donorId])
            });
          }

          Navigator.pushReplacementNamed(context, '/payment-success');
        } else {
          Navigator.pushReplacementNamed(context, '/payment-fail');
        }
      } catch (e) {
        debugPrint('Error verifying or saving payment: $e');
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/payment-fail');
      } finally {
        if (mounted) setState(() => _isSavingToDatabase = false);
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
          
          if (_isSavingToDatabase)
            Container(
              // FIX FOR DEPRECATED WITHOPACITY WARNING:
              color: Colors.white.withValues(alpha: 0.9), 
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Verifying and saving donation...",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}