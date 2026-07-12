import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'local_database.dart'; // Your local database helper

class FindBloodScreen extends StatefulWidget {
  const FindBloodScreen({super.key});
  @override
  State<FindBloodScreen> createState() => _FindBloodScreenState();
}

class _FindBloodScreenState extends State<FindBloodScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Other'
  ];
  String? _selectedBloodGroup;
  final _customBloodController = TextEditingController();
  final _cityController = TextEditingController();
  List<Map<String, dynamic>> _donors = [];
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _cityController.dispose();
    _customBloodController.dispose();
    super.dispose();
  }

  // Clean phone number to digits and '+' only
  String cleanPhoneNumber(String number) {
    return number.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  // Search donor list locally filtered by blood group & city
  Future<void> _search() async {
    setState(() {
      _submitted = true;
      _loading = true;
      _donors.clear();
    });
    if (_formKey.currentState!.validate() && _selectedBloodGroup != null) {
      final bloodGroupToSearch = _selectedBloodGroup == "Other"
          ? _customBloodController.text.trim().toLowerCase()
          : _selectedBloodGroup!.toLowerCase();
      final cityToSearch = _cityController.text.trim().toLowerCase();
      try {
        final allDonors = await LocalDatabase.getDonors();
        final matchedDonors = allDonors.where((donor) {
          final donorBlood = (donor['blood_group'] ?? '').toString().toLowerCase();
          final donorCity = (donor['city'] ?? '').toString().toLowerCase();
          return donorBlood == bloodGroupToSearch && donorCity == cityToSearch;
        }).toList();
        setState(() {
          _donors = matchedDonors;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error searching donors: $e")),
        );
      }
      setState(() => _loading = false);
    } else {
      if (_selectedBloodGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select blood group')),
        );
      }
      setState(() => _loading = false);
    }
  }

  // Open phone dialer with cleaned number
  Future<void> _callDonor(String phoneNumber) async {
    final cleanNumber = cleanPhoneNumber(phoneNumber);
    final Uri telUri = Uri.parse('tel:$cleanNumber');

    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri, mode: LaunchMode.externalApplication);
      } else {
        // fallback for older phones/devices
        await launch('tel:$cleanNumber');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const appColor = Color(0xFF1F48FF);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Blood', style: TextStyle(color: Colors.white)),
        backgroundColor: appColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Blood Group',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _bloodGroups.map((bg) {
                      return ChoiceChip(
                        label: Text(
                          bg,
                          style: TextStyle(
                            color: _selectedBloodGroup == bg ? Colors.white : appColor,
                          ),
                        ),
                        selected: _selectedBloodGroup == bg,
                        selectedColor: appColor,
                        backgroundColor: const Color(0xFFEDEDED),
                        onSelected: (_) {
                          setState(() {
                            _selectedBloodGroup = bg;
                            if (bg != "Other") _customBloodController.clear();
                          });
                        },
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      );
                    }).toList(),
                  ),
                  if (_submitted && _selectedBloodGroup == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Please select blood group',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  if (_selectedBloodGroup == "Other") ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customBloodController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Blood Group',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_selectedBloodGroup == "Other" &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Please enter your blood group';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Enter City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter city' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _search,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: appColor,
                    ),
                    child:
                        const Text('Search', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _donors.isEmpty
                      ? const Center(child: Text("No donors found"))
                      : ListView.builder(
                          itemCount: _donors.length,
                          itemBuilder: (context, index) {
                            final donor = _donors[index];
                            return Card(
                              child: ListTile(
                                leading:
                                    const Icon(Icons.bloodtype, color: Colors.red),
                                title: Text(
                                    "${donor['name']} - ${donor['blood_group']}"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("City: ${donor['city']}"),
                                    Text("Phone: ${donor['phone']}"),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.call),
                                  onPressed: () => _callDonor(donor['phone']),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
