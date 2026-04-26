import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emulator cannot access host localhost via 127.0.0.1.
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // 1. Verify Age Proof
  Future<Map<String, dynamic>> verifyAge(Map<String, dynamic> proof, List<dynamic> publicSignals) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-age'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'proof': proof,
        'publicSignals': publicSignals,
      }),
    );
    return _processResponse(response);
  }

  // 2. Grant Consent
  Future<Map<String, dynamic>> grantConsent({
    required String userDid,
    required String purposeTag,
    required Map<String, dynamic> dataFields,
    required int ttlSeconds,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/grant-consent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_did': userDid,
        'purpose_tag': purposeTag,
        'data_fields': dataFields,
        'ttl_seconds': ttlSeconds,
      }),
    );
    return _processResponse(response);
  }

  // 3. Revoke Consent
  Future<Map<String, dynamic>> revokeConsent(String consentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/revoke-consent/$consentId'),
      headers: {'Content-Type': 'application/json'},
    );
    return _processResponse(response);
  }

  // 4. Get Consent Status
  Future<Map<String, dynamic>> getConsentStatus(String did) async {
    final response = await http.get(
      Uri.parse('$baseUrl/consent/status?did=$did'),
    );
    return _processResponse(response);
  }

  // 5. Get Marketplace Requests
  Future<List<dynamic>> getMarketplaceRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/marketplace/requests'),
    ).timeout(const Duration(seconds: 12));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List<dynamic>) {
        return decoded;
      }
      if (decoded is Map<String, dynamic> && decoded['data'] is List<dynamic>) {
        return decoded['data'] as List<dynamic>;
      }
      throw Exception('Unexpected marketplace response shape');
    } else {
      throw Exception('Failed to load marketplace requests: ${response.statusCode}');
    }
  }

  // 6. Respond to Marketplace Request
  Future<Map<String, dynamic>> respondToMarketplaceRequest({
    required String requestId,
    required String userDid,
    required Map<String, dynamic> providedData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/marketplace/respond'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'request_id': requestId,
        'user_did': userDid,
        'provided_data': providedData,
      }),
    );
    return _processResponse(response);
  }

  // 7. Wallet Status
  Future<Map<String, dynamic>> getWalletStatus(String did) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/status?did=$did'),
    );
    return _processResponse(response);
  }

  // 8. Compliance Scan
  Future<Map<String, dynamic>> scanCompliance(String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/compliance/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );
    return _processResponse(response);
  }

  // 9. Debug Endpoint
  Future<Map<String, dynamic>> getDebugStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/debug-prism'),
    );
    return _processResponse(response);
  }

  // 10. Identity Document Scan
  Future<Map<String, dynamic>> scanIdentityDocument({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/scan-identity-document'),
    );
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response);
  }

  // 11. Onboard User
  Future<Map<String, dynamic>> onboardUser(String did) async {
    final response = await http.post(
      Uri.parse('$baseUrl/onboard?did=$did'),
      headers: {'Content-Type': 'application/json'},
    );
    return _processResponse(response);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}