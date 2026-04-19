import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'screens/consent_request_screen.dart';
import 'screens/business_dashboard_screen.dart';
import 'screens/identity_wallet_screen.dart';
import 'screens/create_identity_screen.dart';
import 'screens/generating_proof_screen.dart';
import 'screens/identity_secured_screen.dart';
import 'screens/data_marketplace_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wallet_dashboard_screen.dart';
import 'screens/active_access_screen.dart';
import 'screens/share_safely_screen.dart';
import 'screens/get_paid_screen.dart';
import 'screens/consent_details_screen.dart';
import 'screens/verification_request_screen.dart';
import 'screens/own_your_data_screen.dart';
import 'screens/verification_success_screen.dart';
import 'screens/consent_history_screen.dart';
import 'screens/privacy_dashboard_screen.dart';

class AppRoutes {
  static const String mainTheme = '/';
  
  // Onboarding Flow
  static const String onboardingOwnYourData = '/onboarding/own-your-data';
  static const String onboardingShareSafely = '/onboarding/share-safely';
  static const String onboardingGetPaid = '/onboarding/get-paid';
  static const String onboardingCreate = '/onboarding/create';
  static const String onboardingProof = '/onboarding/proof';
  static const String onboardingSecured = '/onboarding/secured';
  
  // Consent Flow
  static const String consentRequest = '/consent/request';
  static const String consentDetails = '/consent/details';
  static const String consentHistory = '/consent/history';
  static const String activeAccess = '/consent/active-access';
  
  // Verification Flow
  static const String verificationRequest = '/verification/request';
  static const String verificationSuccess = '/verification/success';
  
  // Core Dashboards & Utilities
  static const String businessDashboard = '/dashboard/business';
  static const String walletDashboard = '/dashboard/wallet';
  static const String dataMarketplace = '/marketplace';
  static const String settings = '/settings';
  static const String privacyDashboard = '/dashboard/privacy';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainTheme:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case onboardingOwnYourData:
        return MaterialPageRoute(builder: (_) => const OwnYourDataScreen());
      case onboardingShareSafely:
        return MaterialPageRoute(builder: (_) => const ShareSafelyScreen());
      case onboardingGetPaid:
        return MaterialPageRoute(builder: (_) => const GetPaidScreen());
      case onboardingCreate:
        return MaterialPageRoute(builder: (_) => const CreateIdentityScreen());
      case onboardingProof:
        return MaterialPageRoute(builder: (_) => const GeneratingProofScreen());
      case onboardingSecured:
        return MaterialPageRoute(builder: (_) => const IdentitySecuredScreen());
      case consentRequest:
        return MaterialPageRoute(builder: (_) => const ConsentRequestScreen());
      case consentDetails:
        return MaterialPageRoute(builder: (_) => const ConsentDetailsScreen());
      case consentHistory:
        return MaterialPageRoute(builder: (_) => const ConsentHistoryScreen());
      case activeAccess:
        return MaterialPageRoute(builder: (_) => const ActiveAccessScreen());
      case verificationRequest:
        return MaterialPageRoute(builder: (_) => const VerificationRequestScreen());
      case verificationSuccess:
        return MaterialPageRoute(builder: (_) => const VerificationSuccessScreen());
      // case businessDashboard:
        // return MaterialPageRoute(builder: (_) => const BusinessDashboardScreen());
      case walletDashboard:
        return MaterialPageRoute(builder: (_) => const WalletDashboardScreen());
      case dataMarketplace:
        return MaterialPageRoute(builder: (_) => const DataMarketplaceScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case privacyDashboard:
        return MaterialPageRoute(builder: (_) => const PrivacyDashboardScreen());
      default:
        return MaterialPageRoute(builder: (_) => const MainShell());
    }
  }
}
