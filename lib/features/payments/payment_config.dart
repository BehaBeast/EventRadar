import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/settings.dart';
import 'payment_gateway.dart';

class PaymentSettings {
  final bool testMode;
  final String paymeMerchantId;
  final String clickServiceId;
  final String clickMerchantId;
  final String stripePublishableKey;
  final PaymentMethod defaultMethod;
  final bool isPaymeConnected;
  final bool isClickConnected;
  final bool isCardConnected;

  const PaymentSettings({
    this.testMode = true,
    this.paymeMerchantId = '66f5e1234567890abcdef123',
    this.clickServiceId = '34567',
    this.clickMerchantId = '23456',
    this.stripePublishableKey = 'pk_test_sample',
    this.defaultMethod = PaymentMethod.payme,
    this.isPaymeConnected = true,
    this.isClickConnected = true,
    this.isCardConnected = true,
  });

  PaymentSettings copyWith({
    bool? testMode,
    String? paymeMerchantId,
    String? clickServiceId,
    String? clickMerchantId,
    String? stripePublishableKey,
    PaymentMethod? defaultMethod,
    bool? isPaymeConnected,
    bool? isClickConnected,
    bool? isCardConnected,
  }) {
    return PaymentSettings(
      testMode: testMode ?? this.testMode,
      paymeMerchantId: paymeMerchantId ?? this.paymeMerchantId,
      clickServiceId: clickServiceId ?? this.clickServiceId,
      clickMerchantId: clickMerchantId ?? this.clickMerchantId,
      stripePublishableKey: stripePublishableKey ?? this.stripePublishableKey,
      defaultMethod: defaultMethod ?? this.defaultMethod,
      isPaymeConnected: isPaymeConnected ?? this.isPaymeConnected,
      isClickConnected: isClickConnected ?? this.isClickConnected,
      isCardConnected: isCardConnected ?? this.isCardConnected,
    );
  }

  Map<String, dynamic> toJson() => {
    'testMode': testMode,
    'paymeMerchantId': paymeMerchantId,
    'clickServiceId': clickServiceId,
    'clickMerchantId': clickMerchantId,
    'stripePublishableKey': stripePublishableKey,
    'defaultMethod': defaultMethod.name,
    'isPaymeConnected': isPaymeConnected,
    'isClickConnected': isClickConnected,
    'isCardConnected': isCardConnected,
  };

  factory PaymentSettings.fromJson(Map<String, dynamic> json) =>
      PaymentSettings(
        testMode: json['testMode'] as bool? ?? true,
        paymeMerchantId: json['paymeMerchantId'] as String? ?? '66f5e1234567890abcdef123',
        clickServiceId: json['clickServiceId'] as String? ?? '34567',
        clickMerchantId: json['clickMerchantId'] as String? ?? '23456',
        stripePublishableKey: json['stripePublishableKey'] as String? ?? 'pk_test_sample',
        defaultMethod: PaymentMethod.values.firstWhere(
          (m) => m.name == json['defaultMethod'],
          orElse: () => PaymentMethod.payme,
        ),
        isPaymeConnected: json['isPaymeConnected'] as bool? ?? true,
        isClickConnected: json['isClickConnected'] as bool? ?? true,
        isCardConnected: json['isCardConnected'] as bool? ?? true,
      );
}

class PaymentConfigNotifier extends Notifier<PaymentSettings> {
  static const _storageKey = 'eventradar_payment_settings';

  @override
  PaymentSettings build() {
    final prefs = ref.watch(preferencesProvider);
    final saved = prefs.getString(_storageKey);
    if (saved != null) {
      try {
        return PaymentSettings.fromJson(jsonDecode(saved) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const PaymentSettings();
  }

  Future<void> updateSettings(PaymentSettings newSettings) async {
    state = newSettings;
    final prefs = ref.read(preferencesProvider);
    await prefs.setString(_storageKey, jsonEncode(newSettings.toJson()));
  }

  PaymentGateway getGateway(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.payme:
        return PaymeGateway(
          merchantId: state.paymeMerchantId,
          testMode: state.testMode,
        );
      case PaymentMethod.click:
        return ClickGateway(
          serviceId: state.clickServiceId,
          merchantId: state.clickMerchantId,
          testMode: state.testMode,
        );
      case PaymentMethod.card:
        return CardGateway(testMode: state.testMode);
      case PaymentMethod.test:
        return const TestGateway();
    }
  }
}

final paymentConfigProvider =
    NotifierProvider<PaymentConfigNotifier, PaymentSettings>(
      PaymentConfigNotifier.new,
    );

