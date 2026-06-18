export interface PrintfulRecipient {
  name: string;
  address1: string;
  address2?: string;
  city: string;
  state_code: string;
  country_code: string;
  zip: string;
  email: string;
  phone?: string;
}

interface StripeAddress {
  line1?: string | null;
  line2?: string | null;
  city?: string | null;
  state?: string | null;
  postal_code?: string | null;
  country?: string | null;
}

interface StripeBillingDetails {
  name?: string | null;
  email?: string | null;
  phone?: string | null;
  address?: StripeAddress | null;
}

interface StripeShipping {
  name?: string | null;
  phone?: string | null;
  address?: StripeAddress | null;
}

export interface StripePaymentIntentSnapshot {
  id: string;
  receipt_email?: string | null;
  shipping?: StripeShipping | null;
  latest_charge?: {
    billing_details?: StripeBillingDetails | null;
  } | null;
}

function readAddress(
  stripeAddress: StripeAddress | null | undefined,
  fallback: PrintfulRecipient,
): Pick<
  PrintfulRecipient,
  'address1' | 'address2' | 'city' | 'state_code' | 'country_code' | 'zip'
> {
  return {
    address1: stripeAddress?.line1?.trim() || fallback.address1,
    address2: stripeAddress?.line2?.trim() || fallback.address2 || '',
    city: stripeAddress?.city?.trim() || fallback.city,
    state_code: stripeAddress?.state?.trim() || fallback.state_code,
    country_code: stripeAddress?.country?.trim()?.toUpperCase() ||
      fallback.country_code,
    zip: stripeAddress?.postal_code?.trim() || fallback.zip,
  };
}

export function recipientFromPaymentIntent(
  partial: PrintfulRecipient,
  paymentIntent: StripePaymentIntentSnapshot,
): PrintfulRecipient {
  const shipping = paymentIntent.shipping;
  const billing = paymentIntent.latest_charge?.billing_details;
  const addressSource = shipping?.address ?? billing?.address;

  return {
    ...partial,
    ...readAddress(addressSource, partial),
    name: shipping?.name?.trim() ||
      billing?.name?.trim() ||
      partial.name,
    email: paymentIntent.receipt_email?.trim() ||
      billing?.email?.trim() ||
      partial.email,
    phone: shipping?.phone?.trim() ||
      billing?.phone?.trim() ||
      partial.phone ||
      '',
  };
}

export function isCompleteRecipient(
  recipient: PrintfulRecipient | null | undefined,
): boolean {
  if (!recipient) {
    return false;
  }

  return Boolean(
    recipient.name?.trim() &&
      recipient.address1?.trim() &&
      recipient.city?.trim() &&
      recipient.state_code?.trim() &&
      recipient.country_code?.trim() &&
      recipient.zip?.trim() &&
      recipient.email?.trim(),
  );
}

export async function fetchPaymentIntentSnapshot(
  paymentIntentId: string,
  stripeSecretKey: string,
): Promise<StripePaymentIntentSnapshot> {
  const params = new URLSearchParams();
  params.append('expand[]', 'latest_charge');

  const response = await fetch(
    `https://api.stripe.com/v1/payment_intents/${paymentIntentId}?${params}`,
    {
      headers: {
        Authorization: `Bearer ${stripeSecretKey}`,
      },
    },
  );

  const paymentIntent = await response.json();
  if (!response.ok) {
    throw new Error(
      paymentIntent.error?.message ?? 'Could not retrieve payment intent',
    );
  }

  return paymentIntent as StripePaymentIntentSnapshot;
}
