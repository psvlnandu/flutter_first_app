import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/env.dart';

class AddressService {
  static Future<String?> validateAddress({
    required String address1,
    required String city,
    required String state,
    required String zip,
  }) async {
    final url = Uri.parse(
      'https://addressvalidation.googleapis.com/v1:validateAddress?key=${Env.googleapikey}',
    );

    final response = await http.post(
      url,
      body: jsonEncode({
        "address": {
          "addressLines": [address1],
          "locality": city,
          "administrativeArea": state,
          "postalCode": zip,
          "regionCode": "US" // Change if international
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Get the 'completeAddress' formatted by Google
      return data['result']['address']['formattedAddress'];
    }
    return null;
  }
}