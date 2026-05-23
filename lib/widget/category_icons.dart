import 'package:flutter/material.dart';
import '../../model/category_model.dart';

class CategoryIcons extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryIcons({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Circle Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withAlpha(100), // ✅ brown when not selected
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                category.icon,
                size: 26,
                color:             // ✅ blue when tapped
                Colors.white,            // ✅ white when not selected
              ),
            ),

            const SizedBox(height: 8),

            /// Title
            Text(
              category.categoryTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color:
                const Color(0xFF6F6F6F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
