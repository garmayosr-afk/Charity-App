import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String paymentId;
  final int amount;
  final String? orphanageId;

  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    required this.paymentId,
    required this.amount,
    this.orphanageId,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('charity-app-21dee.web.app/payment-success')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            } else if (request.url.contains('charity-app-21dee.web.app/payment-fail')) {
              _handlePaymentFailure();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Update the payment record status in the 'payements' collection
  Future<void> _updatePaymentStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('payements')
          .doc(widget.paymentId)
          .update({
        'status': status,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating payment status: $e');
    }
  }

  /// Save a donation record to the 'donations' collection
  Future<void> _saveDonationRecord() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('donations').add({
        'amount': widget.amount,
        'date': FieldValue.serverTimestamp(),
        'donor id': user?.uid ?? '',
        'orphanage id': widget.orphanageId ?? '',
      });
    } catch (e) {
      debugPrint('Error saving donation record: $e');
    }
  }

  /// Update the campaign's raised_amount by adding the donation amount
  Future<void> _updateCampaignProgress() async {
    if (widget.orphanageId == null || widget.orphanageId!.isEmpty) return;

    try {
      // Find campaigns linked to this orphanage that are active
      final campaignsQuery = await FirebaseFirestore.instance
          .collection('campaigns')
          .where('orphanage_id', isEqualTo: widget.orphanageId)
          .where('status', isEqualTo: 'active')
          .get();

      for (final campaignDoc in campaignsQuery.docs) {
        final currentRaised = (campaignDoc.data()['raised_amount'] ?? 0) as num;
        final newRaised = currentRaised + widget.amount;
        final goalAmount = (campaignDoc.data()['goal_amount'] ?? 0) as num;

        await campaignDoc.reference.update({
          'raised_amount': newRaised,
          // If goal is reached, mark campaign as completed
          if (goalAmount > 0 && newRaised >= goalAmount)
            'status': 'completed',
        });
      }
    } catch (e) {
      debugPrint('Error updating campaign progress: $e');
    }
  }

  void _handlePaymentSuccess() async {
    // 1. Update payment status to completed
    await _updatePaymentStatus('completed');

    // 2. Save donation record to 'donations' collection
    await _saveDonationRecord();

    // 3. Update the campaign's raised_amount
    await _updateCampaignProgress();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle,
                  color: Colors.green.shade600, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              "Payment Successful!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF132F4C),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Thank you for your generous donation.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Back to Home",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePaymentFailure() async {
    await _updatePaymentStatus('failed');

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Failed"),
        content: const Text("Your payment could not be processed. Please try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
