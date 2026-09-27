import 'package:flutter/material.dart';

import '../controllers/store_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// "FEMME   HOMME" switch with an underline under the active universe.
class GenderTabs extends StatelessWidget {
  const GenderTabs({super.key, required this.controller});

  final StoreController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Gender.femme, Gender.homme].map((gender) {
        final selected = controller.gender == gender;
        return InkWell(
          onTap: () => controller.setGender(gender),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gender.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 3,
                  width: selected ? 64 : 0,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
