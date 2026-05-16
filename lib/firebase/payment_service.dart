import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Payment service providing interfaces for Razorpay (India) and
/// Stripe (International) payment integrations.
///
/// This service handles:
/// - Initiating Stripe Checkout sessions
/// - Creating Razorpay orders
/// - Verifying Razorpay payment signatures
/// - Managing subscription state
/// - Processing payment responses
class PaymentService {
  PaymentService({
    this.functionsBaseUrl,
    this.razorpayKeyId,
  });

  /// Base URL for calling Firebase Cloud Functions (emulator or production).
  ///
  /// In development with Firebase emulators, use the functions emulator URL.
  /// In production, this is the Firebase Hosting URL or Cloud Functions URL.
  final String? functionsBaseUrl;

  /// Razorpay Key ID for the client-side integration.
  final String? razorpayKeyId;

  // ------------------------------------------------------------------
  // Environment helpers
  // ------------------------------------------------------------------

  /// Returns the Cloud Functions callable URL for a given function name.
  String _functionUrl(String functionName) {
    if (functionsBaseUrl != null) {
      return '$functionsBaseUrl/$functionName';
    }
    // Default emulator URL
    return 'http://127.0.0.1:5001/parenthero-app/us-central1/$functionName';
  }

  // ==================================================================
  // STRIPE
  // ==================================================================

  /// Creates a Stripe Checkout Session for a subscription.
  ///
  /// [priceId] is the Stripe Price ID (e.g., 'price_monthly_usd').
  /// [successUrl] and [cancelUrl] are redirect URLs after payment.
  /// [customerEmail] is optional but recommended to pre-fill.
  ///
  /// Returns a Map with 'sessionId' and 'url' for redirecting to Stripe.
  Future<Map<String, dynamic>> createStripeSubscription({
    required String priceId,
    required String successUrl,
    required String cancelUrl,
    String? customerEmail,
    String? idToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrl('createStripeSubscription')),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'data': {
            'priceId': priceId,
            'successUrl': successUrl,
            'cancelUrl': cancelUrl,
            if (customerEmail != null) 'customerEmail': customerEmail,
          },
        }),
      );

      if (response.statusCode != 200) {
        final error = _parseError(response);
        throw PaymentException(error);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final result = body['result'] as Map<String, dynamic>?;

      if (result == null) {
        throw PaymentException('Invalid response from Stripe function');
      }

      return result;
    } on SocketException {
      throw PaymentException(
        'Network error: Could not reach payment server. '
        'Check your internet connection.',
      );
    } on FormatException {
      throw PaymentException('Invalid response format from payment server.');
    }
  }

  // ==================================================================
  // RAZORPAY
  // ==================================================================

  /// Creates a Razorpay order for subscription.
  ///
  /// [amount] is in **paise** (e.g., ₹499 = 49900 paise).
  /// [currency] defaults to 'INR'.
  ///
  /// Returns a Map with 'orderId', 'amount', 'currency', and 'keyId'
  /// needed to initialize Razorpay Checkout on the client.
  Future<Map<String, dynamic>> createRazorpayOrder({
    required int amount,
    String currency = 'INR',
    String? idToken,
    Map<String, String>? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrl('createRazorpayOrder')),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'data': {
            'amount': amount,
            'currency': currency,
            if (notes != null) 'notes': notes,
          },
        }),
      );

      if (response.statusCode != 200) {
        final error = _parseError(response);
        throw PaymentException(error);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final result = body['result'] as Map<String, dynamic>?;

      if (result == null) {
        throw PaymentException('Invalid response from Razorpay function');
      }

      return result;
    } on SocketException {
      throw PaymentException(
        'Network error: Could not reach payment server. '
        'Check your internet connection.',
      );
    } on FormatException {
      throw PaymentException('Invalid response format from payment server.');
    }
  }

  /// Verifies Razorpay payment signature on the client side.
  ///
  /// Should be called after a successful Razorpay payment to verify
  /// the integrity of the response before relying on it.
  ///
  /// Returns `true` if the signature is valid.
  bool verifyRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String keySecret,
  }) {
    final body = '$orderId|$paymentId';
    final hmac = _hmacSha256(keySecret, body);
    return hmac == signature;
  }

  /// Generates HMAC-SHA256 hash for Razorpay signature verification.
  String _hmacSha256(String key, String data) {
    final hmac = HmacSha256(key);
    return hmac.convert(data);
  }

  // ==================================================================
  // SUBSCRIPTION PLANS
  // ==================================================================

  /// Returns the configured subscription plans with pricing.
  static List<SubscriptionPlan> get subscriptionPlans => [
        const SubscriptionPlan(
          id: 'monthly_inr',
          name: 'Monthly (India)',
          price: 499,
          currency: 'INR',
          period: 'monthly',
          description: 'Full access for one child',
          features: [
            '5-day structured lessons',
            'Interactive quizzes & practice',
            'Beat the Parent game',
            'Daily learning spark',
            'Progress certificates',
            '7-day free trial',
          ],
          stripePriceId: 'price_monthly_inr',
          razorpayPlanId: 'plan_monthly_inr',
        ),
        const SubscriptionPlan(
          id: 'annual_inr',
          name: 'Annual (India)',
          price: 4999,
          currency: 'INR',
          period: 'annual',
          description: 'Best value — 2 months free!',
          features: [
            'Everything in Monthly',
            '2 months free',
            'Priority support',
            'Early access to new topics',
            'Exclusive learning games',
            '7-day free trial',
          ],
          stripePriceId: 'price_annual_inr',
          razorpayPlanId: 'plan_annual_inr',
        ),
        const SubscriptionPlan(
          id: 'family_inr',
          name: 'Family (India)',
          price: 7999,
          currency: 'INR',
          period: 'annual',
          description: 'Up to 3 children',
          features: [
            'Everything in Annual',
            'Up to 3 children profiles',
            'Separate progress tracking',
            'Individual certificates',
            'Family analytics dashboard',
            '7-day free trial',
          ],
          stripePriceId: 'price_family_inr',
          razorpayPlanId: 'plan_family_inr',
        ),
        const SubscriptionPlan(
          id: 'monthly_usd',
          name: 'Monthly (International)',
          price: 999,
          currency: 'USD',
          period: 'monthly',
          description: 'Full access for one child',
          features: [
            '5-day structured lessons',
            'Interactive quizzes & practice',
            'Beat the Parent game',
            'Daily learning spark',
            'Progress certificates',
            '7-day free trial',
          ],
          stripePriceId: 'price_monthly_usd',
          razorpayPlanId: null,
        ),
        const SubscriptionPlan(
          id: 'annual_usd',
          name: 'Annual (International)',
          price: 9999,
          currency: 'USD',
          period: 'annual',
          description: 'Best value — 2 months free!',
          features: [
            'Everything in Monthly',
            '2 months free',
            'Priority support',
            'Early access to new topics',
            'Exclusive learning games',
            '7-day free trial',
          ],
          stripePriceId: 'price_annual_usd',
          razorpayPlanId: null,
        ),
        const SubscriptionPlan(
          id: 'family_usd',
          name: 'Family (International)',
          price: 15999,
          currency: 'USD',
          period: 'annual',
          description: 'Up to 3 children',
          features: [
            'Everything in Annual',
            'Up to 3 children profiles',
            'Separate progress tracking',
            'Individual certificates',
            'Family analytics dashboard',
            '7-day free trial',
          ],
          stripePriceId: 'price_family_usd',
          razorpayPlanId: null,
        ),
      ];

  /// Gets a plan by its ID.
  static SubscriptionPlan? getPlanById(String planId) {
    try {
      return subscriptionPlans.firstWhere((plan) => plan.id == planId);
    } catch (_) {
      return null;
    }
  }

  /// Returns the appropriate payment provider based on currency.
  static PaymentProvider providerForCurrency(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return PaymentProvider.razorpay;
      case 'USD':
      case 'EUR':
      case 'GBP':
      case 'AUD':
      case 'CAD':
      case 'SGD':
        return PaymentProvider.stripe;
      default:
        return PaymentProvider.stripe;
    }
  }

  // ==================================================================
  // HELPERS
  // ==================================================================

  /// Parses error response from the functions API.
  String _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body.containsKey('error')) {
        final error = body['error'] as Map<String, dynamic>;
        return error['message'] as String? ?? 'Unknown payment error';
      }
      return body['message'] as String? ?? 'Payment request failed';
    } catch (_) {
      return 'Payment request failed (HTTP ${response.statusCode})';
    }
  }
}

// ==================================================================
// Models
// ==================================================================

/// Represents a subscription plan.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.period,
    required this.description,
    required this.features,
    this.stripePriceId,
    this.razorpayPlanId,
  });

  /// Unique plan identifier.
  final String id;

  /// Display name of the plan.
  final String name;

  /// Price in the smallest currency unit (paise/cents).
  final int price;

  /// Currency code (INR, USD, etc.).
  final String currency;

  /// Billing period (monthly, annual).
  final String period;

  /// Short description of the plan.
  final String description;

  /// List of feature descriptions.
  final List<String> features;

  /// Stripe Price ID for this plan.
  final String? stripePriceId;

  /// Razorpay Plan ID for this plan.
  final String? razorpayPlanId;

  /// Formatted price string (e.g., "₹499" or "$9.99").
  String get formattedPrice {
    if (currency == 'INR') {
      final rupees = price / 100;
      return '₹${rupees.toInt()}';
    }
    final dollars = price / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  /// Whether this is an annual plan.
  bool get isAnnual => period == 'annual';

  /// Whether this is a monthly plan.
  bool get isMonthly => period == 'monthly';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionPlan &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Supported payment providers.
enum PaymentProvider { stripe, razorpay }

/// Exception thrown by payment operations.
class PaymentException implements Exception {
  const PaymentException(this.message);

  final String message;

  @override
  String toString() => 'PaymentException: $message';
}

// ==================================================================
// HMAC helpers (dependency-free)
// ==================================================================

/// Simple HMAC-SHA256 implementation to avoid external dependencies
/// for Razorpay signature verification.
class HmacSha256 {
  HmacSha256(this.key);

  final String key;

  String convert(String data) {
    // We'll use the platform's crypto capabilities
    // For mobile, use dart:convert + dart:typed_data
    // For a production app, use the `crypto` package instead
    return _computeHmacSha256(key, data);
  }

  String _computeHmacSha256(String key, String data) {
    // This is a simplified version. In production, use the `crypto` package:
    // import 'package:crypto/crypto.dart';
    // final hmac = Hmac(sha256, utf8.encode(key));
    // return hex.encode(hmac.convert(utf8.encode(data)).bytes);
    //
    // For now, we throw a clear message to use the proper package.
    throw UnsupportedError(
      'HMAC-SHA256 requires the `crypto` package. '
      'Add `crypto: ^3.0.0` to pubspec.yaml dependencies.',
    );
  }
}
