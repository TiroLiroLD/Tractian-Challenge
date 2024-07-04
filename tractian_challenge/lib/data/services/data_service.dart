import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tractian_challenge/data/models/asset.dart';
import 'package:tractian_challenge/data/models/location.dart';

class DataService {
  Future<List<Map<String, dynamic>>> fetchUnits() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    final String configResponse = await rootBundle.loadString('assets/data/units_config.json');
    final List<dynamic> unitDirectories = json.decode(configResponse)['units'];

    final List<Map<String, dynamic>> units = [];

    for (final dir in unitDirectories) {
      final String locationsResponse = await rootBundle.loadString('assets/data/$dir/locations.json');
      final List<dynamic> locationsData = json.decode(locationsResponse);
      final List<Location> locations = locationsData.map((data) => Location.fromJson(data)).toList();

      final String assetsResponse = await rootBundle.loadString('assets/data/$dir/assets.json');
      final List<dynamic> assetsData = json.decode(assetsResponse);
      final List<Asset> assets = assetsData.map((data) => Asset.fromJson(data)).toList();

      final String unitName = _getUnitNameFromDirectory(dir);

      units.add({
        'name': unitName,
        'locations': locations,
        'assets': assets,
      });
    }

    return units;
  }

  String _getUnitNameFromDirectory(String dir) {
    final name = dir.replaceAll('_unit', '').replaceAll('_', ' ');
    return '${name[0].toUpperCase()}${name.substring(1)} Unit';
  }
}
