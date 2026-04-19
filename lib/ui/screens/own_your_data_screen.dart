import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../app_routes.dart';

class OwnYourDataScreen extends StatelessWidget {
  const OwnYourDataScreen({Key? key}) : super(key: key);

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
                        height: 300,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 240,
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: Colors.white.withOpacity(0.4)),
                                boxShadow: [
                                  BoxShadow(
                                    color: PrismColors.onSurface.withOpacity(0.04),
                                    blurRadius: 40,
                                    offset: const Offset(0, 10),
                                  )
                                ]
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Data nodes
                                  Positioned(
                                    top: -10,
                                    right: -10,
                                    child: Transform.rotate(
                                      angle: 0.2,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: PrismColors.surfaceContainerLowest,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                                        ),
                                        child: Icon(Icons.storage, color: PrismColors.tertiary, size: 30),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 40,
                                    left: -20,
                                    child: Transform.rotate(
                                      angle: -0.2,
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: PrismColors.surfaceContainerLowest,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                                        ),
                                        child: Icon(Icons.fingerprint, color: PrismColors.primary, size: 28),
                                      ),
                                    ),
                                  ),
                                  // Central Icon
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
                                      boxShadow: [
                                        BoxShadow(color: PrismColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                                      ]
                                    ),
                                    child: const Icon(Icons.verified_user, color: Colors.white, size: 48),
                                  ),
                                  // Bottom lines
                                  Positioned(
                                    bottom: 30,
                                    child: Column(
                                      children: [
                                        Container(width: 120, height: 8, decoration: BoxDecoration(color: PrismColors.surfaceContainerHigh.withOpacity(0.5), borderRadius: BorderRadius.circular(4))),
                                        const SizedBox(height: 8),
                                        Container(width: 160, height: 8, decoration: BoxDecoration(color: PrismColors.surfaceContainerHigh.withOpacity(0.5), borderRadius: BorderRadius.circular(4))),
                                      ],
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
                      Text('Own Your Data', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: PrismColors.onSurface,
                        letterSpacing: -1,
                      )),
                      const SizedBox(height: 16),
                      Text('Take control of your personal data and earn from it.', 
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
                      _buildDot(true),
                      const SizedBox(width: 12),
                      _buildDot(false),
                      const SizedBox(width: 12),
                      _buildDot(false),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.onboardingShareSafely);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.transparent, 
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
