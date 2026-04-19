import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class ConsentDetailsScreen extends StatelessWidget {
  const ConsentDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.background,
      appBar: AppBar(
        title: const Text('Data Consent', style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: PrismColors.onSurface,
        )),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PrismColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PrismColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('PRISM ETHER', style: TextStyle(
              color: PrismColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            )),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero Section
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: PrismColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: PrismColors.onSurface.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ]
              ),
              child: Icon(Icons.shopping_cart, color: PrismColors.primary, size: 48),
            ),
            const SizedBox(height: 24),
            Text('FastKart Delivery', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: PrismColors.onSurface,
            )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: PrismColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: PrismColors.outlineVariant.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user, color: PrismColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text('Consent Health Score:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PrismColors.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  Text('8.7/10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: PrismColors.primary)),
                  const SizedBox(width: 4),
                  Text('HIGH TRUST', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: PrismColors.primary.withOpacity(0.6))),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details Container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Consent Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('LIVE AUTHORIZATION', style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: PrismColors.onSurfaceVariant.withOpacity(0.6),
                )),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildDetailItem(context, 'Data Shared', 'Location', Icons.location_on, PrismColors.primary),
            const SizedBox(height: 12),
            _buildDetailItem(context, 'Purpose', 'Delivery tracking', Icons.ads_click, PrismColors.tertiary),
            const SizedBox(height: 12),
            _buildDetailItem(context, 'Duration', '7 days', Icons.calendar_today, PrismColors.secondary),
            const SizedBox(height: 12),

            // Countdown Style
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXPIRES IN', style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  )),
                  const SizedBox(height: 8),
                  Text('6d 22h', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trust Indicators
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  _buildTrustItem('AES-256 Encrypted Transfer', Icons.lock),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: PrismColors.outlineVariant.withOpacity(0.1)),
                  ),
                  _buildTrustItem('Zero-Knowledge Proof Verified', Icons.shield),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: PrismColors.error,
                  backgroundColor: PrismColors.error.withOpacity(0.05),
                  side: BorderSide(color: PrismColors.error.withOpacity(0.2), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Revoke Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: PrismColors.surfaceContainerHighest,
                  foregroundColor: PrismColors.onSecondaryFixedVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Extend Consent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PrismColors.outlineVariant.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: PrismColors.onSurface.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: PrismColors.onSurfaceVariant,
                letterSpacing: 1.0,
              )),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTrustItem(String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: PrismColors.onSurfaceVariant, fontSize: 13)),
        const Spacer(),
        Icon(icon, color: PrismColors.onSurfaceVariant.withOpacity(0.4), size: 16),
      ],
    );
  }
}
