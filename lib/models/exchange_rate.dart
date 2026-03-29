class ExchangeRate {
  final String base;
  final String date;
  final Map<String, double> rates;

  ExchangeRate({
    required this.base,
    required this.date,
    required this.rates,
  });

  // Factory meetod JSON-i konverteerimiseks objektiks
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      base: json['base'],
      date: json['date'],
      rates: Map<String, double>.from(
        json['rates'].map((key, value) => MapEntry(key, value.toDouble())),
      ),
    );
  }
}