// lib/presentation/pages/unit_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tractian_challenge/presentation/widgets/collapsible_widget.dart';
import 'package:tractian_challenge/presentation/widgets/tree_search_bar.dart';
import 'package:tractian_challenge/presentation/widgets/filter_buttons.dart';
import 'package:tractian_challenge/themes/app_colors.dart';
import 'package:tractian_challenge/providers.dart';

import '../../data/models/node.dart';

class UnitPage extends ConsumerStatefulWidget {
  final String unitName;
  final String assetFilePath;
  final String locationFilePath;

  UnitPage({
    required this.unitName,
    required this.assetFilePath,
    required this.locationFilePath,
  });

  @override
  _UnitPageState createState() => _UnitPageState();
}

class _UnitPageState extends ConsumerState<UnitPage> {
  late Map<String, Node> _nodes;
  late List<Node> _rootNodes;

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
          final locationsAsyncValue = ref.watch(locationsProvider(widget.locationFilePath));

          return assetsAsyncValue.when(
            data: (assets) {
              return locationsAsyncValue.when(
                data: (locations) {
                  _nodes = buildNodeTree(locations, assets);
                  _rootNodes = _nodes.values.where((node) => node.parentId == null).toList();

                  _applyFilters(isEnergySensorActive, isCriticalStatusActive, searchQuery);

                  return Column(
                    children: [
                      TreeSearchBar(
                        onSearch: (text) {
                          ref.read(searchQueryProvider.notifier).state = text;
                          _applyFilters(isEnergySensorActive, isCriticalStatusActive, text);
                          setState(() {}); // Rebuild the widget tree
                        },
                      ),
                      FilterButtons(
                        isEnergySensorActive: isEnergySensorActive,
                        isCriticalStatusActive: isCriticalStatusActive,
                        onEnergySensorFilter: () {
                          ref.read(energySensorFilterProvider.notifier).state = !isEnergySensorActive;
                          _applyFilters(!isEnergySensorActive, isCriticalStatusActive, searchQuery);
                          setState(() {}); // Rebuild the widget tree
                        },
                        onCriticalStatusFilter: () {
                          ref.read(criticalStatusFilterProvider.notifier).state = !isCriticalStatusActive;
                          _applyFilters(isEnergySensorActive, !isCriticalStatusActive, searchQuery);
                          setState(() {}); // Rebuild the widget tree
                        },
                      ),
                      Expanded(
                        child: ListView(
                          children: _rootNodes.expand(buildTreeView).toList(),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
      ),
    );
  }

  Map<String, Node> buildNodeTree(List<Node> locations, List<Node> assets) {
    final Map<String, Node> nodes = {};

    for (var node in locations) {
      nodes[node.id] = Node(
        id: node.id,
        name: node.name,
        parentId: node.parentId,
        locationId: null,
        sensorType: null,
        status: null,
        children: [],
      );
    }

    for (var node in assets) {
      nodes[node.id] = Node(
        id: node.id,
        name: node.name,
        parentId: node.parentId,
        locationId: node.locationId,
        sensorType: node.sensorType,
        status: node.status,
        children: [],
      );
    }

    nodes.values.forEach((node) {
      final parentId = node.parentId ?? node.locationId;
      if (parentId != null && nodes.containsKey(parentId)) {
        nodes[parentId]!.children.add(node);
      }
    });

    return nodes;
  }

  void _applyFilters(bool isEnergySensorActive, bool isCriticalStatusActive, String searchQuery) {
    _rootNodes.forEach((node) {
      updateRenderStatus(node, isEnergySensorActive, isCriticalStatusActive, searchQuery);
    });
  }

  void updateRenderStatus(Node node, bool isEnergySensorActive, bool isCriticalStatusActive, String query) {
    node.shouldRender = applyAllFilters(node, isEnergySensorActive, isCriticalStatusActive, query);
    print('Node: ${node.name}, shouldRender: ${node.shouldRender}');

    for (var child in node.children) {
      updateRenderStatus(child, isEnergySensorActive, isCriticalStatusActive, query);
      if (child.shouldRender) {
        node.shouldRender = true;
      }
    }

    node.propagateRenderStatus();
  }

  bool applyAllFilters(Node node, bool isEnergySensorActive, bool isCriticalStatusActive, String query) {
    return searchQueryFilter(node, query) &&
        (!isEnergySensorActive || energySensorFilter(node)) &&
        (!isCriticalStatusActive || criticalStatusFilter(node));
  }

  bool energySensorFilter(Node node) {
    bool shouldRender = node.sensorType == 'energy';
    print('energySensorFilter called for node with id: ${node.id}, sensorType: ${node.sensorType}, shouldRender: $shouldRender');
    return shouldRender;
  }

  bool criticalStatusFilter(Node node) {
    bool shouldRender = node.status == 'alert';
    print('criticalStatusFilter called for node with id: ${node.id}, status: ${node.status}, shouldRender: $shouldRender');
    return shouldRender;
  }

  bool searchQueryFilter(Node node, String query) {
    bool shouldRender = node.name.toLowerCase().contains(query.toLowerCase());
    print('searchQueryFilter called for node with id: ${node.id}, name: ${node.name}, query: $query, shouldRender: $shouldRender');
    return shouldRender;
  }

  List<Widget> buildTreeView(Node node) {
    if (!node.shouldRender) return [];

    return [
      CollapsibleWidget(
        title: node.name,
        iconPath: node.sensorType != null ? 'assets/images/icons/component.png' : 'assets/images/icons/location.png',
        status: node.status,
        isExpanded: true,
        disableCollapse: false,
        children: node.children.where((child) => child.shouldRender).expand(buildTreeView).toList(),
      )
    ];
  }
}
