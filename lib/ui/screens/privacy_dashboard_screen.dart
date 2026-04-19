import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../app_routes.dart';

class PrivacyDashboardScreen extends StatelessWidget {
  const PrivacyDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.background,
      appBar: AppBar(
        title: Text('PRISM', style: TextStyle(
          fontWeight: FontWeight.w900, 
          color: PrismColors.primary,
          letterSpacing: -1,
        )),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: PrismColors.onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Earnings Section
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [PrismColors.primary, PrismColors.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: PrismColors.primary.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL EARNED', style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('₹1,570', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      )),
                      const SizedBox(width: 8),
                      Text('via Data Rewards', style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.5)),
                            ),
                            child: const Icon(Icons.lock, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 8), // Small gap
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.5)),
                            ),
                            child: const Icon(Icons.fingerprint, size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.walletDashboard);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: const Text('VIEW WALLET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Data Overview Section
            Row(
              children: [
                Expanded(
                  child: _buildBentoCard(
                    context, 
                    icon: Icons.verified_user, 
                    value: '12', 
                    label: 'Active Consents',
                    iconColor: PrismColors.primary,
                    bgColor: PrismColors.primary.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBentoCard(
                    context, 
                    icon: Icons.share, 
                    value: '48', 
                    label: 'Data Shared',
                    iconColor: PrismColors.tertiary,
                    bgColor: PrismColors.tertiary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Active Consents
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Consents', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.consentHistory);
                  },
                  child: Text('MANAGE ALL', style: TextStyle(
                    color: PrismColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 12,
                  )),
                )
              ],
            ),
            const SizedBox(height: 16),
            
            _buildConsentCard(
              context,
              company: 'FastKart Delivery',
              dataType: 'Location',
              icon: Icons.location_on,
              statusText: '6d 22h',
              subStatus: 'Expiring soon',
              isWarning: true,
            ),
            const SizedBox(height: 16),
            _buildConsentCard(
              context,
              company: 'HealthyLife',
              dataType: 'Step Count',
              icon: Icons.directions_walk,
              statusText: '29d 14h',
              subStatus: 'Active',
              isWarning: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCard(BuildContext context, {
    required IconData icon, required String value, required String label, required Color iconColor, required Color bgColor
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: PrismColors.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: PrismColors.onSurface.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PrismColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildConsentCard(BuildContext context, {
    required String company, required String dataType, required IconData icon, required String statusText, required String subStatus, required bool isWarning
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    child: Icon(Icons.business, color: PrismColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(icon, size: 14, color: PrismColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(dataType.toUpperCase(), style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: PrismColors.onSurfaceVariant,
                          )),
                        ],
                      )
                    ],
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: isWarning ? Colors.red : PrismColors.onSurface),
                      const SizedBox(width: 4),
                      Text(statusText, style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isWarning ? Colors.red : PrismColors.onSurface,
                      )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subStatus.toUpperCase(), style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: PrismColors.onSurfaceVariant,
                  )),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.consentDetails);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: PrismColors.surfaceContainerHighest,
                    foregroundColor: PrismColors.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text('View Audit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: PrismColors.onSurface,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text('Revoke Access', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
