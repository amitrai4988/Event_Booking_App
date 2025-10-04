import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.white), // 🔹 Title text is white
        ),
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white), // 🔹 Back arrow white
      ),
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          color: Colors.blue.shade900, // 🔹 Dark blue background for card
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Title
                Text(
                  order['category'] ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // 🔹 White text
                  ),
                ),
                const SizedBox(height: 12),

                // Event Type
                if (order['eventType'] != null)
                  _buildRow("Event Type", order['eventType']),
                if (order['country'] != null &&
                    order['stateName'] != null &&
                    order['city'] != null)
                  _buildRow(
                      "Location",
                      "${order['city']}, ${order['stateName']}, ${order['country']}"),
                if (order['eventDates'] != null)
                  _buildRow(
                      "Event Dates",
                      (order['eventDates'] as List<dynamic>)
                          .map((d) => d.toString().split("T")[0])
                          .join(", ")),
                if (order['adults'] != null)
                  _buildRow("Guests", "${order['adults']} adults"),
                if (order['veg'] != null || order['nonVeg'] != null)
                  _buildRow(
                      "Catering",
                      (order['veg'] == true ? "Veg " : "") +
                          (order['nonVeg'] == true ? "Non-Veg" : "")),
                if (order['cuisine'] != null)
                  _buildRow("Cuisine", order['cuisine']),
                if (order['budget'] != null && order['currency'] != null)
                  _buildRow(
                      "Budget", "${order['budget']} ${order['currency']}"),
                if (order['responseTime'] != null)
                  _buildRow("Response Time", order['responseTime']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, // 🔹 Label white
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white, // 🔹 Value white
              ),
            ),
          ),
        ],
      ),
    );
  }
}
