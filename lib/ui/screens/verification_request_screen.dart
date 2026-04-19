import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../app_routes.dart';

class VerificationRequestScreen extends StatelessWidget {
  const VerificationRequestScreen({Key? key}) : super(key: key);

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
        backgroundColor: Colors.white.withOpacity(0.6),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: PrismColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.lock, color: PrismColors.outline, size: 16),
              const SizedBox(width: 4),
              Text('SECURE SESSION', style: TextStyle(
                color: PrismColors.outline,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              )),
              const SizedBox(width: 16),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text('SECURITY PROTOCOL', style: TextStyle(
              color: PrismColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2.0,
            )),
            const SizedBox(height: 8),
            Text('Verification Request', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: PrismColors.onSurface,
            )),
            const SizedBox(height: 32),

            // Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: PrismColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: PrismColors.onSurface.withOpacity(0.04), blurRadius: 48, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Partner Info
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: PrismColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.shield, color: PrismColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Request from', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: PrismColors.onSurfaceVariant)),
                          const Text('A Partner App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Main Detail
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: PrismColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.fingerprint, color: PrismColors.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Verify Age (18+)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Provide a zero-knowledge proof of your age without sharing your identity or birth date.', style: TextStyle(
                                fontSize: 13,
                                color: PrismColors.onSurfaceVariant,
                                height: 1.5,
                              ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Trust Metrics
                  _buildTrustMetric('Your actual birth date remains hidden'),
                  const SizedBox(height: 12),
                  _buildTrustMetric('Zero-knowledge proof generated locally'),
                  const SizedBox(height: 40),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.verificationSuccess);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.transparent, // handled by ink
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
                          child: const Text('Generate Secure Proof', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Decline Request', style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: PrismColors.onSurfaceVariant,
                        fontSize: 14,
                      )),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Branding
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: PrismColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, color: PrismColors.primary, size: 14),
                    const SizedBox(width: 8),
                    Text('SECURED BY PRISM CRYPTOGRAPHY', style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: PrismColors.onSurfaceVariant,
                    )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTrustMetric(String text) {
    return Row(
      children: [
        const Icon(Icons.verified, color: Colors.green, size: 16),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: PrismColors.onSurfaceVariant))),
      ],
    );
  }
}
