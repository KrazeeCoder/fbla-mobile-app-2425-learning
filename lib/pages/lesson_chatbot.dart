import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart' hide MessageOptions;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:math';

import '../services/ai_services.dart';
import '../utils/jsonUtility.dart';

// Message data class for the chat
class ChatMessageData {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? quickReplies;

  ChatMessageData({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickReplies,
  });
}

class ChatbotScreen extends StatefulWidget {
  final String topicId;
  const ChatbotScreen({required this.topicId});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // Keep track of user data
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'user';
  final String userName =
      FirebaseAuth.instance.currentUser?.displayName ?? 'User';
  final String? userImage = FirebaseAuth.instance.currentUser?.photoURL;

  // Chat session from Gemini
  final ChatSession _chat =
      contentHelpModel.startChat(safetySettings: safetySettings);

  // State
  List<ChatMessageData> messages = [];
  bool isLoading = false;
  String topicTitle = "Current Lesson";

  @override
  void initState() {
    super.initState();
    // Add welcome message with quick replies
    messages.add(
      ChatMessageData(
        text:
            'Hello! I am your study assistant! How can I help with your current lesson?',
        isUser: false,
        timestamp: DateTime.now(),
        quickReplies: [
          "Explain the topic",
          "Give me examples",
          "Quiz me",
          "Simplify this concept",
        ],
      ),
    );

    // Attempt to get the topic title
    _getTopicTitle();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _getTopicTitle() async {
    try {
      String title = await _getTopicTitleFromId(widget.topicId);
      setState(() {
        topicTitle = title;
      });
    } catch (e) {
      print("Error getting topic title: $e");
    }
  }

  Future<String> _getTopicTitleFromId(String topicId) async {
    Map<String, dynamic> data = await loadJsonData();

    for (Map subject in data["subjects"]) {
      for (Map grade in subject["grades"]) {
        for (Map unit in grade["units"]) {
          for (Map subtopic in unit["subtopics"]) {
            if (topicId == subtopic["subtopic_id"].toString()) {
              return subtopic["title"] ?? "Current Lesson";
            }
          }
        }
      }
    }
    return "Current Lesson";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text('Study Assistant - $topicTitle'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Info Card at the top
          if (messages.length == 1 && !isLoading) _buildInfoCard(),

          // Loading indicator at the top
          if (isLoading)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "EarthPal is thinking...",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageItem(message, index);
              },
            ),
          ),

          // Quick reply buttons for the first message if not typing
          if (!isLoading &&
              messages.isNotEmpty &&
              messages[0].quickReplies != null)
            _buildQuickReplies(messages[0].quickReplies!),

          // Input field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessageData message, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar (only for AI messages)
          if (!message.isUser) _buildAvatar(isUser: false),

          SizedBox(width: 8),

          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: message.isUser
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Colors.green.shade100,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text with formatting
                  _formatMarkdownText(message.text, !message.isUser),

                  // Timestamp
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: message.isUser
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 8),

          // User Avatar (only for user messages)
          if (message.isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    const double size = 36;
    return CircleAvatar(
      radius: size / 2 + 5,
      backgroundColor: isUser
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.white,
      backgroundImage: !isUser
          ? AssetImage('assets/branding/earthpal_logo.png')
          : (userImage != null
              ? NetworkImage(userImage!) as ImageProvider
              : null),
      child: (isUser && userImage == null) || (!isUser && false)
          ? Text(
              isUser ? (userName.isNotEmpty ? userName[0] : '?') : 'A',
              style: TextStyle(
                fontSize: size / 2,
                fontWeight: FontWeight.bold,
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.green.shade800,
              ),
            )
          : null,
    );
  }

  Widget _formatMarkdownText(String text, bool isAiMessage) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          color: isAiMessage ? Colors.black87 : Colors.white,
          height: 1.4,
        ),
        children: _processFormattedText(text),
      ),
    );
  }

  Widget _buildQuickReplies(List<String> quickReplies) {
    return Container(
      height: 45,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: quickReplies.map((reply) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => _handleQuickReply(reply),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  reply,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Ask about your lesson...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  _sendMessage(text);
                }
              },
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  if (_messageController.text.trim().isNotEmpty) {
                    _sendMessage(_messageController.text);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  backgroundImage:
                      AssetImage('assets/branding/earthpal_logo.png'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EarthPal Study Assistant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'I can help you understand this lesson better!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Ask me questions about your current lesson, request examples, or get quiz questions to test your understanding!',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _processFormattedText(String text) {
    print(
        'Processing full text: "${text.substring(0, min(50, text.length))}..."');
    List<TextSpan> spans = [];
    List<String> lines = text.split("\n");

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line.trim().isEmpty) {
        // Handle empty lines
        if (i < lines.length - 1) {
          spans.add(TextSpan(text: "\n"));
        }
        continue;
      }

      print(
          'Processing line ${i + 1}/${lines.length}: "${line.substring(0, min(30, line.length))}"${line.length > 30 ? "..." : ""}');

      // Process headings
      if (line.startsWith("# ")) {
        spans.add(TextSpan(
          text: "${line.substring(2)}\n",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
      // Process subheadings
      else if (line.startsWith("## ")) {
        spans.add(TextSpan(
          text: "${line.substring(3)}\n",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
      // Process bullet points
      else if (line.startsWith("- ") || line.startsWith("* ")) {
        print('Found bullet point');
        // Apply formatting to bullet point content
        List<TextSpan> bulletContent =
            _processInlineFormatting(line.substring(2));

        // Add bullet symbol
        spans.add(TextSpan(text: "• "));

        // Add formatted content
        spans.addAll(bulletContent);

        // Add newline if not the last line
        if (i < lines.length - 1) {
          spans.add(TextSpan(text: "\n"));
        }
      }
      // Process numbered lists - more permissive pattern
      else if (RegExp(r'^\d+\.').hasMatch(line)) {
        print('Found numbered list item');
        // Find where the content starts after the number
        Match? match = RegExp(r'^\d+\.(\s*)').firstMatch(line);
        if (match != null) {
          int contentStart = match.end;
          print('Numbered list content starts at: $contentStart');

          // Add the number part unchanged
          spans.add(TextSpan(text: line.substring(0, contentStart)));

          // Make sure we have content to format
          if (contentStart < line.length) {
            // Format the content part
            String contentPart = line.substring(contentStart);
            print('Numbered list content: "$contentPart"');
            List<TextSpan> numberContent =
                _processInlineFormatting(contentPart);
            spans.addAll(numberContent);
          }

          // Add newline if not the last line
          if (i < lines.length - 1) {
            spans.add(TextSpan(text: "\n"));
          }
        } else {
          // Fallback if regex doesn't match (shouldn't happen)
          spans.add(TextSpan(text: "$line${i < lines.length - 1 ? "\n" : ""}"));
        }
      }
      // Regular line
      else {
        print('Found regular line');
        // Process inline formatting
        List<TextSpan> inlineSpans = _processInlineFormatting(line);

        // Add formatted content
        spans.addAll(inlineSpans);

        // Add newline if not the last line
        if (i < lines.length - 1) {
          spans.add(TextSpan(text: "\n"));
        }
      }
    }

    print('Total spans generated: ${spans.length}');
    return spans;
  }

  List<TextSpan> _processInlineFormatting(String text) {
    // Edge case: Empty text
    if (text.isEmpty) {
      return [TextSpan(text: "")];
    }

    print(
        'Processing inline text: "${text.length > 30 ? text.substring(0, 30) + "..." : text}"');

    // Process each formatting type separately for more reliability
    // Start with just plain text
    List<TextSpan> spans = [TextSpan(text: text)];

    try {
      // Process bold text - ensure we don't match empty content
      spans = _processSpecificFormat(spans, RegExp(r'\*\*(.+?)\*\*'),
          (match) => TextStyle(fontWeight: FontWeight.bold), 1, 'Bold');

      // Process italic text
      spans = _processSpecificFormat(spans, RegExp(r'\*(.+?)\*'),
          (match) => TextStyle(fontStyle: FontStyle.italic), 1, 'Italic');

      // Process code text
      spans = _processSpecificFormat(
          spans,
          RegExp(r'`(.+?)`'),
          (match) => TextStyle(
                fontFamily: 'monospace',
                backgroundColor: Colors.grey.shade200,
                color: Colors.black87,
              ),
          1,
          'Code');

      // Process subscript
      spans = _processSpecificFormat(
          spans,
          RegExp(r'<sub>(.+?)</sub>'),
          (match) => TextStyle(
                fontSize: 12,
                textBaseline: TextBaseline.alphabetic,
                height: 2.0,
              ),
          1,
          'Subscript');

      // Process superscript
      spans = _processSpecificFormat(
          spans,
          RegExp(r'<sup>(.+?)</sup>'),
          (match) => TextStyle(
                fontSize: 12,
                textBaseline: TextBaseline.alphabetic,
                height: 0.7,
              ),
          1,
          'Superscript');
    } catch (e) {
      print('Error processing formatted text: $e');
      // Return original text if there was an error
      return [TextSpan(text: text)];
    }

    print('Final spans count: ${spans.length}');
    return spans;
  }

  // Helper method to process a specific formatting pattern
  List<TextSpan> _processSpecificFormat(
      List<TextSpan> inputSpans,
      RegExp pattern,
      TextStyle Function(String) styleBuilder,
      int groupIndex,
      String formatName) {
    List<TextSpan> result = [];

    for (var span in inputSpans) {
      // Only process text spans (not already styled spans)
      if (span.style == null) {
        String text = span.text ?? '';

        // Skip empty text
        if (text.isEmpty) {
          result.add(span);
          continue;
        }

        List<Match> matches = pattern.allMatches(text).toList();

        if (matches.isEmpty) {
          // No matches, keep original span
          result.add(span);
        } else {
          int lastEnd = 0;
          for (var match in matches) {
            print(
                '$formatName match found: "${match.group(0)}" -> "${match.group(groupIndex)}"');

            // Add text before the match
            if (match.start > lastEnd) {
              result.add(TextSpan(text: text.substring(lastEnd, match.start)));
            }

            // Add the styled text
            String? innerText = match.group(groupIndex);
            if (innerText != null) {
              result.add(TextSpan(
                text: innerText,
                style: styleBuilder(innerText),
              ));
            }

            lastEnd = match.end;
          }

          // Add any remaining text after the last match
          if (lastEnd < text.length) {
            result.add(TextSpan(text: text.substring(lastEnd)));
          }
        }
      } else {
        // If the span already has styling, keep it as is
        result.add(span);
      }
    }

    return result;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
    return "${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  void _sendMessage(String text) {
    // Clear the text field
    _messageController.clear();

    // Add user message
    setState(() {
      // Remove any quick replies from the first message
      if (messages.isNotEmpty && messages[0].quickReplies != null) {
        final oldMessage = messages[0];
        messages[0] = ChatMessageData(
          text: oldMessage.text,
          isUser: oldMessage.isUser,
          timestamp: oldMessage.timestamp,
        );
      }

      // Add new user message
      messages.add(ChatMessageData(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));

      isLoading = true;
    });

    // Generate AI response
    generateResponseForTextContentQuestion(
      text,
      widget.topicId,
      _chat,
      context,
    ).then((aiResponse) {
      if (mounted) {
        setState(() {
          isLoading = false;
          if (aiResponse != null) {
            messages.add(ChatMessageData(
              text: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          }
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          messages.add(ChatMessageData(
            text: "I'm having trouble connecting. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
      print("Error generating AI response: $e");
    });
  }

  void _handleQuickReply(String replyText) {
    _sendMessage(replyText);
  }
}
