import 'dart:convert';
import 'package:http/http.dart' as http;

// Change this to your local network IP and port where backend is running
const String backendUrl = "https://life-saver-6dt6.onrender.com";

// Signup with additional fields: phone, gender, bloodGroup
Future<Map<String, dynamic>> signup(
    String email,
    String username,
    String password,
    String phone,
    String gender,
    String bloodGroup,
) async {
  final response = await http.post(
    Uri.parse('$backendUrl/signup'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "username": username,
      "password": password,
      "phone": phone,
      "gender": gender,
      "blood_group": bloodGroup,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Signup failed');
  }
}

// Login returns full profile data on success
Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$backendUrl/login'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
  }
}
