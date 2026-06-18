import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/basket/print_basket_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/shipping_countries.dart';
import 'package:opart_v2/print/widgets/order_price_breakdown.dart';
import 'package:opart_v2/print/widgets/shipping_country_picker.dart';

class PrintCheckoutStep extends StatefulWidget {
  const PrintCheckoutStep({super.key});

  @override
  State<PrintCheckoutStep> createState() => _PrintCheckoutStepState();
}

class _PrintCheckoutStepState extends State<PrintCheckoutStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _zipController;
  late final FocusNode _zipFocus;
  late ShippingCountry _selectedCountry;

  @override
  void initState() {
    super.initState();
    final flowAddress = context.read<PrintFlowCubit>().state.shippingAddress;
    final basketAddress =
        context.read<PrintBasketCubit>().state.shippingAddress;
    final address = basketAddress.canEstimate ? basketAddress : flowAddress;
    _zipController = TextEditingController(text: address.zip);
    _selectedCountry = ShippingCountry.resolveSupported(address.countryCode);
    if (basketAddress.canEstimate) {
      context.read<PrintFlowCubit>().updateShippingAddress(basketAddress);
    }
    _zipFocus = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final cubit = context.read<PrintFlowCubit>();
      if (cubit.state.shippingAddress.canEstimate &&
          cubit.state.estimate == null) {
        unawaited(cubit.estimateShipping());
      }
    });
  }

  @override
  void dispose() {
    _zipController.dispose();
    _zipFocus.dispose();
    super.dispose();
  }

  void _maybeEstimate() {
    final address = _buildAddress();
    if (!address.canEstimate) {
      return;
    }
    final cubit = context.read<PrintFlowCubit>();
    cubit.updateShippingAddress(address);
    unawaited(context.read<PrintBasketCubit>().updateShippingAddress(address));
    unawaited(cubit.estimateShipping());
  }

  void _onCountryChanged(ShippingCountry country) {
    setState(() => _selectedCountry = country);
    _maybeEstimate();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                if (state.selectedVariant != null)
                  Text(
                    state.selectedVariant!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Enter your delivery region to see the total. '
                  'Name, email, and full address are collected securely at payment.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                ShippingCountryPickerFormField(
                  initialValue: _selectedCountry,
                  onChanged: _onCountryChanged,
                ),
                _field(
                  controller: _zipController,
                  focusNode: _zipFocus,
                  label: 'ZIP / Postal code',
                  autofillHints: const [AutofillHints.postalCode],
                  keyboardType: TextInputType.visiblePassword,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _unfocus(),
                  validator: _required,
                  onChanged: (_) => _maybeEstimate(),
                ),
                if (state.isBusy || state.estimate != null) ...[
                  const SizedBox(height: 16),
                  OrderPriceBreakdown(
                    estimate: state.estimate,
                    productLabel: 'Product',
                    isLoading: state.isBusy && state.estimate == null,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed:
                      state.isBusy || state.estimate == null ? null : _pay,
                  child: const Text('Pay'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool autocorrect = true,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onFieldSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        autocorrect: autocorrect,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  ShippingAddress _buildAddress() {
    return ShippingAddress(
      name: '',
      email: '',
      address1: '',
      city: '',
      stateCode: '',
      countryCode: _selectedCountry.code,
      zip: _zipController.text.trim(),
    );
  }

  void _pay() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    TextInput.finishAutofillContext();
    final cubit = context.read<PrintFlowCubit>();
    cubit.updateShippingAddress(_buildAddress());
    cubit.startCheckout();
  }
}
