/// Supabase project configuration.
///
/// Pass values at build time:
/// `--dart-define=SUPABASE_URL=https://xxx.supabase.co`
/// `--dart-define=SUPABASE_ANON_KEY=eyJ...`
class SupabaseConfig {
  /// Set to true when re-enabling the print shop backend.
  static const enabled = false;

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const stripeSuccessUrl = String.fromEnvironment(
    'STRIPE_SUCCESS_URL',
    defaultValue: 'opartlab://print/checkout/success',
  );

  static const stripeCancelUrl = String.fromEnvironment(
    'STRIPE_CANCEL_URL',
    defaultValue: 'opartlab://print/checkout/cancel',
  );

  static bool get isConfigured =>
      enabled && url.isNotEmpty && anonKey.isNotEmpty;
}
