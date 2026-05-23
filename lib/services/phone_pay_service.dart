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
    await PhonePePaymentSdk.init(
      _environment,
      _clientId,   // merchantId = clientId in new API
      'cart_flow',
      true,
    );
    _isInitialized = true;
  }

  /// Step 2 — Get OAuth access token (cached until expiry)
  Future<String> _getAccessToken() async {
    // Return cached token if still valid
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    final response = await http.post(
      Uri.parse('https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id'     : _clientId,
        'client_version': _clientVersion,
        'client_secret' : _clientSecret,
        'grant_type'    : 'client_credentials',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('PhonePe auth failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    _accessToken = data['access_token'];

    // Token usually expires in 1 hour — cache for 55 mins to be safe
    final expiresIn = data['expires_in'] ?? 3600;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 300));

    return _accessToken!;
  }

  /// Step 3 — Create payment order and get SDK token
  Future<Map<String, String>> _createOrder({
    required String token,
    required String transactionId,
    required int amountInPaise,
    required String callbackUrl,
  }) async {
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
          'message'    : 'Cart Payment',
          'merchantId' : _clientId,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Order creation failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    // Returns sdkToken to pass to startTransaction
    return {
      'sdkToken'     : data['sdkToken'] ?? data['token'] ?? '',
      'orderId'      : data['orderId']  ?? transactionId,
    };
  }

  /// Main method — call this from CartScreen
  Future<Map<String, dynamic>> startPayment({
    required BuildContext context,
    required double amountInRupees,
    required String userId,
  }) async {
    await _initSdk();

    final transactionId = 'TXN${const Uuid().v4().replaceAll('-', '').substring(0, 18).toUpperCase()}';
    final amountInPaise = (amountInRupees * 100).toInt();
    const callbackUrl   = 'https://yourapp.com/phonepe/callback';

    try {
      // 1. Get OAuth token
      final token = await _getAccessToken();

      // 2. Create order → get SDK token
      final order = await _createOrder(
        token        : token,
        transactionId: transactionId,
        amountInPaise: amountInPaise,
        callbackUrl  : callbackUrl,
      );

      final sdkToken = order['sdkToken']!;

      if (sdkToken.isEmpty) {
        return {'success': false, 'transactionId': transactionId, 'message': 'Failed to get SDK token'};
      }

      // 3. Launch PhonePe payment UI
      final result = await PhonePePaymentSdk.startTransaction(
        sdkToken,
        _appSchema,
      );

      if (result == null) {
        return {'success': false, 'transactionId': transactionId, 'message': 'Payment cancelled'};
      }

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
      return {'success': false, 'transactionId': transactionId, 'message': 'Error: $e'};
    }
  }
}
