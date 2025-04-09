import 'package:http/http.dart' as http;
import 'dart:convert';

/// Generates a professional LinkedIn post message
String generateProfessionalLinkedInPost({
  required int level,
  required int totalXP,
  required String subject,
  required String subtopic,
}) {
  return '''
🎉 Achievement Unlocked! 🎉

I'm proud to share that I just reached **Level $level** with **$totalXP XP** while exploring **$subject** in the FBLA Learning App! 📚✨  
Most recently, I mastered **"$subtopic"**, and the journey has been both fun and educational.

This app transforms learning into an exciting adventure — combining knowledge, gameplay, and real growth. Every subtopic I complete brings me closer to mastering subjects like **Math, Science, History, and English** — the fun way! 🚀

#GamifiedLearning #StudentMilestone #LevelUp #XP #EdTech #FBLA #LearningApp #AchievementUnlocked #GrowthMindset
''';
}

/// Posts the given message to LinkedIn
Future<void> postToLinkedIn({
  required String accessToken,
  required String message,
}) async {
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
          "shareMediaCategory":
              "NONE", // You can change this if you add image upload
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
      showTextDialog('Success', 'Post shared successfully on LinkedIn.');
    } else {
      showTextDialog(
        'Error',
        'Failed to share post on LinkedIn. Status Code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }
  } catch (error) {
    showTextDialog('Error', 'Failed to share post on LinkedIn. Error: $error');
  }
}

/// Shows a basic dialog or message (can be updated with Flutter dialog)
void showTextDialog(String title, String message) {
  print('$title: $message'); // Replace with actual UI dialog if needed
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
