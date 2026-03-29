import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_rate.dart';

class ApiService {
  static const String baseUrl = 'api.frankfurter.app';

  // Meetod värskete kursside pärimiseks
  Future<ExchangeRate> fetchLatestRates(String baseCurrency) async {
    final url = Uri.https(baseUrl, '/latest', {'from': baseCurrency});
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ExchangeRate.fromJson(data);
      } else {
        throw Exception('Failed to load rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, String>> fetchCurrencyNames() async {
  final url = Uri.https(baseUrl, '/currencies');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Konverteerime Map<String, dynamic> -> Map<String, String>
      return data.map((key, value) => MapEntry(key, value.toString()));
    } else {
      throw Exception('Failed to load currency names');
    }
  } catch (e) {
    throw Exception('Network error while fetching names: $e');
  }
}
}