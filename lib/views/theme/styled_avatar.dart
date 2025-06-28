import 'package:flutter/material.dart';
import '../constants.dart';
import 'app_theme.dart';

class StyledAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool isActive;
  final IconData placeholderIcon;

  const StyledAvatar({
    Key? key,
    this.imageUrl,
    this.radius = 30,
    this.isActive = false,
    this.placeholderIcon = Icons.person,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.avatarDecoration(),
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: primaryColor.withOpacity(0.1),
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            child: imageUrl == null || imageUrl!.isEmpty
                ? Icon(placeholderIcon, size: radius, color: primaryColor)
                : null,
          ),
          // Active status indicator
          if (isActive != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: radius * 0.5,
                height: radius * 0.5,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}