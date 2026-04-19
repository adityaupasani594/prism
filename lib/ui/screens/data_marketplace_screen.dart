import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class DataMarketplaceScreen extends StatelessWidget {
  const DataMarketplaceScreen({Key? key}) : super(key: key);

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
            
            _buildOfferCard(
              context,
              icon: Icons.shopping_bag,
              iconColor: PrismColors.primary,
              bgColor: PrismColors.primary.withOpacity(0.1),
              category: 'Shopping preferences',
              title: 'Retail Analytics',
              price: '₹15',
              timeLeft: '3 days left',
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
            ),
            const SizedBox(height: 16),
            _buildOfferCard(
              context,
              icon: Icons.public,
              iconColor: PrismColors.secondary,
              bgColor: PrismColors.secondary.withOpacity(0.1),
              category: 'Browsing habits',
              title: 'Web Patterns',
              price: '₹25',
              timeLeft: '5 days left',
            ),
             const SizedBox(height: 16),
            _buildOfferCard(
              context,
              icon: Icons.location_on,
              iconColor: PrismColors.onSurfaceVariant,
              bgColor: PrismColors.onSurfaceVariant.withOpacity(0.1),
              category: 'Location history (Low res)',
              title: 'Traffic Node',
              price: '₹10',
              timeLeft: '24 hours left',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, {
    required IconData icon, required Color iconColor, required Color bgColor, required String category, required String title, required String price, required String timeLeft
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrismColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }
}
