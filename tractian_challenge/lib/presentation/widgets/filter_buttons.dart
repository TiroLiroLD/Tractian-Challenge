import 'package:flutter/material.dart';
import 'package:tractian_challenge/themes/app_colors.dart';

class FilterButtons extends StatelessWidget {
  final bool isEnergySensorActive;
  final bool isCriticalStatusActive;
  final VoidCallback onEnergySensorFilter;
  final VoidCallback onCriticalStatusFilter;

  FilterButtons({
    required this.isEnergySensorActive,
    required this.isCriticalStatusActive,
    required this.onEnergySensorFilter,
    required this.onCriticalStatusFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16), // Padding at the start
        _buildFilterButton(
          context,
          isActive: isEnergySensorActive,
          onPressed: onEnergySensorFilter,
          icon: Icons.bolt,
          label: 'Sensor de Energia',
        ),
        const SizedBox(width: 8), // Space between buttons
        _buildFilterButton(
          context,
          isActive: isCriticalStatusActive,
          onPressed: onCriticalStatusFilter,
          icon: Icons.error_outline,
          label: 'Crítico',
        ),
        const SizedBox(width: 16), // Padding at the end
      ],
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required bool isActive,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon,
          color: isActive ? AppColors.buttonText : AppColors.buttonOffText),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4, // 20px line height / 14px font size
          color: isActive ? AppColors.buttonText : AppColors.buttonOffText,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? AppColors.buttonBackground
            : AppColors.buttonOffBackground,
        side: isActive
            ? const BorderSide(color: AppColors.buttonBackground)
            : const BorderSide(color: AppColors.buttonOffBorder),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        elevation: 0,
        // remove shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
