import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'jsonUtility.dart';

const apiKey = "AIzaSyB6cpbKGMdZeY8p28TRRPzzkFRUzMjG_SQ";

final contentHelpModel = GenerativeModel(
  model: 'gemini-1.5-flash-latest',
  apiKey: apiKey,
);


final safetySettings = [
  SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
  SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
  SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
  SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
];


Future<String?> generateResponseForTextContentQuestion(String text, String topicId, ChatSession currentChat, BuildContext context) async {
  String subtopicContent = await loadTopicContent(topicId);

  try{
    String prompt =
    '''
    Answer this question: $text. Here is the content for the lesson that the user is asking about $subtopicContent. Keep your response such that the relevant grade level for the topic will understand.
    Keep responses under 2 paragraphs (or more concise response if applicable) and do not repeat the content that I gave you.
    ''';
    final content = Content.text(prompt);
    final response = await currentChat.sendMessage(content);

    return response.text?.trim();
  } catch(e){
    print("ai not working: $e");
  }
  return null;
}


Future<String> loadTopicContent(String topicId) async {
  Map<String, dynamic> data = await loadJsonData();

  for (Map subject in data["subjects"]){
    for (Map grade in subject["grades"]){
      for (Map unit in grade["units"]){
        for (Map subtopic in unit["subtopics"]){
          if (topicId == subtopic["subtopic_id"].toString()){
            return subtopic["reading"]["content"];
          }
        }
      }
    }
  }

  return " ";
}
