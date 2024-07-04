import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tractian_challenge/presentation/widgets/collapsible_widget.dart';
import 'package:tractian_challenge/presentation/widgets/tree_search_bar.dart';
import 'package:tractian_challenge/presentation/widgets/filter_buttons.dart';
import 'package:tractian_challenge/data/models/location.dart';
import 'package:tractian_challenge/data/models/asset.dart';
import 'package:tractian_challenge/themes/app_colors.dart';
import 'package:tractian_challenge/providers.dart';

class UnitPage extends StatefulWidget {
  final String unitName;
  final List<Location> locations;
  final String assetFilePath;

  UnitPage({
    required this.unitName,
    required this.locations,
    required this.assetFilePath,
  });

  @override
  _UnitPageState createState() => _UnitPageState();
}

class _UnitPageState extends State<UnitPage> {
  late List<Asset> _allAssets;
  late List<Asset> _filteredAssets;
  late Map<String, List<Asset>> _assetsByParentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unitName, style: const TextStyle(color: AppColors.headerText)),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final isEnergySensorActive = ref.watch(energySensorFilterProvider);
          final isCriticalStatusActive = ref.watch(criticalStatusFilterProvider);
          final searchQuery = ref.watch(searchQueryProvider);
          final assetsAsyncValue = ref.watch(assetsProvider(widget.assetFilePath));

          assetsAsyncValue.when(
            data: (assets) {
              _allAssets = assets;
              _filteredAssets = _applyFilters(assets, isEnergySensorActive, isCriticalStatusActive, searchQuery);
              _assetsByParentId = _buildAssetsByParentId(isEnergySensorActive || isCriticalStatusActive || searchQuery.isNotEmpty ? _filteredAssets : _allAssets);
            },
            loading: () {},
            error: (error, stack) {
              return Center(child: Text('Error: $error'));
            },
          );

          return Column(
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
                    final assetsToDisplay = isEnergySensorActive || isCriticalStatusActive || searchQuery.isNotEmpty ? _filteredAssets : _allAssets;
                    final _assetsByParentId = _buildAssetsByParentId(assetsToDisplay);
                    return ListView(
                      children: _buildCollapsibleWidgets(widget.locations, _assetsByParentId, isEnergySensorActive, isCriticalStatusActive, searchQuery),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Asset> _applyFilters(List<Asset> assets, bool isEnergySensorActive, bool isCriticalStatusActive, String searchQuery) {
    List<Asset> filtered = assets;

    if (isEnergySensorActive) {
      filtered = filtered.where((asset) => asset.sensorType == 'energy').toList();
    }

    if (isCriticalStatusActive) {
      filtered = filtered.where((asset) => asset.status == 'alert').toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((asset) => asset.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return _retainRelevantAssetPaths(assets, filtered);
  }

  List<Asset> _retainRelevantAssetPaths(List<Asset> allAssets, List<Asset> filteredAssets) {
    if (filteredAssets.isEmpty) {
      return allAssets;
    }

    final Set<String> relevantAssetIds = {};
    final Map<String, List<Asset>> assetsByParentId = _buildAssetsByParentId(allAssets);

    void collectRelevantAssets(Asset asset) {
      relevantAssetIds.add(asset.id);
      final children = assetsByParentId[asset.id] ?? [];
      for (final child in children) {
        if (filteredAssets.contains(child)) {
          relevantAssetIds.add(child.id);
        } else {
          collectRelevantAssets(child);
        }
      }
    }

    for (final asset in filteredAssets) {
      relevantAssetIds.add(asset.id);
      String? parentId = asset.parentId;
      while (parentId != null && parentId.isNotEmpty) {
        relevantAssetIds.add(parentId);
        final parent = allAssets.firstWhere((a) => a.id == parentId, orElse: () => Asset(id: '', name: '', locationId: null));
        if (parent.id.isNotEmpty) {
          parentId = parent.parentId;
        } else {
          break;
        }
      }
      collectRelevantAssets(asset);
    }

    return allAssets.where((asset) => relevantAssetIds.contains(asset.id)).toList();
  }

  Map<String, List<Asset>> _buildAssetsByParentId(List<Asset> assets) {
    final Map<String, List<Asset>> assetsByParentId = {};
    for (var asset in assets) {
      assetsByParentId.putIfAbsent(asset.parentId ?? '', () => []).add(asset);
    }
    return assetsByParentId;
  }

  List<Widget> _buildCollapsibleWidgets(List<Location> locations, Map<String, List<Asset>> assetsByParentId, bool isEnergySensorActive, bool isCriticalStatusActive, String searchQuery) {
    return locations.map((location) {
      final locationAssets = assetsByParentId['']?.where((asset) => asset.locationId == location.id).toList() ?? [];
      return locationAssets.isNotEmpty || !isEnergySensorActive && !isCriticalStatusActive && searchQuery.isEmpty
          ? CollapsibleWidget(
        title: location.name,
        icon: Icons.location_on,
        children: _buildAssetWidgets(locationAssets, assetsByParentId, isEnergySensorActive, isCriticalStatusActive, searchQuery),
      )
          : Container();
    }).toList();
  }

  List<Widget> _buildAssetWidgets(List<Asset> assets, Map<String, List<Asset>> assetsByParentId, bool isEnergySensorActive, bool isCriticalStatusActive, String searchQuery) {
    return assets.map((asset) {
      final assetComponents = assetsByParentId[asset.id] ?? [];
      return assetComponents.isNotEmpty || assetMatchesFilter(asset, isEnergySensorActive, isCriticalStatusActive, searchQuery) || !isEnergySensorActive && !isCriticalStatusActive && searchQuery.isEmpty
          ? CollapsibleWidget(
        title: asset.name,
        icon: Icons.build,
        status: asset.status, // Pass status to CollapsibleWidget
        children: _buildAssetWidgets(assetComponents, assetsByParentId, isEnergySensorActive, isCriticalStatusActive, searchQuery),
      )
          : Container();
    }).toList();
  }

  bool assetMatchesFilter(Asset asset, bool isEnergySensorActive, bool isCriticalStatusActive, String searchQuery) {
    if (isEnergySensorActive && asset.sensorType == 'energy') {
      return true;
    }

    if (isCriticalStatusActive && asset.status == 'alert') {
      return true;
    }

    if (searchQuery.isNotEmpty && asset.name.toLowerCase().contains(searchQuery.toLowerCase())) {
      return true;
    }

    return false;
  }
}
