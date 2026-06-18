import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/op_art_catalog.dart';

class OpArtCatalogPicker extends StatelessWidget {
  const OpArtCatalogPicker({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final OpArtType selectedType;
  final ValueChanged<OpArtType> onSelected;

  static const double _tileSize = 88;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _tileSize + 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: kOpArtCatalog.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final entry = kOpArtCatalog[index];
          final isSelected = entry.opArtType == selectedType;

          return SizedBox(
            width: _tileSize,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (isSelected) {
                    return;
                  }
                  HapticFeedback.lightImpact();
                  onSelected(entry.opArtType);
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: _tileSize,
                      height: _tileSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.cyan.shade700
                              : Colors.transparent,
                          width: 3,
                        ),
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          entry.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Righteous',
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
