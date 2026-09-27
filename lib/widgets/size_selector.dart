import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

/// Row of square size boxes; the selected one is filled in black.
class SizeSelector extends StatelessWidget {
  const SizeSelector({
    super.key,
    required this.product,
    required this.selected,
    required this.onSelected,
    this.showError = false,
  });

  final Product product;
  final String? selected;
  final ValueChanged<String> onSelected;

  /// Highlights the selector when the customer tried to add without a size.
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final label = product.sizeKind.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: '$label : ',
            style: const TextStyle(color: AppColors.textSecondary),
            children: [
              TextSpan(
                text: selected ?? 'sélectionnez',
                style: TextStyle(
                  color: showError && selected == null ? AppColors.danger : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: product.sizes.map((size) {
            final isSelected = size == selected;
            return Semantics(
              button: true,
              selected: isSelected,
              label: '$label $size',
              child: InkWell(
                onTap: () => onSelected(size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  constraints: const BoxConstraints(minWidth: 46),
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.textPrimary : AppColors.surface,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.textPrimary
                          : (showError && selected == null ? AppColors.danger : const Color(0xFFBDB8AF)),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (showError && selected == null) ...[
          const SizedBox(height: 8),
          Text(
            'Veuillez choisir une ${label.toLowerCase().split(' ').first}.',
            style: const TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

class SizeGuideButton extends StatelessWidget {
  const SizeGuideButton({super.key, required this.kind});

  final SizeKind kind;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => showDialog(context: context, builder: (_) => _SizeGuideDialog(kind: kind)),
      icon: const Icon(Icons.straighten_rounded, size: 18),
      label: const Text('Guide des tailles'),
    );
  }
}

class _SizeGuideDialog extends StatelessWidget {
  const _SizeGuideDialog({required this.kind});

  final SizeKind kind;

  (List<String>, List<List<String>>) get _table {
    switch (kind) {
      case SizeKind.shoe:
        // Pointure européenne = 1,5 × (longueur du pied en cm + 1,5).
        return (
          ['Pointure (EU)', 'Longueur du pied'],
          [
            for (var size = 35; size <= 46; size++)
              ['$size', '${(size / 1.5 - 1.5).toStringAsFixed(1).replaceAll('.', ',')} cm'],
          ],
        );
      case SizeKind.belt:
        return (
          ['Taille ceinture', 'Tour de taille'],
          [
            for (var size = 80; size <= 110; size += 5) ['$size', '${size - 5} – ${size - 1} cm'],
          ],
        );
      case SizeKind.clothing:
      case SizeKind.oneSize:
        return (
          ['Taille', 'Équivalence FR', 'Tour de poitrine'],
          const [
            ['XS', '34', '80 – 86 cm'],
            ['S', '36 – 38', '86 – 92 cm'],
            ['M', '40', '92 – 98 cm'],
            ['L', '42 – 44', '98 – 104 cm'],
            ['XL', '46', '104 – 110 cm'],
            ['XXL', '48', '110 – 116 cm'],
            ['3XL', '50', '116 – 122 cm'],
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (headers, rows) = _table;
    return AlertDialog(
      title: const Text('Guide des tailles'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.symmetric(inside: const BorderSide(color: AppColors.border)),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: AppColors.background),
                  children: headers.map((h) => _cell(h, bold: true)).toList(),
                ),
                ...rows.map((row) => TableRow(children: row.map(_cell).toList())),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Entre deux tailles ? Choisissez la plus grande pour un porté plus ample.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fermer')),
      ],
    );
  }

  Widget _cell(String text, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(text, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
      );
}
