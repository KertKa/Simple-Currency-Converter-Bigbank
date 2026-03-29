import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/exchange_rate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  
  // State muutujad
  String _baseCurrency = 'EUR';
  double _amount = 1.0;
  Map<String, String> _currencyNames = {};
  ExchangeRate? _exchangeData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  // Esmane laadimine: nimed + kursid
  Future<void> _initialLoad() async {
    try {
      final names = await _apiService.fetchCurrencyNames();
      final rates = await _apiService.fetchLatestRates(_baseCurrency);
      setState(() {
        _currencyNames = names;
        _exchangeData = rates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Kursi värskendamine, kui baasvaluuta muutub
  Future<void> _updateRates(String newBase) async {
    setState(() => _isLoading = true);
    try {
      final rates = await _apiService.fetchLatestRates(newBase);
      setState(() {
        _baseCurrency = newBase;
        _exchangeData = rates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Uuendamine ebaõnnestus";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BigBank Currency Converter')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildRatesList()),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Summa'),
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() => _amount = double.tryParse(val) ?? 0.0),
              ),
              DropdownButton<String>(
                value: _baseCurrency,
                isExpanded: true,
                items: _currencyNames.keys.map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text('$code - ${_currencyNames[code]}'),
                  );
                }).toList(),
                onChanged: (val) => val != null ? _updateRates(val) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatesList() {
    final rates = _exchangeData?.rates ?? {};
    final keys = rates.keys.toList();

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final code = keys[index];
        final rate = rates[code]!;
        final name = _currencyNames[code] ?? '';

        return ListTile(
          title: Text(code),
          subtitle: Text(name),
          trailing: Text(
            (_amount * rate).toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      },
    );
  }
}