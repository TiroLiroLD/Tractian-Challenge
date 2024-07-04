import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tractian_challenge/data/services/data_service.dart';
import 'data/models/node.dart';

final dataServiceProvider = Provider((ref) => DataService());

final energySensorFilterProvider = StateProvider<bool>((ref) => false);
final criticalStatusFilterProvider = StateProvider<bool>((ref) => false);
final searchQueryProvider = StateProvider<String>((ref) => '');

final locationsProvider = FutureProvider.family<List<Node>, String>((ref, filePath) async {
  final dataService = ref.read(dataServiceProvider);
  final locationsJson = await dataService.fetchLocations(filePath);
  return locationsJson.map((json) {
    return Node.fromJson({...json, 'locationNode': true});
  }).toList();
});

final assetsProvider = FutureProvider.family<List<Node>, String>((ref, filePath) async {
  final dataService = ref.read(dataServiceProvider);
  final assetsJson = await dataService.fetchAssets(filePath);
  return assetsJson.map((json) => Node.fromJson(json)).toList();
});
