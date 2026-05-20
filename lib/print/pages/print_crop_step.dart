import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/widgets/print_crop_editor.dart';

class PrintCropStep extends StatelessWidget {
  const PrintCropStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      buildWhen: (previous, current) =>
          previous.squareArtworkBytes != current.squareArtworkBytes ||
          previous.placement != current.placement ||
          previous.selectedSpec != current.selectedSpec ||
          previous.status != current.status,
      builder: (context, state) {
        final spec = state.selectedSpec;
        final squareBytes = state.squareArtworkBytes;

        if (spec == null) {
          return const Center(child: Text('Select a size first.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    spec.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (squareBytes != null)
                    PrintCropEditor(
                      squareArtworkBytes: squareBytes,
                      aspectRatio: spec.aspectRatio,
                      placement: state.placement,
                      onPlacementChanged: (placement) => context
                          .read<PrintFlowCubit>()
                          .updatePlacement(placement),
                    )
                  else
                    AspectRatio(
                      aspectRatio: spec.aspectRatio,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: squareBytes != null && !state.isBusy
                      ? () => context.read<PrintFlowCubit>().confirmCrop()
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
