import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Set<String> _favorites = {};

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

      await _loadFavorites(); // Laeme lemmikud enne UI uuendamist

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

  // LAADIMINE seadmest
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = (prefs.getStringList('favorites') ?? []).toSet();
    });
  }

  // SALVESTAMINE seadmesse
  Future<void> _toggleFavorite(String code) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(code)) {
        _favorites.remove(code);
      } else {
        _favorites.add(code);
      }
    });
    await prefs.setStringList('favorites', _favorites.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bigbank Currency Exchange'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null // veateate kuvamine, kui on viga
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Viga andmete laadimisel:\n$_errorMessage',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
        : Column( // vigade puudumisel näitame andmeid
            children: [
              _buildHeader(),
              const Divider(),
              Expanded(child: _buildRatesList()),
            ],
          ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Summa',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => setState(() => _amount = double.tryParse(val) ?? 0.0),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _baseCurrency,
            decoration: const InputDecoration(labelText: 'Baasvaluuta'),
            items: _currencyNames.keys.map((code) {
              return DropdownMenuItem(value: code, child: Text('$code - ${_currencyNames[code]}'));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                _baseCurrency = val;
                _updateRates(val);
              }
            },
          ),
        ],
      ),
    );
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

  Widget _buildRatesList() {
    final rates = _exchangeData?.rates ?? {};
    // Sorteerime nii, et lemmikud on eespool
    final sortedKeys = rates.keys.toList()
      ..sort((a, b) {
        if (_favorites.contains(a) && !_favorites.contains(b)) return -1;
        if (!_favorites.contains(a) && _favorites.contains(b)) return 1;
        return a.compareTo(b);
      });

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final code = sortedKeys[index];
        final isFav = _favorites.contains(code);

        return ListTile(
          leading: IconButton(
            icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? Colors.orange : null),
            onPressed: () => _toggleFavorite(code),
          ),
          title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(_currencyNames[code] ?? ''),
          trailing: Text(
            (_amount * rates[code]!).toStringAsFixed(2),
            style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}