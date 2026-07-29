import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:glow_in_the_damp/models/project_model.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';
  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<FlameSafetyLampModel> filteredList(List<FlameSafetyLampModel> list) {
    if (searchQuery.isEmpty) return list;
    final query = searchQuery.toLowerCase();
    return list
        .where(
          (item) =>
              item.gauzeGridSeal.toLowerCase().contains(query) ||
              item.wireAlloy.label.toLowerCase().contains(query) ||
              item.wireAlloy.code.toLowerCase().contains(query) ||
              item.sleeveLayout.label.toLowerCase().contains(query) ||
              item.airInletPattern.label.toLowerCase().contains(query) ||
              item.glassGrade.label.toLowerCase().contains(query) ||
              item.originDisplay.toLowerCase().contains(query) ||
              item.notes.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)),
        )
        .toList();
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
