import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/pages/print_flow_page.dart';
import 'package:opart_v2/print/pages/print_product_step.dart';
import 'package:opart_v2/print/widgets/op_art_catalog_picker.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late final PrintFlowCubit _cubit;
  OpArtType _selectedType = OpArtType.Squares;

  @override
  void initState() {
    super.initState();
    _cubit = PrintFlowCubit(
      recipe: OpArtRecipe.defaultForType(OpArtType.Squares),
    );
    unawaited(_cubit.initialize());
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _onOpArtTypeSelected(OpArtType type) {
    setState(() {
      _selectedType = type;
    });
    unawaited(
      _cubit.changeRecipe(OpArtRecipe.defaultForType(type)),
    );
  }

  void _onProductSelected(PrintProduct product) {
    unawaited(
      PrintFlowPage.open(
        context,
        recipe: Map<String, dynamic>.from(_cubit.state.recipe),
        initialProduct: product,
      ),
    );
  }

  void _onPhoneCaseGroupSelected() {
    unawaited(
      PrintFlowPage.open(
        context,
        recipe: Map<String, dynamic>.from(_cubit.state.recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<PrintFlowCubit, PrintFlowState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.cyan.withValues(alpha: 0.85),
              centerTitle: true,
              title: const Text(
                'Print Your Design',
                style: TextStyle(
                  fontFamily: 'Righteous',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
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
                    OpArtCatalogPicker(
                      selectedType: _selectedType,
                      onSelected: _onOpArtTypeSelected,
                    ),
                    Expanded(
                      child: PrintProductStep(
                        products: state.products,
                        onProductSelected: _onProductSelected,
                        onPhoneCaseGroupSelected: _onPhoneCaseGroupSelected,
                      ),
                    ),
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
}
