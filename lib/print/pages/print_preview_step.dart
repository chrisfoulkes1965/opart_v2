import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/widgets/print_crop_editor.dart';

class PrintPreviewStep extends StatelessWidget {
  const PrintPreviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      buildWhen: (previous, current) =>
          previous.previewMockupUrl != current.previewMockupUrl ||
          previous.exportPreviewBytes != current.exportPreviewBytes ||
          previous.placement != current.placement ||
          previous.recipe != current.recipe ||
          previous.selectedVariant != current.selectedVariant ||
          previous.selectedSpec != current.selectedSpec ||
          previous.selectedProduct != current.selectedProduct ||
          previous.status != current.status ||
          previous.progressMessage != current.progressMessage,
      builder: (context, state) {
        final variant = state.selectedVariant;
        final spec = state.selectedSpec;
        final product = state.selectedProduct;
        final mockupUrl = state.previewMockupUrl;
        final exportBytes = state.exportPreviewBytes;
        final hasExport = exportBytes != null && exportBytes.isNotEmpty;
        final hasMockup = mockupUrl != null && mockupUrl.isNotEmpty;
        final isGenerating = state.isBusy;
        final mockupMaxHeight = MediaQuery.sizeOf(context).height * 0.42;
        final canShowCropPreview =
            spec != null && product != null && state.hasValidRecipe;

        if (!canShowCropPreview && !hasExport && !isGenerating) {
          return const Center(child: Text('Nothing to preview yet.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
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
                  Text(
                    'Your print file',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cropped region — matches your selection.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (hasExport && spec != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PrintCropFrame(
                          aspectRatio: spec.aspectRatio,
                          maxHeight: mockupMaxHeight,
                          child: Image.memory(
                            exportBytes,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  else if (canShowCropPreview)
                    SizedBox(
                      height: mockupMaxHeight.clamp(200, 480),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PrintCropEditor(
                            recipe: state.recipe,
                            aspectRatio: spec.aspectRatio,
                            placement: state.placement,
                            rasterService:
                                context.read<PrintFlowCubit>().rasterService,
                            interactive: false,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: mockupMaxHeight.clamp(160, 320),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Generating print file…'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'On your product',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Printful mockup — how your design sits on the item.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (hasMockup)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: mockupMaxHeight,
                        ),
                        child: Image.network(
                          mockupUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Could not load product mockup.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (isGenerating)
                    SizedBox(
                      height: mockupMaxHeight.clamp(160, 320),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              state.progressMessage ??
                                  'Generating product mockup…',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
                    onPressed: hasMockup && !state.isBusy
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
