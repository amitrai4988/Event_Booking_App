import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../widgets/category_card.dart';
import 'login_screen.dart';
import 'order_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String displayName = "User";
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = "";
  int? _highlightedIndex;

  final List<Category> sampleCategories = [
    Category(
      id: 1,
      title: 'Travel & Stay',
      subtitle: 'Hotels and stays',
      image:
      'https://www.roadaffair.com/wp-content/uploads/2017/10/cancun-resort-mexico-shutterstock_387167935.jpg',
      description: 'Find comfortable stays across the city.',
      items: [{'id': 201, 'name': 'CityHotel', 'price': '₹3,000 / night'}],
    ),
    Category(
      id: 2,
      title: 'Banquets & Venues',
      subtitle: 'Large halls and event venues',
      image:
      'https://images.venuebookingz.com/19800-1600268647-wm-seven-seas-hotel-delhi-banquet-hall-6.jpg',
      description: 'Beautiful spaces for weddings & corporate events.',
      items: [
        {'id': 101, 'name': 'Grand Hall', 'price': '₹50,000'},
        {'id': 102, 'name': 'Lakeview Banquet', 'price': '₹75,000'},
      ],
    ),
    Category(
      id: 3,
      title: 'Retail Stores & Shops',
      subtitle: 'Shops and stores',
      image:
      'https://a.cdn-hotels.com/gdcs/production45/d1954/fc79fb2d-5fe6-4c03-b977-02f226b8073a.jpg',
      description: 'Retail outlets and stores nearby.',
      items: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      displayName = prefs.getString('logged_name') ?? "User";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_name');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _showProfileMenu() async {
    final prefs = await SharedPreferences.getInstance();
    String? loggedUser = prefs.getString('logged_name');
    if (loggedUser == null) return;

    Map<String, dynamic> userOrders = {};
    String? ordersJson = prefs.getString('user_orders');
    if (ordersJson != null) {
      try {
        userOrders = jsonDecode(ordersJson);
      } catch (e) {
        userOrders = {};
      }
    }

    List<Map<String, dynamic>> currentUserOrders = [];
    if (userOrders.containsKey(loggedUser)) {
      var rawOrders = userOrders[loggedUser];
      if (rawOrders is List) {
        currentUserOrders = rawOrders
            .where((order) => order is Map && order.isNotEmpty)
            .map<Map<String, dynamic>>(
                (order) => Map<String, dynamic>.from(order))
            .toList();
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Updated CircleAvatar with first letter
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                title: Text(displayName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: const Text("Free Plan"),
              ),
              const Divider(),
              const Text("My Orders",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (currentUserOrders.isEmpty)
                const Text("No orders yet",
                    style: TextStyle(color: Colors.black54))
              else
                ...currentUserOrders.map((order) {
                  return ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: Text(order['category'] ?? ""),
                    subtitle: const Text("Tap to see details"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsScreen(order: order),
                        ),
                      );
                    },
                  );
                }).toList(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout",
                    style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: _logout,
              ),
            ],
          ),
        );
      },
    );
  }

  void _searchCategory(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });

    final index = sampleCategories.indexWhere((cat) =>
    cat.title.toLowerCase().contains(_searchQuery) ||
        cat.subtitle.toLowerCase().contains(_searchQuery));

    if (index != -1) {
      setState(() => _highlightedIndex = index);

      // Auto scroll to matched card
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          index * 220.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });

      // Fade out highlight after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (mounted && _highlightedIndex == index) {
          setState(() => _highlightedIndex = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _showProfileMenu,
                        child: Row(
                          children: [
                            // Updated CircleAvatar with first letter
                            CircleAvatar(
                              backgroundColor: Colors.indigo,
                              radius: 22,
                              child: Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(displayName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("Free Plan",
                                style: TextStyle(color: Colors.indigo)),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.notifications, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                      onChanged: _searchCategory,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Categories",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Column(
                    children: sampleCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cat = entry.value;
                      final isHighlighted = index == _highlightedIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: isHighlighted
                                  ? Colors.blueAccent
                                  : Colors.transparent,
                              width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CategoryCard(category: cat),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
