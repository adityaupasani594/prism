import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/glass_card.dart';
import '../../theme/colors.dart';

class IdentityWalletScreen extends StatefulWidget {
  const IdentityWalletScreen({Key? key}) : super(key: key);

  @override
  State<IdentityWalletScreen> createState() => _IdentityWalletScreenState();
}

class _IdentityWalletScreenState extends State<IdentityWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const TopAppBar(title: 'Identity Wallet'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Credentials',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your verified identities securely.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 32),

            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.badge, color: PrismColors.primary, size: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: PrismColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'VERIFIED',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: PrismColors.primary,
                              ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('State ID', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Issued by Dept. of Motor Vehicles', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
