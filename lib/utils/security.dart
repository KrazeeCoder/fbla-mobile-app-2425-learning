import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/encryption_service.dart'; // Your EncryptionService and UserSession implementation

// Set user keys after login
Future<void> setLoginUserKeys(User user) async {
  String? token = await user.getIdToken();
  final encryptionService = EncryptionService.instance;

  final requestBodyForKey = {'token': token};

  final encryptionKey =
      await encryptionService.getEncryptionKeyfromVault(requestBodyForKey);

  UserSession.instance.initialize(
    uid: user.uid,
    secureKey: encryptionKey,
  );
}

// Generate secure random key
Uint8List generateSecureRandomKey(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

// AES-CBC decryption (if needed)
Uint8List decryptData(Uint8List data, Uint8List key, Uint8List iv) {
  if (![16, 24, 32].contains(key.length)) {
    throw ArgumentError('Invalid AES key size. Must be 16, 24, or 32 bytes.');
  }
  if (iv.length != 16) {
    throw ArgumentError('Invalid IV size. Must be 16 bytes.');
  }

  try {
    final cipher = PaddedBlockCipher('AES/CBC/PKCS7')
      ..init(
        false,
        PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(key), iv),
          null,
        ),
      );

    return cipher.process(data);
  } catch (e) {
    throw Exception('Decryption failed: $e');
  }
}

Uint8List generateIV() {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
}

// Get encryption key for parent/child user
Future<Uint8List> getEncryptionKey() async {
  final session = UserSession.instance;

  Uint8List? storedKey = session.secureKey;
  if (storedKey == null) {
    throw Exception('No secure key found in session.');
  }
  return storedKey;
}

// AES-GCM Encryption
Uint8List aesGcmEncrypt(Uint8List data, Uint8List key, Uint8List iv) {
  final encrypter = encrypt.Encrypter(encrypt.AES(
    encrypt.Key(key),
    mode: encrypt.AESMode.gcm,
  ));
  final encrypted = encrypter.encryptBytes(data, iv: encrypt.IV(iv));
  return encrypted.bytes;
}

// AES-GCM Decryption
Uint8List aesGcmDecrypt(Uint8List encryptedData, Uint8List key, Uint8List iv) {
  final encrypter = encrypt.Encrypter(encrypt.AES(
    encrypt.Key(key),
    mode: encrypt.AESMode.gcm,
  ));
  return Uint8List.fromList(encrypter.decryptBytes(
    encrypt.Encrypted(encryptedData),
    iv: encrypt.IV(iv),
  ));
}

// Encrypt a single text value with a random IV
Future<Map<String, String>> encryptTextWithIV(String text) async {
  Uint8List key = await getEncryptionKey();
  Uint8List iv = generateIV();

  Uint8List textBytes = Uint8List.fromList(utf8.encode(text));
  Uint8List encryptedBytes = aesGcmEncrypt(textBytes, key, iv);

  return {
    'text': base64Encode(encryptedBytes),
    'iv': base64Encode(iv),
  };
}

// Encrypt user details
Future<Map<String, String>> encryptUserInfoWithIV(
  String userId,
  String email,
  String firstname,
  String lastname,
  String profilepic,
) async {
  Uint8List key = await getEncryptionKey();
  Uint8List iv = generateIV();

  Map<String, String> encryptedData = {};

  print("Encrypting user data for $userId");
  print("encryption key: ${base64Encode(key)}");
  print("profilepic tpo encyrpt: $profilepic");

  encryptedData['email'] =
      base64Encode(aesGcmEncrypt(utf8.encode(email), key, iv));
  encryptedData['firstname'] =
      base64Encode(aesGcmEncrypt(utf8.encode(firstname), key, iv));
  encryptedData['lastname'] =
      base64Encode(aesGcmEncrypt(utf8.encode(lastname), key, iv));
  encryptedData['profilePic'] =
      base64Encode(aesGcmEncrypt(utf8.encode(profilepic), key, iv));
  encryptedData['iv'] = base64Encode(iv);
  print("Encrypted data: $encryptedData");

  return encryptedData;
}

Future<Map<String, String>?> decryptUserDetails(String userId) async {
  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map<String, dynamic>?;
    if (userData == null) return null;

    print("User data: $userData");

    String? encodedIV = userData['iv'];
    Uint8List key = await getEncryptionKey();

    print("Decrypting user data for $userId");
    print("Encryption key: ${base64Encode(key)}");

    Map<String, String> decryptedDetails = {};

    // Helper to safely decode and decrypt
    String safeDecrypt(String? base64String, Uint8List key, Uint8List iv) {
      if (base64String == null || base64String.trim().isEmpty) return '';
      try {
        return utf8.decode(
          aesGcmDecrypt(base64Decode(base64String), key, iv),
        );
      } catch (e) {
        print("⚠️ Error decrypting field: $e");
        return '';
      }
    }

    if (encodedIV == null || encodedIV.trim().isEmpty) {
      // Unencrypted fallback
      decryptedDetails['email'] = userData['email'] ?? '';
      decryptedDetails['firstname'] = userData['firstName'] ?? '';
      decryptedDetails['lastname'] = userData['lastName'] ?? '';
      decryptedDetails['profilePic'] =
          userData['settings']?['profilePic'] ?? '';
    } else {
      Uint8List iv = base64Decode(encodedIV);

      decryptedDetails['email'] = safeDecrypt(userData['email'], key, iv);
      decryptedDetails['firstname'] =
          safeDecrypt(userData['firstName'], key, iv);
      decryptedDetails['lastname'] = safeDecrypt(userData['lastName'], key, iv);

      final profilePicEncrypted = userData['settings']?['profilePic'];
      decryptedDetails['profilePic'] =
          safeDecrypt(profilePicEncrypted, key, iv);
      print("Decrypted data: $decryptedDetails['profilePic'] ");
    }

    return decryptedDetails;
  } catch (e) {
    print("❌ Error decrypting user data: $e");
    return null;
  }
}
