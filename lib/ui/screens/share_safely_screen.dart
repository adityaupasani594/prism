import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../app_routes.dart';

class ShareSafelyScreen extends StatelessWidget {
  const ShareSafelyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: PrismColors.primary),
            const SizedBox(width: 8),
            Text('PRISM', style: TextStyle(
              fontWeight: FontWeight.w900, 
              color: PrismColors.primary,
              letterSpacing: -1,
            )),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.onboardingCreate);
            },
            child: Text('Skip', style: TextStyle(color: PrismColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration
                      SizedBox(
                        height: 250,
                        width: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [PrismColors.primary.withOpacity(0.1), Colors.transparent],
                                  radius: 1.0,
                                ),
                              ),
                            ),
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: PrismColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: PrismColors.onSurface.withOpacity(0.08),
                                    blurRadius: 40,
                                    offset: const Offset(0, 10),
                                  )
                                ]
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
                                    ),
                                    child: const Icon(Icons.share, color: Colors.white, size: 40),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: PrismColors.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.verified, color: PrismColors.primary, size: 20),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: PrismColors.outlineVariant.withOpacity(0.2)),
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                      ),
                                      child: Icon(Icons.key, color: PrismColors.onSurfaceVariant, size: 20),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Text
                      Text('Share Safely', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: PrismColors.onSurface,
                        letterSpacing: -1,
                      )),
                      const SizedBox(height: 16),
                      Text('Only share what is necessary using secure verification', 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: PrismColors.onSurfaceVariant,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Area
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(false),
                      const SizedBox(width: 12),
                      _buildDot(true),
                      const SizedBox(width: 12),
                      _buildDot(false),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.onboardingGetPaid);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.transparent, // Let Container handle gradient
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ).copyWith(
                        elevation: WidgetStateProperty.all(0),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? PrismColors.primary : PrismColors.outlineVariant.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
