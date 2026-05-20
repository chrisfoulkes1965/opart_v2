import 'package:opart_v2/print/models/print_models.dart';
import 'package:opart_v2/print/models/print_spec_templates.dart';

enum PhoneCaseBrand {
  iphone(PrintSpecTemplates.phoneCaseProductId, 'iPhone'),
  samsung(PrintSpecTemplates.samsungPhoneCaseProductId, 'Samsung');

  const PhoneCaseBrand(this.productId, this.label);

  final int productId;
  final String label;

  static PhoneCaseBrand? forProductId(int productId) {
    for (final brand in PhoneCaseBrand.values) {
      if (brand.productId == productId) {
        return brand;
      }
    }
    return null;
  }
}

enum PhoneCaseFinish {
  glossy('Glossy'),
  matte('Matte');

  const PhoneCaseFinish(this.printfulColor);

  final String printfulColor;
}

class DeviceCaseModelGroup {
  const DeviceCaseModelGroup({
    required this.title,
    required this.models,
  });

  final String title;
  final List<String> models;
}

class DeviceCaseCatalog {
  DeviceCaseCatalog._();

  static List<String> uniqueModels(List<PrintVariant> variants) {
    final seen = <String>{};
    final models = <String>[];

    for (final variant in variants) {
      final model = variant.size.trim();
      if (model.isEmpty || seen.contains(model)) {
        continue;
      }
      seen.add(model);
      models.add(model);
    }

    models.sort((a, b) => _modelSortKey(b).compareTo(_modelSortKey(a)));
    return models;
  }

  static List<DeviceCaseModelGroup> groupModels({
    required List<String> models,
    required PhoneCaseBrand brand,
  }) {
    final grouped = <String, List<String>>{};

    for (final model in models) {
      final title = switch (brand) {
        PhoneCaseBrand.iphone => _iphoneGroupTitle(model),
        PhoneCaseBrand.samsung => _samsungGroupTitle(model),
      };
      grouped.putIfAbsent(title, () => []).add(model);
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => _groupSortKey(b.key).compareTo(_groupSortKey(a.key)));

    return entries
        .map(
          (entry) => DeviceCaseModelGroup(
            title: entry.key,
            models: entry.value,
          ),
        )
        .toList();
  }

  static List<String> filterModels(List<String> models, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return models;
    }

    return models
        .where((model) => model.toLowerCase().contains(trimmed))
        .toList();
  }

  static PrintVariant? findVariant({
    required List<PrintVariant> variants,
    required String modelSize,
    required PhoneCaseFinish finish,
  }) {
    for (final variant in variants) {
      if (variant.size == modelSize &&
          variant.color == finish.printfulColor &&
          variant.inStock) {
        return variant;
      }
    }
    return null;
  }

  static bool isAvailableForFinish({
    required List<PrintVariant> variants,
    required String modelSize,
    required PhoneCaseFinish finish,
  }) {
    return findVariant(
          variants: variants,
          modelSize: modelSize,
          finish: finish,
        ) !=
        null;
  }

  static String _iphoneGroupTitle(String model) {
    final match = RegExp(r'iPhone\s+(\d+)').firstMatch(model);
    if (match != null) {
      return 'iPhone ${match.group(1)} series';
    }
    return 'Older models';
  }

  static String _samsungGroupTitle(String model) {
    final sMatch = RegExp(r'Galaxy\s+S(\d+)').firstMatch(model);
    if (sMatch != null) {
      return 'Galaxy S${sMatch.group(1)} series';
    }

    final aMatch = RegExp(r'Galaxy\s+A(\d+)').firstMatch(model);
    if (aMatch != null) {
      return 'Galaxy A${aMatch.group(1)} series';
    }

    final noteMatch = RegExp(r'Galaxy\s+Note\s+(\d+)').firstMatch(model);
    if (noteMatch != null) {
      return 'Galaxy Note ${noteMatch.group(1)} series';
    }

    return 'Other Samsung models';
  }

  static int _modelSortKey(String model) {
    final iphoneMatch = RegExp(r'iPhone\s+(\d+)').firstMatch(model);
    if (iphoneMatch != null) {
      return int.tryParse(iphoneMatch.group(1)!) ?? 0;
    }

    final samsungNoteMatch = RegExp(r'Galaxy\s+Note\s+(\d+)').firstMatch(model);
    if (samsungNoteMatch != null) {
      return 1500000 + (int.tryParse(samsungNoteMatch.group(1)!) ?? 0);
    }

    final samsungSMatch = RegExp(r'Galaxy\s+S(\d+)').firstMatch(model);
    if (samsungSMatch != null) {
      return 2000000 + (int.tryParse(samsungSMatch.group(1)!) ?? 0);
    }

    final samsungAMatch = RegExp(r'Galaxy\s+A(\d+)').firstMatch(model);
    if (samsungAMatch != null) {
      return 1000000 + (int.tryParse(samsungAMatch.group(1)!) ?? 0);
    }

    return 0;
  }

  static int _groupSortKey(String title) {
    final iphoneMatch = RegExp(r'iPhone\s+(\d+)').firstMatch(title);
    if (iphoneMatch != null) {
      return int.tryParse(iphoneMatch.group(1)!) ?? 0;
    }

    final samsungNoteMatch = RegExp(r'Galaxy\s+Note\s+(\d+)').firstMatch(title);
    if (samsungNoteMatch != null) {
      return 1500000 + (int.tryParse(samsungNoteMatch.group(1)!) ?? 0);
    }

    final samsungSMatch = RegExp(r'Galaxy\s+S(\d+)').firstMatch(title);
    if (samsungSMatch != null) {
      return 2000000 + (int.tryParse(samsungSMatch.group(1)!) ?? 0);
    }

    final samsungAMatch = RegExp(r'Galaxy\s+A(\d+)').firstMatch(title);
    if (samsungAMatch != null) {
      return 1000000 + (int.tryParse(samsungAMatch.group(1)!) ?? 0);
    }

    return -1;
  }
}
