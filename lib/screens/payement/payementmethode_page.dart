import 'package:flutter/material.dart';
import '../../widgets/background.dart';
import '../../widgets/card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'payment_webview_page.dart';



class PayementMethodPage extends StatefulWidget {
  final int amount;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String paymentId;
  final String? orphanageId;

  const PayementMethodPage({
    super.key,
    required this.amount,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.paymentId,
    this.orphanageId,
  });

  @override
  State<PayementMethodPage> createState() => _PayementMethodPageState();
}

class _PayementMethodPageState extends State<PayementMethodPage> {
  bool _isLoading = false;

  Future<String> getPaymentUrl(int amount, String email, String firstName, String lastName, String phoneNumber) async {
    final response = await http.post(
      Uri.parse('https://api.konnect.network/api/v2/payments/init-payment'),
      headers: {
        'x-api-key': '69f7ad792fd977d0330e30d8:Ss9zKFeq6qiW92ehuoFIgmX4X',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'receiverWalletId': '69f7ad792fd977d0330e30de',
        'token': 'TND',
        'amount': amount * 1000,           // convert to millimes
        'type': 'immediate',
        'description': 'Donation - SOS Children\'s Village',
        'acceptedPaymentMethods': ['wallet', 'bank_card', 'e-DINAR'],
        'lifespan': 10,                     // payment link valid for 10 minutes
        'checkoutForm': false,              // we already collected user info
        'addPaymentFeesToAmount': false,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'email': email,
        'orderId': widget.paymentId,
        'successUrl': 'https://charity-app-21dee.web.app/payment-success',
        'failUrl': 'https://charity-app-21dee.web.app/payment-fail',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['payUrl'];               // open this in WebView
    } else {
      throw Exception('Payment failed: ${response.body}');
    }
  }

  void _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url = await getPaymentUrl(
        widget.amount,
        widget.email,
        widget.firstName,
        widget.lastName,
        widget.phoneNumber,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebViewPage(
            paymentUrl: url,
            paymentId: widget.paymentId,
            amount: widget.amount,
            orphanageId: widget.orphanageId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Method"),
        centerTitle: true,
      ),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    RoleCard(
                      description: "Pay with a postal card",
                      title: 'Postal Card',
                      icon: Icons.card_giftcard,
                      color: Colors.green,
                      buttonText: "Continue",
                      onPressed: _processPayment,
                    ),
                    const SizedBox(height: 20),
                    RoleCard(
                      description: "Pay with a bank card",
                      title: "Bank Card",
                      icon: Icons.wallet,
                      color: Colors.lightGreen,
                      buttonText: "continue",
                      onPressed: _processPayment,
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
