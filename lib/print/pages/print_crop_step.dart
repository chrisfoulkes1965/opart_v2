import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/widgets/print_crop_editor.dart';

class PrintCropStep extends StatefulWidget {
  const PrintCropStep({super.key});

  @override
  State<PrintCropStep> createState() => _PrintCropStepState();
}

class _PrintCropStepState extends State<PrintCropStep> {
  final _editorKey = GlobalKey<PrintCropEditorState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      buildWhen: (previous, current) =>
          previous.placement != current.placement ||
          previous.selectedSpec != current.selectedSpec ||
          previous.selectedProduct != current.selectedProduct ||
          previous.recipe != current.recipe ||
          previous.status != current.status ||
          previous.progressMessage != current.progressMessage ||
          previous.printAreaResolved != current.printAreaResolved ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        final spec = state.selectedSpec;
        final product = state.selectedProduct;

        if (spec == null || product == null) {
          return const Center(child: Text('Select a size first.'));
        }

        if (state.isBusy && !state.printAreaResolved) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (state.progressMessage != null) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      state.progressMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        if (!state.printAreaResolved) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Colors.red.shade700),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ??
                        'Could not load print dimensions. Please try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () =>
                        context.read<PrintFlowCubit>().retryPrintArea(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final canContinue =
            state.hasValidRecipe && state.printAreaResolved && !state.isBusy;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      spec.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Move crop · Pinch to resize',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: PrintCropEditor(
                  key: _editorKey,
                  recipe: state.recipe,
                  aspectRatio: spec.aspectRatio,
                  placement: state.placement,
                  rasterService: context.read<PrintFlowCubit>().rasterService,
                  onPlacementChanged: (placement) =>
                      context.read<PrintFlowCubit>().updatePlacement(placement),
                ),
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canContinue
                      ? () {
                          final editor = _editorKey.currentState;
                          if (editor != null) {
                            context
                                .read<PrintFlowCubit>()
                                .updatePlacement(editor.currentPlacement);
                          }
                          context.read<PrintFlowCubit>().confirmCrop();
                        }
                      : null,
                  child: const Text('Preview on product'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
