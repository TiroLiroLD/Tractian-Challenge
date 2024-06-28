import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:tractian_challenge/themes/app_colors.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/images/logos/tractian.svg',
          width: 126,
          height: 17,
          color: Theme.of(context).appBarTheme.iconTheme?.color,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true, // Center the title to match the design
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUnitButton(context, 'Jaguar Unit'),
            const Gap(16),
            _buildUnitButton(context, 'Tobias Unit'),
            const Gap(16),
            _buildUnitButton(context, 'Apex Unit'),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitButton(BuildContext context, String unitName) {
    return Container(
      width: 317, // Fixed width
      height: 76, // Fixed height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: () {
          // Navigate to the corresponding unit's page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnitPage(unitName: unitName),
            ),
          );
        },
        child: Text(
          unitName,
          style: const TextStyle(color: AppColors.buttonText),
        ),
      ),
    );
  }
}

class UnitPage extends StatelessWidget {
  final String unitName;

  const UnitPage({required this.unitName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          unitName,
          style: const TextStyle(color: AppColors.headerText),
        ),
        backgroundColor: AppColors.headerBackground,
      ),
      body: Center(
        child: Text('Details for $unitName'),
      ),
    );
  }
}
