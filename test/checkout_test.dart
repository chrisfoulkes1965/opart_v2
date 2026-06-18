import 'package:flutter_test/flutter_test.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/shipping_countries.dart';

void main() {
  group('ShippingCountry', () {
    test('finds country by ISO code', () {
      expect(ShippingCountry.byCode('us')?.name, 'United States');
      expect(ShippingCountry.byCode('GB')?.name, 'United Kingdom');
    });

    test('finds country by name', () {
      expect(ShippingCountry.byName('Canada')?.code, 'CA');
    });

    test('search matches code and name', () {
      final results = ShippingCountry.search('ger');
      expect(results.map((country) => country.code), contains('DE'));
    });

    test('supportedCodes lists all Printful destinations', () {
      expect(ShippingCountry.supportedCodes, contains('US'));
      expect(
        ShippingCountry.supportedCodes.length,
        ShippingCountry.all.length,
      );
    });

    test('resolveSupported uses known code', () {
      expect(ShippingCountry.resolveSupported('de').code, 'DE');
    });

    test('resolveSupported falls back when code is unsupported', () {
      expect(
        ShippingCountry.resolveSupported('ZZ').code,
        ShippingCountry.deviceDefault.code,
      );
    });
  });

  group('ShippingAddress', () {
    test('canEstimate requires country and zip', () {
      const address = ShippingAddress(
        name: '',
        address1: '',
        city: '',
        stateCode: '',
        countryCode: 'US',
        zip: '',
        email: '',
      );

      expect(address.canEstimate, isFalse);

      expect(
        address.copyWith(zip: '90210').canEstimate,
        isTrue,
      );
    });

    test('canStartCheckout only needs estimate fields', () {
      const address = ShippingAddress(
        name: '',
        address1: '',
        city: '',
        stateCode: '',
        countryCode: 'GB',
        zip: 'SW1A 1AA',
        email: '',
      );

      expect(address.canStartCheckout, isTrue);
    });
  });

  group('PrintEstimate', () {
    test('parses full retail breakdown from API payload', () {
      final estimate = PrintEstimate.fromJson({
        'currency': 'USD',
        'printful_subtotal_cents': 2000,
        'printful_shipping_cents': 500,
        'printful_tax_cents': 200,
        'printful_total_cents': 2700,
        'retail_subtotal_cents': 2600,
        'retail_delivery_cents': 650,
        'retail_tax_cents': 260,
        'retail_total_cents': 3510,
      });

      expect(estimate.currency, 'USD');
      expect(estimate.retailSubtotalCents, 2600);
      expect(estimate.retailDeliveryCents, 650);
      expect(estimate.retailTaxCents, 260);
      expect(estimate.retailTotalCents, 3510);
      expect(estimate.hasTax, isTrue);
      expect(
        estimate.retailSubtotalCents +
            estimate.retailDeliveryCents +
            estimate.retailTaxCents,
        estimate.retailTotalCents,
      );
    });

    test('applyRetailMarkup matches backend default percent', () {
      expect(PrintEstimate.applyRetailMarkup(1000), 1300);
    });
  });

  group('CheckoutSession', () {
    test('parses payment intent payload', () {
      final session = CheckoutSession.fromJson({
        'order_id': 'order-123',
        'client_secret': 'pi_secret',
        'retail_total_cents': 4200,
        'currency_code': 'usd',
      });

      expect(session.orderId, 'order-123');
      expect(session.clientSecret, 'pi_secret');
      expect(session.retailTotalCents, 4200);
      expect(session.currencyCode, 'usd');
    });
  });
}
