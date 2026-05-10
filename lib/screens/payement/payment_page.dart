import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../widgets/background.dart';

// ─── Konnect Config ───────────────────────────────────────────────
const String kKonnectApiKey =
    '69f7ad792fd977d0330e30d8:Ss9zKFeq6qiW92ehuoFIgmX4X';
const String kKonnectWallet = '69f7ad792fd977d0330e30de';
const String kKonnectBaseUrl = 'https://api.preprod.konnect.network/api/v2';

// ─── Initiate Payment directly from Flutter ───────────────────────
Future<Map<String, String>> getPaymentUrl(int amountInTND) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  final name = doc.data()?['name'] ?? '';
  final email = doc.data()?['email'] ?? '';
  final phone = doc.data()?['phoneNumber'] ?? '';

  final parts = (name as String).split(' ');
  final firstName = parts.isNotEmpty ? parts[0] : '';
  final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

  final response = await http.post(
    Uri.parse('$kKonnectBaseUrl/payments/init-payment'),
    headers: {'Content-Type': 'application/json', 'x-api-key': kKonnectApiKey},
    body: jsonEncode({
      'receiverWalletId': kKonnectWallet,
      'token': 'TND',
      'amount': amountInTND * 1000, // millimes
      'type': 'immediate',
      'description': "Donation - SOS Children's Village",
      'acceptedPaymentMethods': ['wallet', 'bank_card', 'e-DINAR'],
      'lifespan': 30,
      'checkoutForm': true,
      'addPaymentFeesToAmount': false,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phone,
      'orderId': 'donation_${DateTime.now().millisecondsSinceEpoch}',
      'successUrl': 'https://yourapp.com/success',
      'failUrl': 'https://yourapp.com/fail',
      'theme': 'light',
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Konnect error: ${response.body}');
  }

  final data = jsonDecode(response.body);
  return {'payUrl': data['payUrl'], 'paymentRef': data['paymentRef']};
}

// ─── WebView Screen ───────────────────────────────────────────────
class PaymentWebViewPage extends StatefulWidget {
  final String payUrl;
  final String paymentRef;

  const PaymentWebViewPage({
    super.key,
    required this.payUrl,
    required this.paymentRef,
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
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (req) {
            if (req.url.contains('success')) {
              _onPaymentResult(success: true);
              return NavigationDecision.prevent;
            } else if (req.url.contains('fail')) {
              _onPaymentResult(success: false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.payUrl));
  }

  void _onPaymentResult({required bool success}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PaymentResultPage(success: success)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF132F4C),
        elevation: 0,
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

// ─── Result Screen ────────────────────────────────────────────────
class PaymentResultPage extends StatelessWidget {
  final bool success;
  const PaymentResultPage({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.cancel,
              color: success ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              success ? 'Payment Successful!' : 'Payment Failed',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              success
                  ? 'Thank you for your generous donation 🧡'
                  : 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: success ? Colors.green : Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment Page (your existing UI, cleaned up) ──────────────────
class PaymentPage extends StatefulWidget {
  final String paymentMethod; // "postal" or "bank"
  final int amount; // in TND

  const PaymentPage({
    super.key,
    required this.paymentMethod,
    required this.amount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;

  String get _methodTitle =>
      widget.paymentMethod == 'postal' ? 'Postal Card' : 'Bank Card';

  IconData get _methodIcon => widget.paymentMethod == 'postal'
      ? Icons.card_giftcard
      : Icons.credit_card;

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    try {
      final result = await getPaymentUrl(widget.amount);
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentWebViewPage(
            payUrl: result['payUrl']!,
            paymentRef: result['paymentRef']!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          '$_methodTitle Payment',
          style: const TextStyle(
            color: Color(0xFF132F4C),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Background(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBEADB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _methodIcon,
                            color: const Color(0xFFDF5A20),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.90,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF7A00),
                                      Color(0xFFFFB800),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Amount display
                    Text(
                      '${widget.amount} TND',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF132F4C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Donation - SOS Children\'s Village',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'You will be redirected to a secure payment page to complete your donation.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Confirm button
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFCA56A), Color(0xFFF7D57B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handlePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Proceed to Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Security note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Secured with SSL encryption',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
