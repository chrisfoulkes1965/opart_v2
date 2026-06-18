import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:opart_v2/config/stripe_config.dart';
import 'package:opart_v2/print/models/print_models.dart';

class StripeService {
  StripeService._();

  static bool _initialized = false;

  static bool get isConfigured => StripeConfig.isConfigured;

  static Future<void> initialize() async {
    if (_initialized || !StripeConfig.isConfigured) {
      return;
    }

    Stripe.publishableKey = StripeConfig.publishableKey;
    if (StripeConfig.appleMerchantId.isNotEmpty) {
      Stripe.merchantIdentifier = StripeConfig.appleMerchantId;
    }
    await Stripe.instance.applySettings();
    _initialized = true;
  }

  static Future<void> presentPaymentSheet({
    required CheckoutSession checkout,
    required ShippingAddress estimateAddress,
    PrintEstimate? estimate,
  }) async {
    if (!isConfigured) {
      throw StateError('Stripe is not configured for this build.');
    }

    if (!_initialized) {
      await initialize();
    }

    final applePay = StripeConfig.appleMerchantId.isNotEmpty
        ? PaymentSheetApplePay(
            merchantCountryCode: estimateAddress.countryCode,
            cartItems: _applePayItems(checkout, estimate),
          )
        : null;

    final googlePay = StripeConfig.googlePayEnabled
        ? PaymentSheetGooglePay(
            merchantCountryCode: estimateAddress.countryCode,
            currencyCode: checkout.currencyCode.toUpperCase(),
            testEnv: kDebugMode || StripeConfig.googlePayTestEnv,
          )
        : null;

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: checkout.clientSecret,
        merchantDisplayName: 'OpArt Lab',
        billingDetails: BillingDetails(
          address: Address(
            city: '',
            country: estimateAddress.countryCode,
            line1: '',
            line2: '',
            postalCode: estimateAddress.zip,
            state: '',
          ),
        ),
        billingDetailsCollectionConfiguration:
            const BillingDetailsCollectionConfiguration(
          name: CollectionMode.always,
          email: CollectionMode.always,
          phone: CollectionMode.automatic,
          address: AddressCollectionMode.full,
        ),
        applePay: applePay,
        googlePay: googlePay,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }

  static List<ApplePayCartSummaryItem> _applePayItems(
    CheckoutSession checkout,
    PrintEstimate? estimate,
  ) {
    if (estimate == null) {
      return [
        ApplePayCartSummaryItem.immediate(
          label: 'OpArt Lab',
          amount:
              _formatAmount(checkout.retailTotalCents, checkout.currencyCode),
        ),
      ];
    }

    final items = <ApplePayCartSummaryItem>[
      ApplePayCartSummaryItem.immediate(
        label: 'Products',
        amount: estimate.formatMoney(estimate.retailSubtotalCents),
      ),
      ApplePayCartSummaryItem.immediate(
        label: 'Delivery',
        amount: estimate.formatMoney(estimate.retailDeliveryCents),
      ),
    ];

    if (estimate.hasTax) {
      items.add(
        ApplePayCartSummaryItem.immediate(
          label: 'Tax',
          amount: estimate.formatMoney(estimate.retailTaxCents),
        ),
      );
    }

    items.add(
      ApplePayCartSummaryItem.immediate(
        label: 'OpArt Lab',
        amount: estimate.formatMoney(estimate.retailTotalCents),
      ),
    );

    return items;
  }

  static String _formatAmount(int cents, String currencyCode) {
    final amount = cents / 100;
    return '${currencyCode.toUpperCase()} ${amount.toStringAsFixed(2)}';
  }
}
