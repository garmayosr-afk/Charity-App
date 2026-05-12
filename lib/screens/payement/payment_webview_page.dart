import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/background.dart'; 
import 'payment_webview_screen.dart'; // Make sure this path is correct!

// ─── Konnect Config ───────────────────────────────────────────────
const String kKonnectApiKey = '69f7ad792fd977d0330e30d8:Ss9zKFeq6qiW92ehuoFIgmX4X';
const String kKonnectWallet = '69f7ad792fd977d0330e30de';
const String kKonnectBaseUrl = 'https://api.preprod.konnect.network/api/v2';

// ─── Initiate Payment Function (Fixed "undefined" error) ──────────
Future<Map<String, String>> getPaymentUrl(double amountInTND) async { 
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

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
      'amount': (amountInTND * 1000).toInt(),
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

// ─── Payment Page UI ──────────────────────────────────────────────
class PaymentPage extends StatefulWidget {
  final String paymentMethod;
  final double amount;
  final String? orphanageId; 
  final String? campaignId;

  const PaymentPage({
    super.key,
    required this.paymentMethod,
    required this.amount,
    this.orphanageId,
    this.campaignId,
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
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: result['payUrl']!,
            paymentRef: result['paymentRef']!,
            amount: widget.amount,              
            orphanageId: widget.orphanageId,    
            campaignId: widget.campaignId,      
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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

                    Text(
                      '${widget.amount.toStringAsFixed(0)} TND', 
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
                            color: Colors.orange.withValues(alpha: 0.3), // FIXED DEPRECATION WARNING
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