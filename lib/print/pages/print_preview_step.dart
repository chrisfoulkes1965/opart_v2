import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';

class PrintPreviewStep extends StatelessWidget {
  const PrintPreviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      buildWhen: (previous, current) =>
          previous.previewMockupUrl != current.previewMockupUrl ||
          previous.selectedVariant != current.selectedVariant ||
          previous.status != current.status ||
          previous.progressMessage != current.progressMessage,
      builder: (context, state) {
        final variant = state.selectedVariant;
        final mockupUrl = state.previewMockupUrl;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: mockupUrl != null && mockupUrl.isNotEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (variant != null)
                          Text(
                            variant.displayLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            mockupUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Could not load product preview.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This is a Printful mockup of your cropped design.',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          if (state.progressMessage != null) ...[
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                state.progressMessage!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
            SafeArea(
              minimum: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    onPressed: state.isBusy
                        ? null
                        : () => context.read<PrintFlowCubit>().goBack(),
                    child: const Text('Edit crop'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: mockupUrl != null &&
                            mockupUrl.isNotEmpty &&
                            !state.isBusy
                        ? () => context.read<PrintFlowCubit>().goToCheckout()
                        : null,
                    child: const Text('Continue to Checkout'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
