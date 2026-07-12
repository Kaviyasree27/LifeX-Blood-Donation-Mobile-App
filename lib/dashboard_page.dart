import 'package:flutter/material.dart';
import 'become_donor_screen.dart';
import 'find_blood_screen.dart';
import 'nearby_camps_screen.dart';
import 'chatbot_screen.dart';
import 'blood_donation_quiz_page.dart';

// Dashboard Page
class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  const DashboardPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final username = profile['username'] ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Home",
          style: TextStyle(
            color: Color(0xFF1F48FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 14),
            Text(
              "Hello, $username!",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F48FF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Let's save lives together.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.22,
              children: [
                _FeatureTile(
                  icon: Icons.bloodtype,
                  label: "Become a Donor",
                  color: const Color(0xFFFFF1F3),
                  iconColor: const Color(0xFFFF5E7A),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BecomeDonorScreen()),
                  ),
                ),
                _FeatureTile(
                  icon: Icons.location_on,
                  label: "Nearby Camps",
                  color: const Color(0xFFF0F5FF),
                  iconColor: const Color(0xFF1F48FF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NearbyCampsScreen()),
                  ),
                ),
                _FeatureTile(
                  icon: Icons.search,
                  label: "Find Blood",
                  color: const Color(0xFF4B91FF).withOpacity(0.13),
                  iconColor: const Color(0xFF1F48FF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FindBloodScreen()),
                  ),
                ),
                _FeatureTile(
                  icon: Icons.chat_bubble_outline,
                  label: "Chatbot",
                  color: const Color(0xFFDFDFFD).withOpacity(0.4),
                  iconColor: const Color(0xFF7A5FFF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BloodDonationEligibilityForm()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7F8E6),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.quiz, color: Color(0xFF04D17C), size: 32),
                    SizedBox(width: 16),
                    Text(
                      "Eligibility Quiz",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF04D17C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(profile: profile),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _BottomNavBar({required this.profile});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: const Color(0xFF1F48FF),
      unselectedItemColor: Colors.grey[400],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage(profile: profile)),
          );
        }
      },
    );
  }
}

// Profile Page
class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> profile;
  const ProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final username = profile['username'] ?? 'User Name';
    final email = profile['email'] ?? 'user@example.com';
    final gender = profile['gender'] ?? 'Not specified';
    final phone = profile['phone'] ?? 'Not specified';
    final bloodGroup = profile['blood_group'] ?? 'Not specified';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F48FF),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF1F48FF),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "",
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F48FF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _SectionHeader("Personal Details"),
            _InfoRow(label: "Name", value: username),
            _InfoRow(label: "Gender", value: gender),
            _InfoRow(label: "Blood Group", value: bloodGroup),
            const SizedBox(height: 28),
            _SectionHeader("Contact Details"),
            _InfoRow(label: "Phone No.", value: phone),
            _InfoRow(label: "Email", value: email),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F48FF),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1F48FF),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
