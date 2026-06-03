import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:uuid/uuid.dart';

class PhonePePaymentService {
  static final PhonePePaymentService instance =
  PhonePePaymentService._internal();
  PhonePePaymentService._internal();

  // ─── YOUR TEST CREDENTIALS ───────────────────────────────────────────────
  static const String _clientId      = 'M22MRKS7233WW_2605241310';
  static const String _merchantName  = 'Luxe'; // ← Add your Organization Name here
  static const String _clientVersion = '1';
  static const String _clientSecret  = 'NDI4NmYzYWYtODlhMC00MjQwLTk3ZjYtMjYwNzhiZjg2YmZi'; // ← paste yours
  static const String _environment   = 'SANDBOX';
  static const String _appSchema     = ''; // iOS only, leave empty for Android
  // ─────────────────────────────────────────────────────────────────────────

  // OAuth token cache
  String? _accessToken;
  DateTime? _tokenExpiry;

  bool _isInitialized = false;

  /// Step 1 — Initialize the SDK
  Future<void> _initSdk() async {
    if (_isInitialized) return;
    try {
      debugPrint('PhonePe: Initializing SDK for $_environment...');
      final isInitialized = await PhonePePaymentSdk.init(
        _environment,
        _clientId,
        'cart_flow',
        true,
      ).timeout(const Duration(seconds: 15));
      
      _isInitialized = isInitialized;
      debugPrint('PhonePe: SDK Init result: $_isInitialized');
      if (!_isInitialized) {
        throw Exception('SDK initialization returned false. Please verify your Merchant ID.');
      }
    } catch (e) {
      _isInitialized = false;
      debugPrint('PhonePe: SDK Init Error: $e');
      rethrow;
    }
  }

  /// Step 2 — Get OAuth access token (cached until expiry)
  Future<String> _getAccessToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      debugPrint('PhonePe: Fetching OAuth token...');
      final response = await http.post(
        Uri.parse('https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id'     : _clientId,
          'client_version': _clientVersion,
          'client_secret' : _clientSecret,
          'grant_type'    : 'client_credentials',
        },
      ).timeout(const Duration(seconds: 20));

      debugPrint('PhonePe: Order Response Body: ${response.body}');

      if (response.statusCode != 200) {
        String errorMsg = 'Auth failed (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error_description'] != null) {
            errorMsg += ': ${errorData['error_description']}';
          } else if (errorData['message'] != null) {
            errorMsg += ': ${errorData['message']}';
          }
        } catch (_) {}
        debugPrint('PhonePe: $errorMsg');
        throw Exception(errorMsg);
      }

      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];

      if (_accessToken == null) {
        throw Exception('Access token missing in response');
      }

      final expiresIn = data['expires_in'] ?? 3600;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 300));
      debugPrint('PhonePe: OAuth token obtained successfully.');

      return _accessToken!;
    } catch (e) {
      debugPrint('PhonePe: Auth Error: $e');
      rethrow;
    }
  }

  /// Step 3 — Create payment order and get SDK token
  Future<Map<String, String>> _createOrder({
    required String token,
    required String transactionId,
    required int amountInPaise,
    required String callbackUrl,
  }) async {
    try {
      debugPrint('PhonePe: Creating order $transactionId...');
      final response = await http.post(
        Uri.parse('https://api-preprod.phonepe.com/apis/pg-sandbox/checkout/v2/pay'),
        headers: {
          'Content-Type' : 'application/json',
          'Authorization': 'O-Bearer $token',
        },
        body: jsonEncode({
          'merchantOrderId': transactionId,
          'amount'         : amountInPaise,
          'expireAfter'    : 1200, // seconds
          'metaInfo'       : {
            'udf1': 'cart_payment',
          },
          'paymentFlow': {
            'type'       : 'PG_CHECKOUT',
            'message'    : 'Payment to $_merchantName',
            'merchantId' : _clientId,
          },
        }),
      ).timeout(const Duration(seconds: 20));

      debugPrint('PhonePe: Order Response Body: ${response.body}');

      if (response.statusCode != 200) {
        String errorMsg = 'Order failed (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMsg += ': ${errorData['message']}';
          }
        } catch (_) {}
        debugPrint('PhonePe: $errorMsg');
        throw Exception(errorMsg);
      }

      final data = jsonDecode(response.body);
      
      // Try to extract token from various possible locations in the JSON
      String? sdkToken;
      if (data['sdkToken'] != null) {
        sdkToken = data['sdkToken'].toString();
      } else if (data['token'] != null) {
        sdkToken = data['token'].toString();
      } else if (data['data'] != null && data['data']['sdkToken'] != null) {
        sdkToken = data['data']['sdkToken'].toString();
      } else if (data['redirectUrl'] != null) {
        // Extract token from redirectUrl if present (Common in some PhonePe versions)
        try {
          final uri = Uri.parse(data['redirectUrl'].toString());
          sdkToken = uri.queryParameters['token'];
        } catch (_) {}
      }

      if (sdkToken == null || sdkToken.isEmpty) {
        throw Exception('SDK Token missing. Response: ${response.body}');
      }

      debugPrint('PhonePe: Order created. SDK Token acquired.');
      return {
        'sdkToken'     : sdkToken.toString(),
        'orderId'      : data['orderId']?.toString() ?? transactionId,
      };
    } catch (e) {
      debugPrint('PhonePe: Order Error: $e');
      rethrow;
    }
  }

  /// Main method — call this from CartScreen
  Future<Map<String, dynamic>> startPayment({
    required BuildContext context,
    required double amountInRupees,
    required String userId,
  }) async {
    final transactionId = 'TXN${const Uuid().v4().replaceAll('-', '').substring(0, 18).toUpperCase()}';

    try {
      await _initSdk();

      final amountInPaise = (amountInRupees * 100).toInt();
      const callbackUrl   = 'https://yourapp.com/phonepe/callback';

      final token = await _getAccessToken();

      final order = await _createOrder(
        token        : token,
        transactionId: transactionId,
        amountInPaise: amountInPaise,
        callbackUrl  : callbackUrl,
      );

      final sdkToken = order['sdkToken']!;
      debugPrint('PhonePe: Starting transaction with token...');

      final result = await PhonePePaymentSdk.startTransaction(
        sdkToken,
        _appSchema,
      ).timeout(const Duration(minutes: 5), onTimeout: () {
        debugPrint('PhonePe: Transaction timed out at 5 minutes.');
        return null;
      });

      if (result == null) {
        debugPrint('PhonePe: result is null (User cancelled or Timeout)');
        return {'success': false, 'transactionId': transactionId, 'message': 'Payment cancelled or timed out'};
      }

      debugPrint('PhonePe: Transaction result received: $result');
      final status  = result['status']?.toString() ?? '';
      final success = status == 'SUCCESS';

      return {
        'success'      : success,
        'transactionId': transactionId,
        'orderId'      : order['orderId'],
        'status'       : status,
        'message'      : success ? 'Payment successful' : (result['error']?.toString() ?? 'Payment failed'),
      };
    } catch (e) {
      debugPrint('PhonePe: startPayment caught error: $e');
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }
      return {
        'success': false,
        'transactionId': transactionId,
        'message': message,
      };
    }
  }
}
