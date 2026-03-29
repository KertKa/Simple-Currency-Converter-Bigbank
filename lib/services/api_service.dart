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
}