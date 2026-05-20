import 'package:flutter/material.dart';
import 'package:opart_v2/print/models/print_models.dart';

class PrintConfirmationStep extends StatelessWidget {
  const PrintConfirmationStep({super.key, required this.order});

  final PrintOrderSummary? order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 72, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Thank you!',
            style: TextStyle(
              fontFamily: 'Righteous',
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order == null
                ? 'Your payment was received. We are preparing your print order.'
                : 'Order status: ${order!.status}',
            textAlign: TextAlign.center,
          ),
          if (order?.productName != null) ...[
            const SizedBox(height: 12),
            Text(order!.productName!, textAlign: TextAlign.center),
          ],
          if (order?.trackingUrl != null && order!.trackingUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            SelectableText('Tracking: ${order!.trackingUrl!}'),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to OpArt Lab'),
          ),
        ],
      ),
    );
  }
}
