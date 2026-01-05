import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';

// Define a simple class to hold the result
class AddressValidationResult {
  final Map<String, String> parsedAddress;
  final String formattedAddress;
  final bool isSuspicious;
  final bool isInComplete;

  AddressValidationResult({
    required this.parsedAddress,
    required this.formattedAddress,
    required this.isSuspicious,
    required this.isInComplete,
  });
}

class AddressService {
  static Future<AddressValidationResult?> validateAddress({
    required String address1,
    String? address2,
    required String city,
    required String state,
    required String zip,
  }) async {
    final url = Uri.parse(
      'https://addressvalidation.googleapis.com/v1:validateAddress?key=${Env.googleapikey}',
    );
    // Combine address lines into the list
    final List<String> addressLines = [address1];
    if (address2 != null && address2.isNotEmpty) {
      addressLines.add(address2);
    }

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "address": {
            "addressLines": addressLines, // Now sends both!
            "locality": city,
            "administrativeArea": state,
            "postalCode": zip,
            "regionCode": "US",
          },
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('response: $data');

        final parsed = parseGoogleResponse(data);
        debugPrint('parsed: $parsed');

        final verdict = data['result']['verdict'];
        bool isIncomplete =
            verdict['possibleNextAction'] == 'FIX' ||
            verdict['validationGranularity'] == 'OTHER';

        final bool isSuspicious = response.body.contains(
          "UNCONFIRMED_AND_SUSPICIOUS",
        );

        return AddressValidationResult(
          parsedAddress: parsed,
          formattedAddress: data['result']['address']['formattedAddress'] ?? '',
          isSuspicious: isSuspicious,
          isInComplete: isIncomplete,
        );
      }
    } catch (e) {
      debugPrint('API Error: $e');
    }
    return null;
  }

  static Future<void> fetchPlaceDetails(
    String placeId, {
    required TextEditingController address1,
    required TextEditingController city,
    required TextEditingController state,
    required TextEditingController zip,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${Env.googleapikey}',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['result'];
      final components = data['address_components'] as List;

      // Logic to map components to your controllers
      for (var comp in components) {
        final types = comp['types'] as List;
        final value = comp['short_name'];

        if (types.contains('street_number')) address1.text = value;
        if (types.contains('route')) address1.text += ' ${value}';
        if (types.contains('locality')) city.text = value;
        if (types.contains('administrative_area_level_1')) state.text = value;
        if (types.contains('postal_code')) zip.text = value;
      }
    }
  }

  static Future<List<dynamic>> getAutocompletePredictions(String input) async {
    // sessiontoken is a unique ID for each "typing session" to save money on API credits
    final String sessionToken = 'session_123456';

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input'
      '&key=${Env.googleapikey}'
      '&sessiontoken=$sessionToken',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Autocomplete_data:$data');
      // // DEBUG PRINT: This will show the corrected names
      // debugPrint('AUTOCOMPLETE PREDICTIONS for "$input":');
      // for (var prediction in data['predictions']) {
      //   debugPrint(' - Suggestion: ${prediction['description']}');
      //   debugPrint(' - Place ID: ${prediction['place_id']}');
      // }
      return data['predictions'];
    }
    return [];
  }

  static Map<String, String> parseGoogleResponse(Map<String, dynamic> data) {
    final usps = data['result']['uspsData'];
    final address = data['result']['address'];
    final components = address['addressComponents'] as List;

    Map<String, String> parsed = {
      'address1': '', // We'll put the Hotel/Business name here
      'address2': '', // We'll put the Street Address here
      'city': '',
      'state': '',
      'zip': '',
    };

    // If USPS data exists, it's usually cleaner for US addresses
    if (usps != null && usps['standardizedAddress'] != null) {
      final std = usps['standardizedAddress'];
      return {
        'address1': std['firstAddressLine'] ?? '',
        'address2': std['secondAddressLine'] ?? '',
        'city': std['city'] ?? '',
        'state':
            address['postalAddress']['administrativeArea'] ??
            '', // State is usually here
        'zip': std['zipCode'] ?? '',
      };
    }

    for (var comp in components) {
      final type = comp['componentType'];
      final text = comp['componentName']['text'];

      switch (type) {
        case 'point_of_interest':
          parsed['address1'] = text; // "Extended Stay"
          break;
        case 'street_number':
          parsed['address2'] = parsed['address2']!.isEmpty
              ? text
              : "${parsed['address2']} $text";
        case 'route':
          parsed['address2'] = parsed['address2']!.isEmpty
              ? text
              : "${parsed['address2']} $text";
          break;
        case 'locality':
          parsed['city'] = text;
          break;
        case 'administrative_area_level_1':
          parsed['state'] = text;
          break;
        case 'postal_code':
          parsed['zip'] = text;
          break;
      }
    }
    return parsed;
  }
}
