import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../ai_utility.dart';

class ChatbotScreen extends StatefulWidget {
  final String topicId;
  const ChatbotScreen({required this.topicId});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  ChatUser user = ChatUser(
    id: '2',
    firstName: FirebaseAuth.instance.currentUser?.displayName ?? 'User',
  );

  ChatUser aiUser = ChatUser(
    id: '1',
    firstName: "EarthPal AI",
    profileImage: 'assets/mushroom.png',
  );

  final ChatSession _chat = contentHelpModel.startChat(safetySettings: safetySettings);

  List<ChatMessage> messages = <ChatMessage>[];

  @override
  void initState() {
    super.initState();
    messages.insert(
      0,
      ChatMessage(
        text: 'Hello, how can I assist you?',
        user: aiUser,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              currentUser: user,
              onSend: (ChatMessage message) async {
                setState(() {
                  messages.insert(0, message);
                });

                try {
                  String? aiResponse = await generateResponseForTextContentQuestion(
                    message.text,
                    widget.topicId,
                    _chat,
                    context,
                  );

                  if (aiResponse != null) {
                    setState(() {
                      messages.insert(
                        0,
                        ChatMessage(
                          text: aiResponse,
                          user: aiUser,
                          createdAt: DateTime.now(),
                        ),
                      );
                    });
                  }
                } catch (e) {
                  print("Error generating AI response: $e");
                }
              },
              messages: messages,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _formatText(String content) {
    List<Widget> formattedTextWidgets = [];
    List<String> lines = content.split("\n");

    for (String line in lines) {
      if (line.startsWith("### ")) {
        // Section Heading Formatting
        formattedTextWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.replaceFirst("### ", ""),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        );
      } else if (line.startsWith("- ")) {
        // Bullet Points Formatting with Bold Text Support
        formattedTextWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontSize: 16)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: _formatBoldText(line.replaceFirst("- ", "")), // Apply bold formatting inside bullet points
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Regular Paragraph Text with Bold Formatting
        formattedTextWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: _formatBoldText(line),
              ),
            ),
          ),
        );
      }
    }

    return formattedTextWidgets;
  }

  /// Helper function to format **bold text** inside paragraphs and bullet points
  List<TextSpan> _formatBoldText(String text) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*'); // Match bold text
    int lastMatchEnd = 0;

    for (var match in exp.allMatches(text)) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd, match.start),
      ));
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }
    spans.add(TextSpan(text: text.substring(lastMatchEnd)));

    return spans;
  }
}