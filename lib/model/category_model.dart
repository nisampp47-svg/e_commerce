import 'package:flutter/material.dart';

class CategoryModel {
  final String categoryId;
  final String categoryTitle;
  final IconData icon;

  const CategoryModel({
    required this.categoryId,
    required this.categoryTitle,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] as String,
      categoryTitle: json['category_title'] as String,
      // Icon mapping logic based on standard string names from database
      icon: _getIconFromString(json['icon_name'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    'category_title': categoryTitle,
    'icon_name': icon.codePoint.toString(), // Simplified serialization
  };

  static IconData _getIconFromString(String name) {
    switch (name) {
      case 'weekend': return Icons.weekend;
      case 'chair': return Icons.chair;
      case 'table_restaurant': return Icons.table_restaurant;
      case 'bed': return Icons.bed;
      default: return Icons.grid_view_rounded;
    }
  }
}