import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:typed_data';

class ApiService {
  String baseUrl;
  String hmacSecret;
  String authToken;

  // Private constructor for singleton
  ApiService._privateConstructor({
    required this.baseUrl,
    required this.hmacSecret,
    required this.authToken,
  });

  // Singleton instance
  static final ApiService _instance = ApiService._privateConstructor(
    baseUrl: 'https://us-central1-voxigo.cloudfunctions.net/secureKeyServer',
    hmacSecret: 'default-hmac-secret',
    authToken: 'default-auth-token',
  );

  // Getter for the instance
  static ApiService get instance => _instance;

  // Factory constructor to initialize the singleton with remote config
  static Future<ApiService> initialize({bool force = false}) async {
    final configValues = await fetchRemoteConfig();
    _instance.baseUrl =
        "https://us-central1-voxigo.cloudfunctions.net/secureKeyServer";
    _instance.hmacSecret = configValues['hmac_secret'] ?? 'default-hmac-secret';
    _instance.authToken = configValues['auth_token'] ?? 'default-auth-token';

    print("🔄 ApiService initialized with:");
    print("🔑 hmacSecret: ${_instance.hmacSecret}");
    print("🔐 authToken: ${_instance.authToken}");

    return _instance;
  }

  /// Method to generate HMAC signature for the request body
  String generateHMACSignature(Map<String, dynamic> body) {
    final payload = jsonEncode(body);
    final hmac = Hmac(sha256, utf8.encode(hmacSecret));
    final digest = hmac.convert(utf8.encode(payload));
    return digest.toString();
  }

  /// POST helper
  Future<http.Response> _post(
    String endpoint,
    Map<String, dynamic> body, {
    String? hmacSignature,
  }) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $authToken",
      if (hmacSignature != null) "x-signature": hmacSignature,
    };

    try {
      return await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      log("HTTP Request failed: $e");
      throw Exception("Failed to make POST request: $e");
    }
  }

  /// New secure function call to generate or fetch encryption key
  Future<Uint8List> getEncryptionKeyfromVault(
      Map<String, dynamic> requestBody) async {
    final signature = generateHMACSignature(requestBody);
    print("Signature: $signature");

    int retryCount = 0;
    const maxRetries = 3;

    final url = Uri.parse(
        "$baseUrl/securekey/generateSecureKey"); // full path to function

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $authToken",
      "x-signature": signature,
    };

    print("🔐 Requesting Encryption Key from Vault...");
    print("🔗 URL: $url");
    print("📦 Request Body: ${jsonEncode(requestBody)}");
    print("🛡️ Headers:");
    headers.forEach((key, value) => print("   $key: $value"));

    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(requestBody),
        );

        print("📬 Response Status: ${response.statusCode}");
        print("📬 Response Body: ${response.body}");

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData.containsKey('key')) {
            print("✅ Successfully received encryption key from vault.");
            return base64Decode(responseData['key']);
          } else {
            throw Exception("Key not found in the response body.");
          }
        } else {
          print("❌ Failed to get encryption key: ${response.body}");
          throw Exception(
              "Error: ${response.statusCode} - ${response.reasonPhrase}");
        }
      } catch (e) {
        retryCount++;
        print("⚠️ Attempt $retryCount failed: $e");

        if (retryCount >= maxRetries) {
          print("🛑 Error in getEncryptionKey after $maxRetries attempts: $e");
          throw Exception(
              "Failed to retrieve encryption key after retries: $e");
        }
      }
    }

    throw Exception("Unexpected error in getEncryptionKey.");
  }

  /// Firebase token method (keep if you're using it for other services)
  Future<String> getFirebaseToken(String uid) async {
    final requestBody = {
      "uid": uid,
    };

    try {
      final response = await _post("generateToken", requestBody);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("token generate success ${responseData['token']}");

        return responseData['token'];
      } else {
        log("Failed to get Firebase token: ${response.body}");
        throw Exception(
            "Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      log("Error in getFirebaseToken: $e");
      throw Exception("Failed to retrieve Firebase token: $e");
    }
  }

  void dispose() {
    baseUrl = '';
    hmacSecret = '';
    authToken = '';
    log('ApiService disposed');
  }
}

/// Fetch Firebase Remote Config
Future<Map<String, String>> fetchRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  try {
    await remoteConfig.setDefaults(<String, dynamic>{
      'hmac_secret': 'default-hmac-secret',
      'auth_token': 'default-auth-token',
    });

    await remoteConfig.fetchAndActivate();

    final hmacSecret = remoteConfig.getString('hmac_secret');
    final authToken = remoteConfig.getString('auth_token');

    print('Fetched remote config: $hmacSecret, $authToken');
    return {
      'hmac_secret': hmacSecret,
      'auth_token': authToken,
    };
  } catch (e) {
    throw Exception('Error fetching remote config: $e');
  }
}

enum UserType {
  parent,
  child,
}

class UserSession {
  String? uid;
  Uint8List? secureKey;

  UserSession._privateConstructor();

  static final UserSession _instance = UserSession._privateConstructor();

  static UserSession get instance => _instance;

  void initialize({
    required String uid,
    required Uint8List secureKey,
  }) {
    this.uid = uid;
    this.secureKey = secureKey;
    print("UserSession initialized with: $uid, $secureKey");
  }

  void clear() {
    uid = null;
    secureKey = null;
  }

  void dispose() {
    clear();
    log('UserSession disposed');
  }

  @override
  String toString() {
    return 'UserSession(uid: $uid, secureKey: $secureKey)';
  }
}
