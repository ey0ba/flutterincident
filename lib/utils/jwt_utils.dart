// lib/utils/jwt_utils.dart

import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

String? extractInstitutionId(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token');
    }

    final payload = base64Url.normalize(parts[1]); // Extract the payload
    final decoded = utf8.decode(base64Url.decode(payload)); // Decode Base64
    final Map<String, dynamic> payloadMap = json.decode(decoded); // Parse JSON

    return payloadMap['institution_id']?.toString(); // Extract institution_id
  } catch (e) {
    print('Error extracting institution_id: $e');
    return null; // Return null if there's an error
  }
}

void validateToken(String token) {
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  print("Decoded Token: $decodedToken");
}
