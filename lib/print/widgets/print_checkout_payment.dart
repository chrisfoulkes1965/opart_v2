import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/pages/print_confirmation_step.dart';
import 'package:opart_v2/print/repositories/printful_repository.dart';
import 'package:opart_v2/services/stripe_service.dart';

class PrintCheckoutPayment {
  PrintCheckoutPayment._();

  static Future<void> present({
    required BuildContext context,
    required CheckoutSession checkout,
    required ShippingAddress estimateAddress,
    PrintEstimate? estimate,
    VoidCallback? onSuccess,
  }) async {
    if (!StripeService.isConfigured) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payments are not configured. Add STRIPE_PUBLISHABLE_KEY to build.',
          ),
        ),
      );
      return;
    }

    try {
      await StripeService.presentPaymentSheet(
        checkout: checkout,
        estimateAddress: estimateAddress,
        estimate: estimate,
      );
      if (!context.mounted) {
        return;
      }
      onSuccess?.call();
      await _showConfirmation(context, checkout.orderId);
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        return;
      }
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.error.localizedMessage ?? 'Payment failed'),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  static Future<void> _showConfirmation(
    BuildContext context,
    String orderId,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => _ConfirmationLoader(orderId: orderId),
      ),
    );
  }
}

class _ConfirmationLoader extends StatefulWidget {
  const _ConfirmationLoader({required this.orderId});

  final String orderId;

  @override
  State<_ConfirmationLoader> createState() => _ConfirmationLoaderState();
}

class _ConfirmationLoaderState extends State<_ConfirmationLoader> {
  PrintOrderSummary? _order;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final repository = PrintfulRepository();
      final order = await repository.fetchOrder(widget.orderId);
      if (!mounted) {
        return;
      }
      setState(() => _order = order);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan.withValues(alpha: 0.85),
        title: const Text(
          'Order Confirmed',
          style: TextStyle(
            fontFamily: 'Righteous',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : _order == null
              ? const Center(child: CircularProgressIndicator())
              : PrintConfirmationStep(order: _order),
    );
  }
}
