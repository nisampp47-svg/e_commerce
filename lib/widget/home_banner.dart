import 'package:e_commerce/widget/shimmer_title.dart';
import 'package:flutter/material.dart';

import '../services/supabase_images.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          children: [

            /// Background Image
            Positioned.fill(
              child: SupabaseImage(
                imageName: 'brown_sofa.jpg',
                fit: BoxFit.cover,
              ),
            ),

            /// Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF6A5AE0), // deep purple
                      Color(0x006A5AE0), // transparent
                    ],
                  ),
                ),
              ),
            ),

            /// Text + Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text(
                    "NEW COLLECTION",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Modern Living\nSpace Design",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const ShimmerText(text:
                      "Explore Now", fontSize: 15, color: Colors.red,

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
