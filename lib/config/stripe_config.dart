/// Stripe client configuration.
///
/// Pass values at build time:
/// `--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...`
/// `--dart-define=STRIPE_APPLE_MERCHANT_ID=merchant.com.example`
class StripeConfig {
  static const publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const appleMerchantId = String.fromEnvironment(
    'STRIPE_APPLE_MERCHANT_ID',
  );

  static const googlePayTestEnv = bool.fromEnvironment(
    'STRIPE_GOOGLE_PAY_TEST_ENV',
    defaultValue: true,
  );

  static const googlePayEnabled = bool.fromEnvironment(
    'STRIPE_GOOGLE_PAY_ENABLED',
    defaultValue: true,
  );

  static bool get isConfigured => publishableKey.isNotEmpty;
}
