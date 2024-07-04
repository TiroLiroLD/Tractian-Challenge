import 'package:flutter/material.dart';
import 'package:tractian_challenge/themes/app_colors.dart';

class TreeSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  TreeSearchBar({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.searchBoxBackground,
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar Ativo ou Local',
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4, // 20px line height / 14px font size
              color: AppColors.searchBoxIconColor,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.searchBoxIconColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.4, // 20px line height / 14px font size
            color: AppColors.searchBoxIconColor,
          ),
          onChanged: onSearch,
        ),
      ),
    );
  }
}
