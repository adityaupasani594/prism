import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/colors.dart';

class ActiveAccessScreen extends StatefulWidget {
  const ActiveAccessScreen({Key? key}) : super(key: key);

  @override
  State<ActiveAccessScreen> createState() => _ActiveAccessScreenState();
}

class _ActiveAccessScreenState extends State<ActiveAccessScreen> {
  static const String _demoDid = 'did:prism:user123';

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _activeConsents = [];
  final Set<String> _revokingConsentIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadActiveConsents();
  }

  Future<void> _loadActiveConsents() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiService().getConsentStatus(_demoDid);
      final consents = response['consents'];
      if (!mounted) return;
      setState(() {
        _activeConsents = consents is List<dynamic> ? consents : <dynamic>[];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load active access data.';
      });
    }
  }

  Future<void> _revokeConsentById(String consentId) async {
    if (_revokingConsentIds.contains(consentId)) return;

    setState(() {
      _revokingConsentIds.add(consentId);
    });

    try {
      await ApiService().revokeConsent(consentId);
      if (!mounted) return;
      setState(() {
        _activeConsents = _activeConsents
            .where((consent) => consent['id']?.toString() != consentId)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access revoked successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to revoke access: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _revokingConsentIds.remove(consentId);
      });
    }
  }

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
            Text('Privacy Vault', style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: PrismColors.onSurface,
              letterSpacing: -0.5,
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
            // Hero
            Text('Active Access', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: PrismColors.onSurface,
              letterSpacing: -1,
            )),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(color: PrismColors.onSurfaceVariant, fontSize: 14, height: 1.5),
                children: [
                  const TextSpan(text: 'You have '),
                  TextSpan(
                    text: '${_activeConsents.length} services',
                    style: TextStyle(fontWeight: FontWeight.bold, color: PrismColors.primary),
                  ),
                  const TextSpan(text: ' currently accessing your personal data ecosystem.'),
                ]
              )
            ),
            const SizedBox(height: 32),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null) ...[
              Center(
                child: Column(
                  children: [
                    Text(_errorMessage!, style: TextStyle(color: PrismColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: _loadActiveConsents, child: const Text('Retry')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else if (_activeConsents.isEmpty) ...[
              Center(
                child: Text(
                  'No active services currently.',
                  style: TextStyle(color: PrismColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              ..._activeConsents.map((consent) {
                final consentId = consent['id']?.toString() ?? '';
                final purposeTag = consent['purpose_tag']?.toString() ?? 'Unknown service';
                final dataFields = consent['data_fields']?.toString() ?? 'Data access';
                final expiry = consent['expiry_timestamp']?.toString() ?? 'N/A';
                final isRevoking = _revokingConsentIds.contains(consentId);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildAccessCard(
                    context,
                    company: purposeTag,
                    dataType: dataFields,
                    icon: Icons.lock_open,
                    iconColor: PrismColors.primary,
                    expiresText: 'Expires: $expiry',
                    progress: 0.6,
                    progressColor: PrismColors.primary,
                    isRevoking: isRevoking,
                    onRevoke: consentId.isEmpty ? null : () => _revokeConsentById(consentId),
                  ),
                );
              }),
            ],

            // Empty State
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: PrismColors.surfaceContainerLow.withOpacity(0.4),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: PrismColors.outlineVariant.withOpacity(0.3), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_moderator, size: 40, color: PrismColors.outline),
                  const SizedBox(height: 12),
                  const Text('Looking for more?', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Third-party integrations will appear here as they request access.', 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: PrismColors.outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Privacy Illustration
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: PrismColors.inverseSurface,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vault Security', style: TextStyle(
                    color: PrismColors.inverseOnSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
                  const SizedBox(height: 8),
                  Text('Your data remains encrypted and only accessible via the keys you provide.', style: TextStyle(
                    color: PrismColors.inverseOnSurface.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.5,
                  )),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildAvatar('https://i.pravatar.cc/100?img=5'),
                      Transform.translate(offset: const Offset(-12, 0), child: _buildAvatar('https://i.pravatar.cc/100?img=8')),
                      Transform.translate(
                        offset: const Offset(-24, 0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: PrismColors.surfaceContainerHighest,
                            border: Border.all(color: PrismColors.inverseSurface, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: const Text('+12', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PrismColors.inverseSurface, width: 2),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildAccessCard(BuildContext context, {
    required String company,
    required String dataType,
    required IconData icon,
    required Color iconColor,
    required String expiresText,
    required double progress,
    required Color progressColor,
    bool isWarning = false,
    bool isRevoking = false,
    VoidCallback? onRevoke,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: PrismColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(dataType.toUpperCase(), style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: PrismColors.onSurfaceVariant,
                      )),
                    ],
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: PrismColors.primaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('ACTIVE', style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: PrismColors.onPrimaryFixedVariant,
                )),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Access Lifecycle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PrismColors.onSurfaceVariant)),
              Text(expiresText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isWarning ? PrismColors.error : PrismColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: PrismColors.surfaceContainerHigh,
            color: progressColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: isRevoking ? null : onRevoke,
              icon: const Icon(Icons.cancel, size: 20),
              label: isRevoking
                  ? const Text('Revoking...', style: TextStyle(fontWeight: FontWeight.bold))
                  : const Text('Revoke Access', style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: PrismColors.errorContainer,
                foregroundColor: PrismColors.onErrorContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
