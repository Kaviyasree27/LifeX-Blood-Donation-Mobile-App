import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];
  static const Color blue = Color(0xFF1F48FF);
  String? geminiApiKey;

  @override
  void initState() {
    super.initState();
    geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(text, true));
    });

    if (geminiApiKey == null || geminiApiKey!.isEmpty) {
      setState(() {
        _messages.add(_Message("Error: Gemini API key not found in .env", false));
      });
      return;
    }

    const String geminiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    try {
      final response = await http.post(
        Uri.parse('$geminiUrl?key=$geminiApiKey'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": text}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No reply from Gemini';
        setState(() {
          _messages.add(_Message(reply, false));
        });
      } else {
        setState(() {
          _messages.add(_Message("Error: ${response.body}", false));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_Message("Error: $e", false));
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeX Bot', style: TextStyle(color: Colors.white)),
        backgroundColor: blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment:
                        msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!msg.isUser)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: CircleAvatar(
                            backgroundColor: blue.withOpacity(0.1),
                            backgroundImage: const AssetImage('assets/images/redx_logo.png'),
                            radius: 18,
                          ),
                        ),
                      Flexible(
                        child: Container(
                          margin: msg.isUser
                              ? const EdgeInsets.only(left: 50, bottom: 8)
                              : const EdgeInsets.only(right: 50, bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: msg.isUser ? blue : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft:
                                  msg.isUser ? const Radius.circular(16) : const Radius.circular(4),
                              bottomRight:
                                  msg.isUser ? const Radius.circular(4) : const Radius.circular(16),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isUser ? Colors.white : blue,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      if (msg.isUser)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: CircleAvatar(
                            backgroundColor: blue.withOpacity(0.1),
                            child: const Icon(Icons.person, color: blue, size: 22),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          sendMessage(value.trim());
                          _controller.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    backgroundColor: blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final text = _controller.text;
                        if (text.trim().isNotEmpty) {
                          sendMessage(text.trim());
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE6E9FF),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  _Message(this.text, this.isUser);
}
