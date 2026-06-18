import 'dart:ui';

class ShippingCountry {
  const ShippingCountry({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;

  static List<String> get supportedCodes =>
      all.map((country) => country.code).toList(growable: false);

  static ShippingCountry get deviceDefault {
    final deviceCode =
        PlatformDispatcher.instance.locale.countryCode?.toUpperCase();
    return resolveSupported(deviceCode);
  }

  static ShippingCountry resolveSupported(String? countryCode) {
    if (countryCode != null && countryCode.isNotEmpty) {
      final match = byCode(countryCode);
      if (match != null) {
        return match;
      }
    }
    return byCode('US')!;
  }

  static const List<ShippingCountry> all = [
    ShippingCountry(code: 'US', name: 'United States'),
    ShippingCountry(code: 'GB', name: 'United Kingdom'),
    ShippingCountry(code: 'CA', name: 'Canada'),
    ShippingCountry(code: 'AU', name: 'Australia'),
    ShippingCountry(code: 'AT', name: 'Austria'),
    ShippingCountry(code: 'BE', name: 'Belgium'),
    ShippingCountry(code: 'BR', name: 'Brazil'),
    ShippingCountry(code: 'BG', name: 'Bulgaria'),
    ShippingCountry(code: 'HR', name: 'Croatia'),
    ShippingCountry(code: 'CY', name: 'Cyprus'),
    ShippingCountry(code: 'CZ', name: 'Czech Republic'),
    ShippingCountry(code: 'DK', name: 'Denmark'),
    ShippingCountry(code: 'EE', name: 'Estonia'),
    ShippingCountry(code: 'FI', name: 'Finland'),
    ShippingCountry(code: 'FR', name: 'France'),
    ShippingCountry(code: 'DE', name: 'Germany'),
    ShippingCountry(code: 'GR', name: 'Greece'),
    ShippingCountry(code: 'HK', name: 'Hong Kong'),
    ShippingCountry(code: 'HU', name: 'Hungary'),
    ShippingCountry(code: 'IE', name: 'Ireland'),
    ShippingCountry(code: 'IT', name: 'Italy'),
    ShippingCountry(code: 'JP', name: 'Japan'),
    ShippingCountry(code: 'LV', name: 'Latvia'),
    ShippingCountry(code: 'LT', name: 'Lithuania'),
    ShippingCountry(code: 'LU', name: 'Luxembourg'),
    ShippingCountry(code: 'MY', name: 'Malaysia'),
    ShippingCountry(code: 'MT', name: 'Malta'),
    ShippingCountry(code: 'MX', name: 'Mexico'),
    ShippingCountry(code: 'NL', name: 'Netherlands'),
    ShippingCountry(code: 'NZ', name: 'New Zealand'),
    ShippingCountry(code: 'NO', name: 'Norway'),
    ShippingCountry(code: 'PL', name: 'Poland'),
    ShippingCountry(code: 'PT', name: 'Portugal'),
    ShippingCountry(code: 'RO', name: 'Romania'),
    ShippingCountry(code: 'SG', name: 'Singapore'),
    ShippingCountry(code: 'SK', name: 'Slovakia'),
    ShippingCountry(code: 'SI', name: 'Slovenia'),
    ShippingCountry(code: 'KR', name: 'South Korea'),
    ShippingCountry(code: 'ES', name: 'Spain'),
    ShippingCountry(code: 'SE', name: 'Sweden'),
    ShippingCountry(code: 'CH', name: 'Switzerland'),
    ShippingCountry(code: 'TW', name: 'Taiwan'),
  ];

  static ShippingCountry? byCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final country in all) {
      if (country.code == normalized) {
        return country;
      }
    }
    return null;
  }

  static ShippingCountry? byName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final country in all) {
      if (country.name.toLowerCase() == normalized) {
        return country;
      }
    }
    return null;
  }

  static List<ShippingCountry> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return all;
    }

    return all
        .where(
          (country) =>
              country.name.toLowerCase().contains(normalized) ||
              country.code.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }
}
