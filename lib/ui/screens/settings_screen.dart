import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: PrismColors.primary.withOpacity(0.1), width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/100?img=11'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('PRISM', style: TextStyle(
              fontWeight: FontWeight.w900, 
              color: PrismColors.onSurface,
              letterSpacing: -1,
            )),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: PrismColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PrismColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: PrismColors.onSurface.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const CircleAvatar(
                        backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Alex Rivers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('DID: 0xA7...92K', style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PrismColors.onSurfaceVariant,
                  )),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: PrismColors.surfaceContainerHighest,
                        foregroundColor: PrismColors.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: const Text('View Identity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Privacy Controls
            _buildSectionHeader(Icons.security, 'Privacy Controls', PrismColors.primary),
            _buildSettingsBox([
              _buildSwitchTile('Always ask before sharing', true),
              _buildDivider(),
              _buildSwitchTile('Auto-expire consent', false),
              _buildDivider(),
              _buildActionTile('Default consent duration', '7 days', Icons.expand_more),
            ]),
            const SizedBox(height: 32),

            // Preferences
            _buildSectionHeader(Icons.tune, 'Preferences', PrismColors.tertiary),
            _buildSettingsBox([
              _buildActionTile('Language', 'English', Icons.chevron_right),
              _buildDivider(),
              _buildSwitchTile('Notifications', true),
            ]),
            const SizedBox(height: 32),

            // Security
            _buildSectionHeader(Icons.lock, 'Security', PrismColors.primary),
            _buildSettingsBox([
              _buildSwitchTile('Enable biometric lock', true),
              _buildDivider(),
              _buildActionTile('Set PIN', '', Icons.chevron_right),
            ]),
            const SizedBox(height: 32),

            // Danger Zone
            _buildSectionHeader(Icons.warning, 'Danger Zone', PrismColors.error),
            Container(
              decoration: BoxDecoration(
                color: PrismColors.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildDangerActionTile('Delete Account', Icons.delete_forever, true),
                  _buildDangerActionTile('Reset Identity', Icons.refresh, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSettingsBox(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(String title, bool value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          // Custom switch simulation
          Container(
            width: 48,
            height: 24,
            decoration: BoxDecoration(
              gradient: value ? const LinearGradient(colors: [PrismColors.primary, PrismColors.tertiary]) : null,
              color: value ? null : PrismColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.all(4),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String trailingText, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          Row(
            children: [
              if (trailingText.isNotEmpty)
                Text(trailingText, style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 12, 
                  color: PrismColors.primary,
                )),
              if (trailingText.isNotEmpty) const SizedBox(width: 8),
              Icon(icon, size: 16, color: PrismColors.onSurfaceVariant),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDangerActionTile(String title, IconData icon, bool isDestructive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 13,
            color: isDestructive ? PrismColors.error : PrismColors.onSurface,
          )),
          Icon(icon, size: 20, color: isDestructive ? PrismColors.error : PrismColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildDivider() => const SizedBox(height: 4);
}
