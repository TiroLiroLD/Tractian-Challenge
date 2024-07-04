import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tractian_challenge/presentation/widgets/collapsible_widget.dart';
import 'package:tractian_challenge/presentation/widgets/tree_search_bar.dart';
import 'package:tractian_challenge/presentation/widgets/filter_buttons.dart';
import 'package:tractian_challenge/data/models/location.dart';
import 'package:tractian_challenge/data/models/asset.dart';
import 'package:tractian_challenge/themes/app_colors.dart';
import 'package:tractian_challenge/providers.dart';

class UnitPage extends ConsumerWidget {
  final String unitName;
  final List<Location> locations;
  final String assetFilePath;

  UnitPage({
    required this.unitName,
    required this.locations,
    required this.assetFilePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnergySensorActive = ref.watch(energySensorFilterProvider);
    final isCriticalStatusActive = ref.watch(criticalStatusFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final assetsAsyncValue = ref.watch(assetsProvider(assetFilePath));

    List<Asset> filteredAssets = [];
    assetsAsyncValue.when(
      data: (assets) {
        filteredAssets = assets;
        if (isEnergySensorActive) {
          filteredAssets = filteredAssets.where((asset) => asset.sensorType == 'energy').toList();
        }
        if (isCriticalStatusActive) {
          filteredAssets = filteredAssets.where((asset) => asset.status == 'critical').toList();
        }
        if (searchQuery.isNotEmpty) {
          filteredAssets = filteredAssets
              .where((asset) => asset.name.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
        }
      },
      loading: () {},
      error: (error, stack) {
        return Center(child: Text('Error: $error'));
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(unitName, style: const TextStyle(color: AppColors.headerText)),
      ),
      body: Column(
        children: [
          TreeSearchBar(
            onSearch: (text) {
              ref.read(searchQueryProvider.notifier).state = text;
            },
          ),
          FilterButtons(
            isEnergySensorActive: isEnergySensorActive,
            isCriticalStatusActive: isCriticalStatusActive,
            onEnergySensorFilter: () {
              ref.read(energySensorFilterProvider.notifier).state = !isEnergySensorActive;
            },
            onCriticalStatusFilter: () {
              ref.read(criticalStatusFilterProvider.notifier).state = !isCriticalStatusActive;
            },
          ),
          Expanded(
            child: assetsAsyncValue.when(
              data: (assets) {
                final _assetsByParentId = <String, List<Asset>>{};
                for (var asset in assets) {
                  _assetsByParentId.putIfAbsent(asset.parentId ?? '', () => []).add(asset);
                }
                return ListView(
                  children: _buildCollapsibleWidgets(locations, filteredAssets, _assetsByParentId),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCollapsibleWidgets(
      List<Location> locations, List<Asset> assets, Map<String, List<Asset>> assetsByParentId) {
    return locations.map((location) {
      final locationAssets = assets.where((asset) => asset.locationId == location.id).toList();
      return CollapsibleWidget(
        title: location.name,
        icon: Icons.location_on,
        children: _buildAssetWidgets(locationAssets, assetsByParentId),
      );
    }).toList();
  }

  List<Widget> _buildAssetWidgets(List<Asset> assets, Map<String, List<Asset>> assetsByParentId) {
    return assets.map((asset) {
      final assetComponents = assetsByParentId[asset.id] ?? [];
      return CollapsibleWidget(
        title: asset.name,
        icon: Icons.build,
        children: _buildAssetWidgets(assetComponents, assetsByParentId),
      );
    }).toList();
  }
}
