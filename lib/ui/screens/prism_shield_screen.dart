import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/colors.dart';

class PrismShieldScreen extends StatefulWidget {
  const PrismShieldScreen({Key? key}) : super(key: key);

  @override
  State<PrismShieldScreen> createState() => _PrismShieldScreenState();
}

class _PrismShieldScreenState extends State<PrismShieldScreen> {
  static const String _demoDid = 'did:prism:user123';

  bool _isLoading = true;
  bool _isSimulating = false;
  String? _message;
  Map<String, dynamic>? _activeConsent;
  List<dynamic> _auditEvents = [];

  @override
  void initState() {
    super.initState();
    _loadShieldState();
  }

  Future<void> _loadShieldState() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _message = null;
      });
    }

    try {
      final consentResponse = await ApiService().getConsentStatus(_demoDid);
      final auditLog = await ApiService().getShieldAuditLog(_demoDid);
      final consents = consentResponse['consents'];

      if (!mounted) return;
      setState(() {
        _activeConsent = consents is List && consents.isNotEmpty
            ? Map<String, dynamic>.from(consents.first as Map)
            : null;
        _auditEvents = auditLog;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _message = 'Unable to load Shield data. Approve a Consent Exchange request after starting the backend.';
      });
    }
  }

  Future<void> _simulateAccess({required bool overScope, required bool wrongPurpose}) async {
    final consent = _activeConsent;
    if (consent == null) {
      setState(() {
        _message = 'Approve one Consent Exchange request first, then return to Shield.';
      });
      return;
    }

    final fields = _fieldsFor(consent);
    final requestedFields = overScope
        ? <String>[...fields, 'workspace_env_vars', 'private_email']
        : (fields.isEmpty ? <String>['approved_signal'] : fields);

    final approvedPurpose = (consent['purpose'] ?? consent['purpose_tag'] ?? 'Approved purpose').toString();
    final purpose = wrongPurpose ? 'Unapproved AI workspace analysis' : approvedPurpose;

    setState(() {
      _isSimulating = true;
      _message = null;
    });

    try {
      final result = await ApiService().checkShieldAccess(
        userDid: _demoDid,
        consentId: consent['id'].toString(),
        requesterName: (consent['requester_name'] ?? 'Enterprise Partner').toString(),
        purpose: purpose,
        requestedFields: requestedFields,
        resource: overScope ? 'google_workspace_sensitive_assets' : 'approved_consented_dataset',
      );

      await _loadShieldState();
      if (!mounted) return;
      setState(() {
        _message = '${result['decision'].toString().toUpperCase()}: ${result['reason']}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Shield simulation failed: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSimulating = false;
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
            Icon(Icons.admin_panel_settings, color: PrismColors.primary),
            const SizedBox(width: 8),
            Text(
              'PRISM Shield',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: PrismColors.onSurface,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: PrismColors.onSurfaceVariant),
            onPressed: _loadShieldState,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enterprise Access Governance',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: PrismColors.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'After consent is granted, enterprises and AI tools can only access data through approved purpose, scope, and expiry.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PrismColors.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildPolicyCard(context),
              const SizedBox(height: 20),
              _buildSimulationCard(context),
              if (_message != null) ...[
                const SizedBox(height: 16),
                _buildMessage(_message!),
              ],
              const SizedBox(height: 24),
              _buildRiskCard(),
              const SizedBox(height: 24),
              _buildAuditLog(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard(BuildContext context) {
    final consent = _activeConsent;
    final fields = consent == null ? <String>[] : _fieldsFor(consent);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: PrismColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: PrismColors.outlineVariant.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PrismColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.policy, color: PrismColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consent == null ? 'No active policy yet' : (consent['requester_name'] ?? consent['purpose_tag']).toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      consent == null
                          ? 'Approve a Consent Exchange request to create a Shield policy.'
                          : (consent['purpose'] ?? consent['purpose_tag']).toString(),
                      style: TextStyle(fontSize: 12, color: PrismColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (consent != null) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fields.map((field) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: PrismColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    field.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PrismColors.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _buildPolicyRow('Disclosure', consent['disclosure_mode']?.toString().replaceAll('_', ' ') ?? 'verified proof'),
            _buildPolicyRow('Expires', consent['expiry_timestamp']?.toString() ?? 'Unknown'),
          ],
        ],
      ),
    );
  }

  Widget _buildSimulationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: PrismColors.inverseSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulate enterprise access',
            style: TextStyle(
              color: PrismColors.inverseOnSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These buttons call PRISM Shield. Allowed access passes; over-scope or wrong-purpose access is blocked and logged.',
            style: TextStyle(
              color: PrismColors.inverseOnSurface.withOpacity(0.75),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          _buildSimButton(
            label: 'Allowed access',
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: _isSimulating ? null : () => _simulateAccess(overScope: false, wrongPurpose: false),
          ),
          const SizedBox(height: 10),
          _buildSimButton(
            label: 'Block over-scope access',
            icon: Icons.block,
            color: PrismColors.error,
            onTap: _isSimulating ? null : () => _simulateAccess(overScope: true, wrongPurpose: false),
          ),
          const SizedBox(height: 10),
          _buildSimButton(
            label: 'Block wrong purpose',
            icon: Icons.warning,
            color: Colors.orange,
            onTap: _isSimulating ? null : () => _simulateAccess(overScope: false, wrongPurpose: true),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: PrismColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: PrismColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security, color: PrismColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'In a Vercel-style AI tool breach, Shield does not claim to stop the third-party compromise. It limits blast radius by giving the tool only narrow, temporary access to approved data.',
              style: TextStyle(
                color: PrismColors.onSurfaceVariant,
                height: 1.45,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLog(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audit Log',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        if (_auditEvents.isEmpty)
          Text(
            'No Shield access events yet.',
            style: TextStyle(color: PrismColors.onSurfaceVariant),
          )
        else
          ..._auditEvents.map((event) {
            final item = Map<String, dynamic>.from(event as Map);
            final decision = item['decision']?.toString() ?? 'blocked';
            final isAllowed = decision == 'allowed';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PrismColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isAllowed ? Colors.green.withOpacity(0.2) : PrismColors.error.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isAllowed ? Icons.check_circle : Icons.error,
                    color: isAllowed ? Colors.green : PrismColors.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          decision.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isAllowed ? Colors.green : PrismColors.error,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['reason']?.toString() ?? 'No reason provided',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (item['requested_fields'] as List<dynamic>? ?? const []).join(', '),
                          style: TextStyle(fontSize: 11, color: PrismColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildMessage(String message) {
    final isAllowed = message.startsWith('ALLOWED');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAllowed ? Colors.green.shade50 : PrismColors.errorContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isAllowed ? Colors.green.shade800 : PrismColors.onErrorContainer,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPolicyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: PrismColors.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  List<String> _fieldsFor(Map<String, dynamic> consent) {
    final scope = consent['scope'];
    final fields = scope is Map ? scope['fields'] : null;
    if (fields is List) {
      return fields.map((field) => field.toString()).toList();
    }
    final dataFields = consent['data_fields'];
    if (dataFields is Map) {
      final approved = dataFields['approved_fields'];
      if (approved is List) {
        return approved.map((field) => field.toString()).toList();
      }
      return dataFields.keys.map((field) => field.toString()).toList();
    }
    return const [];
  }
}
