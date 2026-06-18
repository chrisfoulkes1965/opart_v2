import { applyMarkup } from './http.ts';
import { getDesignSignedUrl } from './designs.ts';
import { printfulFetch, recipientForEstimateCosts } from './printful.ts';
import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

export interface EstimateLineInput {
  variant_id: number;
  design_id: string;
  quantity?: number;
}

export interface EstimateRecipient {
  country_code: string;
  state_code?: string;
  city?: string;
  zip?: string;
  address1?: string;
  name?: string;
}

export interface OrderCostEstimate {
  currency: string;
  printful_subtotal_cents: number;
  printful_shipping_cents: number;
  printful_tax_cents: number;
  printful_total_cents: number;
  retail_subtotal_cents: number;
  retail_delivery_cents: number;
  retail_tax_cents: number;
  retail_total_cents: number;
}

export async function estimateOrderCosts(
  service: SupabaseClient,
  items: EstimateLineInput[],
  recipient: EstimateRecipient,
): Promise<OrderCostEstimate> {
  const printfulItems = await Promise.all(
    items.map(async (item) => {
      const fileUrl = await getDesignSignedUrl(service, item.design_id);
      return {
        variant_id: item.variant_id,
        quantity: item.quantity ?? 1,
        files: [{ url: fileUrl }],
      };
    }),
  );

  const estimate = await printfulFetch<{
    code: number;
    result: {
      costs: {
        currency: string;
        subtotal: string;
        shipping: string;
        tax: string;
        total: string;
      };
    };
  }>('/orders/estimate-costs', {
    method: 'POST',
    body: JSON.stringify({
      recipient: recipientForEstimateCosts(recipient),
      items: printfulItems,
    }),
  });

  const costs = estimate.result.costs;
  const printfulSubtotalCents = Math.round(parseFloat(costs.subtotal) * 100);
  const printfulShippingCents = Math.round(parseFloat(costs.shipping) * 100);
  const printfulTaxCents = Math.round(parseFloat(costs.tax) * 100);
  const printfulTotalCents = Math.round(parseFloat(costs.total) * 100);

  return {
    currency: costs.currency,
    printful_subtotal_cents: printfulSubtotalCents,
    printful_shipping_cents: printfulShippingCents,
    printful_tax_cents: printfulTaxCents,
    printful_total_cents: printfulTotalCents,
    retail_subtotal_cents: applyMarkup(printfulSubtotalCents),
    retail_delivery_cents: applyMarkup(printfulShippingCents),
    retail_tax_cents: applyMarkup(printfulTaxCents),
    retail_total_cents: applyMarkup(printfulTotalCents),
  };
}
