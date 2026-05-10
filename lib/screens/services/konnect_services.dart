import 'dart:convert';

import 'package:http/http.dart' as http;

const String kKonnectApiKey =
    '69f7ad792fd977d0330e30d8:Ss9zKFeq6qiW92ehuoFIgmX4X';
const String kKonnectBaseUrl = 'https://api.preprod.konnect.network/api/v2';

class KonnectService {
  const KonnectService._();

  static Future<Map<String, dynamic>> getPaymentStatus(
    String paymentRef,
  ) async {
    final response = await http.get(
      Uri.parse('$kKonnectBaseUrl/payments/$paymentRef'),
      headers: {'x-api-key': kKonnectApiKey},
    );

    if (response.statusCode != 200) {
      throw Exception('Konnect error: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
