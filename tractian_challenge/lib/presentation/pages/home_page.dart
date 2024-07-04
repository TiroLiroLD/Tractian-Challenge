import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tractian_challenge/data/services/data_service.dart';
import 'package:tractian_challenge/presentation/pages/unit_page.dart';
import 'package:tractian_challenge/themes/app_colors.dart';
import 'package:tractian_challenge/data/models/asset.dart';
import 'package:tractian_challenge/data/models/location.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataService _dataService = DataService();
  late Future<List<Map<String, dynamic>>> _unitsFuture;

  @override
  void initState() {
    super.initState();
    _unitsFuture = _dataService.fetchUnits();
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
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
                      unit['name'],
                      unit['locations'],
                      unit['assets'],
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

  Widget _buildUnitButton(
      BuildContext context, String unitName, List<Location> locations, List<Asset> assets) {
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
                locations: locations,
                assets: assets,
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
