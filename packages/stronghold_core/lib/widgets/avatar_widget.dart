import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Avatar with optional network image and initials fallback.
class AvatarWidget extends StatelessWidget {
  final String initials;
  final double size;
  final String? imageUrl;
  final Gradient gradient;
  final Color textColor;
  final double borderRadius;

  const AvatarWidget({
    super.key,
    required this.initials,
    this.size = 40,
    this.imageUrl,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.textColor = const Color(0xFFF1F5F9),
    this.borderRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _initialsAvatar(),
        errorWidget: (context, url, error) => _initialsAvatar(),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    final fontSize = size * 0.38;
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
