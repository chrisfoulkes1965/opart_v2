import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:opart_v2/print/models/device_case_catalog.dart';
import 'package:opart_v2/print/models/print_catalog.dart';
import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_placement.dart';
import 'package:opart_v2/print/models/print_spec.dart';
import 'package:opart_v2/print/models/shipping_countries.dart';

enum PrintFlowStep {
  product,
  variant,
  crop,
  preview,
  checkout,
  confirmation,
}

enum PrintFlowStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

class PrintFlowState extends Equatable {
  static final ShippingAddress defaultShippingAddress = ShippingAddress(
    name: '',
    address1: '',
    city: '',
    stateCode: '',
    countryCode: ShippingCountry.deviceDefault.code,
    zip: '',
    email: '',
  );

  PrintFlowState({
    this.step = PrintFlowStep.product,
    this.status = PrintFlowStatus.initial,
    this.recipe = const {},
    this.products = const [],
    this.variants = const [],
    this.productPreviewByProductId = const {},
    this.designPreviewBytes,
    this.exportPreviewBytes,
    this.mockups = const [],
    this.previewMockupUrl,
    this.selectedProduct,
    this.selectedVariant,
    this.selectedSpec,
    this.phoneCaseBrand,
    this.phoneCaseFinish = PhoneCaseFinish.glossy,
    this.phoneCaseVariantsByBrand = const {},
    this.selectedApparelColor,
    this.selectedApparelSize,
    this.placement = PrintPlacement.initial,
    this.printAreaResolved = false,
    this.registeredDesign,
    this.estimate,
    this.checkoutSession,
    this.completedOrder,
    ShippingAddress? shippingAddress,
    this.errorMessage,
    this.progressMessage,
  }) : shippingAddress = shippingAddress ?? defaultShippingAddress;

  final PrintFlowStep step;
  final PrintFlowStatus status;
  final Map<String, dynamic> recipe;
  final List<PrintProduct> products;
  final List<PrintVariant> variants;
  final Map<int, Uint8List> productPreviewByProductId;
  final Uint8List? designPreviewBytes;
  final Uint8List? exportPreviewBytes;
  final List<PrintMockup> mockups;
  final String? previewMockupUrl;
  final PrintProduct? selectedProduct;
  final PrintVariant? selectedVariant;
  final PrintSpec? selectedSpec;
  final PhoneCaseBrand? phoneCaseBrand;
  final PhoneCaseFinish phoneCaseFinish;
  final Map<PhoneCaseBrand, List<PrintVariant>> phoneCaseVariantsByBrand;
  final String? selectedApparelColor;
  final String? selectedApparelSize;
  final PrintPlacement placement;
  final bool printAreaResolved;
  final RegisteredDesign? registeredDesign;
  final PrintEstimate? estimate;
  final CheckoutSession? checkoutSession;
  final PrintOrderSummary? completedOrder;
  final ShippingAddress shippingAddress;
  final String? errorMessage;
  final String? progressMessage;

  bool get hasValidRecipe => PrintCatalog.isRecipeValid(recipe);

  bool get isBusy =>
      status == PrintFlowStatus.loading || status == PrintFlowStatus.submitting;

  bool get blocksEntireScreen =>
      isBusy &&
      step != PrintFlowStep.crop &&
      step != PrintFlowStep.variant &&
      step != PrintFlowStep.preview;

  String artworkKeyFor(PrintSpec spec, [PrintPlacement? placement]) {
    final p = placement ?? this.placement;
    return '${spec.widthPx}x${spec.heightPx}_${p.cacheKey}';
  }

  PrintFlowState copyWith({
    PrintFlowStep? step,
    PrintFlowStatus? status,
    Map<String, dynamic>? recipe,
    List<PrintProduct>? products,
    List<PrintVariant>? variants,
    Map<int, Uint8List>? productPreviewByProductId,
    Uint8List? designPreviewBytes,
    Uint8List? exportPreviewBytes,
    bool clearExportPreviewBytes = false,
    List<PrintMockup>? mockups,
    String? previewMockupUrl,
    bool clearPreviewMockupUrl = false,
    PrintProduct? selectedProduct,
    PrintVariant? selectedVariant,
    PrintSpec? selectedSpec,
    PhoneCaseBrand? phoneCaseBrand,
    bool clearPhoneCaseBrand = false,
    PhoneCaseFinish? phoneCaseFinish,
    Map<PhoneCaseBrand, List<PrintVariant>>? phoneCaseVariantsByBrand,
    bool clearPhoneCaseVariantsByBrand = false,
    String? selectedApparelColor,
    String? selectedApparelSize,
    bool clearApparelSelection = false,
    PrintPlacement? placement,
    bool? printAreaResolved,
    RegisteredDesign? registeredDesign,
    PrintEstimate? estimate,
    CheckoutSession? checkoutSession,
    bool clearCheckoutSession = false,
    PrintOrderSummary? completedOrder,
    ShippingAddress? shippingAddress,
    String? errorMessage,
    String? progressMessage,
    bool clearError = false,
  }) {
    return PrintFlowState(
      step: step ?? this.step,
      status: status ?? this.status,
      recipe: recipe ?? this.recipe,
      products: products ?? this.products,
      variants: variants ?? this.variants,
      productPreviewByProductId:
          productPreviewByProductId ?? this.productPreviewByProductId,
      designPreviewBytes: designPreviewBytes ?? this.designPreviewBytes,
      exportPreviewBytes: clearExportPreviewBytes
          ? null
          : exportPreviewBytes ?? this.exportPreviewBytes,
      mockups: mockups ?? this.mockups,
      previewMockupUrl: clearPreviewMockupUrl
          ? null
          : previewMockupUrl ?? this.previewMockupUrl,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedSpec: selectedSpec ?? this.selectedSpec,
      phoneCaseBrand:
          clearPhoneCaseBrand ? null : phoneCaseBrand ?? this.phoneCaseBrand,
      phoneCaseFinish: phoneCaseFinish ?? this.phoneCaseFinish,
      phoneCaseVariantsByBrand: clearPhoneCaseVariantsByBrand
          ? const {}
          : phoneCaseVariantsByBrand ?? this.phoneCaseVariantsByBrand,
      selectedApparelColor: clearApparelSelection
          ? null
          : selectedApparelColor ?? this.selectedApparelColor,
      selectedApparelSize: clearApparelSelection
          ? null
          : selectedApparelSize ?? this.selectedApparelSize,
      placement: placement ?? this.placement,
      printAreaResolved: printAreaResolved ?? this.printAreaResolved,
      registeredDesign: registeredDesign ?? this.registeredDesign,
      estimate: estimate ?? this.estimate,
      checkoutSession:
          clearCheckoutSession ? null : checkoutSession ?? this.checkoutSession,
      completedOrder: completedOrder ?? this.completedOrder,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      progressMessage: progressMessage,
    );
  }

  @override
  List<Object?> get props => [
        step,
        status,
        recipe,
        products,
        variants,
        productPreviewByProductId,
        designPreviewBytes,
        exportPreviewBytes,
        mockups,
        previewMockupUrl,
        selectedProduct,
        selectedVariant,
        selectedSpec,
        phoneCaseBrand,
        phoneCaseFinish,
        phoneCaseVariantsByBrand,
        selectedApparelColor,
        selectedApparelSize,
        placement,
        printAreaResolved,
        registeredDesign,
        estimate,
        checkoutSession,
        completedOrder,
        shippingAddress,
        errorMessage,
        progressMessage,
      ];
}
