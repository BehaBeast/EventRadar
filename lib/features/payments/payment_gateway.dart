import 'dart:convert';

enum PaymentMethod {
  payme,
  click,
  card,
  test,
}

enum PaymentStatus {
  pending,
  success,
  failed,
  cancelled,
}

class PaymentRequest {
  final String orderId;
  final String eventId;
  final String eventTitle;
  final int amount; // in minor units or whole UZS
  final String currency;
  final String buyerEmail;
  final String buyerName;
  final Map<String, dynamic> metadata;

  const PaymentRequest({
    required this.orderId,
    required this.eventId,
    required this.eventTitle,
    required this.amount,
    this.currency = 'UZS',
    required this.buyerEmail,
    required this.buyerName,
    this.metadata = const {},
  });
}

class PaymentResult {
  final bool success;
  final String paymentId;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? redirectUrl;
  final String? errorMessage;
  final DateTime timestamp;

  const PaymentResult({
    required this.success,
    required this.paymentId,
    required this.method,
    required this.status,
    this.redirectUrl,
    this.errorMessage,
    required this.timestamp,
  });
}

abstract class PaymentGateway {
  PaymentMethod get method;
  String get name;
  String get description;

  Future<PaymentResult> processPayment(PaymentRequest request);
  Future<PaymentStatus> checkStatus(String paymentId);
}

/// Payme Payment Gateway Adapter (Payme Business Merchant API)
class PaymeGateway implements PaymentGateway {
  final String merchantId;
  final bool testMode;

  const PaymeGateway({
    this.merchantId = '66f5e1234567890abcdef123',
    this.testMode = true,
  });

  @override
  PaymentMethod get method => PaymentMethod.payme;

  @override
  String get name => 'Payme';

  @override
  String get description => 'Оплата через Payme (Uzcard / Humo / Visa)';

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // Official Payme Merchant Checkout Link construction:
    // Amount in tiyins (1 UZS = 100 tiyins)
    final amountInTiyin = request.amount * 100;
    final params = 'm=$merchantId;ac.order_id=${request.orderId};a=$amountInTiyin;c=https://eventradar.uz/payment/callback';
    final base64Params = base64Url.encode(utf8.encode(params));
    final checkoutUrl = testMode
        ? 'https://test.paycom.uz/$base64Params'
        : 'https://checkout.paycom.uz/$base64Params';

    // Simulate network delay for verification
    await Future.delayed(const Duration(milliseconds: 600));

    final paymentId = 'payme_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}';
    return PaymentResult(
      success: true,
      paymentId: paymentId,
      method: PaymentMethod.payme,
      status: PaymentStatus.success,
      redirectUrl: checkoutUrl,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PaymentStatus> checkStatus(String paymentId) async {
    return PaymentStatus.success;
  }
}

/// Click Payment Gateway Adapter (Click Merchant API)
class ClickGateway implements PaymentGateway {
  final String serviceId;
  final String merchantId;
  final bool testMode;

  const ClickGateway({
    this.serviceId = '34567',
    this.merchantId = '23456',
    this.testMode = true,
  });

  @override
  PaymentMethod get method => PaymentMethod.click;

  @override
  String get name => 'Click';

  @override
  String get description => 'Оплата через Click Up / Click Evolution';

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // Official Click Payment Link construction:
    final checkoutUrl =
        'https://my.click.uz/services/pay?service_id=$serviceId&merchant_id=$merchantId&amount=${request.amount}&transaction_param=${request.orderId}&return_url=https://eventradar.uz/click/return';

    await Future.delayed(const Duration(milliseconds: 600));

    final paymentId = 'click_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}';
    return PaymentResult(
      success: true,
      paymentId: paymentId,
      method: PaymentMethod.click,
      status: PaymentStatus.success,
      redirectUrl: checkoutUrl,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PaymentStatus> checkStatus(String paymentId) async {
    return PaymentStatus.success;
  }
}

/// Bank Card / Uzcard / Humo / Visa / Mastercard Gateway
class CardGateway implements PaymentGateway {
  final bool testMode;

  const CardGateway({this.testMode = true});

  @override
  PaymentMethod get method => PaymentMethod.card;

  @override
  String get name => 'Банковская карта';

  @override
  String get description => 'Uzcard, Humo, Visa, Mastercard';

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final paymentId = 'card_${request.orderId}_${DateTime.now().millisecondsSinceEpoch}';
    return PaymentResult(
      success: true,
      paymentId: paymentId,
      method: PaymentMethod.card,
      status: PaymentStatus.success,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PaymentStatus> checkStatus(String paymentId) async {
    return PaymentStatus.success;
  }
}

/// Deterministic Test Gateway for sandbox / verification
class TestGateway implements PaymentGateway {
  const TestGateway();

  @override
  PaymentMethod get method => PaymentMethod.test;

  @override
  String get name => 'Тестовый шлюз';

  @override
  String get description => 'Мгновенное тестирование оплаты без списания средств';

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final paymentId = 'test_tx_${DateTime.now().millisecondsSinceEpoch}';
    return PaymentResult(
      success: true,
      paymentId: paymentId,
      method: PaymentMethod.test,
      status: PaymentStatus.success,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PaymentStatus> checkStatus(String paymentId) async {
    return PaymentStatus.success;
  }
}

