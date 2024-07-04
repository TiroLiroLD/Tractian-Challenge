import 'package:flutter/material.dart';
import 'package:tractian_challenge/presentation/widgets/collapsible_widget.dart';
import 'package:tractian_challenge/presentation/widgets/tree_search_bar.dart';
import 'package:tractian_challenge/presentation/widgets/filter_buttons.dart';
import 'package:tractian_challenge/data/models/location.dart';
import 'package:tractian_challenge/data/models/asset.dart';
import 'package:tractian_challenge/themes/app_colors.dart';

class UnitPage extends StatefulWidget {
  final String unitName;
  final List<Location> locations;
  final List<Asset> assets;

  UnitPage({
    required this.unitName,
    required this.locations,
    required this.assets,
  });

  @override
  _UnitPageState createState() => _UnitPageState();
}

class _UnitPageState extends State<UnitPage> {
  bool isEnergySensorActive = false;
  bool isCriticalStatusActive = false;
  String searchText = '';

  void handleSearch(String text) {
    setState(() {
      searchText = text;
    });
  }

  void toggleEnergySensorFilter() {
    setState(() {
      isEnergySensorActive = !isEnergySensorActive;
    });
  }

  void toggleCriticalStatusFilter() {
    setState(() {
      isCriticalStatusActive = !isCriticalStatusActive;
    });
  }

  List<Asset> get filteredAssets {
    List<Asset> filtered = widget.assets;

    if (isEnergySensorActive) {
      filtered = filtered.where((asset) => asset.sensorType == 'energy').toList();
    }

    if (isCriticalStatusActive) {
      filtered = filtered.where((asset) => asset.status == 'critical').toList();
    }

    if (searchText.isNotEmpty) {
      filtered = filtered
          .where((asset) => asset.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unitName, style: const TextStyle(color: AppColors.headerText)),
      ),
      body: Column(
        children: [
          TreeSearchBar(onSearch: handleSearch),
          FilterButtons(
            isEnergySensorActive: isEnergySensorActive,
            isCriticalStatusActive: isCriticalStatusActive,
            onEnergySensorFilter: toggleEnergySensorFilter,
            onCriticalStatusFilter: toggleCriticalStatusFilter,
          ),
          Expanded(
            child: ListView(
              children: _buildCollapsibleWidgets(widget.locations, filteredAssets),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCollapsibleWidgets(List<Location> locations, List<Asset> assets) {
    return locations.map((location) {
      final locationAssets = assets.where((asset) => asset.locationId == location.id).toList();
      return CollapsibleWidget(
        title: location.name,
        icon: Icons.location_on,
        children: locationAssets.map((asset) {
          final assetComponents = assets.where((component) => component.parentId == asset.id).toList();
          return CollapsibleWidget(
            title: asset.name,
            icon: Icons.build,
            children: assetComponents.map((component) {
              return CollapsibleWidget(
                title: component.name,
                icon: Icons.memory,
                children: [],
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }
}
