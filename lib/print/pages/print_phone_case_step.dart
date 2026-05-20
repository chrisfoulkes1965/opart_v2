import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opart_v2/print/cubit/print_flow_cubit.dart';
import 'package:opart_v2/print/cubit/print_flow_state.dart';
import 'package:opart_v2/print/models/device_case_catalog.dart';

class PrintPhoneCaseStep extends StatefulWidget {
  const PrintPhoneCaseStep({super.key});

  @override
  State<PrintPhoneCaseStep> createState() => _PrintPhoneCaseStepState();
}

class _PrintPhoneCaseStepState extends State<PrintPhoneCaseStep> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrintFlowCubit, PrintFlowState>(
      buildWhen: (previous, current) =>
          previous.variants != current.variants ||
          previous.status != current.status ||
          previous.phoneCaseBrand != current.phoneCaseBrand ||
          previous.phoneCaseFinish != current.phoneCaseFinish ||
          previous.phoneCaseVariantsByBrand != current.phoneCaseVariantsByBrand,
      builder: (context, state) {
        final brand = state.phoneCaseBrand;
        if (brand == null) {
          return const SizedBox.shrink();
        }

        final variants =
            state.phoneCaseVariantsByBrand[brand] ?? state.variants;

        if (variants.isEmpty) {
          if (state.isBusy) {
            return Center(
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
            );
          }

          return const Center(
            child: Text('No phone models are available right now.'),
          );
        }

        final models = DeviceCaseCatalog.uniqueModels(variants);
        final filteredModels =
            DeviceCaseCatalog.filterModels(models, _searchController.text);
        final groups = DeviceCaseCatalog.groupModels(
          models: filteredModels,
          brand: brand,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<PhoneCaseBrand>(
                    segments: PhoneCaseBrand.values
                        .map(
                          (value) => ButtonSegment<PhoneCaseBrand>(
                            value: value,
                            label: Text(value.label),
                          ),
                        )
                        .toList(),
                    selected: {brand},
                    onSelectionChanged: state.isBusy
                        ? null
                        : (selection) {
                            context
                                .read<PrintFlowCubit>()
                                .selectPhoneCaseBrand(selection.first);
                          },
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<PhoneCaseFinish>(
                    segments: PhoneCaseFinish.values
                        .map(
                          (value) => ButtonSegment<PhoneCaseFinish>(
                            value: value,
                            label: Text(value.printfulColor),
                          ),
                        )
                        .toList(),
                    selected: {state.phoneCaseFinish},
                    onSelectionChanged: state.isBusy
                        ? null
                        : (selection) {
                            context
                                .read<PrintFlowCubit>()
                                .selectPhoneCaseFinish(selection.first);
                          },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search device model…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredModels.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No models match your search.'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _listItemCount(groups),
                      itemBuilder: (context, index) {
                        final item = _itemAt(groups, index);
                        if (item.isHeader) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 4,
                            ),
                            child: Text(
                              item.header!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }

                        final model = item.model!;
                        final available =
                            DeviceCaseCatalog.isAvailableForFinish(
                          variants: variants,
                          modelSize: model,
                          finish: state.phoneCaseFinish,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            title: Text(
                              model,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    available ? Colors.black : Colors.black38,
                              ),
                            ),
                            trailing: available
                                ? const Icon(Icons.chevron_right)
                                : Text(
                                    'Out of stock',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                            enabled: available && !state.isBusy,
                            onTap: available && !state.isBusy
                                ? () => context
                                    .read<PrintFlowCubit>()
                                    .selectPhoneCaseModel(model)
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ListItem {
  const _ListItem.header(this.header) : model = null;

  const _ListItem.model(this.model) : header = null;

  factory _ListItem.headerItem(String header) => _ListItem.header(header);
  factory _ListItem.modelItem(String model) => _ListItem.model(model);

  final String? header;
  final String? model;

  bool get isHeader => header != null;
}

int _listItemCount(List<DeviceCaseModelGroup> groups) {
  var count = 0;
  for (final group in groups) {
    count += 1 + group.models.length;
  }
  return count;
}

_ListItem _itemAt(List<DeviceCaseModelGroup> groups, int index) {
  var offset = 0;
  for (final group in groups) {
    if (index == offset) {
      return _ListItem.headerItem(group.title);
    }
    offset += 1;

    for (final model in group.models) {
      if (index == offset) {
        return _ListItem.modelItem(model);
      }
      offset += 1;
    }
  }

  throw RangeError.index(index, groups, 'index');
}
