import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? eventType;
  String? country;
  String? stateName;
  String? city;
  List<DateTime?> eventDates = [];
  int adults = 0;
  bool nonVeg = false;
  bool veg = false;
  String? cuisine;
  TextEditingController budgetController = TextEditingController();
  String selectedCurrency = "INR";
  String? responseTime;

  final List<String> eventTypes = [
    "Wedding",
    "Anniversary",
    "Corporate event",
    "Other Party"
  ];
  final List<String> countries = ["India", "China", "Japan", "Russia"];
  final List<String> states = ["Maharashtra", "Delhi", "Karnataka"];
  final List<String> cities = ["Powai", "Bandra", "Pune"];
  final List<String> currencies = ["INR", "USD", "EUR"];

  final List<Map<String, String>> cuisines = [
    {"name": "Indian", "image": "https://res.cloudinary.com/rainforest-cruises/images/c_fill,g_auto/f_auto,q_auto/w_1120,h_732,c_fill,g_auto/v1661347392/india-food-paratha/india-food-paratha-1120x732.jpg"},
    {"name": "Italian", "image": "https://tse4.mm.bing.net/th/id/OIP.DccRXuCWk2QDNP3iKYbbtAHaE7?pid=Api&P=0&h=180"},
    {"name": "Asian", "image": "https://media.cntraveler.com/photos/5f63b787978ff785b25015e7/master/w_1600%2Cc_limit/Schezwan%2520Prawns-2A4D9JC.jpg"},
    {"name": "Mexican", "image": "https://wallpaperaccess.com/full/1412105.jpg"},
  ];

  Future<void> pickDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (index < eventDates.length) {
          eventDates[index] = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (eventType == null ||
        country == null ||
        stateName == null ||
        city == null ||
        eventDates.isEmpty ||
        adults == 0 ||
        cuisine == null ||
        budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? loggedUser = prefs.getString('logged_name');
    if (loggedUser == null) return;

    String? ordersJson = prefs.getString('user_orders');
    Map<String, dynamic> userOrders = ordersJson != null ? jsonDecode(ordersJson) : {};

    if (!userOrders.containsKey(loggedUser)) userOrders[loggedUser] = [];

    Map<String, dynamic> orderData = {
      "category": widget.category.title,
      "eventType": eventType,
      "country": country,
      "stateName": stateName,
      "city": city,
      "eventDates": eventDates.map((d) => d?.toIso8601String()).toList(),
      "adults": adults,
      "veg": veg,
      "nonVeg": nonVeg,
      "cuisine": cuisine,
      "budget": int.tryParse(budgetController.text) ?? 0,
      "currency": selectedCurrency,
      "responseTime": responseTime
    };

    userOrders[loggedUser].add(orderData);
    await prefs.setString('user_orders', jsonEncode(userOrders));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully!")),
    );

    Navigator.pop(context); // Go back to HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        title: Text(widget.category.title),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: widget.category.title == "Banquets & Venues"
                ? _buildVenueForm()
                : _buildCategoryDetails(),
          ),
        ),
      ),
    );
  }

  Widget _buildVenueForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tell Us Your Venue Requirements",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: eventType,
          decoration: const InputDecoration(labelText: "Event Type", border: OutlineInputBorder()),
          items: eventTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => eventType = val),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: country,
          decoration: const InputDecoration(labelText: "Country", border: OutlineInputBorder()),
          items: countries.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => country = val),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: stateName,
          decoration: const InputDecoration(labelText: "State", border: OutlineInputBorder()),
          items: states.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => stateName = val),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: city,
          decoration: const InputDecoration(labelText: "City", border: OutlineInputBorder()),
          items: cities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => city = val),
        ),
        const SizedBox(height: 16),

        const Text("Event Dates", style: TextStyle(fontWeight: FontWeight.bold)),
        Column(
          children: [
            for (int i = 0; i < eventDates.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: eventDates[i] != null
                          ? "${eventDates[i]!.day}/${eventDates[i]!.month}/${eventDates[i]!.year}"
                          : ""),
                  decoration: InputDecoration(
                    labelText: "Date ${i + 1}",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => pickDate(i),
                    ),
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: () => setState(() => eventDates.add(null)),
              icon: const Icon(Icons.add),
              label: const Text("Add more dates"),
            )
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          decoration: const InputDecoration(
            labelText: "Number of Adults",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) => setState(() => adults = int.tryParse(val) ?? 0),
        ),
        const SizedBox(height: 20),

        const Text("Catering Preference", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Checkbox(value: veg, onChanged: (val) => setState(() => veg = val ?? false)),
            const Text("Veg"),
            const SizedBox(width: 20),
            Checkbox(value: nonVeg, onChanged: (val) => setState(() => nonVeg = val ?? false)),
            const Text("Non-Veg"),
          ],
        ),
        const SizedBox(height: 20),

        const Text("Please select your Cuisines", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          children: cuisines.map((c) {
            bool isSelected = cuisine == c["name"];
            return GestureDetector(
              onTap: () => setState(() => cuisine = c["name"]),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: isSelected ? 6 : 2,
                color: isSelected ? Colors.blue.shade100 : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        c["image"]!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        c["name"]!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Budget",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: const InputDecoration(labelText: "Currency", border: OutlineInputBorder()),
                items: currencies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => selectedCurrency = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          value: responseTime,
          decoration: const InputDecoration(labelText: "Get offer within (optional)", border: OutlineInputBorder()),
          items: ["24 hours", "2 days", "1 week"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => responseTime = val),
        ),
        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _submitOrder,
            child: const Text("Submit Request",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        )
      ],
    );
  }

  Widget _buildCategoryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            widget.category.image,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              height: 180,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported, size: 48),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(widget.category.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(widget.category.description ?? ""),
        const SizedBox(height: 12),
        if (widget.category.items.isNotEmpty)
          ...widget.category.items.map((it) {
            return ListTile(
              title: Text(it['name'].toString()),
              subtitle: Text(it['price'].toString()),
            );
          }).toList()
        else
          const Text("No items available"),
      ],
    );
  }
}
