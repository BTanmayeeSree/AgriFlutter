import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class LocationLookup {
  LocationLookup({http.Client? client}) : client = client ?? http.Client();
  final http.Client client;
  Future<List<FarmLocation>> byPin(String pin) async {
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(pin)) {
      throw const FormatException('Enter a valid six-digit Indian PIN.');
    }
    final response = await client
        .get(Uri.https('api.postalpincode.in', '/pincode/$pin'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw const FormatException(
        'PIN lookup is unavailable. Use manual entry.',
      );
    }
    final payload = jsonDecode(response.body) as List;
    final offices = payload.isEmpty
        ? null
        : payload.first['PostOffice'] as List?;
    if (offices == null || offices.isEmpty) return [];
    final found = <String, FarmLocation>{};
    for (final office in offices) {
      final district = '${office['District'] ?? ''}',
          state = '${office['State'] ?? ''}';
      if (district.isNotEmpty && state.isNotEmpty) {
        found['$district|$state'] = FarmLocation(district, state);
      }
    }
    return found.values.toList();
  }

  void close() => client.close();
}
