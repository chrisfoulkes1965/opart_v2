import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/basket/print_basket_cubit.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/shipping_countries.dart';
import 'package:opart_v2/print/repositories/printful_repository.dart';
import 'package:opart_v2/print/widgets/order_price_breakdown.dart';
import 'package:opart_v2/print/widgets/print_checkout_payment.dart';
import 'package:opart_v2/print/widgets/shipping_country_picker.dart';

class PrintBasketCheckoutPage extends StatefulWidget {
  const PrintBasketCheckoutPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const PrintBasketCheckoutPage(),
      ),
    );
  }

  @override
  State<PrintBasketCheckoutPage> createState() =>
      _PrintBasketCheckoutPageState();
}

class _PrintBasketCheckoutPageState extends State<PrintBasketCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = PrintfulRepository();
  late final TextEditingController _zipController;
  late ShippingCountry _selectedCountry;

  PrintEstimate? _estimate;
  bool _isEstimating = false;
  bool _isPaying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final address = context.read<PrintBasketCubit>().state.shippingAddress;
    _zipController = TextEditingController(text: address.zip);
    _selectedCountry = ShippingCountry.resolveSupported(address.countryCode);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _maybeEstimate();
    });
  }

  @override
  void dispose() {
    _zipController.dispose();
    super.dispose();
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

  Future<void> _maybeEstimate() async {
    final address = _buildAddress();
    if (!address.canEstimate) {
      setState(() => _estimate = null);
      return;
    }

    final basket = context.read<PrintBasketCubit>();
    await basket.updateShippingAddress(address);

    setState(() {
      _isEstimating = true;
      _errorMessage = null;
    });

    try {
      final estimate = await _repository.estimateBasket(
        items: basket.lineInputs,
        address: address,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _estimate = estimate;
        _isEstimating = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isEstimating = false;
        _errorMessage = PrintfulRepository.formatError(error);
        _estimate = null;
      });
    }
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate() || _estimate == null) {
      return;
    }
    TextInput.finishAutofillContext();

    final basket = context.read<PrintBasketCubit>();
    final address = _buildAddress();
    await basket.updateShippingAddress(address);

    setState(() {
      _isPaying = true;
      _errorMessage = null;
    });

    try {
      final session = await _repository.createBasketCheckoutSession(
        items: basket.state.items
            .map(
              (item) => CheckoutLineInput(
                designId: item.designId,
                variantId: item.variantId,
                productName: item.displayTitle,
                quantity: item.quantity,
              ),
            )
            .toList(),
        address: address,
      );
      if (!mounted) {
        return;
      }
      setState(() => _isPaying = false);

      await PrintCheckoutPayment.present(
        context: context,
        checkout: session,
        estimateAddress: address,
        estimate: _estimate,
        onSuccess: () => unawaited(basket.clear()),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPaying = false;
        _errorMessage = PrintfulRepository.formatError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final basketState = context.watch<PrintBasketCubit>().state;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan.withValues(alpha: 0.85),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontFamily: 'Righteous',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              if (_errorMessage != null) ...[
                Material(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                '${basketState.itemCount} ${basketState.itemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in basketState.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${item.displayTitle}',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Enter your delivery region to see pricing. '
                'Name, email, and full address are collected securely at payment.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              ShippingCountryPickerFormField(
                initialValue: _selectedCountry,
                onChanged: (country) {
                  setState(() => _selectedCountry = country);
                  unawaited(_maybeEstimate());
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _zipController,
                  decoration: const InputDecoration(
                    labelText: 'ZIP / Postal code',
                    border: OutlineInputBorder(),
                  ),
                  autofillHints: const [AutofillHints.postalCode],
                  keyboardType: TextInputType.visiblePassword,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  onChanged: (_) => unawaited(_maybeEstimate()),
                ),
              ),
              OrderPriceBreakdown(
                estimate: _estimate,
                itemLabels: context.read<PrintBasketCubit>().itemLabels,
                isLoading: _isEstimating,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isEstimating || _isPaying || _estimate == null
                    ? null
                    : _pay,
                child: _isPaying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Pay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
