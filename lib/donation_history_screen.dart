import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DonationHistoryScreen extends StatefulWidget {
  final String userEmail; // Pass the logged-in user's email

  const DonationHistoryScreen({super.key, required this.userEmail});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  bool _loading = false;
  List<dynamic> _donations = [];
  final String backendUrl = "http://127.0.0.1:8000"; // change if running elsewhere

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    setState(() {
      _loading = true;
    });

    final url = Uri.parse("$backendUrl/donations?user_email=${Uri.encodeComponent(widget.userEmail)}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _donations = jsonDecode(response.body);
        });
      } else {
        throw Exception("Failed to load donations");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Donations")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _donations.isEmpty
              ? const Center(child: Text("No donations found"))
              : ListView.builder(
                  itemCount: _donations.length,
                  itemBuilder: (context, index) {
                    final donation = _donations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: ListTile(
                        leading: const Icon(Icons.volunteer_activism, color: Colors.red),
                        title: Text("Blood Group: ${donation['blood_group']}"),
                        subtitle: Text(
                          "Date: ${donation['date'] ?? 'N/A'}\nCity: ${donation['city']}",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

