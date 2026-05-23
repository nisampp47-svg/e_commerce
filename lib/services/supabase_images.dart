import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseImage extends StatelessWidget {
  final String imageName;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SupabaseImage({
    super.key,
    required this.imageName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // We use getPublicUrl because it is static and perfect for caching.
    final imageUrl = Supabase.instance.client.storage
        .from('images')
        .getPublicUrl(imageName);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Shorter fade-in makes the app feel faster
      fadeInDuration: const Duration(milliseconds: 300),
      // This is shown while downloading
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      // This is shown if the image fails to load
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
