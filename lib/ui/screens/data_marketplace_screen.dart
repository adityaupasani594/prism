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

  @override
  void initState() {
    super.initState();
    _fetchMarketplaceRequests();
  }

  Future<void> _acceptMarketplaceOffer(Map<String, dynamic> request) async {
    final requestId = request['id']?.toString();
    if (requestId == null || requestId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid request id.')),
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
      );

      if (!mounted) return;

      setState(() {
        _requests = _requests.where((item) => item['id']?.toString() != requestId).toList();
      });

      final summary = (response['summary'] ?? 'Offer accepted successfully.').toString();
      final payoutId = (response['payout_id'] ?? '').toString();
      final reward = (response['reward_amount'] ?? request['reward_amount'] ?? 'N/A').toString();

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Offer Accepted'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reward: $reward'),
                const SizedBox(height: 8),
                Text('Payout ID: ${payoutId.isEmpty ? 'Pending' : payoutId}'),
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
        SnackBar(content: Text('Failed to accept offer: $e')),
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
        _errorMessage = 'Unable to load offers. Check backend connection and try again.';
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
            Text('PRISM', style: TextStyle(
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
          CircleAvatar(
            radius: 16,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/100?img=11'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Text(
              'Earn from Your Data',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: PrismColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Securely monetize your digital footprint while maintaining complete anonymity.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PrismColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Earning Potential Banner
            Container(
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
                  Text('ESTIMATED MONTHLY REVENUE', style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('₹1,450', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      )),
                      const SizedBox(width: 8),
                      Text('potential', style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        const Text('12% higher than last week', style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Offers List
            Text('Active Data Offers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
              const Center(child: Text("No active offers currently."))
            else
              ..._requests.map((req) {
                  final requestId = req['id']?.toString() ?? '';
                  final rewardAmount = req['reward_amount']?.toString() ?? '₹10';
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 16),
                   child: _buildOfferCard(
                    context,
                    icon: Icons.list_alt,
                    iconColor: PrismColors.primary,
                    bgColor: PrismColors.primary.withOpacity(0.1),
                    category: req['requester_name'] ?? 'Data Partner',
                    title: req['title']?.toString() ?? 'Data Offer',
                    price: rewardAmount,
                    timeLeft: 'Active Now',
                    onAccept: () => _acceptMarketplaceOffer(req),
                    isAccepting: _processingRequestIds.contains(requestId),
                   ),
                 );
              }).toList(),
            
            // Adding a few placeholder ones
            if (!_isLoading && _requests.isEmpty) ...[
              _buildOfferCard(
                context,
                icon: Icons.shopping_bag,
                iconColor: PrismColors.primary,
                bgColor: PrismColors.primary.withOpacity(0.1),
                category: 'Shopping preferences',
                title: 'Retail Analytics',
                price: '₹15',
                timeLeft: '3 days left',
                onAccept: () {},
                isAccepting: false,
              ),
              const SizedBox(height: 16),
              _buildOfferCard(
                context,
                icon: Icons.fitness_center,
                iconColor: PrismColors.tertiary,
                bgColor: PrismColors.tertiary.withOpacity(0.1),
                category: 'Fitness data insights',
                title: 'Vitality Pool',
                price: '₹20',
                timeLeft: '2 days left',
                onAccept: () {},
                isAccepting: false,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String category,
    required String title,
    required String price,
    required String timeLeft,
    required VoidCallback onAccept,
    required bool isAccepting,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PrismColors.surface,
        borderRadius: BorderRadius.circular(32),
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
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.toUpperCase(), style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: iconColor,
                      )),
                      const SizedBox(height: 4),
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  )
                ],
              ),
              Text(price, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: PrismColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(timeLeft, style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: PrismColors.onSurfaceVariant,
                  )),
                ],
              ),
              ElevatedButton(
                onPressed: isAccepting ? null : onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrismColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: isAccepting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }
}
