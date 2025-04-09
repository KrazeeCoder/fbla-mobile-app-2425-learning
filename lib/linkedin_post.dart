import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> postToLinkedIn({
  required String accessToken,
  required String message,
}) async {
  const String postUrl = 'https://api.linkedin.com/v2/ugcPosts';

  // Step 1: Get user's LinkedIn URN (ID)
  final profileResponse = await http.get(
    Uri.parse('https://api.linkedin.com/v2/me'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'X-Restli-Protocol-Version': '2.0.0',
    },
  );

  if (profileResponse.statusCode != 200) {
    throw Exception("Failed to get LinkedIn profile: ${profileResponse.body}");
  }

  final profileData = jsonDecode(profileResponse.body);
  final String userUrn = profileData['id']; // e.g., "abc123..."

  // Step 2: Post content
  final response = await http.post(
    Uri.parse(postUrl),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'X-Restli-Protocol-Version': '2.0.0',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "author": "urn:li:person:$userUrn",
      "lifecycleState": "PUBLISHED",
      "specificContent": {
        "com.linkedin.ugc.ShareContent": {
          "shareCommentary": {
            "text": message,
          },
          "shareMediaCategory": "NONE"
        }
      },
      "visibility": {"com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"}
    }),
  );

  if (response.statusCode == 201) {
    print("✅ Successfully posted to LinkedIn!");
  } else {
    throw Exception("❌ Failed to post: ${response.body}");
  }
}
