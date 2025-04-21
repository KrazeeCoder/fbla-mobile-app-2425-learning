import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:typed_data';

// This service is for HMAC signing and securing keys
class EncryptionService {
  String baseUrl;
  String hmacSecret;
  String authToken;

  // Using private named constructors for Singleton pattern
  EncryptionService._privateConstructor({
    required this.baseUrl,
    required this.hmacSecret,
    required this.authToken,
  });

  // Instance of the singleton
  static final EncryptionService _instance =
      EncryptionService._privateConstructor(
    baseUrl: 'https://us-central1-voxigo.cloudfunctions.net/secureKeyServer',
    hmacSecret: 'default-hmac-secret',
    authToken: 'default-auth-token',
  );

  // Gets the instance of the singleton
  static EncryptionService get instance => _instance;

  // Initializes the instance and loads remote config
  static Future<EncryptionService> initialize({bool force = false}) async {
    try {
      final configValues = await fetchRemoteConfig();
      _instance.baseUrl =
          "https://us-central1-voxigo.cloudfunctions.net/secureKeyServer";
      _instance.hmacSecret =
          configValues['hmac_secret'] ?? 'default-hmac-secret';
      _instance.authToken = configValues['auth_token'] ?? 'default-auth-token';
    } catch (e) {
      // Use defaults if we couldn't fetch config
      _instance.baseUrl =
          "https://us-central1-voxigo.cloudfunctions.net/secureKeyServer";
      _instance.hmacSecret = 'default-hmac-secret';
      _instance.authToken = 'default-auth-token';
    }

    return _instance;
  }

  // Generates HMAC SHA-256 signature
  String generateHMACSignature
      (Map<String, dynamic> body) {
    final payload = jsonEncode(body);
    final hmac = Hmac(sha256, utf8.encode(hmacSecret));
    final digest = hmac.convert(utf8.encode(payload));
    return digest.toString();
  }

  // Sends a POST request with the HMAC signature
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

  // Retrieves encryption key from the vault, retrying on failure.
  Future<Uint8List> getEncryptionKeyfromVault(
      Map<String, dynamic> requestBody) async {
    final signature = generateHMACSignature(requestBody);

    int retryCount = 0;
    const maxRetries = 3;

    final url = Uri.parse("$baseUrl/securekey/generateSecureKey");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $authToken",
      "x-signature": signature,
    };

    headers.forEach((key, value) => print("   $key: $value"));

    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData.containsKey('key')) {
            return base64Decode(responseData['key']);
          } else {
            throw Exception("Key not found in the response body.");
          }
        } else {
          throw Exception(
              "Error: ${response.statusCode} - ${response.reasonPhrase}");
        }
      } catch (e) {
        retryCount++;

        if (retryCount >= maxRetries) {
          throw Exception(
              "Failed to retrieve encryption key after retries: $e");
        }
      }
    }

    throw Exception("Unexpected error in getEncryptionKey.");
  }

  // Retrieves a Firebase custom auth token for the receieved user ID
  Future<String> getFirebaseToken(String uid) async {
    final requestBody = {
      "uid": uid,
    };

    try {
      final response = await _post("generateToken", requestBody);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return responseData['token'];
      } else {
        throw Exception(
            "Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("Failed to retrieve Firebase token: $e");
    }
  }

  // Clears stored credentials.
  void dispose() {
    baseUrl = '';
    hmacSecret = '';
    authToken = '';
    log('EncryptionService disposed');
  }
}

// Fetches remote configuration parameters.
// Returns a map with 'hmac_secret' and 'auth_token' values
Future<Map<String, String>> fetchRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  try {
    // Initialize remote config defaults and settings
    await remoteConfig.setDefaults(<String, dynamic>{
      'hmac_secret': 'default-hmac-secret',
      'auth_token': 'default-auth-token',
    });

    // Configure fetch and activation settings
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Warning: Failed to fetch remote config: $e');
      // Continue with defaults
    }

    // Safely get strings with fallbacks
    final hmacSecret = remoteConfig.getString('hmac_secret');
    final authToken = remoteConfig.getString('auth_token');

    // Make sure we're returning valid strings
    return {
      'hmac_secret': hmacSecret.isNotEmpty ? hmacSecret : 'default-hmac-secret',
      'auth_token': authToken.isNotEmpty ? authToken : 'default-auth-token',
    };
  } catch (e) {
    print('Error in fetchRemoteConfig: $e');
    // On error, log and fallback to defaults
    return {
      'hmac_secret': 'default-hmac-secret',
      'auth_token': 'default-auth-token',
    };
  }
}

/// User roles supported by the application.
enum UserType {
  parent,
  child,
}

/// Manages current user session and stores secure key.
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
  }

  void clear() {
    uid = null;
    secureKey = null;
  }

  void dispose() {
    clear();
  }

  @override
  String toString() {
    return 'UserSession(uid: $uid, secureKey: $secureKey)';
  }
}
