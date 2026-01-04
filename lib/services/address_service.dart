import 'dart:convert';
import 'package:flutter/cupertino.dart';
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
          "regionCode": "US", // Change if international
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Inside your Place Order logic
      final resultData = jsonDecode(response.body);
      final parsedAddress = AddressService.parseGoogleResponse(resultData);

      debugPrint('parsed_add:  $parsedAddress');
      bool isSuspicious = response.body.contains("UNCONFIRMED_AND_SUSPICIOUS");
      debugPrint('Response_from_google: $isSuspicious}');

      // Get the 'completeAddress' formatted by Google
      debugPrint('data is ${data['result']['address']}');
      return data['result']['address']['formattedAddress'];
    }
    return null;
  }

  static Map<String, String> parseGoogleResponse(Map<String, dynamic> data) {
    final components = data['result']['address']['addressComponents'] as List;

    Map<String, String> parsed = {
      'address1': '',
      'city': '',
      'state': '',
      'zip': '',
    };

    for (var comp in components) {
      final type = comp['componentType'];
      final text = comp['componentName']['text'];

      switch (type) {
        case 'street_number':
        case 'route':
        case 'subpremise':
        case 'point_of_interest':
          parsed['address1'] = parsed['address1']!.isEmpty
              ? text
              : "${parsed['address1']} $text";
          break;
        case 'locality':
        case 'neighborhood':
          // Only set city if it's empty to avoid neighborhood overwriting locality
          if (parsed['city']!.isEmpty) parsed['city'] = text;
          break;
        case 'administrative_area_level_1':
          parsed['state'] = text;
          break;
        case 'postal_code':
          parsed['zip'] = text;
          break;
      }
    }

    // RE-VALIDATION LOGIC
    // If 'state' is 5 digits, it's actually the zip.
    if (RegExp(r'^\d{5}$').hasMatch(parsed['state']!)) {
      String actualZip = parsed['state']!;
      // If the 'zip' field has the text (like "TX"), move it to state
      if (parsed['zip']!.length <= 3) {
        parsed['state'] = parsed['zip']!;
        parsed['zip'] = actualZip;
      }
    }

    return parsed;
  }
}
