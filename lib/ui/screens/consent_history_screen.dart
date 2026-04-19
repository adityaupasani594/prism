import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../app_routes.dart';

class ConsentHistoryScreen extends StatelessWidget {
  const ConsentHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.surface,
      appBar: AppBar(
        title: const Text('Consent History', style: TextStyle(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Tab Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('All', true),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.activeAccess);
                    },
                    child: _buildTab('Active', false)
                  ),
                  const SizedBox(width: 8),
                  _buildTab('Expired', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search & Summary Stats
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Active', '12', Icons.shield, PrismColors.primary, PrismColors.primary.withOpacity(0.1))),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Total', '48', Icons.history, Colors.white, Colors.white.withOpacity(0.4))),
              ],
            ),
            const SizedBox(height: 32),

            // Latest List
            Text('Recent Permissions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Card 1: Active
            _buildHistoryCard(
              context,
              company: 'FastKart Delivery',
              status: 'Active',
              statusColor: Colors.green,
              lastAccessed: 'Last accessed: 2h ago',
              icon: Icons.shopping_cart,
              tags: ['Location', 'Purchase History'],
              duration: '7 days',
              actionText: 'Manage',
              onTapAction: () {
                Navigator.pushNamed(context, AppRoutes.consentDetails);
              },
            ),
            const SizedBox(height: 16),

            // Card 2: Expired
            Opacity(
              opacity: 0.7,
              child: _buildHistoryCard(
                context,
                company: 'HealthyLife',
                status: 'Expired',
                statusColor: PrismColors.onSurfaceVariant,
                lastAccessed: 'Expired: Oct 24, 2023',
                icon: Icons.fitness_center,
                tags: ['Step Count'],
                duration: '30 days',
                actionText: 'Renew',
                onTapAction: () {
                   Navigator.pushNamed(context, AppRoutes.consentRequest);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Revoked
            _buildHistoryCard(
              context,
              company: 'EcoInsights',
              status: 'Revoked',
              statusColor: PrismColors.error,
              lastAccessed: 'Revoked by user',
              icon: Icons.eco,
              tags: ['Usage Analytics'],
              duration: 'One-time access',
              actionText: 'Re-authorize',
              isRevoked: true,
              onTapAction: () {
                 Navigator.pushNamed(context, AppRoutes.verificationRequest);
              },
            ),
            const SizedBox(height: 32),

            // Security Tip
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Privacy Checkup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('You have 3 active permissions that haven\'t been used in over 14 days.', style: TextStyle(
                    fontSize: 13, color: Colors.white.withOpacity(0.8), height: 1.5,
                  )),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.activeAccess);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: PrismColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: const Text('Review Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? PrismColors.primary : PrismColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(
        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
        fontSize: 14,
        color: isActive ? Colors.white : PrismColors.onSurfaceVariant,
      )),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PrismColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: iconColor == Colors.white ? null : const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
              color: iconColor == Colors.white ? Colors.white : null,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Icon(icon, color: iconColor == Colors.white ? PrismColors.primary : Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title.toUpperCase(), style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: PrismColors.onSurfaceVariant,
          )),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, {
    required String company, required String status, required Color statusColor, 
    required String lastAccessed, required IconData icon, required List<String> tags, 
    required String duration, required String actionText, bool isRevoked = false,
    VoidCallback? onTapAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRevoked ? PrismColors.surfaceContainerLowest : PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isRevoked ? PrismColors.error : PrismColors.outlineVariant.withOpacity(0.0)),
        boxShadow: [
          BoxShadow(
            color: PrismColors.onSurface.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ]
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
                      color: PrismColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: PrismColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(lastAccessed, style: TextStyle(fontSize: 12, color: PrismColors.onSurfaceVariant)),
                    ],
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isRevoked ? PrismColors.errorContainer : statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'Active') ...[
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                    ],
                    Text(status.toUpperCase(), style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isRevoked ? PrismColors.onErrorContainer : statusColor,
                    )),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: tags.map((t) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: PrismColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
              child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PrismColors.onSurfaceVariant)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Divider(color: PrismColors.outlineVariant.withOpacity(0.2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer, size: 14, color: PrismColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('Duration: $duration', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PrismColors.onSurfaceVariant)),
                ],
              ),
              GestureDetector(
                onTap: onTapAction,
                child: Text(actionText, style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12, color: status == 'Expired' ? PrismColors.onSurfaceVariant : PrismColors.primary,
                )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
