import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/pages/print_apparel_step.dart';
import 'package:opart_v2/print/pages/print_checkout_step.dart';
import 'package:opart_v2/print/pages/print_confirmation_step.dart';
import 'package:opart_v2/print/pages/print_crop_step.dart';
import 'package:opart_v2/print/pages/print_phone_case_step.dart';
import 'package:opart_v2/print/pages/print_preview_step.dart';
import 'package:opart_v2/print/pages/print_product_step.dart';
import 'package:opart_v2/print/pages/print_variant_step.dart';
import 'package:url_launcher/url_launcher.dart';

class PrintFlowPage extends StatefulWidget {
  const PrintFlowPage({
    super.key,
    required this.recipe,
    this.completedOrderId,
    this.initialProduct,
  });

  final Map<String, dynamic> recipe;
  final String? completedOrderId;
  final PrintProduct? initialProduct;

  static Future<void> open(
    BuildContext context, {
    required Map<String, dynamic> recipe,
    String? completedOrderId,
    PrintProduct? initialProduct,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PrintFlowPage(
          recipe: recipe,
          completedOrderId: completedOrderId,
          initialProduct: initialProduct,
        ),
      ),
    );
  }

  @override
  State<PrintFlowPage> createState() => _PrintFlowPageState();
}

class _PrintFlowPageState extends State<PrintFlowPage> {
  late final PrintFlowCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PrintFlowCubit(recipe: widget.recipe);
    if (widget.completedOrderId != null) {
      _cubit.completeOrder(widget.completedOrderId!);
    } else if (widget.initialProduct != null) {
      unawaited(_bootstrapWithProduct(widget.initialProduct!));
    } else {
      _cubit.initialize();
    }
  }

  Future<void> _bootstrapWithProduct(PrintProduct product) async {
    await _cubit.initialize();
    if (!mounted) {
      return;
    }
    await _cubit.selectProduct(product);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<PrintFlowCubit, PrintFlowState>(
        listenWhen: (previous, current) =>
            previous.checkoutSession != current.checkoutSession,
        listener: (context, state) async {
          final checkoutUrl = state.checkoutSession?.checkoutUrl;
          if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
            final uri = Uri.parse(checkoutUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.cyan.withValues(alpha: 0.85),
              title: Text(
                _titleForStep(state),
                style: const TextStyle(
                  fontFamily: 'Righteous',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (state.step == PrintFlowStep.product ||
                      state.step == PrintFlowStep.confirmation) {
                    Navigator.of(context).pop();
                  } else {
                    context.read<PrintFlowCubit>().goBack();
                  }
                },
              ),
            ),
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.errorMessage != null &&
                        state.errorMessage!.isNotEmpty)
                      Material(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      ),
                    Expanded(child: _buildStep(context, state)),
                  ],
                ),
                if (state.blocksEntireScreen)
                  ColoredBox(
                    color: Colors.white.withValues(alpha: 0.7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          if (state.progressMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              state.progressMessage!,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _titleForStep(PrintFlowState state) {
    if (state.step == PrintFlowStep.variant && state.phoneCaseBrand != null) {
      return 'Choose phone';
    }

    if (state.step == PrintFlowStep.variant &&
        state.selectedProduct != null &&
        PrintCatalog.isApparelFront(state.selectedProduct!.id)) {
      return 'Choose colour & size';
    }

    return switch (state.step) {
      PrintFlowStep.product => 'Print Your Design',
      PrintFlowStep.variant => 'Choose Size',
      PrintFlowStep.crop => 'Adjust Crop',
      PrintFlowStep.preview => 'Preview',
      PrintFlowStep.checkout => 'Checkout',
      PrintFlowStep.confirmation => 'Order Confirmed',
    };
  }

  Widget _buildStep(BuildContext context, PrintFlowState state) {
    return switch (state.step) {
      PrintFlowStep.product => PrintProductStep(products: state.products),
      PrintFlowStep.variant => state.phoneCaseBrand != null
          ? const PrintPhoneCaseStep()
          : state.selectedProduct != null &&
                  PrintCatalog.isApparelFront(state.selectedProduct!.id)
              ? const PrintApparelStep()
              : const PrintVariantStep(),
      PrintFlowStep.crop => const PrintCropStep(),
      PrintFlowStep.preview => const PrintPreviewStep(),
      PrintFlowStep.checkout => const PrintCheckoutStep(),
      PrintFlowStep.confirmation =>
        PrintConfirmationStep(order: state.completedOrder),
    };
  }
}
