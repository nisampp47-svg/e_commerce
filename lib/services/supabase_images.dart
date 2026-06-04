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

    final imageUrl = Supabase.instance.client.storage
        .from('images')
        .getPublicUrl(imageName);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,

      // Fix: Use memCacheWidth/Height to avoid "Can't acquire next buffer" errors.
      // This limits the decoded image size in the graphics buffer.
      memCacheWidth: (width != null && width! > 0 && width != double.infinity)
          ? (width! * MediaQuery.of(context).devicePixelRatio).round()
          : 500, // Default max width for decoded images
      memCacheHeight: (height != null && height! > 0 && height != double.infinity)
          ? (height! * MediaQuery.of(context).devicePixelRatio).round()
          : null,
      
      fadeInDuration: const Duration(milliseconds: 300),
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
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
