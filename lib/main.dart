import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const CurrencyConverterApp());

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = "USD";
  String _toCurrency = "EUR";
  double _conversionRate = 1.0;
  String _result = "";

  Future<void> _fetchConversionRate() async {
    final url = "https://api.exchangerate-api.com/v4/latest/$_fromCurrency";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _conversionRate = data["rates"][_toCurrency];
        _convert();
      });
    }
  }

  void _convert() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _result = (amount * _conversionRate).toStringAsFixed(2);
    });
  }

  void swapCurrencies() {
    setState(() {
      // Zamiana miejscami walut
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convert();
      _fetchConversionRate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konwerter Walut")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Kwota"),
              keyboardType: TextInputType.number,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: _fromCurrency,
                  items: ["USD", "EUR", "GBP", "PLN"].map((String value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _fromCurrency = value!;
                      _fetchConversionRate();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  iconSize: 32,
                  onPressed: swapCurrencies, // Logika zamiany
                ),
                DropdownButton<String>(
                  value: _toCurrency,
                  items: ["USD", "EUR", "GBP", "PLN"].map((String value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _toCurrency = value!;
                      _fetchConversionRate();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchConversionRate,
              child: const Text("Przelicz"),
            ),
            const SizedBox(height: 20),
            Text(
              "Wynik: $_result $_toCurrency",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
