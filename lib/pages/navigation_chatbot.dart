import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/ai_services.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class NavigationChatbot extends StatefulWidget {
  const NavigationChatbot({super.key});

  @override
  State<NavigationChatbot> createState() => _NavigationChatbotState();
}

class _NavigationChatbotState extends State<NavigationChatbot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatSession _chat =
      navigationHelpModel.startChat(safetySettings: safetySettings);

  List<ChatMessage> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    messages.add(ChatMessage(
      text:
          "Hello! I'm your navigation assistant. How can I help you find your way around the app?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      isLoading = true;
    });

    generateResponseForNavigationQuestion(text, _chat, context)
        .then((response) {
      if (mounted) {
        setState(() {
          isLoading = false;
          if (response != null) {
            messages.add(ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          }
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.navigation,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Finding the best way...",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _processFormattedText(String text) {
    List<TextSpan> spans = [];
    List<String> lines = text.split("\n");

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line.trim().isEmpty) {
        if (i < lines.length - 1) {
          spans.add(const TextSpan(text: "\n"));
        }
        continue;
      }

      // Process headings
      if (line.startsWith("# ")) {
        spans.add(TextSpan(
          text: "${line.substring(2)}\n",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
      // Process subheadings
      else if (line.startsWith("## ")) {
        spans.add(TextSpan(
          text: "${line.substring(3)}\n",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
      // Process bullet points
      else if (line.startsWith("- ") || line.startsWith("* ")) {
        spans.add(const TextSpan(text: "• "));
        spans.addAll(_processInlineFormatting(line.substring(2)));
        if (i < lines.length - 1) {
          spans.add(const TextSpan(text: "\n"));
        }
      }
      // Process numbered lists
      else if (RegExp(r'^\d+\.').hasMatch(line)) {
        Match? match = RegExp(r'^\d+\.(\s*)').firstMatch(line);
        if (match != null) {
          int contentStart = match.end;
          spans.add(TextSpan(text: line.substring(0, contentStart)));
          if (contentStart < line.length) {
            spans
                .addAll(_processInlineFormatting(line.substring(contentStart)));
          }
          if (i < lines.length - 1) {
            spans.add(const TextSpan(text: "\n"));
          }
        } else {
          spans.add(TextSpan(text: "$line${i < lines.length - 1 ? "\n" : ""}"));
        }
      }
      // Regular line
      else {
        spans.addAll(_processInlineFormatting(line));
        if (i < lines.length - 1) {
          spans.add(const TextSpan(text: "\n"));
        }
      }
    }

    return spans;
  }

  List<TextSpan> _processInlineFormatting(String text) {
    if (text.isEmpty) {
      return [const TextSpan(text: "")];
    }

    List<TextSpan> spans = [TextSpan(text: text)];

    try {
      // Process bold text
      spans = _processSpecificFormat(
        spans,
        RegExp(r'\*\*(.+?)\*\*'),
        (match) => const TextStyle(fontWeight: FontWeight.bold),
        1,
        'Bold',
      );

      // Process italic text
      spans = _processSpecificFormat(
        spans,
        RegExp(r'\*(.+?)\*'),
        (match) => const TextStyle(fontStyle: FontStyle.italic),
        1,
        'Italic',
      );

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
        'Code',
      );

      // Process subscript
      spans = _processSpecificFormat(
        spans,
        RegExp(r'<sub>(.+?)</sub>'),
        (match) => const TextStyle(
          fontSize: 12,
          textBaseline: TextBaseline.alphabetic,
          height: 2.0,
        ),
        1,
        'Subscript',
      );

      // Process superscript
      spans = _processSpecificFormat(
        spans,
        RegExp(r'<sup>(.+?)</sup>'),
        (match) => const TextStyle(
          fontSize: 12,
          textBaseline: TextBaseline.alphabetic,
          height: 0.7,
        ),
        1,
        'Superscript',
      );
    } catch (e) {
      print('Error processing formatted text: $e');
      return [TextSpan(text: text)];
    }

    return spans;
  }

  List<TextSpan> _processSpecificFormat(
    List<TextSpan> inputSpans,
    RegExp pattern,
    TextStyle Function(String) styleBuilder,
    int groupIndex,
    String formatName,
  ) {
    List<TextSpan> result = [];

    for (var span in inputSpans) {
      if (span.style == null) {
        String text = span.text ?? '';

        if (text.isEmpty) {
          result.add(span);
          continue;
        }

        List<Match> matches = pattern.allMatches(text).toList();

        if (matches.isEmpty) {
          result.add(span);
        } else {
          int lastEnd = 0;
          for (var match in matches) {
            if (match.start > lastEnd) {
              result.add(TextSpan(text: text.substring(lastEnd, match.start)));
            }

            String? innerText = match.group(groupIndex);
            if (innerText != null) {
              result.add(TextSpan(
                text: innerText,
                style: styleBuilder(innerText),
              ));
            }

            lastEnd = match.end;
          }

          if (lastEnd < text.length) {
            result.add(TextSpan(text: text.substring(lastEnd)));
          }
        }
      } else {
        result.add(span);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return _buildLoadingIndicator();
                }
                return _buildMessage(messages[index]);
              },
            ),
          ),

          // Input Area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Ask about navigation...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _sendMessage(text);
                        _messageController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
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
                          _messageController.clear();
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.navigation,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: message.isUser
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: message.isUser ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                      children: _processFormattedText(message.text),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
