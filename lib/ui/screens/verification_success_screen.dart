import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.surface,
      appBar: AppBar(
        title: const Text('PRISM', style: TextStyle(
          fontWeight: FontWeight.w900, 
          color: PrismColors.primary,
          letterSpacing: -1,
        )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PrismColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: PrismColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Checkmark Illustration
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.1), blurRadius: 40, spreadRadius: 10),
                ]
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade50,
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Success Text
            Text('Age Verified (18+)', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: PrismColors.onSurface,
              letterSpacing: -0.5,
            )),
            const SizedBox(height: 12),
            Text('Proof Shared Successfully', style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: PrismColors.primary,
            )),
            const SizedBox(height: 48),

            // Validation Details
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PrismColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  _buildValidationDetail(
                    Icons.shield, 
                    'Zero-Knowledge Proof Verified', 
                    'No personal data was shared with the requesting app.'
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: PrismColors.outlineVariant.withOpacity(0.2)),
                  ),
                  _buildValidationDetail(
                    Icons.fingerprint, 
                    'Biometrically Secured', 
                    'Authentication logged at 14:02 UTC.'
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.transparent,
                  shadowColor: PrismColors.primary.withOpacity(0.2),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ).copyWith(elevation: WidgetStateProperty.all(0)),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    child: const Text('Return to App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: PrismColors.surfaceContainerHighest,
                  foregroundColor: PrismColors.onSecondaryFixedVariant,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('View Proof Details', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildValidationDetail(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: PrismColors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: PrismColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(
                fontSize: 12,
                color: PrismColors.onSurfaceVariant,
                height: 1.5,
              )),
            ],
          ),
        )
      ],
    );
  }
}
