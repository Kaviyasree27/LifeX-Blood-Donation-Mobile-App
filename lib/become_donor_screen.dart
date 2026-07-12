import 'package:flutter/material.dart';
import 'local_database.dart'; // Import your local_database.dart here

class BecomeDonorScreen extends StatefulWidget {
  const BecomeDonorScreen({super.key});
  @override
  State<BecomeDonorScreen> createState() => _BecomeDonorScreenState();
}

class _BecomeDonorScreenState extends State<BecomeDonorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _customBloodController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodGroup;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Other',
  ];

  bool _submitted = false; // Track if form submission was attempted

  // Helper to clean phone number before dialer use
  String cleanPhoneNumber(String number) {
    return number.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  // Modified submit donor method to save locally
  Future<void> _submitDonor() async {
    final bloodGroupToSend = _selectedBloodGroup == "Other"
        ? _customBloodController.text.trim()
        : _selectedBloodGroup;
    final donor = {
      "name": _nameController.text,
      "age": int.parse(_ageController.text),
      "gender": _selectedGender,
      "blood_group": bloodGroupToSend,
      "phone": _phoneController.text,
      "address": _addressController.text,
      "city": _cityController.text,
    };
    try {
      await LocalDatabase.insertDonor(donor);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thank you!'),
          content: const Text('You are registered as a donor locally.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save donor: $e")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _customBloodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const appColor = Color(0xFF1F48FF);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Become a Donor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: appColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter your name';
                  if (RegExp(r'[0-9]').hasMatch(value)) return 'Name cannot contain numbers';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Age
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter your age';
                  if (int.tryParse(value) == null) return 'Age must be a number';
                  if (int.parse(value) < 18) return 'Must be at least 18 years old';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Gender chips WITHOUT ICONS
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _genders.map((gender) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(
                        gender,
                        style: TextStyle(
                          color: _selectedGender == gender ? Colors.white : appColor,
                        ),
                      ),
                      selected: _selectedGender == gender,
                      selectedColor: appColor,
                      backgroundColor: const Color(0xFFEDEDED),
                      onSelected: (_) => setState(() => _selectedGender = gender),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    ),
                  );
                }).toList(),
              ),
              if (_submitted && _selectedGender == null)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 1),
                  child: Text('Select your gender', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              const SizedBox(height: 16),
              // Blood group chips
              const Text('Blood Group', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _bloodGroups.map((bg) {
                  return ChoiceChip(
                    label: Text(
                      bg,
                      style: TextStyle(color: _selectedBloodGroup == bg ? Colors.white : appColor),
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
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  );
                }).toList(),
              ),
              if (_submitted && _selectedBloodGroup == null)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 1),
                  child: Text('Select blood group', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              if (_selectedBloodGroup == "Other")
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: TextFormField(
                    controller: _customBloodController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your Blood Group',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_selectedBloodGroup == "Other" && (value == null || value.trim().isEmpty)) {
                        return 'Please enter your blood group';
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // Phone number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter phone number';
                  final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
                  if (!RegExp(r'^\+?\d{10,15}$').hasMatch(cleaned)) {
                    return 'Enter a valid phone number (digits, optional +, 10-15 digits)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter address' : null,
              ),
              const SizedBox(height: 16),
              // City
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter city';
                  if (RegExp(r'[0-9]').hasMatch(value)) return 'City cannot contain numbers';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Submit button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _submitted = true; // Mark submit attempt
                  });
                  if (_formKey.currentState!.validate() &&
                      _selectedGender != null &&
                      _selectedBloodGroup != null &&
                      (_selectedBloodGroup != "Other" ||
                          _customBloodController.text.trim().isNotEmpty)) {
                    // All validations pass
                    _submitDonor();
                  } else {
                    // Show SnackBar if gender or blood group not selected
                    if (_selectedGender == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select your gender')),
                      );
                    }
                    if (_selectedBloodGroup == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select your blood group')),
                      );
                    }
                    if (_selectedBloodGroup == "Other" &&
                        _customBloodController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter your blood group')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: appColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}