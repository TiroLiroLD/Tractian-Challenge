import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tractian_challenge/presentation/widgets/collapsible_widget.dart';
import 'package:tractian_challenge/presentation/widgets/tree_search_bar.dart';
import 'package:tractian_challenge/presentation/widgets/filter_buttons.dart';
import 'package:tractian_challenge/data/models/location.dart';
import 'package:tractian_challenge/data/models/asset.dart';
import 'package:tractian_challenge/themes/app_colors.dart';
import 'package:tractian_challenge/providers.dart';

class UnitPage extends ConsumerStatefulWidget {
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

class _UnitPageState extends ConsumerState<UnitPage> {
  late List<Asset> _allAssets;
  late List<Asset> _filteredAssets;
  late Map<String, List<Asset>> _assetsByParentId;

  @override
  void dispose() {
    ref.read(energySensorFilterProvider.notifier).state = false;
    ref.read(criticalStatusFilterProvider.notifier).state = false;
    ref.read(searchQueryProvider.notifier).state = '';
    super.dispose();
  }

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
              _filteredAssets = _applyFilters(ref, assets, isEnergySensorActive, isCriticalStatusActive, searchQuery);
              _assetsByParentId = _buildAssetsByParentId(_filteredAssets);
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
                    final assetsToDisplay = _filteredAssets;
                    return ListView(
                      children: _buildCollapsibleWidgets(ref, widget.locations, _assetsByParentId, isEnergySensorActive || isCriticalStatusActive || searchQuery.isNotEmpty),
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

  List<Asset> _applyFilters(WidgetRef ref, List<Asset> assets, bool isEnergySensorActive, bool isCriticalStatusActive, String searchQuery) {
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

    if (filtered.isEmpty && searchQuery.isNotEmpty) {
      return [];
    }

    return _retainRelevantAssetPaths(ref, assets, filtered);
  }

  List<Asset> _retainRelevantAssetPaths(WidgetRef ref, List<Asset> allAssets, List<Asset> filteredAssets) {
    if (filteredAssets.isEmpty) {
      return [];
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

  List<Widget> _buildCollapsibleWidgets(WidgetRef ref, List<Location> locations, Map<String, List<Asset>> assetsByParentId, bool filterActive) {
    return locations.map((location) {
      final locationAssets = assetsByParentId['']?.where((asset) => asset.locationId == location.id).toList() ?? [];
      return locationAssets.isNotEmpty || !filterActive
          ? CollapsibleWidget(
        title: location.name,
        iconPath: 'assets/images/icons/location.png',
        isExpanded: filterActive,
        disableCollapse: filterActive,
        children: _buildAssetWidgets(ref, locationAssets, assetsByParentId, filterActive),
      )
          : Container();
    }).toList();
  }

  List<Widget> _buildAssetWidgets(WidgetRef ref, List<Asset> assets, Map<String, List<Asset>> assetsByParentId, bool filterActive) {
    return assets.map((asset) {
      final assetComponents = assetsByParentId[asset.id] ?? [];
      return assetComponents.isNotEmpty || assetMatchesFilter(ref, asset, filterActive) || !filterActive
          ? CollapsibleWidget(
        title: asset.name,
        iconPath: asset.status != null ? 'assets/images/icons/component.png' : 'assets/images/icons/asset.png',
        status: asset.status,
        isExpanded: filterActive,
        disableCollapse: filterActive,
        children: _buildAssetWidgets(ref, assetComponents, assetsByParentId, filterActive),
      )
          : Container();
    }).toList();
  }

  bool assetMatchesFilter(WidgetRef ref, Asset asset, bool filterActive) {
    final searchQuery = ref.read(searchQueryProvider);
    if (filterActive && asset.sensorType == 'energy') {
      return true;
    }

    if (filterActive && asset.status == 'alert') {
      return true;
    }

    if (filterActive && searchQuery.isNotEmpty && asset.name.toLowerCase().contains(searchQuery.toLowerCase())) {
      return true;
    }

    return false;
  }
}
