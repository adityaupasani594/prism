import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'ui/app_routes.dart';

void main() {
  runApp(const PrismApp());
}

class PrismApp extends StatelessWidget {
  const PrismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRISM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.onboardingOwnYourData, // Starts the new onboarding flow
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
