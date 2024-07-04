// lib/presentation/pages/home_page.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tractian_challenge/data/services/data_service.dart';
import 'package:tractian_challenge/presentation/pages/unit_page.dart';
import 'package:tractian_challenge/themes/app_colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataService _dataService = DataService();
  late Future<List<Map<String, String>>> _unitsFuture;

  @override
  void initState() {
    super.initState();
    _unitsFuture = fetchUnitConfigs();
  }

  Future<List<Map<String, String>>> fetchUnitConfigs() async {
    final String configResponse = await rootBundle.loadString('assets/data/units_config.json');
    final List<dynamic> unitDirectories = json.decode(configResponse)['units'];

    final List<Map<String, String>> units = unitDirectories.map<Map<String, String>>((dir) {
      final String unitName = _getUnitNameFromDirectory(dir);
      return {
        'name': unitName,
        'locationFilePath': 'assets/data/$dir/locations.json',
        'assetFilePath': 'assets/data/$dir/assets.json',
      };
    }).toList();

    return units;
  }

  String _getUnitNameFromDirectory(String dir) {
    final name = dir.replaceAll('_unit', '').replaceAll('_', ' ');
    return '${name[0].toUpperCase()}${name.substring(1)} Unit';
  }

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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, String>>>(
          future: _unitsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No units available'));
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: snapshot.data!.map((unit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildUnitButton(
                      context,
                      unit['name']!,
                      unit['locationFilePath']!,
                      unit['assetFilePath']!,
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildUnitButton(BuildContext context, String unitName, String locationFilePath, String assetFilePath) {
    return Container(
      width: 317,
      height: 76,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnitPage(
                unitName: unitName,
                locationFilePath: locationFilePath,
                assetFilePath: assetFilePath,
              ),
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
