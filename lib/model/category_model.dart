import 'package:flutter/widgets.dart';

class CategoryModel {
  final String categoryId;
  final String categoryTitle;

  final IconData? icon;

  const CategoryModel({
    required this.categoryId,
    required this.categoryTitle,
    this.icon,
  });
}
