import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../app_routes.dart';

class GetPaidScreen extends StatelessWidget {
  const GetPaidScreen({Key? key}) : super(key: key);

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
                              width: 220,
                              height: 280,
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
                                children: [
                                  Positioned(
                                    top: -40,
                                    right: -40,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
                                          boxShadow: [
                                            BoxShadow(color: PrismColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                                          ]
                                        ),
                                        child: const Icon(Icons.payments, color: Colors.white, size: 36),
                                      ),
                                      const SizedBox(height: 32),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 32),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 8,
                                              width: double.infinity,
                                              decoration: BoxDecoration(color: PrismColors.surfaceContainerLow, borderRadius: BorderRadius.circular(4)),
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                height: 8,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: PrismColors.surfaceContainerHighest,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.auto_awesome, color: PrismColors.primary, size: 12),
                                                  const SizedBox(width: 4),
                                                  Text('REWARD EARNED', style: TextStyle(
                                                    color: PrismColors.primary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Text
                      Text('Get Paid', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: PrismColors.onSurface,
                        letterSpacing: -1,
                      )),
                      const SizedBox(height: 16),
                      Text('Earn rewards when you give consent to share data', 
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
                      _buildDot(false),
                      const SizedBox(width: 12),
                      _buildDot(true),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.onboardingCreate);
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
                          child: const Text('Get Started', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
