import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opart_v2/print/models/shipping_countries.dart';

class ShippingCountryPickerFormField extends FormField<ShippingCountry> {
  ShippingCountryPickerFormField({
    super.key,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    ValueChanged<ShippingCountry>? onChanged,
  }) : super(
          builder: (field) {
            return _ShippingCountryPickerTile(
              value: field.value,
              errorText: field.errorText,
              onChanged: (country) {
                field.didChange(country);
                onChanged?.call(country);
              },
            );
          },
        );
}

class _ShippingCountryPickerTile extends StatelessWidget {
  const _ShippingCountryPickerTile({
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final ShippingCountry? value;
  final ValueChanged<ShippingCountry> onChanged;
  final String? errorText;

  void _openPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      useSafeArea: true,
      searchAutofocus: true,
      showPhoneCode: false,
      showWorldWide: false,
      countryFilter: ShippingCountry.supportedCodes,
      favorite: const ['US', 'GB', 'CA', 'AU'],
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Country name or code',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      onSelect: (country) {
        final shipping = ShippingCountry.byCode(country.countryCode);
        if (shipping == null) {
          return;
        }
        HapticFeedback.selectionClick();
        onChanged(shipping);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;
    final pickerCountry = hasValue ? Country.tryParse(value!.code) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: hasValue ? 'Country, ${value!.name}' : 'Country, not selected',
        child: InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Country',
              border: const OutlineInputBorder(),
              errorText: errorText,
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            isEmpty: !hasValue,
            child: hasValue && pickerCountry != null
                ? Row(
                    children: [
                      Text(
                        pickerCountry.flagEmoji,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pickerCountry.name,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        pickerCountry.countryCode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : Text(
                    hasValue ? value!.name : 'Select country',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
