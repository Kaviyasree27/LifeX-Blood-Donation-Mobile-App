import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'splash_screen.dart';
import 'welcome_screen.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
// Import your Gemini API connected chatbot screen (networked)
import 'chatbot_screen.dart';
import 'blood_donation_quiz_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Loads .env with Gemini API key
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blood Donation App',
      theme: ThemeData(primarySwatch: Colors.red),
      initialRoute: '/', // start at splash
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/signup': (context) => SignupPage(),
        '/login': (context) => LoginPage(),
        // Use the Gemini API connected chatbot here
        '/chatbot': (context) => ChatbotScreen(),
        '/quiz': (context) => BloodDonationEligibilityForm(),
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/dashboard') {
          final profile = settings.arguments as Map<String, dynamic>?;
          if (profile == null) {
            // fallback with empty profile or redirect to login
            return MaterialPageRoute(
              builder: (_) => DashboardPage(profile: {
                'username': 'User',
                'email': 'Not available',
                'gender': 'Not specified',
                'phone': 'Not specified',
                'blood_group': 'Not specified',
              }),
            );
          }
          return MaterialPageRoute(
            builder: (_) => DashboardPage(profile: profile),
          );
        }
        // Unknown route fallback:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
        );
      },
    );
  }
}