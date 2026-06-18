import 'package:flutter/material.dart';
import 'package:opart_v2/print/models/print_models.dart';

class OrderPriceBreakdown extends StatelessWidget {
  const OrderPriceBreakdown({
    super.key,
    required this.estimate,
    this.productLabel = 'Product',
    this.itemLabels,
    this.isLoading = false,
  });

  final PrintEstimate? estimate;
  final String productLabel;
  final List<String>? itemLabels;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _BreakdownSkeleton();
    }

    final resolved = estimate;
    if (resolved == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (itemLabels != null && itemLabels!.length > 1) ...[
              for (final label in itemLabels!)
                _PriceRow(
                  label: label,
                  value: null,
                  isSubline: true,
                ),
              const Divider(height: 24),
            ],
            _PriceRow(
              label: itemLabels != null && itemLabels!.length > 1
                  ? 'Products (${itemLabels!.length})'
                  : productLabel,
              value: resolved.formatMoney(resolved.retailSubtotalCents),
            ),
            const SizedBox(height: 8),
            _PriceRow(
              label: 'Delivery',
              value: resolved.formatMoney(resolved.retailDeliveryCents),
            ),
            if (resolved.hasTax) ...[
              const SizedBox(height: 8),
              _PriceRow(
                label: 'Tax',
                value: resolved.formatMoney(resolved.retailTaxCents),
              ),
            ],
            const Divider(height: 24),
            _PriceRow(
              label: 'Total',
              value: resolved.formatMoney(resolved.retailTotalCents),
              emphasized: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Delivery is for your whole order to this postcode.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.isSubline = false,
  });

  final String label;
  final String? value;
  final bool emphasized;
  final bool isSubline;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        : TextStyle(
            fontSize: isSubline ? 14 : 16,
            fontWeight: isSubline ? FontWeight.normal : FontWeight.w500,
            color: isSubline ? Colors.grey.shade800 : null,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        if (value != null) Text(value!, style: style),
      ],
    );
  }
}

class _BreakdownSkeleton extends StatelessWidget {
  const _BreakdownSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _skeletonRow(),
            const SizedBox(height: 12),
            _skeletonRow(),
            const SizedBox(height: 12),
            _skeletonRow(widthFactor: 0.5),
          ],
        ),
      ),
    );
  }

  Widget _skeletonRow({double widthFactor = 1}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            alignment: Alignment.centerRight,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
