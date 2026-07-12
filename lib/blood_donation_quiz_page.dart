import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blood Donation Eligibility Quiz',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BloodDonationEligibilityForm(),
    );
  }
}

class BloodDonationEligibilityForm extends StatefulWidget {
  const BloodDonationEligibilityForm({super.key});
  @override
  State<BloodDonationEligibilityForm> createState() => _BloodDonationEligibilityFormState();
}

class _BloodDonationEligibilityFormState extends State<BloodDonationEligibilityForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Are you feeling healthy and well today?",
      "answer": null,
      "false_reason": "",
    },
    {
      "question": "Have you donated blood in the past 3–4 months?",
      "answer": null,
      "reason": "You had donated blood in the past 3–4 months.",
    },
    {
      "question": "Are you currently pregnant, breastfeeding, or have been in the last 6 months?",
      "answer": null,
      "reason": "You were pregnant, breastfeeding, or have been in the last 6 months.",
    },
    {
      "question": "In the past 6 months, have you had surgery, tattoos, or piercings?",
      "answer": null,
      "reason": "You had surgery, tattoos, or piercings in the past 6 months.",
    },
    {
      "question": "Do you have a history of heart disease, cancer, or blood disorders?",
      "answer": null,
      "reason": "You had a history of heart disease, cancer, or blood disorders.",
    },
    {
      "question": "Have you had a fever, infection, or any illness in the past week?",
      "answer": null,
      "reason": "You had a fever, infection, or illness in the past week.",
    },
    {
      "question": "Have you ever tested positive for HIV, Hepatitis B, or Hepatitis C?",
      "answer": null,
      "reason": "You have tested positive for HIV, Hepatitis B, or Hepatitis C.",
    },
    {
      "question": "Are you currently taking any prescribed medications?",
      "answer": null,
      "reason": "You were taking prescribed medications.",
    },
  ];

  bool submitted = false;
  String resultText = "";
  bool eligible = false;
  List<String> notEligibleReasons = [];

  void _submitQuiz() {
    List<String> problems = [];
    notEligibleReasons.clear();

    if (nameController.text.trim().isEmpty) {
      problems.add("Please enter your name.");
    }

    final age = int.tryParse(ageController.text.trim());
    if (age == null || age < 18) {
      problems.add("You must be at least 18 years old.");
    }

    final weight = double.tryParse(weightController.text.trim());
    if (weight == null || weight < 50) {
      problems.add("You must weigh at least 50kg.");
    }

    if (questions[0]['answer'] != true) {
      problems.add("You are not feeling healthy and well today.");
      notEligibleReasons.add("You are not feeling healthy and well today.");
    }
    for (int i = 1; i < questions.length; i++) {
      if (questions[i]['answer'] == true) {
        notEligibleReasons.add(questions[i]['reason']);
      }
    }

    if (problems.isEmpty && notEligibleReasons.isEmpty) {
      eligible = true;
      resultText = "Congratulations! You are eligible to donate blood.";
    } else {
      eligible = false;
      resultText = "Sorry, you are NOT eligible to donate blood because:";
      if (problems.isNotEmpty) {
        resultText += "\n\n" + problems.join("\n");
      }
      if (notEligibleReasons.isNotEmpty) {
        resultText += "\n\n" + notEligibleReasons.join("\n");
      }
    }

    setState(() {
      submitted = true;
    });
  }

  void _resetQuiz() {
    nameController.clear();
    ageController.clear();
    weightController.clear();
    for (var q in questions) {
      q['answer'] = null;
    }
    setState(() {
      submitted = false;
      resultText = "";
      eligible = false;
      notEligibleReasons.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blood Donation Eligibility Quiz',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F48FF),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: submitted ? _buildResultView() : _buildQuizForm(),
      ),
    );
  }

  Widget _buildQuizForm() {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "What is your name?"),
        ),
        TextField(
          controller: ageController,
          decoration: const InputDecoration(labelText: "What is your age?"),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: weightController,
          decoration: const InputDecoration(labelText: "What is your weight (kg)?"),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                child: ListTile(
                  title: Text(q['question']),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Yes'),
                          value: true,
                          groupValue: q['answer'],
                          onChanged: (val) {
                            setState(() {
                              questions[index]['answer'] = val;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('No'),
                          value: false,
                          groupValue: q['answer'],
                          onChanged: (val) {
                            setState(() {
                              questions[index]['answer'] = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _submitQuiz,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F48FF),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Check Eligibility",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            eligible ? Icons.check_circle_outline : Icons.error_outline,
            size: 96,
            color: eligible ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            eligible ? "You are eligible to donate blood!" : "You are NOT eligible to donate blood.",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: eligible ? Colors.green : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  resultText,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _resetQuiz,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Retake", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F48FF),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
