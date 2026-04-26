import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/glass_card.dart';
import '../widgets/power_button.dart';
import '../../theme/colors.dart';
import '../app_routes.dart';
import '../../services/api_service.dart';

class ConsentRequestScreen extends StatefulWidget {
  const ConsentRequestScreen({Key? key}) : super(key: key);

  @override
  State<ConsentRequestScreen> createState() => _ConsentRequestScreenState();
}

class _ConsentRequestScreenState extends State<ConsentRequestScreen> {
  static const String _demoDid = 'did:prism:user123';
  bool _isSubmitting = false;

  Future<void> _handleAllow() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService().grantConsent(
        userDid: _demoDid,
        purposeTag: 'Delivery tracking',
        dataFields: {
          'location': true,
          'requester': 'FastKart Delivery',
        },
        ttlSeconds: 7 * 24 * 60 * 60,
      );

      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.verificationSuccess);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to grant consent: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const TopAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consent Context Section
            Text(
              'Consent Request',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'A third-party application is requesting temporary access to your digital vault identity.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Requester Identity Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PrismColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Center(
                          child: Icon(Icons.local_shipping, color: PrismColors.primary, size: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FastKart Delivery',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'VERIFIED REQUESTER',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: PrismColors.primary,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: PrismColors.primary.withOpacity(0.2), width: 4),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '8.7',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: PrismColors.primary,
                                    ),
                              ),
                              Text(
                                'TRUST',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Glassmorphic Details Card
            GlassCard(
              padding: const EdgeInsets.all(32),
              borderRadius: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: PrismColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('PURPOSE', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Access your location for real-time delivery tracking and driver navigation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: PrismColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('DATA REQUESTED', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: PrismColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Location (Geo-Point)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PrismColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: PrismColors.outlineVariant, thickness: 0.2),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, color: PrismColors.onSurfaceVariant, size: 20),
                          const SizedBox(width: 8),
                          Text('Consent Duration', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      Text(
                        '7 days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: PrismColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            PowerButton(
              text: _isSubmitting ? 'Allowing...' : 'Allow',
              onPressed: _isSubmitting ? () {} : _handleAllow,
            ),
            const SizedBox(height: 16),
            PowerButton(
              text: 'Deny',
              isPrimary: false,
              onPressed: () {
                // In a real app, maybe go back or show a confirmation
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 32),

            // Security Footer
            Text(
              'Your encryption keys remain private. PRISM ensures that FastKart only receives anonymized coordinates for the duration specified.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
