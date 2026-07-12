import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'local_database.dart'; // Import your local database helper

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final customBloodController = TextEditingController();
  String? selectedGender;
  String? selectedBloodGroup;
  bool _isLoading = false;
  bool _submitted = false;
  bool _obscurePassword = true;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> bloodOptions = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Other',
  ];

  // Hash the password using SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> handleSignup() async {
    setState(() {
      _submitted = true;
    });
    if (!_formKey.currentState!.validate()) return;
    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }
    if (selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your blood group')),
      );
      return;
    }
    final bloodGroup =
        selectedBloodGroup == "Other" ? customBloodController.text.trim() : selectedBloodGroup!;
    if (bloodGroup.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your blood group')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hashedPassword = hashPassword(passwordController.text.trim());

      final user = {
        "email": emailController.text.trim(),
        "username": usernameController.text.trim(),
        "password_hash": hashedPassword,
        "phone": phoneController.text.trim(),
        "gender": selectedGender,
        "blood_group": bloodGroup,
      };

      await LocalDatabase.insertUser(user);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful. Please login.')),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    customBloodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1F48FF);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign up to get started",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: primaryColor),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: primaryColor),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      String email = value.trim();
                      if (RegExp(r'^[A-Z]').hasMatch(email)) {
                        return 'Email should not start with a capital letter';
                      }
                      final regex = RegExp(r'^[\w-\.]+@([\w-\.]+)+[\w-]{2,4}$');
                      if (!regex.hasMatch(email)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: primaryColor),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone, color: primaryColor),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value.trim())) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: genderOptions.map((gender) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(
                            gender,
                            style: TextStyle(
                              color: selectedGender == gender ? Colors.white : primaryColor,
                            ),
                          ),
                          selected: selectedGender == gender,
                          selectedColor: primaryColor,
                          backgroundColor: const Color(0xFFEDEDED),
                          onSelected: (_) => setState(() => selectedGender = gender),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_submitted && selectedGender == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 1),
                      child: Text('Please select your gender', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  const SizedBox(height: 16),
                  const Text('Blood Group', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: bloodOptions.map((bg) {
                      return ChoiceChip(
                        label: Text(
                          bg,
                          style: TextStyle(
                            color: selectedBloodGroup == bg ? Colors.white : primaryColor,
                          ),
                        ),
                        selected: selectedBloodGroup == bg,
                        selectedColor: primaryColor,
                        backgroundColor: const Color(0xFFEDEDED),
                        onSelected: (_) {
                          setState(() {
                            selectedBloodGroup = bg;
                            if (bg != "Other") customBloodController.clear();
                          });
                        },
                        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      );
                    }).toList(),
                  ),
                  if (_submitted && selectedBloodGroup == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 1),
                      child: Text('Please select your blood group', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  if (selectedBloodGroup == "Other")
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: TextFormField(
                        controller: customBloodController,
                        decoration: InputDecoration(
                          labelText: 'Enter your Blood Group (e.g., A1+)',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (selectedBloodGroup == "Other" &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Please enter your blood group';
                          }
                          return null;
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.grey[700]),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.pushReplacementNamed(context, '/login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
