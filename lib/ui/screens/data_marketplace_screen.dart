import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/api_service.dart';

class DataMarketplaceScreen extends StatefulWidget {
  const DataMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<DataMarketplaceScreen> createState() => _DataMarketplaceScreenState();
}

class _DataMarketplaceScreenState extends State<DataMarketplaceScreen> {
  static const String _demoDid = 'did:prism:user123';

  bool _isLoading = true;
  List<dynamic> _requests = [];
  String? _errorMessage;
  final Set<String> _processingRequestIds = <String>{};
  final Map<String, String> _selectedDisclosureModes = <String, String>{};

  static const Map<String, String> _modeLabels = {
    'regional_anonymized': 'Regional insight',
    'verified_proof': 'Verified proof',
    'limited_raw': 'Limited fields',
  };

  static const Map<String, String> _modeDescriptions = {
    'regional_anonymized': 'Default privacy mode. Only aggregate regional intelligence leaves PRISM.',
    'verified_proof': 'PRISM proves eligibility without exposing raw documents.',
    'limited_raw': 'Only approved fields are shared through PRISM Shield with expiry and audit logs.',
  };

  @override
  void initState() {
    super.initState();
    _fetchMarketplaceRequests();
  }

  Future<void> _acceptMarketplaceOffer(Map<String, dynamic> request) async {
    final requestId = request['id']?.toString();
    if (requestId == null || requestId.isEmpty || requestId.startsWith('demo-')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect the backend and seed requests to approve this item.')),
      );
      return;
    }

    setState(() {
      _processingRequestIds.add(requestId);
    });

    try {
      final response = await ApiService().respondToMarketplaceRequest(
        requestId: requestId,
        userDid: _demoDid,
        providedData: {
          'accepted_at': DateTime.now().toIso8601String(),
          'source': 'flutter_app',
        },
        disclosureMode: _selectedModeFor(request),
        requestedScope: _scopeFor(request),
      );

      if (!mounted) return;

      setState(() {
        _requests = _requests.where((item) => item['id']?.toString() != requestId).toList();
      });

      final summary = (response['summary'] ?? 'Consent approved successfully.').toString();
      final creditId = (response['payout_id'] ?? '').toString();
      final creditOffer = (response['credit_offer'] ?? request['credit_offer'] ?? request['reward_amount'] ?? 'N/A').toString();
      final outputType = (response['output_type'] ?? 'protected_output').toString();

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Consent Approved'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Credits reserved: $creditOffer'),
                const SizedBox(height: 8),
                Text('Credit ID: ${creditId.isEmpty ? 'Pending' : creditId}'),
                const SizedBox(height: 8),
                Text('Protected output: $outputType'),
                const SizedBox(height: 12),
                Text(summary),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve consent: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _processingRequestIds.remove(requestId);
      });
    }
  }

  Future<void> _fetchMarketplaceRequests() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final requests = await ApiService().getMarketplaceRequests();
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching requests: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load Consent Exchange requests. Check backend connection and try again.';
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
            Icon(Icons.security, color: PrismColors.primary),
            const SizedBox(width: 8),
            Text(
              'PRISM',
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
        actions: const [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11'),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Consent Exchange',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: PrismColors.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how your data creates value. PRISM defaults to anonymized regional insight and keeps every approval purpose-bound.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PrismColors.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 24),
            _buildCreditBanner(context),
            const SizedBox(height: 28),
            Text(
              'Enterprise Requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PrismColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _fetchMarketplaceRequests,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_requests.isEmpty)
              ..._fallbackCards(context)
            else
              ..._requests.map((req) {
                final request = Map<String, dynamic>.from(req as Map);
                final requestId = request['id']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildOfferCard(
                    context,
                    icon: Icons.hub,
                    iconColor: PrismColors.primary,
                    bgColor: PrismColors.primary.withOpacity(0.1),
                    category: request['category']?.toString() ?? request['requester_name']?.toString() ?? 'Data Partner',
                    title: request['title']?.toString() ?? 'Consent request',
                    price: (request['credit_offer'] ?? request['reward_amount'] ?? '10 credits').toString(),
                    timeLeft: _durationLabel(request),
                    request: request,
                    onAccept: () => _acceptMarketplaceOffer(request),
                    isAccepting: _processingRequestIds.contains(requestId),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PrismColors.primary, PrismColors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PrismColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AVAILABLE VALUE CREDITS',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '1,450',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                'credits',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Privacy-first participation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _fallbackCards(BuildContext context) {
    final List<Map<String, dynamic>> demos = [
      {
        'id': 'demo-retail',
        'category': 'Regional retail insight',
        'title': 'Shopping Preference Trends',
        'credit_offer': '150 credits',
        'duration_days': 21,
        'disclosure_modes': ['regional_anonymized', 'verified_proof'],
        'scope': {'fields': ['shopping_category', 'city_zone']},
      },
      {
        'id': 'demo-fitness',
        'category': 'Health research',
        'title': 'Fitness Lifestyle Pool',
        'credit_offer': '200 wellness credits',
        'duration_days': 30,
        'disclosure_modes': ['regional_anonymized', 'limited_raw'],
        'scope': {'fields': ['step_count_band', 'exercise_frequency']},
      },
    ];

    return demos.map((request) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildOfferCard(
          context,
          icon: Icons.list_alt,
          iconColor: PrismColors.primary,
          bgColor: PrismColors.primary.withOpacity(0.1),
          category: request['category'].toString(),
          title: request['title'].toString(),
          price: request['credit_offer'].toString(),
          timeLeft: _durationLabel(request),
          request: request,
          onAccept: () => _acceptMarketplaceOffer(request),
          isAccepting: false,
        ),
      );
    }).toList();
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String category,
    required String title,
    required String price,
    required String timeLeft,
    required Map<String, dynamic> request,
    required VoidCallback onAccept,
    required bool isAccepting,
  }) {
    final fields = _fieldsFor(request);
    final selectedMode = _selectedModeFor(request);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PrismColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: PrismColors.outlineVariant.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: PrismColors.onSurface.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          if (fields.isNotEmpty) ...[
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
                      letterSpacing: 0.5,
                      color: PrismColors.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 18),
          _buildDisclosureSelector(request, selectedMode),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: PrismColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    timeLeft,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: PrismColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isAccepting ? null : onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrismColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: isAccepting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDisclosureSelector(Map<String, dynamic> request, String selectedMode) {
    final requestId = request['id']?.toString() ?? '';
    final modes = _modesFor(request);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DISCLOSURE LEVEL',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: PrismColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modes.map((mode) {
            final isSelected = selectedMode == mode;
            return ChoiceChip(
              label: Text(_modeLabels[mode] ?? mode),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedDisclosureModes[requestId] = mode;
                });
              },
              selectedColor: PrismColors.primary.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? PrismColors.primary : PrismColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              side: BorderSide(
                color: isSelected ? PrismColors.primary.withOpacity(0.4) : PrismColors.outlineVariant.withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _modeDescriptions[selectedMode] ?? '',
          style: TextStyle(
            fontSize: 11,
            height: 1.35,
            color: PrismColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _selectedModeFor(Map<String, dynamic> request) {
    final requestId = request['id']?.toString() ?? '';
    return _selectedDisclosureModes[requestId] ?? _modesFor(request).first;
  }

  List<String> _modesFor(Map<String, dynamic> request) {
    final rawModes = request['disclosure_modes'];
    if (rawModes is List && rawModes.isNotEmpty) {
      return rawModes.map((mode) => mode.toString()).toList();
    }
    return const ['regional_anonymized', 'verified_proof', 'limited_raw'];
  }

  Map<String, dynamic> _scopeFor(Map<String, dynamic> request) {
    final scope = request['scope'];
    if (scope is Map<String, dynamic>) {
      return scope;
    }
    if (scope is Map) {
      return Map<String, dynamic>.from(scope);
    }
    return {'fields': _fieldsFor(request)};
  }

  List<String> _fieldsFor(Map<String, dynamic> request) {
    final scope = request['scope'];
    final fields = scope is Map ? scope['fields'] : null;
    if (fields is List) {
      return fields.map((field) => field.toString()).toList();
    }
    return const [];
  }

  String _durationLabel(Map<String, dynamic> request) {
    final days = request['duration_days'];
    if (days == null) return 'Purpose-bound';
    return '$days days';
  }
}
