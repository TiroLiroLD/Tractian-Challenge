import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tractian_challenge/data/models/asset.dart';
import 'package:tractian_challenge/data/services/data_service.dart';

final dataServiceProvider = Provider((ref) => DataService());

final energySensorFilterProvider = StateProvider<bool>((ref) => false);
final criticalStatusFilterProvider = StateProvider<bool>((ref) => false);
final searchQueryProvider = StateProvider<String>((ref) => '');

final assetsProvider = FutureProvider.family<List<Asset>, String>((ref, assetFilePath) async {
  final dataService = ref.read(dataServiceProvider);
  return await dataService.fetchAssets(assetFilePath);
});
