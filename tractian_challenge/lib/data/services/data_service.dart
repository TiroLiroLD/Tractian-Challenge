// lib/data/services/data_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/node.dart';

class DataService {
  Future<List<Map<String, dynamic>>> fetchLocations(String filePath) async {
    final String locationsJson = await rootBundle.loadString(filePath);
    final List<dynamic> locationsData = json.decode(locationsJson);
    return locationsData.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchAssets(String filePath) async {
    final String assetsJson = await rootBundle.loadString(filePath);
    final List<dynamic> assetsData = json.decode(assetsJson);
    return assetsData.cast<Map<String, dynamic>>();
  }
}