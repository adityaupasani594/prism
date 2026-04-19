import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String profileImageUrl;
  final VoidCallback? onNotificationTap;

  const TopAppBar({
    Key? key,
    this.title = 'PRISM',
    this.profileImageUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuCzJgSkbhuH-N-8apycAsH0xekbHxUbjGXHAzfG-clzW5mzYe4JfIrFSYajuWij-gYeY_-LjKgfZUuBls89DBF1THtvlY-ZgxMPHQSHBTtK2LoBcQOC-dLD9NYJ1dd21rbCzWe82CJjymvw8QjEWdzKMb6llYzYKTNQh_9Yc1eW4jV0QGiwPchPnDsZ-WOdXnlJmjqpiFO_OGlhwdDEUpVxomCIGnA8F6SfYpwiOvNqK3ia2nZJaQJB3RCydS844_DaNCVCxiFAgCej',
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: PrismColors.surfaceBright.withOpacity(0.8),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PrismColors.surfaceContainerLow,
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: PrismColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(profileImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: PrismColors.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                            ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Icon(
                      Icons.verified_user,
                      color: PrismColors.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
