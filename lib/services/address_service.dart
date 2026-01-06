import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';

// Define a simple class to hold the result
class AddressValidationResult {
  /*
   Holds the final validated address data after calling Google's API.
  */
  final Map<String, String> parsedAddress;
  final String formattedAddress;
  final bool isSuspicious;
  final bool isIncomplete;

  AddressValidationResult({
    required this.parsedAddress,
    required this.formattedAddress,
    required this.isSuspicious,
    required this.isIncomplete,
  });
}

class AddressAutocompleteOption {
  /* 
  Holds ONE suggestion from the autocomplete dropdown.
  Properties:

  description - Full text shown in the dropdown (e.g., "123 Main Street, New York, NY")
  placeId - Unique Google identifier for this location
  mainText - The address part (e.g., "123 Main Street")
  secondaryText - The city/state part (e.g., "New York, NY")
  */
  final String description;
  final String placeId;
  final String mainText;
  final String secondaryText;

  AddressAutocompleteOption({
    required this.description,
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });
  factory AddressAutocompleteOption.fromJson(Map<String, dynamic> json) {
    // Converts raw JSON from Google API into this clean object
    return AddressAutocompleteOption(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
    );
  }
}

class AddressService {
  /*
  The main service class that talks to Google APIs (and your backend)

  _sessionToken 
  ->A unique ID for the entire typing session. Saves money on Google API credits by grouping related requests.
  
  initializeSessionToken()
  What it does: Creates a new session token using the current time in milliseconds.
  Why: Every time the user starts typing an address, they get a new session token. This groups all autocomplete + place details requests together, which Google charges less for.
  */
  static String _sessionToken = '';

  static void initializeSessionToken() {
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  static Future<AddressValidationResult?> validateAddress({
    required String address1,
    String? address2,
    required String city,
    required String state,
    required String zip,
  }) async {
    /*
    When user clicks "PLACE ORDER", this validates the final address is correct/complete.
    FLOW
      User has filled in address and clicks submit
      This function sends the complete address to your backend
      Backend forwards to Google Address Validation API
      Google checks if address is:

      Valid & complete ✓
      Valid but needs fixing (missing apt number, etc.) ✗
      Suspicious (unconfirmed address) 


      Returns AddressValidationResult with all this info
    */
    final url = Uri.parse('http://127.0.0.1:3000/api/validate-address');
    // Combine address lines into the list
    final List<String> addressLines = [address1];
    if (address2 != null && address2.isNotEmpty) {
      addressLines.add(address2);
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "address1": address1,
          "address2":
              address2 ?? "", // ← ADD THIS (convert null to empty string)
          "city": city,
          "state": state,
          "zip": zip,
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
          isIncomplete: isIncomplete,
        );
      }
    } catch (e) {
      debugPrint('API Error: $e');
    }
    return null;
  }

  static Future<List<AddressAutocompleteOption>> getAutocompletePredictions(
    String input,
  ) async {
    /* As the user types in the address field, this returns a list of suggestions.
      FLOW-
      User types "200 Main"
      This function sends "200 Main" to your backend
      Backend forwards to Google Places Autocomplete API
      Google returns suggestions like:
      "200 Main Street, New York, NY"
      "200 Main Ave, Boston, MA"
      These get converted to AddressAutocompleteOption objects
      Dropdown shows them to the user
*/

    if (input.isEmpty) return [];
    if (_sessionToken.isEmpty) initializeSessionToken();

    // final url = Uri.parse(
    //   // 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
    //   'http://127.0.0.1:3000/api/autocomplete'
    //   '?input=${Uri.encodeComponent(input)}'
    //   '&key=${Env.googleapikey}'
    //   '&sessiontoken=$_sessionToken'
    //   '&components=country:us'
    //   '&language=en',
    // );
    final url = Uri.parse(
      'http://127.0.0.1:3000/api/autocomplete?input=${Uri.encodeComponent(input)}&sessionToken=$_sessionToken',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(
          'Autocomplete response: ${data['predictions'].length} results',
        );

        final predictions = (data['predictions'] as List)
            .map((p) => AddressAutocompleteOption.fromJson(p))
            .toList();

        return predictions;
      } else {
        debugPrint('Autocomplete API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Autocomplete Error: $e');
    }
    return [];
  }

  static Future<void> fetchPlaceDetails(
    String placeId, {
    required TextEditingController address1,
    required TextEditingController city,
    required TextEditingController state,
    required TextEditingController zip,
    TextEditingController? address2,
  }) async {
    /*
    When user clicks on one suggestion, this fills in all the address fields automatically.
    FLOW
    User clicks "200 Main Street, New York, NY" from dropdown
    You pass the placeId to this function
    Function calls Google Places Details API
    Google returns address components (street number, route, city, state, zip)
    Function parses these and fills the TextEditingControllers you passed in
    */
    // final url = Uri.parse(
    //   'https://maps.googleapis.com/maps/api/place/details/json'
    //   '?place_id=$placeId'
    //   '&key=${Env.googleapikey}'
    //   '&sessiontoken=$_sessionToken'
    //   '&fields=address_components',
    // );
    final url = Uri.parse(
      'http://127.0.0.1:3000/api/place-details?placeId=$placeId&sessionToken=$_sessionToken',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['result'];
        final components = data['address_components'] as List;

        String streetNumber = '';
        String route = '';

        for (var comp in components) {
          final types = comp['types'] as List;
          final shortName = comp['short_name'];
          final longName = comp['long_name'];

          if (types.contains('street_number')) {
            streetNumber = shortName;
          } else if (types.contains('route')) {
            route = longName;
          } else if (types.contains('locality')) {
            city.text = longName;
          } else if (types.contains('administrative_area_level_1')) {
            state.text = shortName;
          } else if (types.contains('postal_code')) {
            zip.text = shortName;
          }
        }

        // Combine street number and route properly
        if (streetNumber.isNotEmpty && route.isNotEmpty) {
          address1.text = '$streetNumber $route';
        } else if (route.isNotEmpty) {
          address1.text = route;
        }

        debugPrint('Place details filled: ${address1.text}');
      }
    } catch (e) {
      debugPrint('Fetch place details error: $e');
    }
  }

  static Map<String, String> parseGoogleResponse(Map<String, dynamic> data) {
    // Takes the messy JSON from Google's validation API and extracts just what you need
    final usps = data['result']['uspsData'];
    final address = data['result']['address'];
    final components = address['addressComponents'] as List;

    Map<String, String> parsed = {
      'address1': '',
      'address2': '',
      'city': '',
      'state': '',
      'zip': '',
    };

    if (usps != null && usps['standardizedAddress'] != null) {
      final std = usps['standardizedAddress'];
      return {
        'address1': std['firstAddressLine'] ?? '',
        'address2': std['secondAddressLine'] ?? '',
        'city': std['city'] ?? '',
        'state': address['postalAddress']['administrativeArea'] ?? '',
        'zip': std['zipCode'] ?? '',
      };
    }

    for (var comp in components) {
      final type = comp['componentType'];
      final text = comp['componentName']['text'];

      switch (type) {
        case 'point_of_interest':
          parsed['address1'] = text;
          break;
        case 'street_number':
          parsed['address2'] = parsed['address2']!.isEmpty
              ? text
              : '${parsed['address2']} $text';
          break;
        case 'route':
          parsed['address2'] = parsed['address2']!.isEmpty
              ? text
              : '${parsed['address2']} $text';
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
