import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/print_models.dart';

class PrintCheckoutStep extends StatefulWidget {
  const PrintCheckoutStep({super.key});

  @override
  State<PrintCheckoutStep> createState() => _PrintCheckoutStepState();
}

class _PrintCheckoutStepState extends State<PrintCheckoutStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipController;
  String _countryCode = 'US';

  @override
  void initState() {
    super.initState();
    final address = context.read<PrintFlowCubit>().state.shippingAddress;
    _nameController = TextEditingController(text: address.name);
    _emailController = TextEditingController(text: address.email);
    _address1Controller = TextEditingController(text: address.address1);
    _address2Controller = TextEditingController(text: address.address2);
    _cityController = TextEditingController(text: address.city);
    _stateController = TextEditingController(text: address.stateCode);
    _zipController = TextEditingController(text: address.zip);
    _countryCode = address.countryCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
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
              children: [
                if (state.selectedVariant != null)
                  Text(
                    state.selectedVariant!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 16),
                _field(
                  controller: _nameController,
                  label: 'Full name',
                  autofillHints: const [AutofillHints.name],
                  textCapitalization: TextCapitalization.words,
                  validator: _required,
                ),
                _field(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  validator: _required,
                ),
                _field(
                  controller: _address1Controller,
                  label: 'Address line 1',
                  autofillHints: const [AutofillHints.streetAddressLine1],
                  validator: _required,
                ),
                _field(
                  controller: _address2Controller,
                  label: 'Address line 2 (optional)',
                  autofillHints: const [AutofillHints.streetAddressLine2],
                ),
                _field(
                  controller: _cityController,
                  label: 'City',
                  autofillHints: const [AutofillHints.addressCity],
                  textCapitalization: TextCapitalization.words,
                  validator: _required,
                ),
                _field(
                  controller: _stateController,
                  label: 'State / Province',
                  autofillHints: const [AutofillHints.addressState],
                  textCapitalization: TextCapitalization.characters,
                  validator: _required,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _countryCode,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'US', child: Text('United States')),
                    DropdownMenuItem(
                        value: 'GB', child: Text('United Kingdom')),
                    DropdownMenuItem(value: 'CA', child: Text('Canada')),
                    DropdownMenuItem(value: 'AU', child: Text('Australia')),
                    DropdownMenuItem(value: 'DE', child: Text('Germany')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _countryCode = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _zipController,
                  label: 'ZIP / Postal code',
                  autofillHints: const [AutofillHints.postalCode],
                  keyboardType: TextInputType.visiblePassword,
                  autocorrect: false,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: state.isBusy ? null : _updateAndEstimate,
                  child: const Text('Calculate total'),
                ),
                if (state.estimate != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Total: ${state.estimate!.formattedRetailTotal}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isBusy ? null : _pay,
                  child: const Text('Pay with Stripe'),
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
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool autocorrect = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        autocorrect: autocorrect,
        validator: validator,
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  ShippingAddress _buildAddress() {
    return ShippingAddress(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      address1: _address1Controller.text.trim(),
      address2: _address2Controller.text.trim(),
      city: _cityController.text.trim(),
      stateCode: _stateController.text.trim(),
      countryCode: _countryCode,
      zip: _zipController.text.trim(),
    );
  }

  void _updateAndEstimate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final cubit = context.read<PrintFlowCubit>();
    cubit.updateShippingAddress(_buildAddress());
    cubit.estimateShipping();
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
