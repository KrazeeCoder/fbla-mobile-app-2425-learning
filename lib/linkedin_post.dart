import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

/// Generates a professional LinkedIn post message
String generateProfessionalLinkedInPost({
  required int level,
  required int totalXP,
  required String subject,
  required String subtopic,
}) {
  return '''
I'm proud to share that I just reached Level $level with $totalXP XP while exploring $subject in the FBLA Learning App 📚  
Most recently, I completed "$subtopic", and the journey has been both fun and educational.

This app turns learning into an exciting adventure — combining knowledge, gameplay, and real growth. Every subtopic brings me closer to mastering Math, Science, History, and English — the fun way 🚀

#GamifiedLearning #StudentMilestone #LevelUp #XP #EdTech #FBLA #LearningApp #AchievementUnlocked #GrowthMindset
''';
}

/// Posts the given message to LinkedIn
Future<void> postToLinkedIn({
  required BuildContext context,
  required String accessToken,
  required String message,
}) async {
  if (accessToken.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You must be signed into LinkedIn to share.")),
    );
    return;
  }

  try {
    final userId = await fetchLinkedInUserID(accessToken);

    const apiUrl = 'https://api.linkedin.com/v2/ugcPosts';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'X-Restli-Protocol-Version': '2.0.0',
    };

    final postData = {
      "author": "urn:li:person:$userId",
      "lifecycleState": "PUBLISHED",
      "specificContent": {
        "com.linkedin.ugc.ShareContent": {
          "shareCommentary": {
            "text": message,
          },
          "shareMediaCategory": "NONE",
        },
      },
      "visibility": {
        "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC",
      },
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(postData),
    );

    if (response.statusCode == 201) {
      final locationHeader = response.headers['location'];
      if (locationHeader != null && locationHeader.contains('ugcPost')) {
        final postUrn = locationHeader.split('/').last;
        final postUrl = 'https://www.linkedin.com/feed/update/$postUrn';

        showTextDialog('Success', 'Post shared successfully. Opening your post...');
        await launchUrl(Uri.parse(postUrl), mode: LaunchMode.externalApplication);
      } else {
        showTextDialog('Success', 'Post shared successfully, but could not get post link.');
        await launchUrl(Uri.parse('https://www.linkedin.com/feed/'), mode: LaunchMode.externalApplication);
      }
    }

  } catch (error) {
    showTextDialog('Error', 'Failed to share post on LinkedIn. Error: $error');
  }
}


/// Shows a basic dialog or prints message (replace with real UI dialog in Flutter)
void showTextDialog(String title, String message) {
  print('$title: $message');
}

/// Fetches LinkedIn user ID using the access token
Future<String> fetchLinkedInUserID(String accessToken) async {
  final url = Uri.parse('https://api.linkedin.com/v2/userinfo');
  final headers = {'Authorization': 'Bearer $accessToken'};

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['sub']; // For OpenID; or use 'id' for /v2/me
  } else {
    throw Exception(
      'Failed to fetch LinkedIn user ID: ${response.statusCode} - ${response.body}',
    );
  }
}