import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/api_service.dart';

class WalletDashboardScreen extends StatefulWidget {
  const WalletDashboardScreen({Key? key}) : super(key: key);

  @override
  State<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends State<WalletDashboardScreen> {
  static const String _demoDid = 'did:prism:user123';

  bool _isLoading = true;
  String? _errorMessage;
  String _walletBalance = '0';

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiService().getWalletStatus(_demoDid);
      if (!mounted) return;
      setState(() {
        _walletBalance = (response['token_balance'] ?? '0').toString();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load wallet balance.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.background,
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
            icon: Icon(Icons.notifications, color: PrismColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Hero Section
            Center(
              child: Column(
                children: [
                  Text('TOTAL VAULT BALANCE', style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: PrismColors.onSurfaceVariant.withOpacity(0.7),
                  )),
                  const SizedBox(height: 8),
                  Text('₹$_walletBalance', style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: PrismColors.onSurface,
                    letterSpacing: -1,
                    height: 1.0,
                  )),
                  if (_isLoading) ...[
                    const SizedBox(height: 8),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(fontSize: 12, color: PrismColors.error),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle, color: Colors.green.shade700, size: 14),
                        const SizedBox(width: 4),
                        Text('+₹18 earned from recent consent', style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadWallet,
                    icon: const Icon(Icons.account_balance_wallet, size: 20),
                    label: const Text('Refresh Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PrismColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 8,
                      shadowColor: PrismColors.primary.withOpacity(0.5),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatCard(context, 'Privacy Score', 'High', Icons.security, PrismColors.primary, PrismColors.primary.withOpacity(0.1))),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, 'Data Points', '42 Units', Icons.token, PrismColors.tertiary, PrismColors.tertiary.withOpacity(0.1))),
              ],
            ),
            const SizedBox(height: 32),

            // Transaction Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                Text('VIEW ALL', style: TextStyle(
                  color: PrismColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                )),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTransactionItem(context, 'Shared location data', 'Today, 2:15 PM', '+₹18', Icons.location_on, Colors.indigo.shade600, Colors.indigo.shade50),
            _buildTransactionItem(context, 'Shopping preferences', 'Yesterday, 5:40 PM', '+₹12', Icons.shopping_basket, Colors.purple.shade600, Colors.purple.shade50),
            _buildTransactionItem(context, 'Health stats consent', '24 Oct, 2023', '+₹5', Icons.health_and_safety, Colors.blue.shade600, Colors.blue.shade50, isPassive: true),
            
            const SizedBox(height: 32),

            // Security Badge Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PrismColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.fingerprint, color: PrismColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Secure Consent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Your data is encrypted with military-grade PRISM protocols.', style: TextStyle(
                          fontSize: 12,
                          color: PrismColors.onSurfaceVariant,
                          height: 1.5,
                        )),
                      ],
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

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: PrismColors.onSurfaceVariant,
          )),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, String title, String time, String amount, IconData icon, Color iconColor, Color bgColor, {bool isPassive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Opacity(
        opacity: isPassive ? 0.8 : 1.0,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(time, style: TextStyle(fontSize: 11, color: PrismColors.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.green.shade600,
                )),
                const SizedBox(height: 2),
                Text('VERIFIED', style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: PrismColors.onSurfaceVariant,
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
