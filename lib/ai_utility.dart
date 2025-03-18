import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = "[insert api key]";

final model = GenerativeModel(
  model: 'gemini-1.5-flash-latest',
  apiKey: apiKey,
);


final safetySettings = [
  SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
  SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
  SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
  SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
];


Future<String?> generateSentenceSuggestion(int phraseLength, BuildContext context) async {
  try{
    print(apiKey);
    String prompt =
    '''
        NOT BEING USED YET
        ''';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content, safetySettings: safetySettings);

    return response.text;
  } catch(e){
    print("ai not working: $e");
  }
  return null;
}
