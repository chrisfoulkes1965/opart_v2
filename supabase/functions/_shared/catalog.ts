// Keep in sync with lib/print/models/print_product_definition.dart
export const CATALOG_PRODUCT_IDS = [
  268, // Enhanced Matte Paper Poster
  3, // Canvas (in)
  2, // Enhanced Matte Paper Framed Poster
  358, // Kiss-Cut Stickers
  71, // Unisex Staple T-Shirt
  294, // Unisex Pullover Hoodie
  19, // White Glossy Mug
  474, // Spiral Notebook
  83, // All-Over Print Basic Pillow
  84, // All-Over Print Tote Bag
  611, // Cork-Back Coaster
  601, // Tough iPhone Case
  686, // Tough Samsung Case
  505, // Glossy Metal Print
  518, // Wall Tapestry
  906, // Kiss-Cut Holographic Stickers
];

export function resolveCatalogProductIds(): number[] {
  const fromEnv = Deno.env.get('PRINTFUL_PRODUCT_IDS')?.trim();
  if (fromEnv) {
    return fromEnv
      .split(',')
      .map((id) => Number(id.trim()))
      .filter((id) => !Number.isNaN(id));
  }

  return CATALOG_PRODUCT_IDS;
}
